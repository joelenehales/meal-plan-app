import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MealPlanner());
}

class MealPlanner extends StatelessWidget {
  const MealPlanner({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(title: 'Meal Planner'),
      title: 'Meal Planner',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 28, 108, 54)),
        useMaterial3: true,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedRecipe;
  final textController = TextEditingController();
  String recipeList = "";

  void addRecipe(String recipe) {
    setState(() {
      recipeList = recipeList + recipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Meal Planner'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Enter Recipe Name'),
            TextField(controller: textController),
            // Displays all recipes
            FutureBuilder<List<Recipe>>(
                future: DatabaseHelper.instance.getRecipeList(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Recipe>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Loading...'));
                  }
                  return snapshot.data!
                          .isEmpty // Check if there are groceries to display
                      ? Center(child: Text('No Recipes to Display'))
                      : ListView(
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
                                      setState(() {
                                        textController.text = recipe.name;
                                        selectedRecipe = recipe.id;
                                      });
                                    },
                                    onLongPress: () {
                                      // Press and hold to clear selected recipe
                                      setState(() {
                                        selectedRecipe = null;
                                      });
                                    }),
                              ),
                            );
                          }).toList(),
                        );
                }),
          ],
        ),
      ),

      floatingActionButton: SingleChildScrollView(
        child: Row(
          children: [
            FloatingActionButton(
                tooltip: 'Add Recipe',
                child: const Icon(Icons.add_outlined),
                onPressed: () async {
                  // Add recipe with the entered name
                  setState(() {
                    DatabaseHelper.instance
                        .add(Recipe(name: textController.text));
                  });
                }),
            FloatingActionButton(
              tooltip: 'Rename Selected Recipe',
              child: const Icon(Icons.edit_outlined),
              onPressed: () async {
                // If recipe is selected, rename it to the entered text
                if (selectedRecipe != null) {
                  setState(() {
                    DatabaseHelper.instance.rename(
                        Recipe(id: selectedRecipe, name: textController.text));
                  });
                }
              },
            ),
            FloatingActionButton(
              tooltip: 'Delete Selected Recipe',
              child: const Icon(Icons.delete_outlined),
              onPressed: () async {
                // If recipe is selected, remove it
                if (selectedRecipe != null) {
                  setState(() {
                    DatabaseHelper.instance.remove(selectedRecipe!);
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

// Represents a single recipe
class Recipe {
  final int? id; // ? means can be null
  final String name;

  Recipe({this.id, required this.name});

  factory Recipe.fromMap(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // If database does not exist, initialize database. Otherwise, use existing database.
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // Opens database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory);
    String path = join(documentsDirectory.path,
        'appDatabase.db'); // FIXME: Make a better name for this
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Run when opening a database that does not yet exist. Creates all needed tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE recipes(
      id INTEGER PRIMARY KEY,
      name TEXT
    );
    CREATE TABLE ingredients(
      id INTEGER PRIMARY KEY,
      name TEXT
    );
    CREATE TABLE recipeIngredients(
      recipe_id INTEGER,
      ingredient_id INTEGER,
      FOREIGN KEY(recipe_id) REFERENCES recipes(id),
      FOREIGN KEY(ingredient_id) REFERENCES ingredients(id)
    );
    INSERT INTO ingredients VALUES ("Test");
    ''');
  }

  // TODO: Make default list of ingredients on create

  // Queries the database for all recipes and returns in a list
  Future<List<Recipe>> getRecipeList() async {
    Database db = await instance.database;
    var recipes = await db.query('recipes', orderBy: 'name');
    List<Recipe> recipeList = recipes.isNotEmpty
        ? recipes.map((c) => Recipe.fromMap(c)).toList()
        : [];
    return recipeList;
  }

  // Queries the database for all recipes and returns in a list
  Future<List<Recipe>> allIngredients() async {
    Database db = await instance.database;
    var ingredients = await db.query('ingredients', orderBy: 'name');
    List<Recipe> allIngredients = ingredients.isNotEmpty
        ? ingredients.map((c) => Recipe.fromMap(c)).toList()
        : [];
    return allIngredients;
  }

  // Adds recipe to list
  // TODO: Just name for now. Also allow it to add ingredients
  Future<int> add(Recipe recipe) async {
    Database db = await instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  // Removes recipe from list
  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  // Update a recipe
  // TODO: Add a way to update recipe ingredients
  Future<int> rename(Recipe recipe) async {
    Database db = await instance.database;
    return await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }
}
