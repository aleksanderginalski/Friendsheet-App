import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity.dart';

void main() {
  group('Activity Model Tests', () {
    // Helper: creates a valid private activity
    Activity createPrivateActivity({
      String id = 'activity-1',
      String userId = 'user-123',
      String name = 'Coffee',
      String? categoryId,
    }) {
      return Activity(
        id: id,
        userId: userId,
        name: name,
        isGlobal: false,
        categoryId: categoryId,
        createdAt: DateTime(2026, 2, 19),
      );
    }

    // Helper: creates a valid global activity
    Activity createGlobalActivity({
      String id = 'global-activity-1',
      String name = 'Walk',
      String? categoryId,
    }) {
      return Activity(
        id: id,
        userId: null,
        name: name,
        isGlobal: true,
        categoryId: categoryId,
        createdAt: DateTime(2026, 2, 19),
      );
    }

    group('isValid()', () {
      test('returns true for activity with non-empty name', () {
        final activity = createPrivateActivity(name: 'Coffee');
        expect(activity.isValid(), isTrue);
      });

      test('returns false for activity with empty name', () {
        final activity = createPrivateActivity(name: '');
        expect(activity.isValid(), isFalse);
      });

      test('returns false for activity with whitespace-only name', () {
        final activity = createPrivateActivity(name: '   ');
        expect(activity.isValid(), isFalse);
      });

      test('returns true for global activity', () {
        final activity = createGlobalActivity(name: 'Walk');
        expect(activity.isValid(), isTrue);
      });
    });

    group('Global vs Private', () {
      test('global activity has null userId', () {
        final activity = createGlobalActivity();
        expect(activity.userId, isNull);
        expect(activity.isGlobal, isTrue);
      });

      test('private activity has non-null userId', () {
        final activity = createPrivateActivity();
        expect(activity.userId, equals('user-123'));
        expect(activity.isGlobal, isFalse);
      });
    });

    group('categoryId', () {
      test('categoryId is null when not provided', () {
        final activity = createPrivateActivity();
        expect(activity.categoryId, isNull);
      });

      test('categoryId is set when provided', () {
        final activity = createPrivateActivity(categoryId: 'sport-category');
        expect(activity.categoryId, equals('sport-category'));
      });
    });

    group('copyWith()', () {
      test('copyWith updates name correctly', () {
        final activity = createPrivateActivity(name: 'Coffee');
        final updated = activity.copyWith(name: 'Tea');
        expect(updated.name, equals('Tea'));
        expect(updated.id, equals(activity.id));
      });

      test('copyWith assigns categoryId', () {
        final activity = createPrivateActivity();
        final updated = activity.copyWith(categoryId: 'sport-1');
        expect(updated.categoryId, equals('sport-1'));
      });
    });

    group('Equality (==)', () {
      test('two activities with same data are equal', () {
        final a1 = createPrivateActivity();
        final a2 = createPrivateActivity();
        expect(a1, equals(a2));
      });

      test('activities with different names are not equal', () {
        final a1 = createPrivateActivity(name: 'Coffee');
        final a2 = createPrivateActivity(name: 'Tea');
        expect(a1, isNot(equals(a2)));
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round-trip works correctly', () {
        final activity = createPrivateActivity(categoryId: 'sport-1');
        final json = activity.toJson();
        final restored = Activity.fromJson(json);
        expect(restored, equals(activity));
      });

      test('toJson round-trip works for global activity', () {
        final activity = createGlobalActivity();
        final json = activity.toJson();
        final restored = Activity.fromJson(json);
        expect(restored, equals(activity));
      });
    });

    group('toFirestore()', () {
      test('private activity includes userId in map', () {
        final activity = createPrivateActivity();
        final map = activity.toFirestore();
        expect(map['userId'], equals('user-123'));
        expect(map['name'], equals('Coffee'));
        expect(map['isGlobal'], isFalse);
      });

      test('global activity omits userId from map', () {
        final activity = createGlobalActivity();
        final map = activity.toFirestore();
        expect(map.containsKey('userId'), isFalse);
        expect(map['isGlobal'], isTrue);
      });

      test('categoryId omitted from map when null', () {
        final activity = createPrivateActivity();
        final map = activity.toFirestore();
        expect(map.containsKey('categoryId'), isFalse);
      });

      test('categoryId included in map when set', () {
        final activity = createPrivateActivity(categoryId: 'sport-1');
        final map = activity.toFirestore();
        expect(map['categoryId'], equals('sport-1'));
      });
    });
  });
}
