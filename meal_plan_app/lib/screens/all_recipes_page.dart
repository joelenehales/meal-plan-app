import 'package:flutter/material.dart';
import 'dart:async';

import 'recipe_viewer.dart';
import 'new_recipe.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/database_helper.dart';

// Displays all recipes
class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
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
        title: const Text('My Recipes'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //const Text('Search Recipe'), // TODO: Implement search
            //TextField(controller: textController),

            // Display all recipes. Click to view recipe
            FutureBuilder<List<Recipe>>(
                future: DatabaseHelper.instance.getRecipeList(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Recipe>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No recipes to display.'));
                  } else {
                    return Column(
                      children: snapshot.data!.map((recipe) {
                        return Card(
                          child: ListTile(
                            // Each recipe
                            title: Text(recipe.name),
                            onTap: () {
                              // Tap recipe to view ingredients
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeViewer(recipe: recipe)),
                                ).then(refresh);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }
                }),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    tooltip: 'New Recipe',
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewRecipePage()),
                        ).then(refresh);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
