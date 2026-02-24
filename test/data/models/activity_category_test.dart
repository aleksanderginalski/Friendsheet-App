import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';

void main() {
  group('ActivityCategory Model Tests', () {
    // Helper: creates a valid private root category.
    ActivityCategory createRootCategory({
      String id = 'cat-1',
      String userId = 'user-123',
      String name = 'Sport',
      String iconIdentifier = 'sports_icon',
      bool isSelectableAsActivity = false,
    }) {
      return ActivityCategory(
        id: id,
        userId: userId,
        name: name,
        iconIdentifier: iconIdentifier,
        isGlobal: false,
        isSelectableAsActivity: isSelectableAsActivity,
        parentCategoryId: null,
        createdAt: DateTime(2026, 2, 24),
      );
    }

    // Helper: creates a valid subcategory (depth 2).
    ActivityCategory createSubCategory({
      String id = 'cat-2',
      String userId = 'user-123',
      String name = 'Running',
      String parentCategoryId = 'cat-1',
      bool isSelectableAsActivity = true,
    }) {
      return ActivityCategory(
        id: id,
        userId: userId,
        name: name,
        iconIdentifier: 'run_icon',
        isGlobal: false,
        isSelectableAsActivity: isSelectableAsActivity,
        parentCategoryId: parentCategoryId,
        createdAt: DateTime(2026, 2, 24),
      );
    }

    group('Field assignment', () {
      test('root category fields are set correctly', () {
        final category = createRootCategory();
        expect(category.id, equals('cat-1'));
        expect(category.userId, equals('user-123'));
        expect(category.name, equals('Sport'));
        expect(category.iconIdentifier, equals('sports_icon'));
        expect(category.isGlobal, isFalse);
        expect(category.isSelectableAsActivity, isFalse);
        expect(category.parentCategoryId, isNull);
      });

      test('subcategory has parentCategoryId set', () {
        final category = createSubCategory(parentCategoryId: 'cat-1');
        expect(category.parentCategoryId, equals('cat-1'));
      });

      test('isSelectableAsActivity defaults to false for root', () {
        final category = createRootCategory();
        expect(category.isSelectableAsActivity, isFalse);
      });

      test('isSelectableAsActivity can be true for subcategory', () {
        final category = createSubCategory(isSelectableAsActivity: true);
        expect(category.isSelectableAsActivity, isTrue);
      });
    });

    group('Equality (==)', () {
      test('two categories with same data are equal', () {
        final c1 = createRootCategory();
        final c2 = createRootCategory();
        expect(c1, equals(c2));
      });

      test('categories with different names are not equal', () {
        final c1 = createRootCategory(name: 'Sport');
        final c2 = createRootCategory(name: 'Art');
        expect(c1, isNot(equals(c2)));
      });

      test('categories with different iconIdentifiers are not equal', () {
        final c1 = createRootCategory(iconIdentifier: 'icon_a');
        final c2 = createRootCategory(iconIdentifier: 'icon_b');
        expect(c1, isNot(equals(c2)));
      });

      test('categories with different isSelectableAsActivity are not equal',
          () {
        final c1 = createRootCategory(isSelectableAsActivity: false);
        final c2 = createRootCategory(isSelectableAsActivity: true);
        expect(c1, isNot(equals(c2)));
      });
    });

    group('copyWith()', () {
      test('copyWith updates name correctly', () {
        final category = createRootCategory(name: 'Sport');
        final updated = category.copyWith(name: 'Art');
        expect(updated.name, equals('Art'));
        expect(updated.id, equals(category.id));
      });

      test('copyWith assigns parentCategoryId', () {
        final category = createRootCategory();
        final updated = category.copyWith(parentCategoryId: 'parent-1');
        expect(updated.parentCategoryId, equals('parent-1'));
      });

      test('copyWith updates iconIdentifier', () {
        final category = createRootCategory(iconIdentifier: 'old_icon');
        final updated = category.copyWith(iconIdentifier: 'new_icon');
        expect(updated.iconIdentifier, equals('new_icon'));
      });

      test('copyWith updates isSelectableAsActivity', () {
        final category = createRootCategory(isSelectableAsActivity: false);
        final updated = category.copyWith(isSelectableAsActivity: true);
        expect(updated.isSelectableAsActivity, isTrue);
      });
    });

    group('toFirestore()', () {
      test('includes all required fields', () {
        final category = createRootCategory();
        final map = category.toFirestore();
        expect(map['userId'], equals('user-123'));
        expect(map['name'], equals('Sport'));
        expect(map['iconIdentifier'], equals('sports_icon'));
        expect(map['isGlobal'], isFalse);
        expect(map['isSelectableAsActivity'], isFalse);
        expect(map['createdAt'], isA<Timestamp>());
      });

      test('includes isSelectableAsActivity true when set', () {
        final category = createSubCategory(isSelectableAsActivity: true);
        final map = category.toFirestore();
        expect(map['isSelectableAsActivity'], isTrue);
      });

      test('omits parentCategoryId when null', () {
        final category = createRootCategory();
        final map = category.toFirestore();
        expect(map.containsKey('parentCategoryId'), isFalse);
      });

      test('includes parentCategoryId when set', () {
        final category = createSubCategory(parentCategoryId: 'cat-1');
        final map = category.toFirestore();
        expect(map['parentCategoryId'], equals('cat-1'));
      });
    });

    group('fromFirestore()', () {
      test('deserializes all fields correctly', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final docRef =
            await fakeFirestore.collection('activity_categories').add({
          'userId': 'user-123',
          'name': 'Sport',
          'iconIdentifier': 'sports_icon',
          'isGlobal': false,
          'isSelectableAsActivity': true,
          'createdAt': Timestamp.fromDate(DateTime(2026, 2, 24)),
        });

        final doc = await docRef.get();
        final category = ActivityCategory.fromFirestore(doc);

        expect(category.id, equals(docRef.id));
        expect(category.userId, equals('user-123'));
        expect(category.name, equals('Sport'));
        expect(category.iconIdentifier, equals('sports_icon'));
        expect(category.isGlobal, isFalse);
        expect(category.isSelectableAsActivity, isTrue);
        expect(category.parentCategoryId, isNull);
      });

      test('defaults isSelectableAsActivity to false when field is absent',
          () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final docRef =
            await fakeFirestore.collection('activity_categories').add({
          'userId': 'user-123',
          'name': 'Sport',
          'iconIdentifier': 'sports_icon',
          'isGlobal': false,
          'createdAt': Timestamp.fromDate(DateTime(2026, 2, 24)),
        });

        final doc = await docRef.get();
        final category = ActivityCategory.fromFirestore(doc);

        expect(category.isSelectableAsActivity, isFalse);
      });

      test('deserializes parentCategoryId when present', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final docRef =
            await fakeFirestore.collection('activity_categories').add({
          'userId': 'user-123',
          'name': 'Running',
          'iconIdentifier': 'run_icon',
          'isGlobal': false,
          'isSelectableAsActivity': false,
          'parentCategoryId': 'cat-parent',
          'createdAt': Timestamp.fromDate(DateTime(2026, 2, 24)),
        });

        final doc = await docRef.get();
        final category = ActivityCategory.fromFirestore(doc);

        expect(category.parentCategoryId, equals('cat-parent'));
      });

      test('uses doc.id as category id', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final docRef =
            await fakeFirestore.collection('activity_categories').add({
          'userId': 'user-123',
          'name': 'Music',
          'iconIdentifier': 'music_icon',
          'isGlobal': false,
          'isSelectableAsActivity': false,
          'createdAt': Timestamp.fromDate(DateTime(2026, 2, 24)),
        });

        final doc = await docRef.get();
        final category = ActivityCategory.fromFirestore(doc);

        expect(category.id, equals(docRef.id));
        expect(category.id, isNotEmpty);
      });
    });
  });
}
