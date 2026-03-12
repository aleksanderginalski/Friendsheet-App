import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friend_group.dart';
import 'package:friendsheet/data/repositories/friend_group_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FriendGroupRepository repository;

  const userId = 'user-1';

  CollectionReference groupsRef() =>
      fakeFirestore.collection('users').doc(userId).collection('friend_groups');

  // Seeds a group directly in Firestore and returns its generated ID.
  Future<String> seedGroup({
    String name = 'Test Group',
    String? iconIdentifier,
    List<String> personIds = const [],
  }) async {
    final ref = await groupsRef().add({
      'name': name,
      'iconIdentifier': iconIdentifier,
      'personIds': personIds,
      'createdAt': Timestamp.now(),
    });
    return ref.id;
  }

  FriendGroup makeGroup({
    String id = '',
    String name = 'New Group',
    String? iconIdentifier,
    List<String> personIds = const [],
  }) {
    return FriendGroup(
      id: id,
      name: name,
      iconIdentifier: iconIdentifier,
      personIds: personIds,
      createdAt: DateTime(2026, 3, 1),
    );
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FriendGroupRepository(firestore: fakeFirestore);
  });

  group('FriendGroupRepository', () {
    group('getGroupsByUser', () {
      test('returns empty list when no groups exist', () async {
        final result = await repository.getGroupsByUser(userId);
        expect(result, isEmpty);
      });

      test('returns group after add', () async {
        await repository.addGroup(userId, makeGroup(name: 'Climbers'));
        final result = await repository.getGroupsByUser(userId);
        expect(result.length, equals(1));
        expect(result.first.name, equals('Climbers'));
      });

      test('returns multiple groups', () async {
        await repository.addGroup(userId, makeGroup(name: 'A'));
        await repository.addGroup(userId, makeGroup(name: 'B'));
        final result = await repository.getGroupsByUser(userId);
        expect(result.length, equals(2));
      });
    });

    group('addGroup', () {
      test('stores document in correct Firestore path', () async {
        await repository.addGroup(userId, makeGroup(name: 'Runners'));
        final snapshot = await groupsRef().get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first['name'], equals('Runners'));
      });

      test('stores iconIdentifier in document', () async {
        await repository.addGroup(
            userId, makeGroup(name: 'G', iconIdentifier: 'coffee'));
        final snapshot = await groupsRef().get();
        expect(snapshot.docs.first['iconIdentifier'], equals('coffee'));
      });
    });

    group('updateGroup', () {
      test('persists updated name in Firestore', () async {
        final id = await seedGroup(name: 'Old Name');
        final updated = makeGroup(id: id, name: 'New Name');
        await repository.updateGroup(userId, updated);

        final doc = await groupsRef().doc(id).get();
        expect(
            (doc.data() as Map<String, dynamic>)['name'], equals('New Name'));
      });

      test('persists updated iconIdentifier in Firestore', () async {
        final id = await seedGroup(iconIdentifier: 'sport');
        final updated = makeGroup(id: id, iconIdentifier: 'music');
        await repository.updateGroup(userId, updated);

        final doc = await groupsRef().doc(id).get();
        expect((doc.data() as Map<String, dynamic>)['iconIdentifier'],
            equals('music'));
      });
    });

    group('deleteGroup', () {
      test('removes group document from Firestore', () async {
        final id = await seedGroup(name: 'ToDelete');
        await repository.deleteGroup(userId, id);

        final doc = await groupsRef().doc(id).get();
        expect(doc.exists, isFalse);
      });

      test('does not affect other group documents', () async {
        final keepId = await seedGroup(name: 'Keep');
        final deleteId = await seedGroup(name: 'Delete');
        await repository.deleteGroup(userId, deleteId);

        final doc = await groupsRef().doc(keepId).get();
        expect(doc.exists, isTrue);
      });
    });

    group('addPersonToGroup', () {
      test('adds personId to personIds array', () async {
        final id = await seedGroup(personIds: []);
        await repository.addPersonToGroup(userId, id, 'person-1');

        final doc = await groupsRef().doc(id).get();
        final ids = ((doc.data() as Map<String, dynamic>)['personIds'] as List)
            .cast<String>();
        expect(ids, contains('person-1'));
      });

      test('calling twice does not duplicate personId (idempotent)', () async {
        final id = await seedGroup(personIds: []);
        await repository.addPersonToGroup(userId, id, 'person-1');
        await repository.addPersonToGroup(userId, id, 'person-1');

        final doc = await groupsRef().doc(id).get();
        final ids = ((doc.data() as Map<String, dynamic>)['personIds'] as List)
            .cast<String>();
        expect(ids.where((e) => e == 'person-1').length, equals(1));
      });
    });

    group('removePersonFromGroup', () {
      test('removes personId from personIds array', () async {
        final id = await seedGroup(personIds: ['p1', 'p2']);
        await repository.removePersonFromGroup(userId, id, 'p1');

        final doc = await groupsRef().doc(id).get();
        final ids = ((doc.data() as Map<String, dynamic>)['personIds'] as List)
            .cast<String>();
        expect(ids, isNot(contains('p1')));
        expect(ids, contains('p2'));
      });
    });

    group('removePersonFromAllGroups', () {
      test('removes personId from all groups that contain it', () async {
        final id1 = await seedGroup(name: 'G1', personIds: ['p1', 'p2']);
        final id2 = await seedGroup(name: 'G2', personIds: ['p1', 'p3']);
        final id3 = await seedGroup(name: 'G3', personIds: ['p2']);

        await repository.removePersonFromAllGroups(userId, 'p1');

        final doc1 = await groupsRef().doc(id1).get();
        final doc2 = await groupsRef().doc(id2).get();
        final doc3 = await groupsRef().doc(id3).get();

        final ids1 =
            ((doc1.data() as Map<String, dynamic>)['personIds'] as List)
                .cast<String>();
        final ids2 =
            ((doc2.data() as Map<String, dynamic>)['personIds'] as List)
                .cast<String>();
        final ids3 =
            ((doc3.data() as Map<String, dynamic>)['personIds'] as List)
                .cast<String>();

        expect(ids1, isNot(contains('p1')));
        expect(ids2, isNot(contains('p1')));
        // Group 3 did not contain p1 — unaffected.
        expect(ids3, equals(['p2']));
      });

      test('no-op when no group contains personId', () async {
        final id = await seedGroup(personIds: ['p2']);
        await expectLater(
          repository.removePersonFromAllGroups(userId, 'p-absent'),
          completes,
        );
        final doc = await groupsRef().doc(id).get();
        final ids = ((doc.data() as Map<String, dynamic>)['personIds'] as List)
            .cast<String>();
        expect(ids, equals(['p2']));
      });
    });
  });
}
