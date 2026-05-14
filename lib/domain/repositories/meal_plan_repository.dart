
import 'package:recipe_finder_meal_planner/core/database/app_database.dart';
import '../../data/models/meal_slot.dart';

class MealPlanRepository {
  const MealPlanRepository(this._database);

  final AppDatabase _database;

  Future<List<MealSlot>> getPlan() => _database.getMealPlan();

  Future<void> save(MealSlot slot) => _database.upsertMealSlot(slot);

  Future<void> remove(String id) => _database.removeMealSlot(id);
}
