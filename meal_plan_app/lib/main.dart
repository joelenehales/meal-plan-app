import 'package:flutter/material.dart';

void main() {
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

      // Button to print entered text to console
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addRecipe(textController.text);
        },
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
