// Represents a single ingredient
class Ingredient {
  final int id;
  final String name;
  // TODO: Add type
  // TODO: Add icon

  Ingredient({required this.id, required this.name});

  factory Ingredient.fromMap(Map<String, dynamic> json) => Ingredient(
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
