import 'package:flutter/material.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

// Helper class creates a widget that displays a list of ingredients in all
// recipes in a meal plan
// Includes count of occurrences of ingredient in meal plan
class MealPlanIngredientsWidget extends StatefulWidget {
  const MealPlanIngredientsWidget({super.key, required this.mealPlan});

  final MealPlan mealPlan;

  @override
  State<MealPlanIngredientsWidget> createState() =>
      _MealPlanIngredientsWidgetState();
}

class _MealPlanIngredientsWidgetState extends State<MealPlanIngredientsWidget> {
  // Returns the colour to display recipe with based on occurrences in meal plan
  Color getOccurrencesColor(Ingredient ingredient) {
    if (ingredient.occurrences > 1) {
      return Colors.green;
    } else if (ingredient.occurrences == 1) {
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
                  fontSize: fontSize, color: getOccurrencesColor(ingredient)),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ingredient>>(
      future:
          DatabaseHelper.instance.getMealPlanIngredients(widget.mealPlan.id),
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
}
