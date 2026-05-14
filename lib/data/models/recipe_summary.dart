class RecipeSummary {
  const RecipeSummary({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.missedIngredientCount,
    required this.usedIngredientCount,
  });

  final int id;
  final String title;
  final String imageUrl;
  final int missedIngredientCount;
  final int usedIngredientCount;

  factory RecipeSummary.fromJson(Map<String, dynamic> json) {
    return RecipeSummary(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      imageUrl: (json['image'] ?? json['imageUrl'] ?? '').toString(),
      missedIngredientCount:
          (json['missedIngredientCount'] as num?)?.toInt() ?? 0,
      usedIngredientCount: (json['usedIngredientCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': imageUrl,
      'missedIngredientCount': missedIngredientCount,
      'usedIngredientCount': usedIngredientCount,
    };
  }
}
