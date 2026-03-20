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
    });

    group('copyWith()', () {
      test('copyWith updates fields correctly', () {
        final category = createRootCategory();
        final updated = category.copyWith(
          name: 'Art',
          iconIdentifier: 'new_icon',
          isSelectableAsActivity: true,
        );
        expect(updated.name, equals('Art'));
        expect(updated.iconIdentifier, equals('new_icon'));
        expect(updated.isSelectableAsActivity, isTrue);
        expect(updated.id, equals(category.id));
      });

      test('copyWith assigns parentCategoryId', () {
        final category = createRootCategory();
        final updated = category.copyWith(parentCategoryId: 'parent-1');
        expect(updated.parentCategoryId, equals('parent-1'));
      });
    });

    group('toFirestore()', () {
      test('happy path includes all fields', () {
        // Uses subcategory: parentCategoryId set, isSelectableAsActivity true.
        final category = createSubCategory();
        final map = category.toFirestore();
        expect(map['userId'], equals('user-123'));
        expect(map['name'], equals('Running'));
        expect(map['iconIdentifier'], equals('run_icon'));
        expect(map['isGlobal'], isFalse);
        expect(map['isSelectableAsActivity'], isTrue);
        expect(map['parentCategoryId'], equals('cat-1'));
        expect(map['createdAt'], isA<Timestamp>());
      });

      test('omits parentCategoryId when null', () {
        final category = createRootCategory();
        final map = category.toFirestore();
        expect(map.containsKey('parentCategoryId'), isFalse);
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
    });
  });
}
