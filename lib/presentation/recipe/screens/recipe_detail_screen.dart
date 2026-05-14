import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/data/models/meal_slot.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/presentation/favorites/viewmodels/favorites_viewmodel.dart';
import 'package:recipe_finder_meal_planner/presentation/favorites/viewmodels/meal_plan_viewmodel.dart';
import 'package:recipe_finder_meal_planner/presentation/recipe/viewmodels/recipe_detail_viewmodel.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final RecipeSummary recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(recipeDetailViewModelProvider(recipe.id));
    final isFavorite = ref
        .watch(favoritesViewModelProvider)
        .favorites
        .any((item) => item.id == recipe.id);

    return Scaffold(
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => CustomScrollView(
          slivers: [
            _Header(recipe: recipe, isFavorite: isFavorite),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error.toString(), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
        data: (data) => CustomScrollView(
          slivers: [
            _Header(recipe: recipe, detail: data, isFavorite: isFavorite),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  _ActionRow(recipe: recipe),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Ingredients',
                    children: data.ingredients.map(Text.new).toList(),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Instructions',
                    children: [
                      if (data.instructions.isEmpty)
                        const Text('No instructions available.'),
                      for (var i = 0; i < data.instructions.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('${i + 1}. ${data.instructions[i]}'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _NutritionSection(macros: data.macros),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.recipe, this.detail, required this.isFavorite});

  final RecipeSummary recipe;
  final RecipeDetail? detail;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280,
      actions: [
        IconButton.filledTonal(
          tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () =>
              ref.read(favoritesViewModelProvider.notifier).toggle(recipe),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          detail?.title ?? recipe.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: CachedNetworkImage(
          imageUrl: detail?.imageUrl.isNotEmpty == true
              ? detail!.imageUrl
              : recipe.imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => const ColoredBox(
            color: Color(0xFFE8EEE9),
            child: Center(child: Icon(Icons.image_not_supported, size: 42)),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.recipe});

  final RecipeSummary recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final day in Weekday.values.take(7))
          MenuAnchor(
            builder: (context, controller, child) {
              return ActionChip(
                avatar: const Icon(Icons.event_available, size: 18),
                label: Text(day.value.substring(0, 3)),
                onPressed: () => controller.open(),
              );
            },
            menuChildren: [
              for (final meal in MealType.values)
                MenuItemButton(
                  leadingIcon: const Icon(Icons.restaurant),
                  child: Text(meal.value),
                  onPressed: () {
                    ref
                        .read(mealPlanViewModelProvider.notifier)
                        .assign(day: day, mealType: meal, recipe: recipe);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Assigned to ${day.value} ${meal.value}.',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.macros});

  final NutritionMacros macros;

  @override
  Widget build(BuildContext context) {
    if (!macros.hasAny) {
      return const _Section(
        title: 'Nutrition',
        children: [Text('Nutrition data is not available.')],
      );
    }
    final values = {
      'Calories': macros.calories,
      'Protein': macros.protein,
      'Fat': macros.fat,
      'Carbs': macros.carbs,
    };
    return _Section(
      title: 'Nutrition',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in values.entries)
              if (entry.value != null)
                Chip(label: Text('${entry.key}: ${entry.value}')),
          ],
        ),
      ],
    );
  }
}
