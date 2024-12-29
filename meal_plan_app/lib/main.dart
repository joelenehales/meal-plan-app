import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'objects/recipe.dart';
import 'objects/ingredient.dart';
import 'database_helper.dart';
import 'screens/all_recipes_page.dart';
import 'screens/new_recipe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MealPlanner());
}

// Main page (displayed when application loads)
class MealPlanner extends StatelessWidget {
  const MealPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const RecipeListPage(title: 'Meal Planner'), // TODO: Change this?
      title: 'Meal Planner',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 28, 108, 54)),
        useMaterial3: true,
      ),
    );
  }
}
