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
      test('replaces name and preserves other fields', () {
        final updated = baseGroup.copyWith(name: 'Climbing Crew');
        expect(updated.name, 'Climbing Crew');
        expect(updated.id, 'group-1');
        expect(updated.iconIdentifier, 'hiking');
        expect(updated.personIds, ['p1', 'p2']);
      });

      test('replaces personIds list', () {
        final updated = baseGroup.copyWith(personIds: ['p3']);
        expect(updated.personIds, ['p3']);
        expect(updated.name, 'Hiking Crew');
      });

      test('clears iconIdentifier to null', () {
        final updated = baseGroup.copyWith(iconIdentifier: null);
        expect(updated.iconIdentifier, isNull);
      });
    });

    group('equality', () {
      test('two instances with same fields are equal', () {
        final a = FriendGroup(
          id: 'group-1',
          name: 'Hiking Crew',
          iconIdentifier: 'hiking',
          personIds: ['p1', 'p2'],
          createdAt: testDate,
        );
        final b = FriendGroup(
          id: 'group-1',
          name: 'Hiking Crew',
          iconIdentifier: 'hiking',
          personIds: ['p1', 'p2'],
          createdAt: testDate,
        );
        expect(a, equals(b));
      });

      test('different id produces not-equal instances', () {
        final other = baseGroup.copyWith(id: 'group-99');
        expect(baseGroup, isNot(equals(other)));
      });
    });

    group('toJson / fromJson round-trip', () {
      test('preserves all fields including iconIdentifier', () {
        final json = baseGroup.toJson();
        final restored = FriendGroup.fromJson(json);
        expect(restored, equals(baseGroup));
      });

      test('round-trip with null iconIdentifier', () {
        final group = FriendGroup(
          id: 'g2',
          name: 'No Icon Group',
          personIds: [],
          createdAt: testDate,
        );
        final restored = FriendGroup.fromJson(group.toJson());
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

      test('maps name and iconIdentifier correctly', () async {
        final doc = await seedDoc({
          'name': 'Friends',
          'iconIdentifier': 'coffee',
          'personIds': ['p1'],
          'createdAt': Timestamp.fromDate(testDate),
        });
        final group = FriendGroup.fromFirestore(doc);
        expect(group.name, 'Friends');
        expect(group.iconIdentifier, 'coffee');
      });

      test('defaults personIds to empty list when field absent', () async {
        final doc = await seedDoc({
          'name': 'Empty Group',
          'iconIdentifier': null,
        });
        final group = FriendGroup.fromFirestore(doc);
        expect(group.personIds, isEmpty);
      });

      test('maps null iconIdentifier correctly', () async {
        final doc = await seedDoc({
          'name': 'No Icon',
          'iconIdentifier': null,
          'personIds': [],
        });
        final group = FriendGroup.fromFirestore(doc);
        expect(group.iconIdentifier, isNull);
      });

      test('uses document ID as group id', () async {
        final ref = fakeFirestore
            .collection('users')
            .doc('u1')
            .collection('friend_groups')
            .doc('fixed-id');
        await ref.set({'name': 'Fixed', 'personIds': []});
        final doc = await ref.get();
        final group = FriendGroup.fromFirestore(doc);
        expect(group.id, 'fixed-id');
      });

      test('maps createdAt from Timestamp', () async {
        final doc = await seedDoc({
          'name': 'Dated',
          'personIds': [],
          'createdAt': Timestamp.fromDate(testDate),
        });
        final group = FriendGroup.fromFirestore(doc);
        expect(group.createdAt, testDate);
      });

      test('leaves createdAt null when field absent', () async {
        final doc = await seedDoc({'name': 'Undated', 'personIds': []});
        final group = FriendGroup.fromFirestore(doc);
        expect(group.createdAt, isNull);
      });
    });

    group('nullable iconIdentifier', () {
      test('accepts null iconIdentifier', () {
        const group = FriendGroup(id: 'g', name: 'G');
        expect(group.iconIdentifier, isNull);
      });

      test('accepts non-null iconIdentifier', () {
        const group = FriendGroup(id: 'g', name: 'G', iconIdentifier: 'sport');
        expect(group.iconIdentifier, 'sport');
      });
    });
  });
}
