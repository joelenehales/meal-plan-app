import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum IngredientType { produce, dairy, meat, seafood, bakery, pantry, frozen }

extension IngredientTypeExtension on IngredientType {
  // Get ingredient type name
  String get name {
    switch (this) {
      case IngredientType.produce:
        return 'Produce';
      case IngredientType.dairy:
        return 'Dairy';
      case IngredientType.meat:
        return 'Meat';
      case IngredientType.seafood:
        return 'Seafood';
      case IngredientType.bakery:
        return 'Bakery';
      case IngredientType.pantry:
        return 'Pantry';
      case IngredientType.frozen:
        return 'Frozen';
      default:
        return 'Unknown';
    }
  }

  // Get an appropriate icon for the ingredient type
  Icon get icon {
    switch (this) {
      case IngredientType.produce:
        return const Icon(FontAwesomeIcons.carrot);
      case IngredientType.dairy:
        return const Icon(FontAwesomeIcons.cheese);
      case IngredientType.meat:
        return const Icon(FontAwesomeIcons.drumstickBite);
      case IngredientType.seafood:
        return const Icon(FontAwesomeIcons.fish);
      case IngredientType.bakery:
        return const Icon(FontAwesomeIcons.breadSlice);
      case IngredientType.pantry:
        return const Icon(FontAwesomeIcons.jarWheat);
      case IngredientType.frozen:
        return const Icon(FontAwesomeIcons.iceCream);
      default:
        return const Icon(Icons.question_mark);
    }
  }
}

// Represents a single ingredient
class Ingredient {
  final int id;
  final String name;
  final IngredientType type;

  Ingredient({required this.id, required this.name, required this.type});

  factory Ingredient.fromMap(Map<String, dynamic> json) => Ingredient(
      id: json['id'],
      name: json['name'],
      type: IngredientType.values
          .firstWhere((e) => e.name == json['type']) // Convert string to enum
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name // Convert enum to string
    };
  }
}
