import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/data/models/meal_slot.dart';
import 'package:recipe_finder_meal_planner/presentation/favorites/viewmodels/meal_plan_viewmodel.dart';
import 'package:recipe_finder_meal_planner/presentation/recipe/screens/recipe_detail_screen.dart';
import '../viewmodels/favorites_viewmodel.dart';

class FavoritesMealPlanScreen extends ConsumerStatefulWidget {
  const FavoritesMealPlanScreen({super.key});

  @override
  ConsumerState<FavoritesMealPlanScreen> createState() =>
      _FavoritesMealPlanScreenState();
}

class _FavoritesMealPlanScreenState
    extends ConsumerState<FavoritesMealPlanScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved & Plan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(CupertinoIcons.heart_fill),
                  label: Text('Favorites'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(CupertinoIcons.calendar),
                  label: Text('Plan'),
                ),
              ],
              selected: {_segment},
              onSelectionChanged: (value) =>
                  setState(() => _segment = value.first),
            ),
          ),
          Expanded(
            child: _segment == 0 ? const _FavoritesTab() : const _MealPlanTab(),
          ),
        ],
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesViewModelProvider).favorites;
    if (favorites.isEmpty) {
      return const Center(child: Text('Saved recipes appear here.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) => _FavoriteCard(recipe: favorites[index]),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  const _FavoriteCard({required this.recipe});

  final RecipeSummary recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) =>
                    const Center(child: Icon(Icons.image_not_supported)),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Remove favorite',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(favoritesViewModelProvider.notifier)
                          .toggle(recipe),
                    ),
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

class _MealPlanTab extends ConsumerWidget {
  const _MealPlanTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        for (final day in Weekday.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DayPlan(day: day),
          ),
      ],
    );
  }
}

class _DayPlan extends ConsumerWidget {
  const _DayPlan({required this.day});

  final Weekday day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(mealPlanViewModelProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final meal in MealType.values)
          _MealSlotTile(mealType: meal, slot: _slotFor(plan.slots, day, meal)),
      ],
    );
  }

  MealSlot? _slotFor(List<MealSlot> slots, Weekday day, MealType mealType) {
    for (final slot in slots) {
      if (slot.day == day && slot.mealType == mealType) return slot;
    }
    return null;
  }
}

class _MealSlotTile extends ConsumerWidget {
  const _MealSlotTile({required this.mealType, required this.slot});

  final MealType mealType;
  final MealSlot? slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = slot?.recipe;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant),
        title: Text(mealType.value),
        subtitle: Text(recipe?.title ?? 'No recipe assigned'),
        trailing: recipe == null
            ? null
            : Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Open recipe',
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipe: recipe),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref
                        .read(mealPlanViewModelProvider.notifier)
                        .remove(slot!.id),
                  ),
                ],
              ),
      ),
    );
  }
}
