import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'package:recipe_finder_meal_planner/domain/repositories/recipe_repository.dart';

class GetRecipeDetail {
  const GetRecipeDetail(this._repository);

  final RecipeRepository _repository;

  Future<RecipeDetail> call(int recipeId) =>
      _repository.getRecipeDetail(recipeId);
}
