import 'package:flutter/material.dart';
import 'dart:async';

import 'create_meal_plan.dart';
import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/screens/meal_plan_viewer.dart';

// Displays all recipes
class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final textController = TextEditingController();

  // Reload recipe list by refreshing the state
  // Used when returning after editing a recipe, so the changes show
  FutureOr refresh(dynamic value) {
    setState(() {});
  }

  // Displays a list of meal plans as cards
  Widget mealPlansListWidget() {
    return FutureBuilder<List<MealPlan>>(
        future: DatabaseHelper.instance.getMealPlanList(),
        builder:
            (BuildContext context, AsyncSnapshot<List<MealPlan>> snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No meal plans to display.');
          } else {
            return Column(
              children: snapshot.data!.map((mealPlan) {
                return Card(
                  // Each meal plan
                  child: ListTile(
                    title: Text(mealPlan.name),
                    onTap: () {
                      // Tap meal plan to view recipes and ingredients
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MealPlanViewer(mealPlan: mealPlan)),
                        ).then(refresh);
                      });
                    },
                  ),
                );
              }).toList(),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Meal Plans'),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //const Text('Search Meal Plan'), // TODO: Implement search
          //TextField(controller: textController),

          // Display all meal plans
          Expanded(
            child: SingleChildScrollView(child: mealPlansListWidget()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  tooltip: 'New Meal Plan',
                  heroTag: "new_meal_plan_go",
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateMealPlanScreen()),
                      ).then(refresh);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
