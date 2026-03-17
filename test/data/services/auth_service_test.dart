import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/auth_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AuthService authService;

  const userId = 'user-test-1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    authService = AuthService.withFirestore(fakeFirestore);
  });

  // Seeds a global category in the root activity_categories collection (source).
  Future<void> seedGlobalCategory({
    String name = 'Sport',
    String? parentCategoryId,
  }) async {
    final data = <String, dynamic>{
      'userId': '',
      'name': name,
      'iconIdentifier': 'icon',
      'isGlobal': true,
      'isSelectableAsActivity': true,
      'createdAt': Timestamp.now(),
    };
    if (parentCategoryId != null) {
      data['parentCategoryId'] = parentCategoryId;
    }
    await fakeFirestore.collection('activity_categories').add(data);
  }

  // Seeds onboardingCompletedAt on the user document to simulate second login.
  Future<void> seedOnboardingCompleted(String uid) async {
    await fakeFirestore.collection('users').doc(uid).set({
      'onboardingCompletedAt': Timestamp.now(),
    });
  }

  // Returns the user's private activity_categories subcollection reference.
  CollectionReference<Map<String, dynamic>> userCategoriesRef(String uid) =>
      fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('activity_categories');

  group('AuthService._copyGlobalCategoriesToUser (guard logic)', () {
    test('copies global categories when user has none', () async {
      await seedGlobalCategory(name: 'Sport');
      await seedGlobalCategory(name: 'Art');

      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await userCategoriesRef(userId).get();
      expect(snapshot.docs.length, equals(2));
    });

    test('skips batch-copy when onboardingCompletedAt is already set',
        () async {
      await seedGlobalCategory(name: 'Sport');
      await seedOnboardingCompleted(userId);

      await authService.copyGlobalCategoriesToUserForTest(userId);

      // Guard fired — no categories should have been copied.
      final snapshot = await userCategoriesRef(userId).get();
      expect(snapshot.docs, isEmpty);
    });

    test('does nothing when there are no global categories', () async {
      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await userCategoriesRef(userId).get();
      expect(snapshot.docs, isEmpty);
    });

    test('writes onboardingCompletedAt to users/{uid} after first batch-copy',
        () async {
      await seedGlobalCategory(name: 'Sport');

      await authService.copyGlobalCategoriesToUserForTest(userId);

      final userDoc = await fakeFirestore.collection('users').doc(userId).get();
      expect(userDoc.data()?['onboardingCompletedAt'], isNotNull);
      expect(userDoc.data()?['onboardingCompletedAt'], isA<Timestamp>());
    });

    test('does not run batch-copy on second login (onboardingCompletedAt set)',
        () async {
      await seedGlobalCategory(name: 'Sport');

      // First login — copies categories and writes the guard timestamp.
      await authService.copyGlobalCategoriesToUserForTest(userId);

      final countAfterFirst =
          (await userCategoriesRef(userId).get()).docs.length;

      // Second login — guard fires, no additional copies.
      await authService.copyGlobalCategoriesToUserForTest(userId);

      final countAfterSecond =
          (await userCategoriesRef(userId).get()).docs.length;

      expect(countAfterFirst, equals(1));
      expect(countAfterSecond, equals(1));
    });

    test(
        'skips batch-copy when user already has categories in subcollection '
        '(no onboardingCompletedAt set)', () async {
      await seedGlobalCategory(name: 'Sport');

      // Pre-populate the user's subcollection directly — simulates a user who
      // has categories but whose onboardingCompletedAt field is absent.
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('activity_categories')
          .add({
        'userId': userId,
        'name': 'ExistingCategory',
        'iconIdentifier': 'icon',
        'isGlobal': false,
        'isSelectableAsActivity': true,
        'createdAt': Timestamp.now(),
      });

      await authService.copyGlobalCategoriesToUserForTest(userId);

      // Subcollection guard fired — count must remain 1 (the seeded doc).
      final snapshot = await userCategoriesRef(userId).get();
      expect(snapshot.docs.length, equals(1));
    });

    test('remaps parentCategoryId to new user copy IDs', () async {
      final parentRef =
          await fakeFirestore.collection('activity_categories').add({
        'userId': '',
        'name': 'Sport',
        'iconIdentifier': 'icon',
        'isGlobal': true,
        'isSelectableAsActivity': false,
        'createdAt': Timestamp.now(),
      });
      await fakeFirestore.collection('activity_categories').add({
        'userId': '',
        'name': 'Running',
        'iconIdentifier': 'icon',
        'isGlobal': true,
        'isSelectableAsActivity': true,
        'parentCategoryId': parentRef.id,
        'createdAt': Timestamp.now(),
      });

      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await userCategoriesRef(userId).get();

      // Find the child copy (Running) and verify its parentCategoryId points
      // to the user copy of Sport, not the global Sport doc ID.
      final childDoc = snapshot.docs.firstWhere(
        (d) => (d.data())['name'] == 'Running',
      );
      final childParentId = (childDoc.data())['parentCategoryId'] as String?;

      // The parentCategoryId must not be the original global parent ID.
      expect(childParentId, isNotNull);
      expect(childParentId, isNot(equals(parentRef.id)));

      // The parentCategoryId must point to another user copy (Sport).
      final parentDoc =
          await userCategoriesRef(userId).doc(childParentId).get();
      expect(parentDoc.exists, isTrue);
      expect(
          (parentDoc.data() as Map<String, dynamic>)['name'], equals('Sport'));
      expect((parentDoc.data() as Map<String, dynamic>)['isGlobal'], isFalse);
    });

    test('sets isGlobal to false on all copied categories', () async {
      await seedGlobalCategory(name: 'Sport');

      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await userCategoriesRef(userId).get();
      for (final doc in snapshot.docs) {
        expect((doc.data())['isGlobal'], isFalse);
      }
    });

    test('sets copiedFromId to original global document ID', () async {
      final globalRef =
          await fakeFirestore.collection('activity_categories').add({
        'userId': '',
        'name': 'Sport',
        'iconIdentifier': 'icon',
        'isGlobal': true,
        'isSelectableAsActivity': false,
        'createdAt': Timestamp.now(),
      });

      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await userCategoriesRef(userId).get();
      expect(snapshot.docs.length, equals(1));
      expect(
        (snapshot.docs.first.data())['copiedFromId'],
        equals(globalRef.id),
      );
    });
  });
}
