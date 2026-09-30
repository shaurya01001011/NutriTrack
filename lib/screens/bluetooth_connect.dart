import 'package:flutter/material.dart';
import '../services/bluetooth_services.dart';

class BluetoothConnectScreen extends StatefulWidget {
  const BluetoothConnectScreen({super.key});

  @override
  State<BluetoothConnectScreen> createState() => _BluetoothConnectScreenState();
}

class _BluetoothConnectScreenState extends State<BluetoothConnectScreen> {
  final HardwareIntegrationService _hardwareService = HardwareIntegrationService();
  
  bool _isScanning = false;
  bool _isConnecting = false;
  List<Map<String, String>> _devices = [];
  String? _connectedDeviceId;
  double _currentWeight = 0.0;
  bool _isConnected = false;
  final TextEditingController _hostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _hardwareService.initialize();
    await BluetoothService.loadSavedHost();
    if (mounted) {
      _hostController.text = BluetoothService.host;
    }
    
    // Listen to connection state changes
    _hardwareService.connectionStateStream.listen((connected) {
      setState(() {
        _isConnected = connected;
      });
    });
    
    // Listen to weight updates
    _hardwareService.weightDataStream.listen((data) {
      setState(() {
        _currentWeight = data['weight'] as double;
      });
    });
  }

  Future<void> _scanDevices() async {
    await BluetoothService.saveHost(_hostController.text);
    _hostController.text = BluetoothService.host;
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    final devices = await _hardwareService.bluetoothService.scanDevices();
    
    setState(() {
      _devices = devices;
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(String deviceId, String deviceName) async {
    setState(() {
      _isConnecting = true;
      _connectedDeviceId = deviceId;
    });

    final success = await _hardwareService.connectToScale(deviceId);
    
    setState(() {
      _isConnecting = false;
      if (!success) {
        _connectedDeviceId = null;
      }
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to $deviceName'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to device'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    await _hardwareService.disconnectFromScale();
    setState(() {
      _connectedDeviceId = null;
      _currentWeight = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disconnected from device'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _hardwareService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware Connection'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ESP32 Scale',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _isConnected ? 'Connected' : 'Not Connected',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Weight Display
              if (_isConnected) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.monitor_weight,
                          size: 48,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_currentWeight.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(
                          'grams',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Live from ESP32',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.wifi_off),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                // ESP32 address (IP or nutritrack.local)
                TextField(
                  controller: _hostController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'ESP32 address',
                    hintText: 'nutritrack.local or 192.168.x.x',
                    helperText: 'IP is printed in the Arduino Serial Monitor',
                    prefixIcon: Icon(Icons.router),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Scan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanDevices,
                    icon: _isScanning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isScanning ? 'Checking ESP32...' : 'Find ESP32 Scale'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Device List
                if (_devices.isNotEmpty) ...[
                  const Text(
                    'Available ESP32 Scale',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._devices.map((device) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.devices,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        device['name'] ?? 'Unknown Device',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('ID: ${device['id']}'),
                      trailing: _isConnecting && _connectedDeviceId == device['id']
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.wifi,
                              color: Colors.grey[400],
                            ),
                      onTap: _isConnecting
                          ? null
                          : () => _connectToDevice(device['id']!, device['name']!),
                    ),
                  )),
                ] else if (!_isScanning) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ESP32 Scale not found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Make sure the ESP32 is powered on and connected to the same Wi-Fi',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (BluetoothService.lastError.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              BluetoothService.lastError,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],

              // Instructions
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Setup Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstruction('1. Power on your ESP32 device'),
                      _buildInstruction('2. Connect ESP32 and this laptop to the same Wi-Fi'),
                      _buildInstruction('3. Enter the ESP32 address (IP from Serial Monitor) and tap "Find ESP32 Scale"'),
                      _buildInstruction('4. Select NutriTrack Scale'),
                      _buildInstruction('5. Wait for the Wi-Fi connection'),
                      _buildInstruction('6. Real weight will appear automatically'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.amber[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ESP32 Wi-Fi endpoint: /weight • Live data is read from the HX711',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
