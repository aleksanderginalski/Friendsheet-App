import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PersonRepository repository;
  late MeetingRepository meetingRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    meetingRepository = MeetingRepository(firestore: fakeFirestore);
    repository = PersonRepository(
      firestore: fakeFirestore,
      meetingRepository: meetingRepository,
    );
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

    group('updatePerson', () {
      test('updates firstName in Firestore document', () async {
        final saved = await repository.addPerson(makePerson(firstName: 'Anna'));
        final updated = saved.copyWith(firstName: 'Maria');

        await repository.updatePerson(updated);

        final doc =
            await fakeFirestore.collection('persons').doc(saved.id).get();
        expect(doc.data()?['firstName'], equals('Maria'));
      });

      test('updates lastName in Firestore document', () async {
        final saved =
            await repository.addPerson(makePerson(lastName: 'Kowalska'));
        final updated = saved.copyWith(lastName: 'Nowak');

        await repository.updatePerson(updated);

        final doc =
            await fakeFirestore.collection('persons').doc(saved.id).get();
        expect(doc.data()?['lastName'], equals('Nowak'));
      });
    });

    group('deletePerson', () {
      test('removes document from Firestore', () async {
        final saved = await repository.addPerson(makePerson());

        await repository.deletePerson('user-1', saved.id);

        final doc =
            await fakeFirestore.collection('persons').doc(saved.id).get();
        expect(doc.exists, isFalse);
      });

      test('other persons are not affected by delete', () async {
        final saved1 =
            await repository.addPerson(makePerson(firstName: 'Anna'));
        final saved2 = await repository.addPerson(makePerson(firstName: 'Bob'));

        await repository.deletePerson('user-1', saved1.id);

        final doc =
            await fakeFirestore.collection('persons').doc(saved2.id).get();
        expect(doc.exists, isTrue);
      });

      test('removes personId from participantIds in associated meetings',
          () async {
        final saved = await repository.addPerson(makePerson());

        // Create a meeting that includes the person as a participant
        await fakeFirestore.collection('meetings').add({
          'userId': 'user-1',
          'name': 'Test Meeting',
          'date': DateTime(2026, 1, 1),
          'weight': 3,
          'participantIds': [saved.id],
          'activityIds': <String>[],
          'createdAt': DateTime(2026, 1, 1),
          'updatedAt': DateTime(2026, 1, 1),
        });

        await repository.deletePerson('user-1', saved.id);

        final meetings = await fakeFirestore
            .collection('meetings')
            .where('userId', isEqualTo: 'user-1')
            .get();
        expect(meetings.docs.first['participantIds'], isEmpty);
      });
    });
  });
}
