import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_detail.dart';
import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';
import 'package:recipe_finder_meal_planner/data/models/meal_slot.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

class AppDatabase extends GeneratedDatabase {
  AppDatabase() : super(_openConnection()) {
    _ready = _createSchema();
  }

  late final Future<void> _ready;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'recipe_finder_meal_planner');
  }

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  Future<void> ensureReady() => _ready;

  Future<void> _createSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS api_cache (
        cache_key TEXT PRIMARY KEY NOT NULL,
        payload TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS favorites (
        recipe_id INTEGER PRIMARY KEY NOT NULL,
        payload TEXT NOT NULL,
        saved_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS meal_plan (
        id TEXT PRIMARY KEY NOT NULL,
        day TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        recipe_id INTEGER NOT NULL,
        payload TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<CachedPayload?> getCache(String key) async {
    await ensureReady();
    final rows = await customSelect(
      'SELECT payload, cached_at FROM api_cache WHERE cache_key = ? LIMIT 1',
      variables: [Variable.withString(key)],
      readsFrom: const {},
    ).get();
    if (rows.isEmpty) return null;
    return CachedPayload(
      payload: rows.first.read<String>('payload'),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(
        rows.first.read<int>('cached_at'),
      ),
    );
  }

  Future<void> putCache(String key, String payload) async {
    await ensureReady();
    await customStatement(
      '''
      INSERT OR REPLACE INTO api_cache(cache_key, payload, cached_at)
      VALUES (?, ?, ?)
      ''',
      [key, payload, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<RecipeDetail?> getCachedDetail(int recipeId) async {
    final cache = await getCache('detail:$recipeId');
    if (cache == null) return null;
    return RecipeDetail.fromJson(
      jsonDecode(cache.payload) as Map<String, dynamic>,
    );
  }

  Future<List<RecipeSummary>> getFavorites() async {
    await ensureReady();
    final rows = await customSelect(
      'SELECT payload FROM favorites ORDER BY saved_at DESC',
      readsFrom: const {},
    ).get();
    return rows
        .map(
          (row) => RecipeSummary.fromJson(
            jsonDecode(row.read<String>('payload')) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<bool> isFavorite(int recipeId) async {
    await ensureReady();
    final rows = await customSelect(
      'SELECT recipe_id FROM favorites WHERE recipe_id = ? LIMIT 1',
      variables: [Variable.withInt(recipeId)],
      readsFrom: const {},
    ).get();
    return rows.isNotEmpty;
  }

  Future<void> saveFavorite(RecipeSummary recipe) async {
    await ensureReady();
    await customStatement(
      '''
      INSERT OR REPLACE INTO favorites(recipe_id, payload, saved_at)
      VALUES (?, ?, ?)
      ''',
      [
        recipe.id,
        jsonEncode(recipe.toJson()),
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<void> removeFavorite(int recipeId) async {
    await ensureReady();
    await customStatement('DELETE FROM favorites WHERE recipe_id = ?', [
      recipeId,
    ]);
    await customStatement('DELETE FROM meal_plan WHERE recipe_id = ?', [
      recipeId,
    ]);
  }

  Future<List<MealSlot>> getMealPlan() async {
    await ensureReady();
    final rows = await customSelect(
      'SELECT id, day, meal_type, payload FROM meal_plan ORDER BY updated_at DESC',
      readsFrom: const {},
    ).get();
    return rows.map((row) {
      return MealSlot(
        id: row.read<String>('id'),
        day: Weekday.fromValue(row.read<String>('day')),
        mealType: MealType.fromValue(row.read<String>('meal_type')),
        recipe: RecipeSummary.fromJson(
          jsonDecode(row.read<String>('payload')) as Map<String, dynamic>,
        ),
      );
    }).toList();
  }

  Future<void> upsertMealSlot(MealSlot slot) async {
    await ensureReady();
    await customStatement(
      '''
      INSERT OR REPLACE INTO meal_plan(id, day, meal_type, recipe_id, payload, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [
        slot.id,
        slot.day.value,
        slot.mealType.value,
        slot.recipe.id,
        jsonEncode(slot.recipe.toJson()),
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<void> removeMealSlot(String id) async {
    await ensureReady();
    await customStatement('DELETE FROM meal_plan WHERE id = ?', [id]);
  }
}

class CachedPayload {
  const CachedPayload({required this.payload, required this.cachedAt});

  final String payload;
  final DateTime cachedAt;
}
