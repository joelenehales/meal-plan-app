import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum IngredientType { produce, dairy, meat, seafood, bakery, pantry, other }

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
      case IngredientType.other:
        return 'Other';
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
      case IngredientType.other:
        return const Icon(Icons.question_mark);
      default:
        return const Icon(Icons.question_mark);
    }
  }
}

const int DEFAULT_OCCURRENCES = 0;

// Represents a single ingredient
class Ingredient {
  final int id;
  final String name;
  final IngredientType type;
  final int
      occurrences; // TODO: Use RecipeSelectWidget to refactor things so that this doesn't need to be stored as a class variable?

  Ingredient(
      {required this.id,
      required this.name,
      required this.type,
      this.occurrences = DEFAULT_OCCURRENCES});

  factory Ingredient.fromMap(Map<String, dynamic> json) => Ingredient(
      id: json['id'],
      name: json['name'],
      type: IngredientType.values
          .firstWhere((e) => e.name == json['type']), // Convert string to enum
      // Initialize with occurrences if it has one. Used for meal plans only
      occurrences: json.containsKey('occurrences')
          ? json['occurrences']
          : DEFAULT_OCCURRENCES);

  // Does not include occurrences by default, for adding to ingredients database
  Map<String, dynamic> toMap({bool includeOccurrences = false}) {
    Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'type': type.name // Convert enum to string
    };
    if (includeOccurrences) {
      json['occurrences'] = occurrences;
    }

    return json;
  }
}
