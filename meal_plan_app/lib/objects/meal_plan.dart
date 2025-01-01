// Represents a single meal plan
class MealPlan {
  final int id;
  final String name;

  MealPlan({required this.id, required this.name});

  factory MealPlan.fromMap(Map<String, dynamic> json) => MealPlan(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
