import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meal_entry.dart';
import 'package:intl/intl.dart';

class MealProvider with ChangeNotifier {
  List<MealEntry> _mealEntries = [];
  bool _isLoading = false;

  List<MealEntry> get mealEntries => _mealEntries;
  bool get isLoading => _isLoading;

  MealProvider() {
    _loadMealEntries();
  }

  Future<void> _loadMealEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getString('meal_entries');
      
      if (entriesJson != null) {
        final List<dynamic> decoded = json.decode(entriesJson);
        _mealEntries = decoded.map((json) => MealEntry.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading meal entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveMealEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = json.encode(_mealEntries.map((e) => e.toJson()).toList());
      await prefs.setString('meal_entries', entriesJson);
    } catch (e) {
      debugPrint('Error saving meal entries: $e');
    }
  }

  Future<void> addMealEntry(MealEntry entry) async {
    _mealEntries.add(entry);
    await _saveMealEntries();
    notifyListeners();
  }

  Future<void> deleteMealEntry(String id) async {
    _mealEntries.removeWhere((entry) => entry.id == id);
    await _saveMealEntries();
    notifyListeners();
  }

  List<MealEntry> getMealsForDate(DateTime date) {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    return _mealEntries.where((entry) {
      return entry.timestamp.isAfter(startDate) && entry.timestamp.isBefore(endDate);
    }).toList();
  }

  List<MealEntry> getTodayMeals() {
    return getMealsForDate(DateTime.now());
  }

  Map<String, double> getDailyTotals(DateTime date) {
    final meals = getMealsForDate(date);
    
    return {
      'calories': meals.fold(0.0, (sum, entry) => sum + entry.calories),
      'protein': meals.fold(0.0, (sum, entry) => sum + entry.protein),
      'carbs': meals.fold(0.0, (sum, entry) => sum + entry.carbs),
      'fat': meals.fold(0.0, (sum, entry) => sum + entry.fat),
      'fiber': meals.fold(0.0, (sum, entry) => sum + entry.fiber),
    };
  }

  Map<String, double> getTodayTotals() {
    return getDailyTotals(DateTime.now());
  }

  Map<String, List<MealEntry>> getMealsByType(DateTime date) {
    final meals = getMealsForDate(date);
    
    return {
      'breakfast': meals.where((m) => m.mealType == 'breakfast').toList(),
      'lunch': meals.where((m) => m.mealType == 'lunch').toList(),
      'dinner': meals.where((m) => m.mealType == 'dinner').toList(),
      'snacks': meals.where((m) => m.mealType == 'snacks').toList(),
    };
  }

  List<Map<String, dynamic>> getLast7DaysData() {
    final List<Map<String, dynamic>> weeklyData = [];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final totals = getDailyTotals(date);
      
      weeklyData.add({
        'date': date,
        'dateString': DateFormat('EEE').format(date),
        'calories': totals['calories'] ?? 0,
        'protein': totals['protein'] ?? 0,
        'carbs': totals['carbs'] ?? 0,
        'fat': totals['fat'] ?? 0,
      });
    }

    return weeklyData;
  }

  Future<void> clearAllMeals() async {
    _mealEntries.clear();
    await _saveMealEntries();
    notifyListeners();
  }

  Future<void> clearMealsForDate(DateTime date) async {
    final mealsToRemove = getMealsForDate(date);
    for (var meal in mealsToRemove) {
      _mealEntries.remove(meal);
    }
    await _saveMealEntries();
    notifyListeners();
  }
}
