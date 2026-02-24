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

  // Returns the top-level collection used by the global library methods.
  CollectionReference globalLibraryRef() =>
      fakeFirestore.collection('activity_categories');

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

  // Seeds a category in the top-level collection (global library) and returns its ID.
  Future<String> seedGlobalLibraryCategory({
    required String name,
    required bool isSelectable,
    String? parentCategoryId,
    bool isGlobal = false,
    String? specificUserId,
  }) async {
    final data = <String, dynamic>{
      'userId': specificUserId ?? userId,
      'name': name,
      'iconIdentifier': 'icon',
      'isGlobal': isGlobal,
      'isSelectableAsActivity': isSelectable,
      'createdAt': Timestamp.now(),
    };
    if (parentCategoryId != null) {
      data['parentCategoryId'] = parentCategoryId;
    }
    final ref = await globalLibraryRef().add(data);
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

    group('getSelectableCategories', () {
      test('returns empty list when no categories exist', () async {
        final result = await repository.getSelectableCategories(userId);
        expect(result, isEmpty);
      });

      test('returns only selectable private categories for the user', () async {
        await seedGlobalLibraryCategory(name: 'Gory', isSelectable: true);
        await seedGlobalLibraryCategory(name: 'Sport', isSelectable: false);
        await seedGlobalLibraryCategory(
          name: 'OtherUser',
          isSelectable: true,
          specificUserId: 'other-user',
        );

        final result = await repository.getSelectableCategories(userId);

        expect(result.length, equals(1));
        expect(result.first.name, equals('Gory'));
      });

      test('excludes global categories (isGlobal: true)', () async {
        await seedGlobalLibraryCategory(
          name: 'Global',
          isSelectable: true,
          isGlobal: true,
        );
        await seedGlobalLibraryCategory(name: 'Private', isSelectable: true);

        final result = await repository.getSelectableCategories(userId);

        expect(result.length, equals(1));
        expect(result.first.name, equals('Private'));
      });

      test('returned items are ActivityCategory instances', () async {
        await seedGlobalLibraryCategory(name: 'Running', isSelectable: true);

        final result = await repository.getSelectableCategories(userId);

        expect(result.first, isA<ActivityCategory>());
        expect(result.first.isSelectableAsActivity, isTrue);
      });
    });

    group('getAncestorIds', () {
      test('returns only the category itself when it has no parent', () async {
        final rootId = await seedGlobalLibraryCategory(
          name: 'Sport',
          isSelectable: false,
        );

        final result = await repository.getAncestorIds(rootId, userId);

        expect(result, equals([rootId]));
      });

      test('returns leaf and parent IDs for depth-2 category', () async {
        final parentId = await seedGlobalLibraryCategory(
          name: 'Sport',
          isSelectable: false,
        );
        final leafId = await seedGlobalLibraryCategory(
          name: 'Running',
          isSelectable: true,
          parentCategoryId: parentId,
        );

        final result = await repository.getAncestorIds(leafId, userId);

        expect(result.length, equals(2));
        expect(result, containsAll([leafId, parentId]));
        expect(result.first, equals(leafId));
      });

      test('stops traversal when category belongs to different user', () async {
        final otherParentId = await seedGlobalLibraryCategory(
          name: 'OtherParent',
          isSelectable: false,
          specificUserId: 'other-user',
        );
        final leafId = await seedGlobalLibraryCategory(
          name: 'Leaf',
          isSelectable: true,
          parentCategoryId: otherParentId,
        );

        final result = await repository.getAncestorIds(leafId, userId);

        // Stops at leafId because its parent belongs to a different user.
        expect(result, equals([leafId]));
      });

      test('returns at most 3 IDs (max depth guard)', () async {
        final a = await seedGlobalLibraryCategory(
          name: 'A',
          isSelectable: false,
        );
        final b = await seedGlobalLibraryCategory(
          name: 'B',
          isSelectable: false,
          parentCategoryId: a,
        );
        final c = await seedGlobalLibraryCategory(
          name: 'C',
          isSelectable: true,
          parentCategoryId: b,
        );

        final result = await repository.getAncestorIds(c, userId);

        expect(result.length, lessThanOrEqualTo(3));
      });
    });
  });
}
