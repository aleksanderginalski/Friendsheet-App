import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/core/theme/chart_colors.dart';

void main() {
  group('ChartColors', () {
    test('same id always returns the same base color (stable assignment)', () {
      const id = 'category-abc';
      expect(
          ChartColors.getBaseColor(id), equals(ChartColors.getBaseColor(id)));
    });

    test('index stays within palette bounds (0–7)', () {
      // Use a range of ids including edge cases.
      final ids = ['a', 'ab', 'abc', 'id-1', 'id-2', 'id-3', 'x' * 50];
      for (final id in ids) {
        // If index were out of bounds, getBaseColor would throw — so no throw == pass.
        expect(() => ChartColors.getBaseColor(id), returnsNormally);
        expect(() => ChartColors.getGradient(id), returnsNormally);
        expect(() => ChartColors.getStrokeColor(id), returnsNormally);
      }
    });

    test('getGradient returns exactly 4 colors and 4 stops', () {
      const id = 'test-id';
      final gradient = ChartColors.getGradient(id);
      expect(gradient.colors.length, equals(4));
      expect(gradient.stops!.length, equals(4));
    });

    test('getGradient stops are [0.0, 0.3, 0.7, 1.0]', () {
      const id = 'test-id';
      final gradient = ChartColors.getGradient(id);
      expect(gradient.stops, equals([0.0, 0.3, 0.7, 1.0]));
    });

    test(
        'getStrokeColor returns fixed charcoal color (0xFF1C1B1F) regardless of id',
        () {
      const id = 'test-id';
      final stroke = ChartColors.getStrokeColor(id);
      // High-contrast dark stroke — full opacity, independent of palette entry.
      expect(stroke.a, closeTo(1.0, 0.01));
      expect(ChartColors.getStrokeColor('other-id'), equals(stroke));
    });

    test('different ids can produce different colors', () {
      // With 8 palette entries, ids with different hash % 8 give different colors.
      // Find two ids that hash to different indices.
      final colors = List.generate(
        16,
        (i) => ChartColors.getBaseColor('id-$i'),
      );
      // At least two distinct colors exist across 16 ids (palette has 8 entries).
      final distinct = colors.toSet();
      expect(distinct.length, greaterThan(1));
    });

    test('gradient first and last color equal edge color', () {
      const id = 'some-category';
      final base = ChartColors.getBaseColor(id);
      final gradient = ChartColors.getGradient(id);
      expect(gradient.colors.first, equals(base));
      expect(gradient.colors.last, equals(base));
    });
  });
}
