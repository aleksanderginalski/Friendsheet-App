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
      test('returns true for valid person with lastName', () {
        expect(personWithLastName.isValid(), true);
      });

      test('returns true for valid person without lastName', () {
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
      test('toJson and fromJson round-trip with lastName', () {
        final json = personWithLastName.toJson();
        final restored = Person.fromJson(json);
        expect(restored, equals(personWithLastName));
      });

      test('toJson and fromJson round-trip without lastName', () {
        final json = personWithoutLastName.toJson();
        final restored = Person.fromJson(json);
        expect(restored, equals(personWithoutLastName));
      });
    });

    group('toFirestore()', () {
      test('does not include lastName key when null', () {
        final map = personWithoutLastName.toFirestore();
        expect(map.containsKey('lastName'), false);
      });

      test('includes lastName when provided', () {
        final map = personWithLastName.toFirestore();
        expect(map['lastName'], 'Smith');
      });

      test('includes all required fields', () {
        final map = personWithLastName.toFirestore();
        expect(map.containsKey('userId'), true);
        expect(map.containsKey('firstName'), true);
        expect(map.containsKey('createdAt'), true);
      });
    });
  });
}
