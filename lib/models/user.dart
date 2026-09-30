class User {
  String name;
  int age;
  String gender; // male, female, other
  double height;
  double weight;
  String activityLevel; // sedentary, light, moderate, active, very_active
  String goal; // lose, maintain, gain
  double dailyCalorieTarget;
  double proteinTarget;
  double carbsTarget;
  double fatTarget;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    this.dailyCalorieTarget = 2000,
    this.proteinTarget = 100,
    this.carbsTarget = 250,
    this.fatTarget = 65,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalorieTarget': dailyCalorieTarget,
      'proteinTarget': proteinTarget,
      'carbsTarget': carbsTarget,
      'fatTarget': fatTarget,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      age: json['age'] ?? 20,
      gender: json['gender'] ?? 'other',
      height: json['height'] ?? 170.0,
      weight: json['weight'] ?? 70.0,
      activityLevel: json['activityLevel'] ?? 'moderate',
      goal: json['goal'] ?? 'maintain',
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000.0,
      proteinTarget: json['proteinTarget'] ?? 100.0,
      carbsTarget: json['carbsTarget'] ?? 250.0,
      fatTarget: json['fatTarget'] ?? 65.0,
    );
  }
}