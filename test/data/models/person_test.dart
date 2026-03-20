import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';

void main() {
  group('Person Model', () {
    final DateTime testDate = DateTime(2026, 2, 18);

    final Person personWithLastName = Person(
      id: 'person-1',
      userId: 'user-123',
      firstName: 'Anna',
      lastName: 'Smith',
      createdAt: testDate,
    );

    final Person personWithoutLastName = Person(
      id: 'person-2',
      userId: 'user-123',
      firstName: 'Anna',
      createdAt: testDate,
    );

    group('fullName getter', () {
      test('returns firstName and lastName when both provided', () {
        expect(personWithLastName.fullName, 'Anna Smith');
      });

      test('returns only firstName when lastName is null', () {
        expect(personWithoutLastName.fullName, 'Anna');
      });

      test('returns only firstName when lastName is empty string', () {
        final person = Person(
          id: 'person-3',
          userId: 'user-123',
          firstName: 'Anna',
          lastName: '',
          createdAt: testDate,
        );
        expect(person.fullName, 'Anna');
      });
    });

    group('isValid()', () {
      test('returns true for valid person', () {
        expect(personWithoutLastName.isValid(), true);
      });

      test('returns false when firstName is empty', () {
        final person = Person(
          id: 'person-4',
          userId: 'user-123',
          firstName: '',
          createdAt: testDate,
        );
        expect(person.isValid(), false);
      });

      test('returns false when userId is empty', () {
        final person = Person(
          id: 'person-5',
          userId: '',
          firstName: 'Anna',
          createdAt: testDate,
        );
        expect(person.isValid(), false);
      });
    });

    group('Equality', () {
      test('two persons with same data are equal', () {
        final person1 = Person(
          id: 'person-1',
          userId: 'user-123',
          firstName: 'Anna',
          lastName: 'Smith',
          createdAt: testDate,
        );
        final person2 = Person(
          id: 'person-1',
          userId: 'user-123',
          firstName: 'Anna',
          lastName: 'Smith',
          createdAt: testDate,
        );
        expect(person1, equals(person2));
      });

      test('two persons with different id are not equal', () {
        final person2 = personWithLastName.copyWith(id: 'person-999');
        expect(personWithLastName, isNot(equals(person2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated firstName', () {
        final updated = personWithLastName.copyWith(firstName: 'Jane');
        expect(updated.firstName, 'Jane');
        expect(updated.lastName, 'Smith');
        expect(updated.id, 'person-1');
      });

      test('creates copy with removed lastName', () {
        final updated = personWithLastName.copyWith(lastName: null);
        expect(updated.lastName, null);
        expect(updated.fullName, 'Anna');
      });
    });

    group('JSON serialization', () {
      test('round-trip preserves all fields', () {
        final person = Person(
          id: 'person-1',
          userId: 'user-123',
          firstName: 'Anna',
          lastName: 'Smith',
          createdAt: testDate,
          nicknames: ['Ania'],
        );
        final restored = Person.fromJson(person.toJson());
        expect(restored, equals(person));
      });
    });

    group('toFirestore()', () {
      test('happy path includes all fields', () {
        final map = personWithLastName.toFirestore();
        expect(map['userId'], 'user-123');
        expect(map['firstName'], 'Anna');
        expect(map['lastName'], 'Smith');
        expect(map.containsKey('createdAt'), true);
        expect(map['nicknames'], <String>[]);
      });

      test('does not include lastName key when null', () {
        final map = personWithoutLastName.toFirestore();
        expect(map.containsKey('lastName'), false);
      });

      test('includes nicknames when present', () {
        final person = Person(
          id: 'p1',
          userId: 'u1',
          firstName: 'Anna',
          createdAt: testDate,
          nicknames: ['Ania', 'Anka'],
        );
        final map = person.toFirestore();
        expect(map['nicknames'], ['Ania', 'Anka']);
      });

      test('includes linkedUserId when set', () {
        final person = Person(
          id: 'p1',
          userId: 'u1',
          firstName: 'Anna',
          createdAt: testDate,
          linkedUserId: 'uid-friend-42',
        );
        final map = person.toFirestore();
        expect(map['linkedUserId'], 'uid-friend-42');
      });

      test('omits linkedUserId key when null', () {
        final map = personWithoutLastName.toFirestore();
        expect(map.containsKey('linkedUserId'), false);
      });
    });

    group('linkedUserId (fromFirestore)', () {
      late FakeFirebaseFirestore fakeFirestore;

      setUp(() {
        fakeFirestore = FakeFirebaseFirestore();
      });

      test('reads linkedUserId when present in document', () async {
        final ref = await fakeFirestore.collection('persons').add({
          'userId': 'u1',
          'firstName': 'Anna',
          'createdAt': Timestamp.fromDate(testDate),
          'nicknames': <String>[],
          'linkedUserId': 'uid-friend-42',
        });
        final doc = await ref.get();
        final person = Person.fromFirestore(doc);

        expect(person.linkedUserId, 'uid-friend-42');
      });

      test('linkedUserId is null when field absent from document', () async {
        final ref = await fakeFirestore.collection('persons').add({
          'userId': 'u1',
          'firstName': 'Anna',
          'createdAt': Timestamp.fromDate(testDate),
          'nicknames': <String>[],
        });
        final doc = await ref.get();
        final person = Person.fromFirestore(doc);

        expect(person.linkedUserId, isNull);
      });
    });
  });
}
