import 'package:flutter/material.dart';

import 'package:meal_plan_app/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

// Helper class creates a widget that displays a list of ingredients of a
// certain type in a recipe.
class RecipeIngredientsWidget extends StatefulWidget {
  const RecipeIngredientsWidget(
      {super.key, required this.recipe, required this.ingredientType});

  final Recipe recipe;
  final IngredientType ingredientType;

  @override
  State<RecipeIngredientsWidget> createState() =>
      _RecipeIngredientsWidgetState();
}

class _RecipeIngredientsWidgetState extends State<RecipeIngredientsWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ingredient>>(
      future: DatabaseHelper.instance
          .getRecipeIngredientsByType(widget.recipe.id, widget.ingredientType),
      builder:
          (BuildContext context, AsyncSnapshot<List<Ingredient>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No ingredients to display'));
        }
        return Column(
          children: snapshot.data!.map((ingredient) {
            return Text(ingredient.name);
          }).toList(),
        );
      },
    );
  }
}
