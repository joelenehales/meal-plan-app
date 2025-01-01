import 'package:flutter/material.dart';
import 'dart:async';

import 'recipe_viewer.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/database_helper.dart';

// Displays all recipes
class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  int? selectedRecipe;
  final textController = TextEditingController();

  // Reload recipe list by refreshing the state
  // Used when returning after editing a recipe, so the changes show
  FutureOr refresh(dynamic value) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('All Recipes'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Search Recipe'), // TODO: Implement search
            TextField(controller: textController),
            // Displays all recipes
            FutureBuilder<List<Recipe>>(
                future: DatabaseHelper.instance.getRecipeList(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Recipe>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No recipes to display.'));
                  } else {
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.map((recipe) {
                        return Center(
                          child: Card(
                            // Add gray colour to selected recipe
                            color: selectedRecipe == recipe.id
                                ? Colors.white70
                                : Colors.white,
                            // Each recipe
                            child: ListTile(
                              title: Text(recipe.name),
                              onTap: () {
                                // Tap to select recipe to edit or remove
                                setState(() {
                                  // TODO: Here, switch screen to recipe
                                  //textController.text = recipe.name;
                                  selectedRecipe = recipe.id;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeViewer(recipe: recipe)),
                                  ).then(refresh);
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                }),
          ],
        ),
      ),

      floatingActionButton: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              tooltip: 'Rename Selected Recipe',
              child: const Icon(Icons.edit_outlined),
              onPressed: () async {
                // If recipe is selected, rename it to the entered text
                if (selectedRecipe != null) {
                  setState(() {
                    DatabaseHelper.instance.renameRecipe(
                        Recipe(id: selectedRecipe!, name: textController.text));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
