import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meal_plan_app/screens/home.dart';
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
  runApp(const App());
}

// Main page (displayed when application loads)
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 2;

  final List<Widget> screensList = const [
    RecipeListPage(),
    NewRecipePage(),
    Home()
  ];

  // Change screen to the selected navigation button
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Meal Planner App' // TODO: Change to the final name of the app
            ),
      ),

      // Bottom navigation bar
      // TODO: Change the colours
      body: screensList.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.blueGrey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'View All Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_outlined),
            label: 'Add New Recipe',
            // TODO: Put this option in the "View All Recipes" page
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
