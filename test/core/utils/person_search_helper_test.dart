import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/core/utils/person_search_helper.dart';
import 'package:friendsheet/data/models/person.dart';

void main() {
  final testDate = DateTime(2026, 1, 1);

  Person makePerson({
    String firstName = 'Anna',
    String? lastName,
    List<String> nicknames = const [],
  }) {
    return Person(
      id: 'p1',
      userId: 'u1',
      firstName: firstName,
      lastName: lastName,
      createdAt: testDate,
      nicknames: nicknames,
    );
  }

  group('PersonSearchHelper.matches', () {
    test('matches by firstName (exact)', () {
      expect(PersonSearchHelper.matches(makePerson(firstName: 'Anna'), 'Anna'),
          isTrue);
    });

    test('matches by firstName (partial, case-insensitive)', () {
      expect(PersonSearchHelper.matches(makePerson(firstName: 'Anna'), 'ann'),
          isTrue);
    });

    test('matches by lastName', () {
      expect(
        PersonSearchHelper.matches(makePerson(lastName: 'Smith'), 'Smith'),
        isTrue,
      );
    });

    test('matches by lastName (partial, case-insensitive)', () {
      expect(
        PersonSearchHelper.matches(makePerson(lastName: 'Smith'), 'smi'),
        isTrue,
      );
    });

    test('matches by nickname (exact)', () {
      expect(
        PersonSearchHelper.matches(makePerson(nicknames: ['Gosia']), 'Gosia'),
        isTrue,
      );
    });

    test('matches by nickname (partial, case-insensitive)', () {
      expect(
        PersonSearchHelper.matches(
            makePerson(nicknames: ['Gosia', 'Anka']), 'gos'),
        isTrue,
      );
    });

    test('returns false when query matches nothing', () {
      expect(
        PersonSearchHelper.matches(
          makePerson(firstName: 'Anna', lastName: 'Smith', nicknames: ['Ania']),
          'zzz',
        ),
        isFalse,
      );
    });

    test('returns false for empty query', () {
      expect(PersonSearchHelper.matches(makePerson(), ''), isFalse);
    });

    test('returns false for whitespace-only query', () {
      expect(PersonSearchHelper.matches(makePerson(), '   '), isFalse);
    });

    test('returns false when lastName is null and query would match', () {
      // lastName is null — should not throw, should return false for that field
      final person = makePerson(firstName: 'Anna', lastName: null);
      expect(PersonSearchHelper.matches(person, 'smith'), isFalse);
    });

    test('matches cross-field full name (firstName prefix + lastName prefix)',
        () {
      final person =
          makePerson(firstName: 'Aleksander', lastName: 'Ginalski');
      expect(PersonSearchHelper.matches(person, 'Aleksander G'), isTrue);
    });

    test('does not match reversed cross-field query (lastName first)', () {
      final person =
          makePerson(firstName: 'Aleksander', lastName: 'Ginalski');
      expect(PersonSearchHelper.matches(person, 'ski Alek'), isFalse);
    });

    test('matches cross-field full name case-insensitively', () {
      final person =
          makePerson(firstName: 'Aleksander', lastName: 'Ginalski');
      expect(PersonSearchHelper.matches(person, 'aleksander g'), isTrue);
    });
  });
}
