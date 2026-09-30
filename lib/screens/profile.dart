import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import 'home.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _gender = 'other';
  String _activityLevel = 'moderate';
  String _goal = 'maintain';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      final user = userProvider.user!;
      _nameController.text = user.name;
      _ageController.text = user.age.toString();
      _heightController.text = user.height.toString();
      _weightController.text = user.weight.toString();
      _gender = user.gender;
      _activityLevel = user.activityLevel;
      _goal = user.goal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      userProvider.saveUser(
        User(
          name: _nameController.text,
          age: int.parse(_ageController.text),
          gender: _gender,
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          activityLevel: _activityLevel,
          goal: _goal,
        ),
      );

      // Calculate targets based on new data
      userProvider.calculateMacroTargets();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home screen after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              if (userProvider.hasUser) {
                return IconButton(
                  icon: const Icon(Icons.calculate),
                  onPressed: () {
                    userProvider.calculateMacroTargets();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calorie targets recalculated!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
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
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
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
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Personal Information
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
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
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Age',
                                prefixIcon: const Icon(Icons.cake),
                                suffixText: 'years',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your age';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age <= 0 || age > 120) {
                                  return 'Please enter a valid age';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _gender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: const Icon(Icons.wc),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Body Measurements
                    const Text(
                      'Body Measurements',
                      style: TextStyle(
                        fontSize: 18,
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
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Height',
                                  prefixIcon: const Icon(Icons.height),
                                  suffixText: 'cm',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final height = double.tryParse(value);
                                  if (height == null || height <= 0 || height > 300) {
                                    return 'Invalid height';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Weight',
                                  prefixIcon: const Icon(Icons.monitor_weight),
                                  suffixText: 'kg',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final weight = double.tryParse(value);
                                  if (weight == null || weight <= 0 || weight > 500) {
                                    return 'Invalid weight';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity & Goals
                    const Text(
                      'Activity & Goals',
                      style: TextStyle(
                        fontSize: 18,
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
                            DropdownButtonFormField<String>(
                              initialValue: _activityLevel,
                              decoration: InputDecoration(
                                labelText: 'Activity Level',
                                prefixIcon: const Icon(Icons.directions_run),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'sedentary',
                                  child: Text('Sedentary (little or no exercise)'),
                                ),
                                DropdownMenuItem(
                                  value: 'light',
                                  child: Text('Light (1-3 days/week)'),
                                ),
                                DropdownMenuItem(
                                  value: 'moderate',
                                  child: Text('Moderate (3-5 days/week)'),
                                ),
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Active (6-7 days/week)'),
                                ),
                                DropdownMenuItem(
                                  value: 'very_active',
                                  child: Text('Very Active (hard exercise daily)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _activityLevel = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _goal,
                              decoration: InputDecoration(
                                labelText: 'Goal',
                                prefixIcon: const Icon(Icons.flag),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'lose',
                                  child: Text('Lose Weight'),
                                ),
                                DropdownMenuItem(
                                  value: 'maintain',
                                  child: Text('Maintain Weight'),
                                ),
                                DropdownMenuItem(
                                  value: 'gain',
                                  child: Text('Gain Weight'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _goal = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Calculated Targets
                    if (userProvider.hasUser) ...[
                      const Text(
                        'Calculated Targets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade50, Colors.white],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTargetRow('BMR', '${userProvider.calculateBMR().toStringAsFixed(0)} kcal', Icons.calculate),
                                _buildTargetRow('TDEE', '${userProvider.calculateTDEE().toStringAsFixed(0)} kcal', Icons.trending_up),
                                const Divider(height: 24),
                                _buildTargetRow(
                                  'Daily Target',
                                  '${userProvider.user!.dailyCalorieTarget.toStringAsFixed(0)} kcal',
                                  Icons.local_fire_department,
                                  isMain: true,
                                ),
                                const SizedBox(height: 8),
                                _buildTargetRow('Protein', '${userProvider.user!.proteinTarget.toStringAsFixed(0)} g', Icons.fitness_center),
                                _buildTargetRow('Carbs', '${userProvider.user!.carbsTarget.toStringAsFixed(0)} g', Icons.grain),
                                _buildTargetRow('Fat', '${userProvider.user!.fatTarget.toStringAsFixed(0)} g', Icons.water_drop),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTargetRow(String label, String value, IconData icon, {bool isMain = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMain ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isMain ? const Color(0xFF2E7D32) : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                color: isMain ? const Color(0xFF2E7D32) : Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
              color: isMain ? const Color(0xFF2E7D32) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}