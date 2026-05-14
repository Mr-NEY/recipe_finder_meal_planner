import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/presentation/favorites/viewmodels/favorites_viewmodel.dart';
import 'package:recipe_finder_meal_planner/presentation/recipe/viewmodels/recipe_search_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'recipe_detail_screen.dart';

class RecipeSearchScreen extends ConsumerStatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  ConsumerState<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends ConsumerState<RecipeSearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _ingredients = <String>[];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 480) {
      ref.read(recipeSearchViewModelProvider.notifier).loadNextPage();
    }
  }

  void _addIngredientsFromInput() {
    final parts = _controller.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    setState(() {
      for (final part in parts) {
        if (!_ingredients
            .map((item) => item.toLowerCase())
            .contains(part.toLowerCase())) {
          _ingredients.add(part);
        }
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(recipeSearchViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Finder')),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Ingredients',
                        hintText: 'tomato, chicken, basil',
                        suffixIcon: IconButton(
                          tooltip: 'Add ingredients',
                          icon: const Icon(Icons.add),
                          onPressed: _addIngredientsFromInput,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addIngredientsFromInput(),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final ingredient in _ingredients)
                          InputChip(
                            label: Text(ingredient),
                            onDeleted: () =>
                                setState(() => _ingredients.remove(ingredient)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        _addIngredientsFromInput();
                        ref
                            .read(recipeSearchViewModelProvider.notifier)
                            .search(_ingredients);
                      },
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Find recipes'),
                    ),
                  ],
                ),
              ),
            ),
            searchState.when(
              loading: () => const _RecipeGridSkeleton(),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  icon: Icons.wifi_off,
                  message: error.toString(),
                ),
              ),
              data: (data) {
                if (data.recipes.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _MessageState(
                      icon: CupertinoIcons.search,
                      message: 'Add ingredients and search for recipes.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                    itemCount:
                        data.recipes.length + (data.isLoadingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= data.recipes.length) {
                        return const _RecipeCardSkeleton();
                      }
                      return _RecipeCard(recipe: data.recipes[index]);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe});

  final RecipeSummary recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesViewModelProvider)
        .favorites
        .any((item) => item.id == recipe.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (_, _, _) {
                  return const ColoredBox(
                    color: Color(0xFFE8EEE9),
                    child: Center(child: Icon(Icons.image_not_supported)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text('${recipe.missedIngredientCount} missing'),
                      ),
                      IconButton(
                        tooltip: isFavorite
                            ? 'Remove favorite'
                            : 'Save favorite',
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        onPressed: () => ref
                            .read(favoritesViewModelProvider.notifier)
                            .toggle(recipe),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeGridSkeleton extends StatelessWidget {
  const _RecipeGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const _RecipeCardSkeleton(),
      ),
    );
  }
}

class _RecipeCardSkeleton extends StatelessWidget {
  const _RecipeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(child: Container(color: Colors.white)),
            Container(height: 72, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
