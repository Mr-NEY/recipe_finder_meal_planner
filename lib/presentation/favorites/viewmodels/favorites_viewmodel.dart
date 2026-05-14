import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/core/database/app_database.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/domain/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(appDatabaseProvider));
});

final favoritesViewModelProvider =
    NotifierProvider<FavoritesViewModel, FavoritesState>(
      FavoritesViewModel.new,
    );

class FavoritesViewModel extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    _load();
    return const FavoritesState();
  }

  Future<void> _load() async {
    final favorites = await ref
        .read(favoritesRepositoryProvider)
        .getFavorites();
    state = state.copyWith(favorites: favorites);
  }

  Future<void> toggle(RecipeSummary recipe) async {
    final repository = ref.read(favoritesRepositoryProvider);
    final exists =
        state.favorites.any((item) => item.id == recipe.id) ||
        await repository.isFavorite(recipe.id);
    if (exists) {
      await repository.remove(recipe.id);
    } else {
      await repository.add(recipe);
    }
    await _load();
  }

  bool contains(int recipeId) =>
      state.favorites.any((item) => item.id == recipeId);
}

class FavoritesState {
  const FavoritesState({this.favorites = const []});

  final List<RecipeSummary> favorites;

  FavoritesState copyWith({List<RecipeSummary>? favorites}) {
    return FavoritesState(favorites: favorites ?? this.favorites);
  }
}
