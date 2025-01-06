import 'package:flutter/material.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/objects/recipe.dart';

// Helper class creates a widget that displays a list of recipes in a meal plan
class MealPlanRecipesWidget extends StatefulWidget {
  const MealPlanRecipesWidget({super.key, required this.mealPlan});

  final MealPlan mealPlan;

  @override
  State<MealPlanRecipesWidget> createState() => _MealPlanRecipesWidgetState();
}

class _MealPlanRecipesWidgetState extends State<MealPlanRecipesWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.instance.getMealPlanRecipes(widget.mealPlan.id),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recipes to display'));
        }
        return Column(
          children: snapshot.data!.map((recipe) {
            return Text(recipe.name, style: const TextStyle(fontSize: 16.0));
            // TODO: Include ingredients
          }).toList(),
        );
      },
    );
  }
}
