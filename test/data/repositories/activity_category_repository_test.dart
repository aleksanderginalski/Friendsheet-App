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
    bool isSelectableAsActivity = false,
  }) {
    return ActivityCategory(
      id: id,
      userId: userId,
      name: name,
      iconIdentifier: 'sport_icon',
      isGlobal: false,
      isSelectableAsActivity: isSelectableAsActivity,
      parentCategoryId: parentCategoryId,
      createdAt: DateTime(2026, 2, 24),
    );
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ActivityCategoryRepository(firestore: fakeFirestore);
  });

  // Returns the Firestore subcollection reference used by legacy methods.
  CollectionReference categoriesRef() => fakeFirestore
      .collection('users')
      .doc(userId)
      .collection('activity_categories');

  // Seeds a root category in the subcollection and returns its ID.
  Future<String> seedRootCategory({String name = 'Root'}) async {
    final ref = await categoriesRef().add({
      'userId': userId,
      'name': name,
      'iconIdentifier': 'icon',
      'isGlobal': false,
      'isSelectableAsActivity': false,
      'createdAt': Timestamp.now(),
    });
    return ref.id;
  }

  // Seeds a subcategory in the subcollection and returns its ID.
  Future<String> seedSubCategory(
    String parentId, {
    String name = 'Sub',
  }) async {
    final ref = await categoriesRef().add({
      'userId': userId,
      'name': name,
      'iconIdentifier': 'icon',
      'isGlobal': false,
      'isSelectableAsActivity': false,
      'parentCategoryId': parentId,
      'createdAt': Timestamp.now(),
    });
    return ref.id;
  }

  group('ActivityCategoryRepository', () {
    group('addCategory', () {
      test('happy path: stores document in correct Firestore path', () async {
        final category = makeCategory(name: 'Art');
        await repository.addCategory(category);

        final snapshot = await categoriesRef().get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first['name'], equals('Art'));
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

      test('happy path: persists name update in Firestore', () async {
        final rootId = await seedRootCategory(name: 'Old Name');
        final doc = await categoriesRef().doc(rootId).get();
        final existing = ActivityCategory.fromFirestore(doc);
        await repository.updateCategory(existing.copyWith(name: 'New Name'));

        final updated = await categoriesRef().doc(rootId).get();
        expect(
          (updated.data() as Map<String, dynamic>)['name'],
          equals('New Name'),
        );
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

    group('deleteWithChildren', () {
      test('deletes parent and all direct children atomically', () async {
        final parentId = await seedRootCategory(name: 'Parent');
        final child1Id = await seedSubCategory(parentId, name: 'Child1');
        final child2Id = await seedSubCategory(parentId, name: 'Child2');

        await repository.deleteWithChildren(userId, parentId);

        final parentDoc = await categoriesRef().doc(parentId).get();
        final child1Doc = await categoriesRef().doc(child1Id).get();
        final child2Doc = await categoriesRef().doc(child2Id).get();
        expect(parentDoc.exists, isFalse);
        expect(child1Doc.exists, isFalse);
        expect(child2Doc.exists, isFalse);
      });

      test('deletes root category with no children (single delete in batch)',
          () async {
        final id = await seedRootCategory(name: 'Lone Root');

        await repository.deleteWithChildren(userId, id);

        final doc = await categoriesRef().doc(id).get();
        expect(doc.exists, isFalse);
      });
    });

    group('getCategories', () {
      test('returns empty list when no categories exist', () async {
        final result = await repository.getCategories(userId).first;
        expect(result, isEmpty);
      });

      test('returns all categories as typed ActivityCategory instances',
          () async {
        await seedRootCategory(name: 'Music');

        final result = await repository.getCategories(userId).first;
        expect(result.length, equals(1));
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

    group('getSelectableCategories', () {
      test('returns empty list when no categories exist', () async {
        final result = await repository.getSelectableCategories(userId);
        expect(result, isEmpty);
      });

      test('returns only categories with isSelectableAsActivity true',
          () async {
        await categoriesRef().add({
          'userId': userId,
          'name': 'Running',
          'iconIdentifier': 'icon',
          'isGlobal': false,
          'isSelectableAsActivity': true,
          'createdAt': Timestamp.now(),
        });
        await categoriesRef().add({
          'userId': userId,
          'name': 'Sport',
          'iconIdentifier': 'icon',
          'isGlobal': false,
          'isSelectableAsActivity': false,
          'createdAt': Timestamp.now(),
        });

        final result = await repository.getSelectableCategories(userId);

        expect(result.length, equals(1));
        expect(result.first.name, equals('Running'));
        expect(result.first.isSelectableAsActivity, isTrue);
      });

      test('does not return categories from a different user', () async {
        await fakeFirestore
            .collection('users')
            .doc('other-user')
            .collection('activity_categories')
            .add({
          'userId': 'other-user',
          'name': 'Hiking',
          'iconIdentifier': 'icon',
          'isGlobal': false,
          'isSelectableAsActivity': true,
          'createdAt': Timestamp.now(),
        });

        final result = await repository.getSelectableCategories(userId);

        expect(result, isEmpty);
      });
    });

    group('getAncestorIds', () {
      test('returns only the category itself when it has no parent', () async {
        final rootId = await seedRootCategory(name: 'Sport');

        final result = await repository.getAncestorIds(rootId, userId);

        expect(result, equals([rootId]));
      });

      test('returns leaf and parent IDs for depth-2 category', () async {
        final parentId = await seedRootCategory(name: 'Sport');
        final leafId = await seedSubCategory(parentId, name: 'Running');

        final result = await repository.getAncestorIds(leafId, userId);

        expect(result.length, equals(2));
        expect(result, containsAll([leafId, parentId]));
        expect(result.first, equals(leafId));
      });

      test('returns empty list when category does not exist', () async {
        final result = await repository.getAncestorIds('nonexistent', userId);

        expect(result, isEmpty);
      });

      test('stops traversal when parent is not found in subcollection',
          () async {
        // Leaf with a parentCategoryId that does not exist in the subcollection.
        final ref = await categoriesRef().add({
          'userId': userId,
          'name': 'Leaf',
          'iconIdentifier': 'icon',
          'isGlobal': false,
          'isSelectableAsActivity': true,
          'parentCategoryId': 'ghost-parent-id',
          'createdAt': Timestamp.now(),
        });

        final result = await repository.getAncestorIds(ref.id, userId);

        // Traversal stops at leaf because parent document is not found.
        expect(result, equals([ref.id]));
      });

      test('returns at most 3 IDs (max depth guard)', () async {
        final a = await seedRootCategory(name: 'A');
        final b = await seedSubCategory(a, name: 'B');
        // Manually create a depth-3 entry to exercise the loop guard.
        final ref = await categoriesRef().add({
          'userId': userId,
          'name': 'C',
          'iconIdentifier': 'icon',
          'isGlobal': false,
          'isSelectableAsActivity': true,
          'parentCategoryId': b,
          'createdAt': Timestamp.now(),
        });

        final result = await repository.getAncestorIds(ref.id, userId);

        expect(result.length, lessThanOrEqualTo(3));
      });
    });

    group('createSelectableCategory', () {
      test(
          'happy path: creates document and returns category with correct fields',
          () async {
        final category = await repository.createSelectableCategory(
          name: 'Climbing',
          userId: userId,
        );

        expect(category.name, equals('Climbing'));
        expect(category.isSelectableAsActivity, isTrue);
        expect(category.isGlobal, isFalse);
        expect(category.id, isNotEmpty);
        expect(category.userId, equals(userId));

        // Also verify the document was written to Firestore.
        final snapshot =
            await categoriesRef().where('name', isEqualTo: 'Climbing').get();
        expect(snapshot.docs.length, equals(1));
      });
    });
  });
}
