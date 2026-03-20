import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friend_group.dart';

void main() {
  final DateTime testDate = DateTime(2026, 3, 1);

  final FriendGroup baseGroup = FriendGroup(
    id: 'group-1',
    name: 'Hiking Crew',
    iconIdentifier: 'hiking',
    personIds: ['p1', 'p2'],
    createdAt: testDate,
  );

  group('FriendGroup model', () {
    group('copyWith', () {
      test('updates specified fields and preserves others', () {
        final byName = baseGroup.copyWith(name: 'Climbing Crew');
        expect(byName.name, 'Climbing Crew');
        expect(byName.id, 'group-1');
        expect(byName.iconIdentifier, 'hiking');
        expect(byName.personIds, ['p1', 'p2']);

        final byPersonIds = baseGroup.copyWith(personIds: ['p3']);
        expect(byPersonIds.personIds, ['p3']);
        expect(byPersonIds.name, 'Hiking Crew');

        // Nullable field can be cleared to null.
        final withoutIcon = baseGroup.copyWith(iconIdentifier: null);
        expect(withoutIcon.iconIdentifier, isNull);
      });
    });

    group('equality', () {
      test('equal when same fields, not equal when id differs', () {
        final other = FriendGroup(
          id: 'group-1',
          name: 'Hiking Crew',
          iconIdentifier: 'hiking',
          personIds: ['p1', 'p2'],
          createdAt: testDate,
        );
        expect(baseGroup, equals(other));
        expect(baseGroup, isNot(equals(baseGroup.copyWith(id: 'group-99'))));
      });
    });

    group('toJson / fromJson round-trip', () {
      test('preserves all fields including null iconIdentifier', () {
        // With icon.
        expect(FriendGroup.fromJson(baseGroup.toJson()), equals(baseGroup));

        // With null icon and empty personIds.
        final noIcon = FriendGroup(
          id: 'g2',
          name: 'No Icon Group',
          personIds: [],
          createdAt: testDate,
        );
        final restored = FriendGroup.fromJson(noIcon.toJson());
        expect(restored.iconIdentifier, isNull);
        expect(restored.personIds, isEmpty);
      });
    });

    group('fromFirestore', () {
      late FakeFirebaseFirestore fakeFirestore;

      setUp(() {
        fakeFirestore = FakeFirebaseFirestore();
      });

      // Seeds a document and returns its snapshot.
      Future<DocumentSnapshot> seedDoc(Map<String, dynamic> data) async {
        final ref = await fakeFirestore
            .collection('users')
            .doc('u1')
            .collection('friend_groups')
            .add(data);
        return ref.get();
      }

      test('happy path: deserializes all fields correctly', () async {
        final ref = fakeFirestore
            .collection('users')
            .doc('u1')
            .collection('friend_groups')
            .doc('fixed-id');
        await ref.set({
          'name': 'Friends',
          'iconIdentifier': 'coffee',
          'personIds': ['p1'],
          'createdAt': Timestamp.fromDate(testDate),
        });
        final doc = await ref.get();
        final group = FriendGroup.fromFirestore(doc);

        expect(group.id, 'fixed-id');
        expect(group.name, 'Friends');
        expect(group.iconIdentifier, 'coffee');
        expect(group.personIds, ['p1']);
        expect(group.createdAt, testDate);
      });

      test('defaults personIds to empty and accepts null iconIdentifier',
          () async {
        final doc = await seedDoc({
          'name': 'Empty Group',
          'iconIdentifier': null,
        });
        final group = FriendGroup.fromFirestore(doc);
        expect(group.personIds, isEmpty);
        expect(group.iconIdentifier, isNull);
      });

      test('leaves createdAt null when field absent', () async {
        final doc = await seedDoc({'name': 'Undated', 'personIds': []});
        final group = FriendGroup.fromFirestore(doc);
        expect(group.createdAt, isNull);
      });
    });
  });
}
