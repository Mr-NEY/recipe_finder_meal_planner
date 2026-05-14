import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder_meal_planner/core/cache/cache_policy.dart';

void main() {
  group('CachePolicy', () {
    test('treats entries younger than ttl as fresh', () {
      const policy = CachePolicy(ttl: Duration(minutes: 30));
      final now = DateTime(2026, 1, 1, 12);

      expect(
        policy.isFresh(now.subtract(const Duration(minutes: 29)), now: now),
        isTrue,
      );
    });

    test('treats entries older than ttl as stale', () {
      const policy = CachePolicy(ttl: Duration(minutes: 30));
      final now = DateTime(2026, 1, 1, 12);

      expect(
        policy.isFresh(now.subtract(const Duration(minutes: 30)), now: now),
        isFalse,
      );
    });
  });
}
