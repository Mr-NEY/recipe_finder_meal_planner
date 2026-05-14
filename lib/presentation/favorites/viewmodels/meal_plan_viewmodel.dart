import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/core/database/app_database.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:recipe_finder_meal_planner/data/models/meal_slot.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepository(ref.watch(appDatabaseProvider));
});

final mealPlanViewModelProvider =
    NotifierProvider<MealPlanViewModel, MealPlanState>(MealPlanViewModel.new);

class MealPlanViewModel extends Notifier<MealPlanState> {
  @override
  MealPlanState build() {
    _load();
    return const MealPlanState();
  }

  Future<void> _load() async {
    final slots = await ref.read(mealPlanRepositoryProvider).getPlan();
    state = state.copyWith(slots: slots);
  }

  Future<void> assign({
    required Weekday day,
    required MealType mealType,
    required RecipeSummary recipe,
  }) async {
    final slot = MealSlot(
      id: MealSlot.makeId(day, mealType),
      day: day,
      mealType: mealType,
      recipe: recipe,
    );
    await ref.read(mealPlanRepositoryProvider).save(slot);
    await _load();
  }

  Future<void> remove(String id) async {
    await ref.read(mealPlanRepositoryProvider).remove(id);
    await _load();
  }

  MealSlot? slotFor(Weekday day, MealType mealType) {
    final id = MealSlot.makeId(day, mealType);
    for (final slot in state.slots) {
      if (slot.id == id) return slot;
    }
    return null;
  }
}

class MealPlanState {
  const MealPlanState({this.slots = const []});

  final List<MealSlot> slots;

  MealPlanState copyWith({List<MealSlot>? slots}) {
    return MealPlanState(slots: slots ?? this.slots);
  }
}
