import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/presentation/favorites/screens/favorites_meal_plan_screen.dart';
import 'package:recipe_finder_meal_planner/presentation/recipe/screens/recipe_search_screen.dart';

void main() {
  runApp(const ProviderScope(child: RecipePlannerApp(),));
}

class RecipePlannerApp extends StatelessWidget {
  const RecipePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D5B)),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _index == 0
          ? const RecipeSearchScreen()
          : const FavoritesMealPlanScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.bookmark),
            label: 'My Recipes',
          ),
        ],
      ),
    );
  }
}

