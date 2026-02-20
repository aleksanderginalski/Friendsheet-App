import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PersonRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = PersonRepository(firestore: fakeFirestore);
  });

  // Helper: creates a valid Person for tests
  Person makePerson({
    String id = 'test-id',
    String userId = 'user-1',
    String firstName = 'Anna',
    String? lastName = 'Kowalska',
  }) {
    return Person(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime(2026, 2, 20),
    );
  }

  group('PersonRepository', () {
    group('addPerson', () {
      test('returns person with generated ID', () async {
        final person = makePerson();
        final saved = await repository.addPerson(person);
        expect(saved.id, isNotEmpty);
      });

      test('returned person has correct firstName', () async {
        final person = makePerson(firstName: 'Maria');
        final saved = await repository.addPerson(person);
        expect(saved.firstName, equals('Maria'));
      });

      test('returned person has correct lastName', () async {
        final person = makePerson(lastName: 'Nowak');
        final saved = await repository.addPerson(person);
        expect(saved.lastName, equals('Nowak'));
      });

      test('stores document in persons collection', () async {
        final person = makePerson();
        final saved = await repository.addPerson(person);

        final doc =
            await fakeFirestore.collection('persons').doc(saved.id).get();
        expect(doc.exists, isTrue);
      });
    });

    group('getPersonsByUser', () {
      test('returns empty list when no persons exist', () async {
        final result = await repository.getPersonsByUser('user-1');
        expect(result, isEmpty);
      });

      test('returns only persons belonging to given user', () async {
        await repository.addPerson(makePerson(userId: 'user-1'));
        await repository.addPerson(makePerson(userId: 'user-2'));

        final result = await repository.getPersonsByUser('user-1');
        expect(result.length, equals(1));
        expect(result.first.userId, equals('user-1'));
      });

      test('returns all persons for given user', () async {
        await repository.addPerson(makePerson(firstName: 'Anna'));
        await repository.addPerson(makePerson(firstName: 'Bob'));

        final result = await repository.getPersonsByUser('user-1');
        expect(result.length, equals(2));
      });

      test('returns persons sorted alphabetically by firstName', () async {
        await repository.addPerson(makePerson(firstName: 'Zofia'));
        await repository.addPerson(makePerson(firstName: 'Anna'));

        final result = await repository.getPersonsByUser('user-1');
        expect(result.first.firstName, equals('Anna'));
        expect(result.last.firstName, equals('Zofia'));
      });
    });
  });
}
