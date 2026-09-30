import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Web-only ESP32 integration for NutriTrack.
// The ESP32 exposes GET /weight over Wi-Fi and returns:
// {"weight":185.6}
class BluetoothService {
  // The ESP32 address is now editable from the Hardware Connection screen and
  // saved on this device, so a changed IP no longer needs a code edit.
  // Default 'nutritrack.local' works through mDNS (the new sketch advertises
  // it). If your network blocks mDNS, type the IP shown in the Serial Monitor.
  static const String defaultHost = 'nutritrack.local';
  static const String _prefsKey = 'esp32_host';
  static String host = defaultHost;
  static String lastError = '';

  static String get esp32BaseUrl => 'http://$host';

  static String normalizeHost(String value) {
    var v = value.trim();
    v = v.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    return v.isEmpty ? defaultHost : v;
  }

  static Future<void> loadSavedHost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      host = normalizeHost(prefs.getString(_prefsKey) ?? defaultHost);
    } catch (e) {
      host = defaultHost;
    }
  }

  static Future<void> saveHost(String value) async {
    host = normalizeHost(value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, host);
    } catch (e) {
      print('Could not save ESP32 host: $e');
    }
  }

  bool isConnected = false;
  String connectedDeviceId = '';
  String connectedDeviceName = '';
  double currentWeight = 0.0;

  Timer? _pollTimer;
  final StreamController<double> _weightController =
      StreamController<double>.broadcast();
  Stream<double> get weightStream => _weightController.stream;

  Future<List<Map<String, String>>> scanDevices() async {
    // Wi-Fi does not need Bluetooth scanning. Test the ESP32 endpoint instead.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    try {
      final response = await http
          .get(
            Uri.parse('$esp32BaseUrl/weight?t=${DateTime.now().millisecondsSinceEpoch}'),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        lastError = '';
        return [
          {
            'id': esp32BaseUrl,
            'name': 'NutriTrack Scale',
            'rssi': 'Wi-Fi',
          },
        ];
      }
      lastError = 'ESP32 answered with HTTP ${response.statusCode}';
    } on TimeoutException {
      lastError = 'Timed out reaching $esp32BaseUrl. Check the address, that '
          'both devices are on the same Wi-Fi, and that the ESP32 is on.';
    } catch (e) {
      lastError = 'Could not reach $esp32BaseUrl. If this app runs on an '
          'https:// page the browser blocks http:// devices. Run it locally '
          'with flutter run -d chrome.';
      print('ESP32 scan/test failed: $e');
    }

    return [];
  }

  Future<bool> connectToDevice(String deviceId, String deviceName) async {
    try {
      final response = await http
          .get(
            Uri.parse('$esp32BaseUrl/weight?t=${DateTime.now().millisecondsSinceEpoch}'),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) {
        return false;
      }

      final weight = _parseJsonWeight(response.body);

      isConnected = true;
      connectedDeviceId = deviceId;
      connectedDeviceName = deviceName;
      currentWeight = weight;
      _weightController.add(weight);

      _startWeightPolling();
      return true;
    } catch (e) {
      print('Error connecting to ESP32: $e');
      return false;
    }
  }

  void _startWeightPolling() {
    _pollTimer?.cancel();

    // Read the real load-cell value twice per second.
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (!isConnected) {
        _pollTimer?.cancel();
        return;
      }

      try {
        final response = await http
            .get(
              Uri.parse('$esp32BaseUrl/weight?t=${DateTime.now().millisecondsSinceEpoch}'),
              )
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          final weight = _parseJsonWeight(response.body);
          currentWeight = weight;
          _weightController.add(weight);
        }
      } catch (e) {
        print('ESP32 weight read failed: $e');
      }
    });
  }

  double _parseJsonWeight(String body) {
    try {
      final decoded = jsonDecode(body);
      final value = decoded['weight'];
      return value is num ? value.toDouble() : 0.0;
    } catch (e) {
      print('Error parsing ESP32 weight: $e');
      return 0.0;
    }
  }

  Future<void> disconnect() async {
    _pollTimer?.cancel();
    _pollTimer = null;

    isConnected = false;
    connectedDeviceId = '';
    connectedDeviceName = '';
    currentWeight = 0.0;
    _weightController.add(0.0);
  }

  double getCurrentWeight() => currentWeight;

  bool getConnectedStatus() => isConnected;

  Map<String, String> getConnectedDeviceInfo() {
    return {
      'id': connectedDeviceId,
      'name': connectedDeviceName,
    };
  }

  void dispose() {
    _pollTimer?.cancel();
    _weightController.close();
  }
}

// Kept for compatibility with the rest of the project.
class ESP32DataParser {
  static double parseWeight(String data) {
    try {
      final decoded = jsonDecode(data);
      final value = decoded['weight'];
      return value is num ? value.toDouble() : 0.0;
    } catch (e) {
      print('Error parsing weight: $e');
      return 0.0;
    }
  }

  static Map<String, dynamic> parseCalibration(String data) {
    try {
      if (data.contains('CAL:')) {
        final calStr = data.split('CAL:')[1].trim();
        final parts = calStr.split(',');
        return {
          'offset': double.parse(parts[0]),
          'scale': double.parse(parts[1]),
        };
      }
      return {};
    } catch (e) {
      print('Error parsing calibration: $e');
      return {};
    }
  }

  static String formatWeightCommand(double weight) {
    return 'SET_WEIGHT:$weight';
  }

  static String getTareCommand() => 'TARE';

  static String getCalibrationCommand(double offset, double scale) {
    return 'CAL:$offset,$scale';
  }
}

class HardwareIntegrationService {
  final BluetoothService bluetoothService = BluetoothService();

  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream =>
      _connectionStateController.stream;

  final StreamController<Map<String, dynamic>> _weightDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get weightDataStream =>
      _weightDataController.stream;

  StreamSubscription<double>? _weightSubscription;

  Future<void> initialize() async {
    print('ESP32 Wi-Fi hardware integration initialized');
  }

  Future<bool> connectToScale(String deviceId) async {
    final success = await bluetoothService.connectToDevice(
      deviceId,
      'NutriTrack Scale',
    );

    _connectionStateController.add(success);

    await _weightSubscription?.cancel();
    _weightSubscription = null;

    if (success) {
      _weightSubscription = bluetoothService.weightStream.listen((weight) {
        _weightDataController.add({
          'weight': weight,
          'timestamp': DateTime.now(),
          'source': 'ESP32 Wi-Fi',
        });
      });
    }

    return success;
  }

  Future<void> disconnectFromScale() async {
    await bluetoothService.disconnect();
    await _weightSubscription?.cancel();
    _weightSubscription = null;
    _connectionStateController.add(false);
  }

  double getLatestWeight() => bluetoothService.getCurrentWeight();

  bool isConnected() => bluetoothService.getConnectedStatus();

  Map<String, String> getConnectionInfo() =>
      bluetoothService.getConnectedDeviceInfo();

  void dispose() {
    _weightSubscription?.cancel();
    _connectionStateController.close();
    _weightDataController.close();
    bluetoothService.dispose();
  }
}
