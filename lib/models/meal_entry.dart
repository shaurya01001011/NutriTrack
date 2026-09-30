class MealEntry {
  final String id;
  final String foodName;
  final double weightInGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String mealType; // breakfast, lunch, dinner, snacks
  final DateTime timestamp;

  MealEntry({
    required this.id,
    required this.foodName,
    required this.weightInGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.mealType,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'weightInGrams': weightInGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'mealType': mealType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'],
      foodName: json['foodName'],
      weightInGrams: json['weightInGrams'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      fiber: json['fiber'],
      mealType: json['mealType'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
