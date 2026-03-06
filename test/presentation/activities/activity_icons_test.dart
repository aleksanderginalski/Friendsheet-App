import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/activities/activity_icons.dart';

void main() {
  group('resolveActivityIcon', () {
    test('returns correct asset path for known identifier', () {
      expect(
        resolveActivityIcon('coffee'),
        equals('assets/icons/activities/coffee.png'),
      );
      expect(
        resolveActivityIcon('cake'),
        equals('assets/icons/activities/cake.png'),
      );
    });

    test('returns null for unknown identifier', () {
      expect(resolveActivityIcon('unknown_xyz'), isNull);
      expect(resolveActivityIcon('old_sports_tennis'), isNull);
    });

    test('returns null for empty string', () {
      expect(resolveActivityIcon(''), isNull);
    });

    test('returns null for null', () {
      expect(resolveActivityIcon(null), isNull);
    });

    test('kActivityIcons map contains 51 entries', () {
      expect(kActivityIcons.length, equals(51));
    });

    test('all values are valid PNG asset paths', () {
      for (final path in kActivityIcons.values) {
        expect(path, startsWith('assets/icons/activities/'));
        expect(path, endsWith('.png'));
      }
    });
  });
}
