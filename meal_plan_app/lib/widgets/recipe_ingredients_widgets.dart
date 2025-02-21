import 'package:flutter/material.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

// Helper class creates a widget that displays a list of ingredients of a
// certain type in a recipe.
// TODO: Include option to display with headers, instead of isngle type
class RecipeIngredientsWidget extends StatefulWidget {
  const RecipeIngredientsWidget(
      {super.key, required this.recipe, required this.ingredientType});

  final Recipe recipe;
  final IngredientType ingredientType;

  @override
  State<RecipeIngredientsWidget> createState() =>
      _RecipeIngredientsWidgetState();
}

// TODO: Consider refactoring this to make more general? Combine with the
// simillar widget created in recipe_checkbox_widget
class _RecipeIngredientsWidgetState extends State<RecipeIngredientsWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ingredient>>(
        future: DatabaseHelper.instance.getRecipeIngredientsByType(
            widget.recipe.id, widget.ingredientType),
        builder:
            (BuildContext context, AsyncSnapshot<List<Ingredient>> snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // No ingredients of the given type
            return const SizedBox.shrink(); // Empty, sizeless widget
          } else {
            // Add each ingredient of the type
            List<Widget> ingredientsWidget = snapshot.data!.map((ingredient) {
              return Text(ingredient.name);
            }).toList();
            ListTile ingredientTypeLabel = ListTile(
                // Add label with type
                leading: widget.ingredientType.icon,
                title: Text(widget.ingredientType.name));
            // TODO: Add styling here
            return Column(
              children: [ingredientTypeLabel, ...ingredientsWidget],
            );
          }
        });
  }
}
