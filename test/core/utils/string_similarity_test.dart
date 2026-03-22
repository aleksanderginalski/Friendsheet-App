import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/core/utils/string_similarity.dart';

void main() {
  group('normalizedLevenshtein', () {
    test('identical strings return 0.0', () {
      expect(normalizedLevenshtein('sport', 'sport'), 0.0);
    });

    test('two empty strings return 0.0', () {
      expect(normalizedLevenshtein('', ''), 0.0);
    });

    test('empty vs non-empty returns 1.0', () {
      expect(normalizedLevenshtein('', 'hiking'), 1.0);
      expect(normalizedLevenshtein('hiking', ''), 1.0);
    });

    test('completely different strings of equal length return 1.0', () {
      // 'abc' → 'xyz': 3 substitutions / max(3,3) = 1.0
      expect(normalizedLevenshtein('abc', 'xyz'), 1.0);
    });

    test('comparison is case-insensitive', () {
      expect(normalizedLevenshtein('Sport', 'sport'), 0.0);
      expect(normalizedLevenshtein('HIKING', 'hiking'), 0.0);
    });

    test('one-character insertion is well below fuzzy threshold', () {
      // 'sport' vs 'sports': 1 insert / max(5,6) ≈ 0.167
      final dist = normalizedLevenshtein('sport', 'sports');
      expect(dist, lessThan(0.4));
      expect(dist, greaterThan(0.0));
    });

    test('one-character deletion is well below fuzzy threshold', () {
      // 'piwko' vs 'piwo': 1 delete / max(5,4) = 0.2
      final dist = normalizedLevenshtein('piwko', 'piwo');
      expect(dist, lessThan(0.4));
      expect(dist, greaterThan(0.0));
    });

    test('unrelated names exceed fuzzy threshold', () {
      // 'hiking' vs 'swimming': many edits / max(6,8) ≥ 0.5
      final dist = normalizedLevenshtein('hiking', 'swimming');
      expect(dist, greaterThanOrEqualTo(0.4));
    });

    test('result is symmetric', () {
      expect(
        normalizedLevenshtein('piwo', 'piwko'),
        normalizedLevenshtein('piwko', 'piwo'),
      );
    });
  });
}
