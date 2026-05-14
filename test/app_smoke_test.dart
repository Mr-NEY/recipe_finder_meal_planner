import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder_meal_planner/main.dart';

void main() {
  testWidgets('renders the app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RecipePlannerApp()));

    expect(find.text('Recipe Finder'), findsOneWidget);
    expect(find.text('Find recipes'), findsOneWidget);
  });
}
