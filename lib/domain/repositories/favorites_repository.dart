import 'package:recipe_finder_meal_planner/core/database/app_database.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';

class FavoritesRepository {
  const FavoritesRepository(this._database);

  final AppDatabase _database;

  Future<List<RecipeSummary>> getFavorites() => _database.getFavorites();

  Future<bool> isFavorite(int recipeId) => _database.isFavorite(recipeId);

  Future<void> add(RecipeSummary recipe) => _database.saveFavorite(recipe);

  Future<void> remove(int recipeId) => _database.removeFavorite(recipeId);
}
