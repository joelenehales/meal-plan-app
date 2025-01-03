import 'package:flutter/material.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

// Helper class creates a widget that displays a list of ingredients in all
// recipes in a meal plan
// TODO: Could generalize this to "IngredientsListWidget", and have
// RecipeIngredientsWidgand MealPlanIngredients as subclasses OR template the constructor
class MealPlanIngredientsWidget extends StatefulWidget {
  const MealPlanIngredientsWidget({super.key, required this.mealPlan});

  final MealPlan mealPlan;

  @override
  State<MealPlanIngredientsWidget> createState() =>
      _MealPlanIngredientsWidgetState();
}

class _MealPlanIngredientsWidgetState extends State<MealPlanIngredientsWidget> {
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
            return Text(ingredient.name);
          }).toList(),
        );
      },
    );
  }
}
