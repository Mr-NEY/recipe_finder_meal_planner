# Recipe Finder & Meal Planner

## Tech Stack

Using Clean Architecture, MVVM, feature-based structure, Riverpod, Dio, and Drift-backed SQLite persistence.

## Setup

Use Flutter stable and pass your Spoonacular key at runtime:

```bash
flutter pub get
flutter run --dart-define=SPOONACULAR_API_KEY=your_key_here
```

The app intentionally does not commit API keys. If no key is supplied, network calls show a clear configuration error while offline favorites and meal-plan data continue to work.

## Architecture

```text
UI -> ViewModel/Riverpod -> UseCase -> Repository -> Remote Dio + Local Drift
```

Key folders:

- `lib/core/network`: Dio client, interceptors, API errors.
- `lib/core/database`: Drift runtime database and SQL-backed DAOs.
- `lib/core/cache`: 30-minute cache policy.

## Verification Checklist

- Search recipes by comma-separated ingredients.
- Scroll to load additional results.
- Open recipe detail and review ingredients, instructions, and macros.
- Favorite a recipe.
- Assign favorite recipes to Monday-Sunday Breakfast/Lunch/Dinner slots.
- Relaunch and confirm favorites/meal plan persist.
- Disable internet and confirm saved data remains available.
