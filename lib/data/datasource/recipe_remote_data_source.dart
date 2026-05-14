import 'package:dio/dio.dart';
import 'package:recipe_finder_meal_planner/core/network/api_config.dart';
import 'package:recipe_finder_meal_planner/core/network/api_exception.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';

class RecipeRemoteDataSource {
  const RecipeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<RecipeSummary>> findByIngredients({
    required List<String> ingredients,
    required int offset,
    required int number,
  }) async {
    if (!ApiConfig.hasApiKey) {
      throw const ApiException(
        'Missing SPOONACULAR_API_KEY. Pass it with --dart-define.',
      );
    }

    final response = await _dio.get<List<dynamic>>(
      '/recipes/findByIngredients',
      queryParameters: {
        'ingredients': ingredients.join(','),
        'number': number,
        'offset': offset,
        'ranking': 1,
        'ignorePantry': true,
      },
    );
    return (response.data ?? const [])
        .map((item) => RecipeSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RecipeDetail> getRecipeDetail(int recipeId) async {
    if (!ApiConfig.hasApiKey) {
      throw const ApiException(
        'Missing SPOONACULAR_API_KEY. Pass it with --dart-define.',
      );
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/recipes/$recipeId/information',
      queryParameters: {'includeNutrition': true},
    );
    return RecipeDetail.fromJson(response.data ?? const {});
  }
}
