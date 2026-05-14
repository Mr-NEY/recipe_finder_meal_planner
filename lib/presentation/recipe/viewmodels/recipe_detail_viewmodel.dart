import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'recipe_providers.dart';

final recipeDetailViewModelProvider =
    AsyncNotifierProvider.family<RecipeDetailViewModel, RecipeDetail, int>(
      RecipeDetailViewModel.new,
    );

class RecipeDetailViewModel extends FamilyAsyncNotifier<RecipeDetail, int> {
  @override
  Future<RecipeDetail> build(int arg) {
    return ref.watch(getRecipeDetailProvider)(arg);
  }
}
