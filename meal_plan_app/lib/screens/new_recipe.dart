import 'package:flutter/material.dart';

import 'package:meal_plan_app/objects/ingredient.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/database_helper.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({super.key});

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  bool isChecked = false;
  List<int> selectedIngredientIds = [];
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Recipe'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Enter Recipe Name'),
            TextField(controller: textController),
            FutureBuilder<List<Ingredient>>(
                future: DatabaseHelper.instance.getIngredients(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Ingredient>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No Ingredients to Display'));
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.map((ingredient) {
                      // Display each ingredient with a checkbox
                      return CheckboxListTile(
                        title: Text(ingredient.name),
                        value: selectedIngredientIds.contains(ingredient.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              selectedIngredientIds.add(ingredient.id);
                            } else {
                              selectedIngredientIds.remove(ingredient.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                }),
          ],
        ),
      ),

      floatingActionButton: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
                tooltip: 'Save',
                child: const Icon(Icons.save),
                onPressed: () async {
                  // Add recipe with the entered name and ingredients
                  int nextRecipeId =
                      await DatabaseHelper.instance.getNextAvailableRecipeId();
                  setState(() {
                    DatabaseHelper.instance.addRecipe(
                        Recipe(id: nextRecipeId, name: textController.text),
                        selectedIngredientIds);
                    // TODO: Give an error if no ingredients are selected
                    // TODO: Give error if duplicate name is entered
                    // TODO: Give confirmation if entered successfully
                  });
                  // TODO: Clear, to add another recipe
                }),
          ],
        ),
      ),
    );
  }
}
