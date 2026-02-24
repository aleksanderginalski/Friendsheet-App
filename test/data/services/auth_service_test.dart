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

  // Seeds a global category in the top-level activity_categories collection.
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

  // Seeds a private user category (simulates already-copied state).
  Future<void> seedUserCategory(String uid) async {
    await fakeFirestore.collection('activity_categories').add({
      'userId': uid,
      'name': 'Existing',
      'iconIdentifier': 'icon',
      'isGlobal': false,
      'isSelectableAsActivity': false,
      'createdAt': Timestamp.now(),
    });
  }

  group('AuthService._copyGlobalCategoriesToUser (guard logic)', () {
    test('copies global categories when user has none', () async {
      await seedGlobalCategory(name: 'Sport');
      await seedGlobalCategory(name: 'Art');

      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await fakeFirestore
          .collection('activity_categories')
          .where('isGlobal', isEqualTo: false)
          .where('userId', isEqualTo: userId)
          .get();

      expect(snapshot.docs.length, equals(2));
    });

    test('returns early without writing when user already has categories',
        () async {
      await seedGlobalCategory(name: 'Sport');
      await seedUserCategory(userId);

      await authService.copyGlobalCategoriesToUserForTest(userId);

      // Only the pre-existing category should be present, not a new copy.
      final snapshot = await fakeFirestore
          .collection('activity_categories')
          .where('isGlobal', isEqualTo: false)
          .where('userId', isEqualTo: userId)
          .get();

      expect(snapshot.docs.length, equals(1));
      expect(snapshot.docs.first['name'], equals('Existing'));
    });

    test('does nothing when there are no global categories', () async {
      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await fakeFirestore
          .collection('activity_categories')
          .where('isGlobal', isEqualTo: false)
          .where('userId', isEqualTo: userId)
          .get();

      expect(snapshot.docs, isEmpty);
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

      final snapshot = await fakeFirestore
          .collection('activity_categories')
          .where('isGlobal', isEqualTo: false)
          .where('userId', isEqualTo: userId)
          .get();

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
      final parentDoc = await fakeFirestore
          .collection('activity_categories')
          .doc(childParentId)
          .get();
      expect(parentDoc.exists, isTrue);
      expect(
          (parentDoc.data() as Map<String, dynamic>)['name'], equals('Sport'));
      expect((parentDoc.data() as Map<String, dynamic>)['isGlobal'], isFalse);
    });

    test('sets isGlobal to false on all copied categories', () async {
      await seedGlobalCategory(name: 'Sport');

      await authService.copyGlobalCategoriesToUserForTest(userId);

      final snapshot = await fakeFirestore
          .collection('activity_categories')
          .where('userId', isEqualTo: userId)
          .get();

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

      final snapshot = await fakeFirestore
          .collection('activity_categories')
          .where('userId', isEqualTo: userId)
          .get();

      expect(snapshot.docs.length, equals(1));
      expect(
        (snapshot.docs.first.data())['copiedFromId'],
        equals(globalRef.id),
      );
    });
  });
}
