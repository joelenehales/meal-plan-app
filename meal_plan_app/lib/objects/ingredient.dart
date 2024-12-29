import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum IngredientType { produce, dairy, meat, seafood, bakery, pantry, frozen }

extension IngredientTypeExtension on IngredientType {
  // Get an appropriate icon for the ingredient type
  Icon get icon {
    switch (this) {
      case IngredientType.produce:
        return Icon(FontAwesomeIcons.carrot);
      case IngredientType.dairy:
        return Icon(FontAwesomeIcons.cheese);
      case IngredientType.meat:
        return Icon(FontAwesomeIcons.drumstickBite);
      case IngredientType.seafood:
        return Icon(FontAwesomeIcons.fish);
      case IngredientType.bakery:
        return Icon(FontAwesomeIcons.breadSlice);
      case IngredientType.pantry:
        return Icon(FontAwesomeIcons.jarWheat);
      case IngredientType.frozen:
        return Icon(FontAwesomeIcons.iceCream);
      default:
        return Icon(Icons.question_mark);
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
      type: IngredientType.values.firstWhere(
          (e) => e.toString() == json['type']) // Convert string to enum
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString() // Convert enum to string
    };
  }
}
