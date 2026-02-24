import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityCategoryRepository repository;

  const userId = 'user-1';

  // Helper: builds an ActivityCategory instance for testing.
  ActivityCategory makeCategory({
    String id = '',
    String name = 'Sport',
    String? parentCategoryId,
  }) {
    return ActivityCategory(
      id: id,
      userId: userId,
      name: name,
      iconIdentifier: 'sport_icon',
      isGlobal: false,
      parentCategoryId: parentCategoryId,
      createdAt: DateTime(2026, 2, 24),
    );
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ActivityCategoryRepository(firestore: fakeFirestore);
  });

  // Returns the Firestore collection reference used by the repository.
  CollectionReference categoriesRef() => fakeFirestore
      .collection('users')
      .doc(userId)
      .collection('activity_categories');

  // Seeds a root category directly in fake Firestore and returns its ID.
  Future<String> seedRootCategory({String name = 'Root'}) async {
    final ref = await categoriesRef().add({
      'userId': userId,
      'name': name,
      'iconIdentifier': 'icon',
      'isGlobal': false,
      'createdAt': Timestamp.now(),
    });
    return ref.id;
  }

  // Seeds a subcategory (depth 2) directly in fake Firestore and returns its ID.
  Future<String> seedSubCategory(
    String parentId, {
    String name = 'Sub',
  }) async {
    final ref = await categoriesRef().add({
      'userId': userId,
      'name': name,
      'iconIdentifier': 'icon',
      'isGlobal': false,
      'parentCategoryId': parentId,
      'createdAt': Timestamp.now(),
    });
    return ref.id;
  }

  group('ActivityCategoryRepository', () {
    group('addCategory', () {
      test('root category (depth 1) succeeds', () async {
        final category = makeCategory(name: 'Sport');
        await expectLater(repository.addCategory(category), completes);
      });

      test('subcategory (depth 2) succeeds when parent is a root', () async {
        final parentId = await seedRootCategory();
        final category = makeCategory(
          name: 'Running',
          parentCategoryId: parentId,
        );
        await expectLater(repository.addCategory(category), completes);
      });

      test('throws when parent is already a subcategory (depth > 2)', () async {
        final rootId = await seedRootCategory();
        final subId = await seedSubCategory(rootId);
        final category = makeCategory(
          name: 'Ultra Running',
          parentCategoryId: subId,
        );
        await expectLater(
          repository.addCategory(category),
          throwsA(isA<Exception>()),
        );
      });

      test('stores document in correct Firestore path', () async {
        final category = makeCategory(name: 'Art');
        await repository.addCategory(category);

        final snapshot = await categoriesRef().get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first['name'], equals('Art'));
      });
    });

    group('updateCategory', () {
      test('throws when new parent would exceed depth 2', () async {
        final rootId = await seedRootCategory();
        final subId = await seedSubCategory(rootId);
        // Try to re-parent an existing root under a subcategory — depth 3.
        final category = makeCategory(
          id: rootId,
          name: 'Renamed',
          parentCategoryId: subId,
        );
        await expectLater(
          repository.updateCategory(category),
          throwsA(isA<Exception>()),
        );
      });

      test('succeeds when category remains at depth 2', () async {
        final rootId = await seedRootCategory();
        final subId = await seedSubCategory(rootId);
        final doc = await categoriesRef().doc(subId).get();
        final existing = ActivityCategory.fromFirestore(doc);
        final updated = existing.copyWith(name: 'Updated Sub');
        await expectLater(repository.updateCategory(updated), completes);
      });

      test('persists updated name in Firestore', () async {
        final rootId = await seedRootCategory(name: 'Old Name');
        final doc = await categoriesRef().doc(rootId).get();
        final existing = ActivityCategory.fromFirestore(doc);
        await repository.updateCategory(existing.copyWith(name: 'New Name'));

        final updated = await categoriesRef().doc(rootId).get();
        expect((updated.data() as Map<String, dynamic>)['name'],
            equals('New Name'));
      });
    });

    group('deleteCategory', () {
      test('deletes the category document', () async {
        final id = await seedRootCategory(name: 'ToDelete');
        await repository.deleteCategory(userId, id);

        final doc = await categoriesRef().doc(id).get();
        expect(doc.exists, isFalse);
      });

      test('does not affect other category documents', () async {
        final idToKeep = await seedRootCategory(name: 'Keep');
        final idToDelete = await seedRootCategory(name: 'Delete');
        await repository.deleteCategory(userId, idToDelete);

        final doc = await categoriesRef().doc(idToKeep).get();
        expect(doc.exists, isTrue);
      });
    });

    group('getCategories', () {
      test('returns empty list when no categories exist', () async {
        final result = await repository.getCategories(userId).first;
        expect(result, isEmpty);
      });

      test('returns all categories for user', () async {
        await seedRootCategory(name: 'Sport');
        await seedRootCategory(name: 'Art');

        final result = await repository.getCategories(userId).first;
        expect(result.length, equals(2));
      });

      test('returned items are ActivityCategory instances', () async {
        await seedRootCategory(name: 'Music');

        final result = await repository.getCategories(userId).first;
        expect(result.first, isA<ActivityCategory>());
        expect(result.first.name, equals('Music'));
      });

      test('stream emits updated list after adding a category', () async {
        final stream = repository.getCategories(userId);

        await seedRootCategory(name: 'Dance');
        final result = await stream.first;
        expect(result.length, equals(1));
      });
    });
  });
}
