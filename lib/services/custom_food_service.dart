import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food.dart';

class CustomFoodService {
  static const String _customFoodsKey = 'custom_foods';
  
  static Future<List<Food>> getCustomFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customFoodsJson = prefs.getString(_customFoodsKey);
      
      if (customFoodsJson != null) {
        final List<dynamic> decoded = json.decode(customFoodsJson);
        return decoded.map((json) => Food(
          id: json['id'],
          name: json['name'],
          caloriesPer100g: json['caloriesPer100g'],
          proteinPer100g: json['proteinPer100g'],
          carbsPer100g: json['carbsPer100g'],
          fatPer100g: json['fatPer100g'],
          fiberPer100g: json['fiberPer100g'],
        )).toList();
      }
    } catch (e) {
      print('Error loading custom foods: $e');
    }
    
    return [];
  }
  
  static Future<void> addCustomFood(Food food) async {
    try {
      final customFoods = await getCustomFoods();
      customFoods.add(food);
      
      final prefs = await SharedPreferences.getInstance();
      final foodsJson = json.encode(customFoods.map((f) => {
        'id': f.id,
        'name': f.name,
        'caloriesPer100g': f.caloriesPer100g,
        'proteinPer100g': f.proteinPer100g,
        'carbsPer100g': f.carbsPer100g,
        'fatPer100g': f.fatPer100g,
        'fiberPer100g': f.fiberPer100g,
      }).toList());
      
      await prefs.setString(_customFoodsKey, foodsJson);
    } catch (e) {
      print('Error saving custom food: $e');
    }
  }
  
  static Future<void> deleteCustomFood(int foodId) async {
    try {
      final customFoods = await getCustomFoods();
      customFoods.removeWhere((food) => food.id == foodId);
      
      final prefs = await SharedPreferences.getInstance();
      final foodsJson = json.encode(customFoods.map((f) => {
        'id': f.id,
        'name': f.name,
        'caloriesPer100g': f.caloriesPer100g,
        'proteinPer100g': f.proteinPer100g,
        'carbsPer100g': f.carbsPer100g,
        'fatPer100g': f.fatPer100g,
        'fiberPer100g': f.fiberPer100g,
      }).toList());
      
      await prefs.setString(_customFoodsKey, foodsJson);
    } catch (e) {
      print('Error deleting custom food: $e');
    }
  }
  
  static Future<void> clearCustomFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_customFoodsKey);
    } catch (e) {
      print('Error clearing custom foods: $e');
    }
  }
}
