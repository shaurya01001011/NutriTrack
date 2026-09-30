import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../providers/meal_provider.dart';
import '../providers/user_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showWeeklyView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Daily'),
                icon: Icon(Icons.calendar_today),
              ),
              ButtonSegment(
                value: true,
                label: Text('Weekly'),
                icon: Icon(Icons.bar_chart),
              ),
            ],
            selected: {_showWeeklyView},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _showWeeklyView = newSelection.first;
              });
            },
          ),
        ],
      ),
      body: Consumer<MealProvider>(
        builder: (context, mealProvider, _) {
          if (_showWeeklyView) {
            return _buildWeeklyView(mealProvider);
          } else {
            return _buildDailyView(mealProvider);
          }
        },
      ),
    );
  }

  Widget _buildDailyView(MealProvider mealProvider) {
    // Get unique dates from meal entries
    final Set<DateTime> uniqueDates = mealProvider.mealEntries
        .map((entry) => DateTime(
              entry.timestamp.year,
              entry.timestamp.month,
              entry.timestamp.day,
            ))
        .toSet();

    final sortedDates = uniqueDates.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No history yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging meals to see your history',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final totals = mealProvider.getDailyTotals(date);
        final meals = mealProvider.getMealsForDate(date);
        final mealsByType = mealProvider.getMealsByType(date);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: Icon(
              _isToday(date) ? Icons.today : Icons.calendar_today,
              color: _isToday(date) ? Colors.green : null,
            ),
            title: Text(
              _formatDate(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${totals['calories']?.toInt() ?? 0} kcal • ${meals.length} meal${meals.length == 1 ? '' : 's'}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily totals
                    const Text(
                      'Daily Totals',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTotalRow('Calories', totals['calories'] ?? 0, 'kcal', Icons.local_fire_department, Colors.orange),
                    _buildTotalRow('Protein', totals['protein'] ?? 0, 'g', Icons.fitness_center, Colors.blue),
                    _buildTotalRow('Carbs', totals['carbs'] ?? 0, 'g', Icons.grain, Colors.amber),
                    _buildTotalRow('Fat', totals['fat'] ?? 0, 'g', Icons.water_drop, Colors.red),
                    const SizedBox(height: 16),

                    // Meals by type
                    const Text(
                      'Meals',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMealTypeSection('Breakfast', mealsByType['breakfast']!, Icons.breakfast_dining),
                    _buildMealTypeSection('Lunch', mealsByType['lunch']!, Icons.lunch_dining),
                    _buildMealTypeSection('Dinner', mealsByType['dinner']!, Icons.dinner_dining),
                    _buildMealTypeSection('Snacks', mealsByType['snacks']!, Icons.cookie),
                    const SizedBox(height: 16),

                    // Delete button
                    if (!_isToday(date))
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete this day', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            _showDeleteDialog(context, date, mealProvider);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyView(MealProvider mealProvider) {
    final weeklyData = mealProvider.getLast7DaysData();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final targetCalories = userProvider.user?.dailyCalorieTarget ?? 2000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 7 Days',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Weekly summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklySummary(weeklyData, targetCalories),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Weekly chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calorie Trend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCalorieChart(weeklyData, targetCalories),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daily breakdown
          const Text(
            'Daily Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...weeklyData.map((data) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                _isToday(data['date'] as DateTime) ? Icons.today : Icons.calendar_today,
                color: _isToday(data['date'] as DateTime) ? Colors.green : null,
              ),
              title: Text(data['dateString'] as String),
              subtitle: Text('${data['protein']?.toInt() ?? 0}g protein • ${data['carbs']?.toInt() ?? 0}g carbs'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${data['calories']?.toInt() ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, String unit, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            '${value.toInt()} $unit',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection(String title, List meals, IconData icon) {
    if (meals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          ...meals.map((meal) => Padding(
            padding: const EdgeInsets.only(left: 24, top: 2),
            child: Text(
              '• ${meal.foodName} (${meal.weightInGrams.toInt()}g)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(List<Map<String, dynamic>> weeklyData, double targetCalories) {
    final totalCalories = weeklyData.fold<double>(0, (sum, data) => sum + (data['calories'] as double));
    final avgCalories = totalCalories / weeklyData.length;
    final daysOnTarget = weeklyData.where((data) {
      final calories = data['calories'] as double;
      return calories >= targetCalories * 0.9 && calories <= targetCalories * 1.1;
    }).length;

    return Column(
      children: [
        _buildSummaryRow('Total Calories', totalCalories.toInt(), 'kcal'),
        _buildSummaryRow('Average Daily', avgCalories.toInt(), 'kcal'),
        _buildSummaryRow('Days on Target', daysOnTarget, '/ 7'),
        _buildSummaryRow('Target', targetCalories.toInt(), 'kcal'),
      ],
    );
  }

  Widget _buildSummaryRow(String label, int value, String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$value $suffix',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieChart(List<Map<String, dynamic>> weeklyData, double targetCalories) {
    final maxCalories = weeklyData.fold<double>(0, (max, data) {
      final calories = data['calories'] as double;
      return calories > max ? calories : max;
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        data: weeklyData,
        targetCalories: targetCalories,
        maxCalories: maxCalories > 0 ? maxCalories : targetCalories,
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (_isToday(date)) return 'Today';
    if (_isYesterday(date)) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  void _showDeleteDialog(BuildContext context, DateTime date, MealProvider mealProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this day?'),
        content: Text('Are you sure you want to delete all meals from ${_formatDate(date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              mealProvider.clearMealsForDate(date);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Day deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double targetCalories;
  final double maxCalories;

  const BarChart({
    super.key,
    required this.data,
    required this.targetCalories,
    required this.maxCalories,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: BarChartPainter(
        data: data,
        targetCalories: targetCalories,
        maxCalories: maxCalories,
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double targetCalories;
  final double maxCalories;

  BarChartPainter({
    required this.data,
    required this.targetCalories,
    required this.maxCalories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final barWidth = chartWidth / data.length * 0.6;
    final gap = chartWidth / data.length * 0.4;

    // Draw target line
    final targetY = padding + chartHeight * (1 - targetCalories / maxCalories);
    final targetPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(padding, targetY),
      Offset(size.width - padding, targetY),
      targetPaint,
    );

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final calories = data[i]['calories'] as double;
      final barHeight = chartHeight * (calories / maxCalories);
      final x = padding + i * (barWidth + gap) + gap / 2;
      final y = padding + chartHeight - barHeight;

      final barPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      // Draw rounded rectangle
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, barPaint);

      // Draw day label
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i]['dateString'] as String,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - padding + 8),
      );

      // Draw calorie label
      final caloriePainter = TextPainter(
        text: TextSpan(
          text: '${calories.toInt()}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      caloriePainter.layout();
      caloriePainter.paint(
        canvas,
        Offset(x + barWidth / 2 - caloriePainter.width / 2, y - 14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}