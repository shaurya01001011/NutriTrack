import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'add_food.dart';
import 'history.dart';
import 'profile.dart';
import 'settings.dart';
import '../widgets/calorie.dart';
import '../widgets/progress_bar.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, MealProvider>(
        builder: (context, userProvider, mealProvider, _) {
          final user = userProvider.user;
          final todayTotals = mealProvider.getTodayTotals();
          final todayMeals = mealProvider.getTodayMeals();
          final mealsByType = mealProvider.getMealsByType(DateTime.now());

          final targetCalories = user?.dailyCalorieTarget ?? 2000;
          final targetProtein = user?.proteinTarget ?? 100;
          final targetCarbs = user?.carbsTarget ?? 250;
          final targetFat = user?.fatTarget ?? 65;

          final consumedCalories = todayTotals['calories'] ?? 0;
          final consumedProtein = todayTotals['protein'] ?? 0;
          final consumedCarbs = todayTotals['carbs'] ?? 0;
          final consumedFat = todayTotals['fat'] ?? 0;

          return Container(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
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
                          child: Icon(
                            _getGreetingIcon(),
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
                                'Good ${_getGreeting()}!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('EEEE, MMM d').format(DateTime.now()),
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

                  // Calorie Card
                  const Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CalorieCard(
                    consumed: consumedCalories,
                    target: targetCalories,
                  ),
                  const SizedBox(height: 20),

                  // Macro Progress Bars
                  ProgressBar(
                    title: 'Protein',
                    current: consumedProtein,
                    target: targetProtein,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  ProgressBar(
                    title: 'Carbohydrates',
                    current: consumedCarbs,
                    target: targetCarbs,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  ProgressBar(
                    title: 'Fat',
                    current: consumedFat,
                    target: targetFat,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 30),

                  // Today's Meals
                  const Text(
                    'Today\'s Meals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (todayMeals.isEmpty)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No meals logged today',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Add Food" to start tracking',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _buildMealSection('Breakfast', mealsByType['breakfast']!, Icons.breakfast_dining, Colors.orange),
                    _buildMealSection('Lunch', mealsByType['lunch']!, Icons.lunch_dining, Colors.green),
                    _buildMealSection('Dinner', mealsByType['dinner']!, Icons.dinner_dining, Colors.purple),
                    _buildMealSection('Snacks', mealsByType['snacks']!, Icons.cookie, const Color(0xFF8B4513)),
                  ],
                  const SizedBox(height: 30),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Food'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddFoodScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.history),
                          label: const Text('History'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text('Profile'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny; // Morning - Sun
    if (hour < 17) return Icons.wb_twilight; // Afternoon - Twilight
    return Icons.nights_stay; // Evening - Moon
  }

  Widget _buildMealSection(String title, List meals, IconData icon, Color color) {
    if (meals.isEmpty) return const SizedBox.shrink();

    final totalCalories = meals.fold<double>(0, (sum, meal) => sum + meal.calories);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${totalCalories.toInt()} kcal',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...meals.map((meal) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    child: Text(
                      '${meal.foodName} (${meal.weightInGrams.toInt()}g)',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${meal.calories.toInt()} kcal',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}