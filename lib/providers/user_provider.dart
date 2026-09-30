import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get hasUser => _user != null;

  UserProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      
      if (userJson != null) {
        _user = User.fromJson(json.decode(userJson));
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUser(User user) async {
    _user = user;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  Future<void> updateUser({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    String? goal,
    double? dailyCalorieTarget,
    double? proteinTarget,
    double? carbsTarget,
    double? fatTarget,
  }) async {
    if (_user == null) return;

    _user = User(
      name: name ?? _user!.name,
      age: age ?? _user!.age,
      gender: gender ?? _user!.gender,
      height: height ?? _user!.height,
      weight: weight ?? _user!.weight,
      activityLevel: activityLevel ?? _user!.activityLevel,
      goal: goal ?? _user!.goal,
      dailyCalorieTarget: dailyCalorieTarget ?? _user!.dailyCalorieTarget,
      proteinTarget: proteinTarget ?? _user!.proteinTarget,
      carbsTarget: carbsTarget ?? _user!.carbsTarget,
      fatTarget: fatTarget ?? _user!.fatTarget,
    );

    await saveUser(_user!);
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      debugPrint('Error clearing user: $e');
    }
  }

  double calculateBMR() {
    if (_user == null) return 0;

    // Mifflin-St Jeor Equation
    double bmr;
    if (_user!.gender == 'male') {
      bmr = 10 * _user!.weight + 6.25 * _user!.height - 5 * _user!.age + 5;
    } else {
      bmr = 10 * _user!.weight + 6.25 * _user!.height - 5 * _user!.age - 161;
    }

    return bmr;
  }

  double calculateTDEE() {
    if (_user == null) return 0;

    final bmr = calculateBMR();
    double activityMultiplier;

    switch (_user!.activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55;
    }

    return bmr * activityMultiplier;
  }

  double calculateCalorieTarget() {
    if (_user == null) return 0;

    final tdee = calculateTDEE();

    switch (_user!.goal) {
      case 'lose':
        return tdee - 500; // 500 calorie deficit
      case 'gain':
        return tdee + 500; // 500 calorie surplus
      case 'maintain':
      default:
        return tdee;
    }
  }

  void calculateMacroTargets() {
    if (_user == null) return;

    final calorieTarget = calculateCalorieTarget();
    
    // Standard macro distribution: 30% protein, 50% carbs, 20% fat
    final proteinTarget = (calorieTarget * 0.30) / 4; // 4 cal per gram
    final carbsTarget = (calorieTarget * 0.50) / 4; // 4 cal per gram
    final fatTarget = (calorieTarget * 0.20) / 9; // 9 cal per gram

    updateUser(
      dailyCalorieTarget: calorieTarget,
      proteinTarget: proteinTarget,
      carbsTarget: carbsTarget,
      fatTarget: fatTarget,
    );
  }
}
