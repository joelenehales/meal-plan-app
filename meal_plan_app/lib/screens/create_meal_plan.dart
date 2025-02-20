import 'package:flutter/material.dart';

import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/utils/dialog_helpers.dart';
import 'package:meal_plan_app/widgets/recipe_checkbox_widget.dart';

// TODO: Add ingredients thing

class CreateMealPlanScreen extends StatefulWidget {
  const CreateMealPlanScreen({super.key});

  @override
  State<CreateMealPlanScreen> createState() => _CreateMealPlanScreenState();
}

class _CreateMealPlanScreenState extends State<CreateMealPlanScreen> {
  bool isChecked = false;
  List<int> selectedRecipeIds = [];
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Meal Plan'),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                      labelText: 'Meal Plan Name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'New Meal Plan'))),
          Expanded(
              child: SingleChildScrollView(
                  child: RecipeCheckboxWidget(
                      selectedRecipeIds: selectedRecipeIds))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  tooltip: 'Save',
                  heroTag: "save_meal_plan",
                  child: const Icon(Icons.save),
                  onPressed: () async {
                    String mealPlanName = textController.text;
                    // Show error if no ingredients have been selected
                    if (selectedRecipeIds.isEmpty) {
                      customDialog(
                          'No recipes selected.', DialogType.error, context);
                    }
                    // Show error if no name is entered
                    else if (mealPlanName == "") {
                      customDialog('No meal plan name entered.',
                          DialogType.error, context);
                    }
                    // Duplicate recipe name
                    else if (await DatabaseHelper.instance
                        .duplicateMealPlanName(mealPlanName)) {
                      customDialog(
                          'Meal plan with the entered name already exists.',
                          DialogType.error,
                          context);
                    }
                    // Valid input
                    else {
                      // Add meal plan with the entered name and recipes
                      int mealPlanId = await DatabaseHelper.instance
                          .getNextAvailableMealPlanId();
                      setState(() {
                        DatabaseHelper.instance.addMealPlan(
                            MealPlan(id: mealPlanId, name: mealPlanName),
                            selectedRecipeIds);
                      });
                      customDialog('Meal plan created successfully!',
                              DialogType.confirmation, context)
                          .then((_) {
                        Navigator.pop(
                            context); // Return to meal plan list after popup is confirmed
                      });
                    }
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
