import 'package:flutter/material.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

// Helper class creates a widget that displays a list of ingredients in all
// recipes in a meal plan
// Includes count of occurrences of ingredient in meal plan
// TODO: not sure if I like this named constructor method?
class MealPlanIngredientsWidget extends StatefulWidget {
  // Default constructor
  const MealPlanIngredientsWidget(
      {super.key,
      required this.mealPlan,
      required this.selectedRecipeIds,
      required this.useExistingMealPlan});

  // Use an existing meal plan
  factory MealPlanIngredientsWidget.fromExistingMealPlan(
      {Key? key, required MealPlan mealPlan}) {
    return MealPlanIngredientsWidget(
        mealPlan: mealPlan, selectedRecipeIds: null, useExistingMealPlan: true);
  }

  // Use a list of recipes (tentative meal plan)
  factory MealPlanIngredientsWidget.fromSelectedRecipes(
      {Key? key, required List<int> selectedRecipeIds}) {
    return MealPlanIngredientsWidget(
        mealPlan: null,
        selectedRecipeIds: selectedRecipeIds,
        useExistingMealPlan: false);
  }

  final MealPlan? mealPlan;
  final List<int>? selectedRecipeIds;
  final bool useExistingMealPlan; // Indicates which factory was used

  @override
  State<MealPlanIngredientsWidget> createState() =>
      _MealPlanIngredientsWidgetState();
}

class _MealPlanIngredientsWidgetState extends State<MealPlanIngredientsWidget> {
  // Returns the colour to display recipe with based on occurrences in meal plan
  Color getOccurrencesColor(int occurrences) {
    if (occurrences > 1) {
      return Colors.green;
    } else if (occurrences == 1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Displays a single ingredient's name and occurrences in the meal plan
  Widget ingredientCountWidget(Ingredient ingredient) {
    const double fontSize = 16.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            flex: 3,
            child: Text(ingredient.name,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: fontSize))),
        Expanded(
            flex: 1,
            child: Text(
              ingredient.occurrences.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fontSize,
                  // TODO: Refactor this to use a FutureBuilder, like the
                  // RecipeSelectWidget
                  color: getOccurrencesColor(ingredient.occurrences)),
            )),
      ],
    );
  }

  // Search the database for the list of ingredients. Query is selected
  // depending on whether an existing meal plan or list of selected recipes was
  // used to create the object
  Future<List<Ingredient>> getIngredientsList() {
    Future<List<Ingredient>> ingredientsList = widget.useExistingMealPlan
        ? DatabaseHelper.instance.getMealPlanIngredients(widget.mealPlan!.id)
        : DatabaseHelper.instance
            .ingredientOccurrenceCount(widget.selectedRecipeIds!);
    return ingredientsList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ingredient>>(
      future: getIngredientsList(),
      builder:
          (BuildContext context, AsyncSnapshot<List<Ingredient>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No ingredients to display'));
        }
        return Column(
          children: snapshot.data!.map((ingredient) {
            return ingredientCountWidget(ingredient);
          }).toList(),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant MealPlanIngredientsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.useExistingMealPlan &&
        !oldWidget.useExistingMealPlan &&
        oldWidget.selectedRecipeIds!.length !=
            widget.selectedRecipeIds!.length) {
      setState(() {}); // Forces rebuild when recipe list changes
    }
  }
}
