import '../models/food.dart';

class NutritionResult {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  NutritionResult({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
}

class NutritionService {
  static NutritionResult calculate(
    Food food,
    double weightInGrams,
  ) {
    double multiplier = weightInGrams / 100;

    return NutritionResult(
      calories: food.caloriesPer100g * multiplier,
      protein: food.proteinPer100g * multiplier,
      carbs: food.carbsPer100g * multiplier,
      fat: food.fatPer100g * multiplier,
      fiber: food.fiberPer100g * multiplier,
    );
  }
}