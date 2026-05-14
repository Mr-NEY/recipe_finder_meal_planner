class RecipeDetail {
  const RecipeDetail({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.macros,
  });

  final int id;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final NutritionMacros macros;

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    final analyzedInstructions =
        (json['analyzedInstructions'] as List?) ?? const [];
    final steps = analyzedInstructions
        .expand((item) => ((item as Map?)?['steps'] as List?) ?? const [])
        .map((step) => ((step as Map?)?['step'] ?? '').toString())
        .where((step) => step.trim().isNotEmpty)
        .toList();

    final extendedIngredients =
        (json['extendedIngredients'] as List?) ?? const [];
    final ingredients = extendedIngredients
        .map((item) {
          final map = item as Map?;
          return (map?['original'] ?? map?['name'] ?? '').toString();
        })
        .where((ingredient) => ingredient.trim().isNotEmpty)
        .toList();

    return RecipeDetail(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      imageUrl: (json['image'] ?? '').toString(),
      ingredients: ingredients,
      instructions: steps,
      macros: NutritionMacros.fromSpoonacular(json['nutrition'] as Map?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': imageUrl,
      'extendedIngredients': ingredients
          .map((item) => {'original': item})
          .toList(),
      'analyzedInstructions': [
        {
          'steps': [
            for (var i = 0; i < instructions.length; i++)
              {'number': i + 1, 'step': instructions[i]},
          ],
        },
      ],
      'nutrition': macros.toJson(),
    };
  }
}

class NutritionMacros {
  const NutritionMacros({this.calories, this.protein, this.fat, this.carbs});

  final String? calories;
  final String? protein;
  final String? fat;
  final String? carbs;

  bool get hasAny => [
    calories,
    protein,
    fat,
    carbs,
  ].any((value) => value != null && value.isNotEmpty);

  factory NutritionMacros.fromSpoonacular(Map? nutrition) {
    final nutrients = (nutrition?['nutrients'] as List?) ?? const [];
    String? find(String name) {
      for (final nutrient in nutrients) {
        final map = nutrient as Map?;
        if ((map?['name'] ?? '').toString().toLowerCase() ==
            name.toLowerCase()) {
          final amount = map?['amount'];
          final unit = map?['unit'] ?? '';
          return amount == null ? null : '$amount$unit';
        }
      }
      return null;
    }

    return NutritionMacros(
      calories: find('Calories'),
      protein: find('Protein'),
      fat: find('Fat'),
      carbs: find('Carbohydrates'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nutrients': [
        if (calories != null)
          {'name': 'Calories', 'amount': calories, 'unit': ''},
        if (protein != null) {'name': 'Protein', 'amount': protein, 'unit': ''},
        if (fat != null) {'name': 'Fat', 'amount': fat, 'unit': ''},
        if (carbs != null)
          {'name': 'Carbohydrates', 'amount': carbs, 'unit': ''},
      ],
    };
  }
}
