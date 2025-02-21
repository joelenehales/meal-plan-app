import 'package:flutter/material.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/widgets/recipe_ingredients_widgets.dart';

// Helper class creates a widget that displays a list of recipes with
// checkboxes. Selected recipes are stored in a list by their ID.
class RecipeSelectWidget extends StatefulWidget {
  const RecipeSelectWidget({super.key, required this.selectedRecipeIds});

  final List<int> selectedRecipeIds; // Reference to external list

  @override
  State<RecipeSelectWidget> createState() => _RecipeSelectWidgetState();
}

class _RecipeSelectWidgetState extends State<RecipeSelectWidget> {
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
  List<Widget> ingredientsListWidget(Recipe recipe) {
    List<Widget> widgetList = [];
    for (var ingredientType in IngredientType.values) {
      widgetList.add(RecipeIngredientsWidget(
        recipe: recipe,
        ingredientType: ingredientType,
      ));
    }
    return widgetList;
  }

  // Displays a single recipe, a checkbox, and the number of ingredients it
  // shares with the other selected recipes
  Widget recipeCardWidget(Recipe recipe) {
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
      children: ingredientsListWidget(recipe),
    ));
  }

  // Create the widget of a group of recipe cards. Used for either the selected
  // recipes or all recipes
  List<Widget> recipeCardGroup(
      String title, List<Recipe> recipes, String? emptyMessage) {
    List<Widget> recipeCards = [];
    if (recipes.isEmpty) {
      // No recipes provided
      if (emptyMessage != null) {
        // Display message, if provided
        recipeCards.add(Text(emptyMessage));
      } else {
        recipeCards.add(const SizedBox.shrink()); // Empty, sizeless widget
      }
    } else {
      for (var recipe in recipes) {
        // Add card for each recipe
        recipeCards.add(recipeCardWidget(recipe));
      }
    }

    return [
      Text(title),
      SingleChildScrollView(child: Column(children: recipeCards))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.instance.getRecipeList(),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No recipes to display. Try adding one!'));
          // TODO: Add button here to go to add a new recipe
        } else {
          List<Recipe> allRecipes = snapshot.data!;

          // Filter selected vs. unselected recipes
          // TODO: may be worthwhile to refactor from using recipe ID list to
          // just recipe references
          List<Recipe> selectedRecipes = allRecipes
              .where((recipe) => widget.selectedRecipeIds.contains(recipe.id))
              .toList();
          List<Recipe> unselectedRecipes = allRecipes
              .where((recipe) =>
                  widget.selectedRecipeIds.contains(recipe.id) == false)
              .toList();

          List<Widget> selectedRecipeCards = recipeCardGroup(
              "Selected Recipes", selectedRecipes, "No recipes selected.");
          List<Widget> unselectedRecipeCards = recipeCardGroup("All Recipes",
              unselectedRecipes, "No recipes to display. Try adding one!");
          return Column(children: [
            ...selectedRecipeCards,
            const SizedBox(height: 20),
            ...unselectedRecipeCards
          ]);
        }
      },
    );
  }
}
