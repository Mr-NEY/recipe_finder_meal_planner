import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/core/cache/cache_providers.dart';
import 'package:recipe_finder_meal_planner/core/database/app_database.dart';
import 'package:recipe_finder_meal_planner/core/network/connectivity_provider.dart';
import 'package:recipe_finder_meal_planner/core/network/dio_provider.dart';
import 'package:recipe_finder_meal_planner/data/datasource/recipe_local_data_source.dart';
import 'package:recipe_finder_meal_planner/data/datasource/recipe_remote_data_source.dart';
import 'package:recipe_finder_meal_planner/data/repositories/recipe_repository_impl.dart';
import 'package:recipe_finder_meal_planner/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder_meal_planner/domain/usecases/get_recipe_detail.dart';
import 'package:recipe_finder_meal_planner/domain/usecases/search_recipes.dart';


final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  return RecipeRemoteDataSource(ref.watch(dioProvider));
});

final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  return RecipeLocalDataSource(ref.watch(appDatabaseProvider));
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(
    remote: ref.watch(recipeRemoteDataSourceProvider),
    local: ref.watch(recipeLocalDataSourceProvider),
    connectivity: ref.watch(connectivityProvider),
    cachePolicy: ref.watch(cachePolicyProvider),
  );
});

final searchRecipesProvider = Provider<SearchRecipes>((ref) {
  return SearchRecipes(ref.watch(recipeRepositoryProvider));
});

final getRecipeDetailProvider = Provider<GetRecipeDetail>((ref) {
  return GetRecipeDetail(ref.watch(recipeRepositoryProvider));
});
