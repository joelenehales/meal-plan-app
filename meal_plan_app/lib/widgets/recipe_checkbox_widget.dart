import 'package:flutter/material.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/widgets/ingredient_checkbox_widget.dart';
import 'package:meal_plan_app/widgets/recipe_ingredients_widgets.dart';

// TODO: Need to add ingredients tracking

// Helper class creates a widget that displays a list of recipes with
// checkboxes. Selected recipes are stored in a list by their ID.
class RecipeCheckboxWidget extends StatefulWidget {
  const RecipeCheckboxWidget({super.key, required this.selectedRecipeIds});

  final List<int> selectedRecipeIds; // Reference to external list

  @override
  State<RecipeCheckboxWidget> createState() => _RecipeCheckboxWidgetState();
}

class _RecipeCheckboxWidgetState extends State<RecipeCheckboxWidget> {
  // Returns the colour to display recipe with based on the number of common ingredients
  // TODO: Partially copied from ingredients widget, refactor
  Color getCountColor(int count) {
    if (count > 1) {
      return Colors.green;
    } else if (count == 1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Displays the recipe's ingredients sorted by type. Skips types with no ingredients
  List<Widget> recipeIngredientsWidget(Recipe recipe) {
    List<Widget> widgetList = [];
    for (var ingredientType in IngredientType.values) {
      widgetList.add(FutureBuilder<List<Ingredient>>(
          future: DatabaseHelper.instance
              .getRecipeIngredientsByType(recipe.id, ingredientType),
          builder:
              (BuildContext context, AsyncSnapshot<List<Ingredient>> snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink(); // Empty, sizeless widget
            } else {
              List<Widget> ingredientsWidget = snapshot.data!.map((ingredient) {
                return Text(ingredient.name);
              }).toList();
              ingredientsWidget.insert(0, Text(ingredientType.name));
              return Column(
                children: ingredientsWidget,
              );
            }
          }));
    }
    return widgetList;
  }

  // Displays a single recipe, a checkbox, and the number of ingredients it
  // shares with the other selected recipes
  Widget recipeCheckboxWidget(Recipe recipe) {
    const double fontSize = 16.0;
    bool recipeIsSelected = widget.selectedRecipeIds.contains(recipe.id);
    return Card(
        child: ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(recipe.name, style: const TextStyle(fontSize: fontSize)),
          const SizedBox(width: 20), // Spacing
          FutureBuilder<int>(
              future: DatabaseHelper.instance.getCommonIngredientCount(
                  recipe.id, widget.selectedRecipeIds),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int commonIngredientCount = snapshot.data!;
                  return Text(
                    commonIngredientCount.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: fontSize,
                        color: getCountColor(commonIngredientCount)),
                  );
                } else {
                  return const Text(
                      "Error Occurred"); // TODO: Format this better?
                }
              }),
        ],
      ),
      leading: IconButton(
          icon: Icon(recipeIsSelected ? Icons.remove : Icons.add),
          onPressed: () {
            setState(() {
              if (!recipeIsSelected) {
                widget.selectedRecipeIds.add(recipe.id);
              } else {
                widget.selectedRecipeIds.remove(recipe.id);
              }
            });
          }),
      children: recipeIngredientsWidget(recipe),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.instance.getRecipeList(),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No recipes to display. Try adding one!'));
          // TODO: Add button here to add a new recipe
        }
        return Column(
          children: snapshot.data!.map((recipe) {
            return recipeCheckboxWidget(recipe);
          }).toList(),
        );
      },
    );
  }
}
