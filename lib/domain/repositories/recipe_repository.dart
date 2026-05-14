import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';

abstract class RecipeRepository {
  Future<List<RecipeSummary>> searchByIngredients({
    required List<String> ingredients,
    required int page,
    int pageSize = 12,
  });

  Future<RecipeDetail> getRecipeDetail(int recipeId);
}
