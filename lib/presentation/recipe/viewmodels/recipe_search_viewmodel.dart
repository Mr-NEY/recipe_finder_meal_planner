import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'recipe_providers.dart';

final recipeSearchViewModelProvider =
    AsyncNotifierProvider<RecipeSearchViewModel, RecipeSearchState>(
      RecipeSearchViewModel.new,
    );

class RecipeSearchViewModel extends AsyncNotifier<RecipeSearchState> {
  static const _pageSize = 12;

  @override
  Future<RecipeSearchState> build() async {
    return const RecipeSearchState();
  }

  Future<void> search(List<String> ingredients) async {
    final cleaned = _cleanIngredients(ingredients);
    if (cleaned.isEmpty) {
      state = const AsyncData(RecipeSearchState());
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final recipes = await ref.read(searchRecipesProvider)(
        ingredients: cleaned,
        page: 0,
        pageSize: _pageSize,
      );
      return RecipeSearchState(
        ingredients: cleaned,
        recipes: recipes,
        page: 0,
        hasMore: recipes.length == _pageSize,
      );
    });
  }

  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.ingredients.isEmpty) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    try {
      final recipes = await ref.read(searchRecipesProvider)(
        ingredients: current.ingredients,
        page: nextPage,
        pageSize: _pageSize,
      );
      state = AsyncData(
        current.copyWith(
          recipes: [...current.recipes, ...recipes],
          page: nextPage,
          hasMore: recipes.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  List<String> _cleanIngredients(List<String> ingredients) {
    return ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }
}

class RecipeSearchState {
  const RecipeSearchState({
    this.ingredients = const [],
    this.recipes = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<String> ingredients;
  final List<RecipeSummary> recipes;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  RecipeSearchState copyWith({
    List<String>? ingredients,
    List<RecipeSummary>? recipes,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RecipeSearchState(
      ingredients: ingredients ?? this.ingredients,
      recipes: recipes ?? this.recipes,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
