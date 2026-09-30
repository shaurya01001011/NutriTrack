import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../models/meal_entry.dart';
import '../services/nutrition_services.dart';
import '../services/bluetooth_services.dart';
import 'dart:async';
import '../providers/meal_provider.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;

  const FoodDetailsScreen({
    super.key,
    required this.food,
  });

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final TextEditingController weightController = TextEditingController(text: '100');
  String _selectedMealType = 'snacks';
  NutritionResult? result;
  
  final HardwareIntegrationService _hardwareService = HardwareIntegrationService();
  StreamSubscription<Map<String, dynamic>>? _weightSubscription;
  Timer? _connectionRetryTimer;
  bool _useLiveWeight = true;
  bool _isConnecting = false;
  bool _esp32Connected = false;
  double _liveWeight = 0.0;

  @override
  void initState() {
    super.initState();
    // Auto-calculate on load
    calculateNutrition();
    // Initialize hardware service
    _initializeHardware();
  }

  Future<void> _initializeHardware() async {
    await _hardwareService.initialize();

    _weightSubscription = _hardwareService.weightDataStream.listen((data) {
      if (!mounted) return;

      final weight = (data['weight'] as num?)?.toDouble() ?? 0.0;
      setState(() {
        _liveWeight = weight;
        _esp32Connected = true;
      });

      // Keep the weight field connected directly to the real ESP32 reading.
      // Manual entry remains available by turning off the Live ESP32 switch.
      if (_useLiveWeight && weight > 0) {
        final newText = weight.toStringAsFixed(1);
        if (weightController.text != newText) {
          weightController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
          calculateNutrition(showError: false);
        }
      }
    });

    // Try immediately, then retry in the background so a temporary Wi-Fi
    // delay does not leave the switch disabled forever.
    await _tryConnectEsp32();
    _connectionRetryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && !_esp32Connected) {
        _tryConnectEsp32();
      }
    });
  }

  Future<bool> _tryConnectEsp32() async {
    if (_isConnecting || _esp32Connected) return _esp32Connected;

    _isConnecting = true;
    try {
      final devices = await _hardwareService.bluetoothService.scanDevices();
      if (devices.isNotEmpty) {
        final success = await _hardwareService.connectToScale(devices.first['id']!);
        if (mounted && success) {
          setState(() {
            _esp32Connected = true;
            _useLiveWeight = true;
          });
        }
        return success;
      }
    } catch (_) {
      // Manual entry remains available when the ESP32 cannot be reached.
    } finally {
      _isConnecting = false;
    }
    return false;
  }

  Future<void> _toggleWeightMode(bool live) async {
    if (live) {
      final connected = await _tryConnectEsp32();
      if (!connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ESP32 not reachable. Make sure it is on the same Wi-Fi.'),
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() => _useLiveWeight = true);
      if (_liveWeight > 0) {
        final newText = _liveWeight.toStringAsFixed(1);
        weightController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
        calculateNutrition(showError: false);
      }
    } else {
      setState(() => _useLiveWeight = false);
    }
  }

  void calculateNutrition({bool showError = true}) {
    final weight = double.tryParse(weightController.text);

    if (weight == null || weight <= 0) {
      if (showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid weight')),
        );
      }
      return;
    }

    setState(() {
      result = NutritionService.calculate(widget.food, weight);
    });
  }

  void saveMealEntry() {
    if (result == null) {
      calculateNutrition();
      if (result == null) return;
    }

    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    final mealEntry = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: widget.food.name,
      weightInGrams: double.parse(weightController.text),
      calories: result!.calories,
      protein: result!.protein,
      carbs: result!.carbs,
      fat: result!.fat,
      fiber: result!.fiber,
      mealType: _selectedMealType,
      timestamp: DateTime.now(),
    );

    mealProvider.addMealEntry(mealEntry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.food.name} added to $_selectedMealType!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _weightSubscription?.cancel();
    _connectionRetryTimer?.cancel();
    weightController.dispose();
    _hardwareService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food.name),
        actions: [
          if (result != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: saveMealEntry,
              tooltip: 'Add to meal',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.food.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${widget.food.caloriesPer100g} kcal per 100g',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Weight input card: live ESP32 weight + manual fallback
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Enter Weight',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => _toggleWeightMode(!_useLiveWeight),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (_useLiveWeight && _esp32Connected)
                                    ? Colors.green.withValues(alpha: 0.10)
                                    : Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: (_useLiveWeight && _esp32Connected)
                                      ? Colors.green.shade300
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _esp32Connected ? Icons.wifi : Icons.wifi_off,
                                    size: 18,
                                    color: _esp32Connected ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _useLiveWeight ? 'ESP32 Live' : 'Manual',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _useLiveWeight && _esp32Connected
                                          ? Colors.green.shade700
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Switch.adaptive(
                                    value: _useLiveWeight,
                                    onChanged: (value) => _toggleWeightMode(value),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_esp32Connected && _useLiveWeight)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.sensors, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                'Live weight from ESP32: ${_liveWeight.toStringAsFixed(1)} g',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextField(
                        controller: weightController,
                        readOnly: _useLiveWeight && _esp32Connected,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: _useLiveWeight && _esp32Connected
                              ? 'Live weight from ESP32'
                              : 'Weight in grams',
                          suffixText: 'g',
                          prefixIcon: const Icon(Icons.scale),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => calculateNutrition(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _esp32Connected
                            ? (_useLiveWeight
                                ? 'Weight updates automatically. Turn off ESP32 Live to enter weight manually.'
                                : 'Manual entry enabled. You can enter the weight yourself.')
                            : 'ESP32 not connected. Enter the weight manually.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Meal type selection
              const Text(
                'Add to meal:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'breakfast',
                    label: Text('Breakfast'),
                    icon: Icon(Icons.breakfast_dining),
                  ),
                  ButtonSegment(
                    value: 'lunch',
                    label: Text('Lunch'),
                    icon: Icon(Icons.lunch_dining),
                  ),
                  ButtonSegment(
                    value: 'dinner',
                    label: Text('Dinner'),
                    icon: Icon(Icons.dinner_dining),
                  ),
                  ButtonSegment(
                    value: 'snacks',
                    label: Text('Snacks'),
                    icon: Icon(Icons.cookie),
                  ),
                ],
                selected: {_selectedMealType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedMealType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Nutrition results
              if (result != null) ...[
                const Text(
                  'Nutrition Facts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildNutritionRow('Calories', '${result!.calories.toStringAsFixed(1)} kcal', Icons.local_fire_department, Colors.orange),
                        const Divider(height: 24),
                        _buildNutritionRow('Protein', '${result!.protein.toStringAsFixed(1)} g', Icons.fitness_center, Colors.blue),
                        _buildNutritionRow('Carbs', '${result!.carbs.toStringAsFixed(1)} g', Icons.grain, Colors.amber),
                        _buildNutritionRow('Fat', '${result!.fat.toStringAsFixed(1)} g', Icons.water_drop, Colors.red),
                        _buildNutritionRow('Fiber', '${result!.fiber.toStringAsFixed(1)} g', Icons.eco, Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: saveMealEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Add to Today\'s Meals'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}