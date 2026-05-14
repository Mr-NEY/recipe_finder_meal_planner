import 'dart:convert';

import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';

import '../../../../core/database/app_database.dart';

class RecipeLocalDataSource {
  const RecipeLocalDataSource(this._database);

  final AppDatabase _database;

  Future<CachedPayload?> getSearchCache(String key) => _database.getCache(key);

  Future<void> putSearchCache(String key, List<RecipeSummary> recipes) {
    return _database.putCache(
      key,
      jsonEncode(recipes.map((recipe) => recipe.toJson()).toList()),
    );
  }

  List<RecipeSummary> parseSearchPayload(String payload) {
    return (jsonDecode(payload) as List)
        .map((item) => RecipeSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CachedPayload?> getDetailCache(int recipeId) =>
      _database.getCache('detail:$recipeId');

  Future<void> putDetailCache(RecipeDetail detail) {
    return _database.putCache(
      'detail:${detail.id}',
      jsonEncode(detail.toJson()),
    );
  }

  RecipeDetail parseDetailPayload(String payload) {
    return RecipeDetail.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }
}
