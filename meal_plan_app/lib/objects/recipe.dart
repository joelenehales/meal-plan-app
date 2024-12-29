// Represents a single recipe
class Recipe {
  final int id;
  final String name;
  // TODO: Add icon
  // TODO: Add type of cuisine

  Recipe({required this.id, required this.name});

  factory Recipe.fromMap(Map<String, dynamic> json) => Recipe(
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
