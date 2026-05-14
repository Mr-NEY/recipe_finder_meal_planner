import 'package:recipe_finder_meal_planner/data/models/recipe_summary.dart';

enum Weekday {
  monday('Monday'),
  tuesday('Tuesday'),
  wednesday('Wednesday'),
  thursday('Thursday'),
  friday('Friday'),
  saturday('Saturday'),
  sunday('Sunday');

  const Weekday(this.value);

  final String value;

  static Weekday fromValue(String value) {
    return Weekday.values.firstWhere(
      (day) => day.value == value,
      orElse: () => Weekday.monday,
    );
  }
}

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner');

  const MealType(this.value);

  final String value;

  static MealType fromValue(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.breakfast,
    );
  }
}

class MealSlot {
  const MealSlot({
    required this.id,
    required this.day,
    required this.mealType,
    required this.recipe,
  });

  final String id;
  final Weekday day;
  final MealType mealType;
  final RecipeSummary recipe;

  static String makeId(Weekday day, MealType mealType) =>
      '${day.value}:${mealType.value}';

  MealSlot copyWith({Weekday? day, MealType? mealType, RecipeSummary? recipe}) {
    final nextDay = day ?? this.day;
    final nextMealType = mealType ?? this.mealType;
    return MealSlot(
      id: makeId(nextDay, nextMealType),
      day: nextDay,
      mealType: nextMealType,
      recipe: recipe ?? this.recipe,
    );
  }
}
