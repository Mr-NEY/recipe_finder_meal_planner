import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/domain/repositories/recipe_repository.dart';

class SearchRecipes {
  const SearchRecipes(this._repository);

  final RecipeRepository _repository;

  Future<List<RecipeSummary>> call({
    required List<String> ingredients,
    required int page,
    int pageSize = 12,
  }) {
    return _repository.searchByIngredients(
      ingredients: ingredients,
      page: page,
      pageSize: pageSize,
    );
  }
}
