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
            //const Text(
            //  'You have pushed the button this many times:',
            //),
            //Text(
            //  '$_counter',
            //  style: Theme.of(context).textTheme.headlineMedium,
            //),
            const Text(
              'Enter Recipe Name',
            ),
            TextField(
              controller: textController,
            ),
            Text(recipeList),

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
                              child: ListTile(
                                  // Each recipe
                                  title: Text(recipe.name),
                                  onLongPress: () {
                                    // Remove recipe when pressed and held
                                    // TODO: Change this eventually to be different
                                    setState(() {
                                      DatabaseHelper.instance
                                          .remove(recipe.id!);
                                    });
                                  }),
                            );
                          }).toList(),
                        );
                }),
            //Text(
            //  '$_counter',
            //  style: Theme.of(context).textTheme.headlineMedium,
            //),
          ],
        ),
      ),

      // Button to increment counter
      //floatingActionButton: FloatingActionButton(
      //  onPressed: _incrementCounter,
      //  tooltip: 'Increment',
      //  child: const Icon(Icons.add),
      //), // This trailing comma makes auto-formatting nicer for build methods.

      // Button to add recipe to the database
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await DatabaseHelper.instance.add(
            // Adds recipe with the given name
            Recipe(name: textController.text),
          );
          setState(() {
            textController.clear(); // Reset the entered text
          });
        },
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
    String path = join(documentsDirectory.path, 'recipes.db');
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
    )
    ''');
  }

  // Queries the database for all recipes and returns in a list
  Future<List<Recipe>> getRecipeList() async {
    Database db = await instance.database;
    var recipes = await db.query('recipes', orderBy: 'name');
    List<Recipe> recipeList = recipes.isNotEmpty
        ? recipes.map((c) => Recipe.fromMap(c)).toList()
        : [];
    return recipeList;
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
  // TODO: Add a way to update recipe name
  Future<int> rename(Recipe recipe) async {
    Database db = await instance.database;
    return await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }
}
