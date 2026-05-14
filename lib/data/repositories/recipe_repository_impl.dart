import 'package:recipe_finder_meal_planner/core/cache/cache_policy.dart';
import 'package:recipe_finder_meal_planner/data/datasource/recipe_local_data_source.dart';
import 'package:recipe_finder_meal_planner/data/datasource/recipe_remote_data_source.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/domain/repositories/recipe_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class RecipeRepositoryImpl implements RecipeRepository {
  const RecipeRepositoryImpl({
    required RecipeRemoteDataSource remote,
    required RecipeLocalDataSource local,
    required Connectivity connectivity,
    required CachePolicy cachePolicy,
  }) : _remote = remote,
       _local = local,
       _connectivity = connectivity,
       _cachePolicy = cachePolicy;

  final RecipeRemoteDataSource _remote;
  final RecipeLocalDataSource _local;
  final Connectivity _connectivity;
  final CachePolicy _cachePolicy;

  @override
  Future<List<RecipeSummary>> searchByIngredients({
    required List<String> ingredients,
    required int page,
    int pageSize = 12,
  }) async {
    final normalized =
        ingredients
            .map((item) => item.trim().toLowerCase())
            .where((item) => item.isNotEmpty)
            .toList()
          ..sort();
    final key = 'search:${normalized.join('|')}:page:$page:size:$pageSize';
    final cached = await _local.getSearchCache(key);
    if (cached != null && _cachePolicy.isFresh(cached.cachedAt)) {
      return _local.parseSearchPayload(cached.payload);
    }

    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.every((result) => result == ConnectivityResult.none)) {
      if (cached != null) return _local.parseSearchPayload(cached.payload);
      return const [];
    }

    try {
      final recipes = await _remote.findByIngredients(
        ingredients: normalized,
        offset: page * pageSize,
        number: pageSize,
      );
      await _local.putSearchCache(key, recipes);
      return recipes;
    } catch (_) {
      if (cached != null) return _local.parseSearchPayload(cached.payload);
      rethrow;
    }
  }

  @override
  Future<RecipeDetail> getRecipeDetail(int recipeId) async {
    final cached = await _local.getDetailCache(recipeId);
    if (cached != null && _cachePolicy.isFresh(cached.cachedAt)) {
      return _local.parseDetailPayload(cached.payload);
    }

    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.every((result) => result == ConnectivityResult.none) &&
        cached != null) {
      return _local.parseDetailPayload(cached.payload);
    }

    try {
      final detail = await _remote.getRecipeDetail(recipeId);
      await _local.putDetailCache(detail);
      return detail;
    } catch (_) {
      if (cached != null) return _local.parseDetailPayload(cached.payload);
      rethrow;
    }
  }
}
