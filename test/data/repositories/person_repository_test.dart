import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/friend_group_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/services/hive_service.dart';
import 'package:hive/hive.dart';

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
      friendGroupRepository: FriendGroupRepository(firestore: fakeFirestore),
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

  // Helper: returns the persons subcollection reference for a given userId.
  CollectionReference<Map<String, dynamic>> personsRef(String userId) =>
      fakeFirestore.collection('users').doc(userId).collection('persons');

  // Helper: returns the meetings subcollection reference for a given userId.
  CollectionReference<Map<String, dynamic>> meetingsRef(String userId) =>
      fakeFirestore.collection('users').doc(userId).collection('meetings');

  group('PersonRepository', () {
    group('addPerson', () {
      test(
          'happy path: returns saved person with correct fields and stores in Firestore',
          () async {
        final person = makePerson(firstName: 'Maria', lastName: 'Nowak');
        final saved = await repository.addPerson(person);

        expect(saved.id, isNotEmpty);
        expect(saved.firstName, equals('Maria'));
        expect(saved.lastName, equals('Nowak'));

        final doc = await personsRef('user-1').doc(saved.id).get();
        expect(doc.exists, isTrue);
      });
    });

    group('getPersonsByUser', () {
      test('returns empty list when no persons exist', () async {
        final result = await repository.getPersonsByUser('user-1');
        expect(result, isEmpty);
      });

      test('returns all persons for given user, excluding other users',
          () async {
        await repository
            .addPerson(makePerson(userId: 'user-1', firstName: 'Anna'));
        await repository
            .addPerson(makePerson(userId: 'user-1', firstName: 'Bob'));
        await repository
            .addPerson(makePerson(userId: 'user-2', firstName: 'Other'));

        final result = await repository.getPersonsByUser('user-1');
        expect(result.length, equals(2));
        expect(result.every((p) => p.userId == 'user-1'), isTrue);
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
      test('persists updated firstName and lastName in Firestore', () async {
        final saved = await repository.addPerson(
          makePerson(firstName: 'Anna', lastName: 'Kowalska'),
        );
        final updated = saved.copyWith(firstName: 'Maria', lastName: 'Nowak');

        await repository.updatePerson(updated);

        final doc = await personsRef('user-1').doc(saved.id).get();
        expect(doc.data()?['firstName'], equals('Maria'));
        expect(doc.data()?['lastName'], equals('Nowak'));
      });
    });

    group('isDuplicateName', () {
      test('returns false when no persons exist', () async {
        final result =
            await repository.isDuplicateName('user-1', 'Anna', 'Kowalska');
        expect(result, isFalse);
      });

      test('returns true for exact match', () async {
        await repository
            .addPerson(makePerson(firstName: 'Anna', lastName: 'Kowalska'));

        final result =
            await repository.isDuplicateName('user-1', 'Anna', 'Kowalska');
        expect(result, isTrue);
      });

      test('returns true for case-insensitive match', () async {
        await repository
            .addPerson(makePerson(firstName: 'Anna', lastName: 'Kowalska'));

        final result =
            await repository.isDuplicateName('user-1', 'anna', 'kowalska');
        expect(result, isTrue);
      });

      test('returns false when excludeId matches the only duplicate', () async {
        final saved = await repository
            .addPerson(makePerson(firstName: 'Anna', lastName: 'Kowalska'));

        final result = await repository.isDuplicateName(
          'user-1',
          'Anna',
          'Kowalska',
          excludeId: saved.id,
        );
        expect(result, isFalse);
      });

      test('returns false when lastName differs', () async {
        await repository
            .addPerson(makePerson(firstName: 'Anna', lastName: 'Kowalska'));

        final result =
            await repository.isDuplicateName('user-1', 'Anna', 'Nowak');
        expect(result, isFalse);
      });
    });

    group('deletePerson', () {
      test('removes document from Firestore', () async {
        final saved = await repository.addPerson(makePerson());

        await repository.deletePerson('user-1', saved.id);

        final doc = await personsRef('user-1').doc(saved.id).get();
        expect(doc.exists, isFalse);
      });

      test('other persons are not affected by delete', () async {
        final saved1 =
            await repository.addPerson(makePerson(firstName: 'Anna'));
        final saved2 = await repository.addPerson(makePerson(firstName: 'Bob'));

        await repository.deletePerson('user-1', saved1.id);

        final doc = await personsRef('user-1').doc(saved2.id).get();
        expect(doc.exists, isTrue);
      });

      test('removes personId from participantIds in associated meetings',
          () async {
        final saved = await repository.addPerson(makePerson());

        // Create a meeting in the user's subcollection that includes the person
        await meetingsRef('user-1').add({
          'userId': 'user-1',
          'name': 'Test Meeting',
          'date': DateTime(2026, 1, 1),
          'weight': 3,
          'participantIds': [saved.id],
          'createdAt': DateTime(2026, 1, 1),
          'updatedAt': DateTime(2026, 1, 1),
        });

        await repository.deletePerson('user-1', saved.id);

        final meetings = await meetingsRef('user-1').get();
        expect(meetings.docs.first['participantIds'], isEmpty);
      });
    });

    group('linkPartner', () {
      late Directory hiveDir;

      setUp(() async {
        hiveDir = await Directory.systemTemp.createTemp('hive_person_link_');
        await HiveService.initialize(testPath: hiveDir.path);
      });

      tearDown(() async {
        await Hive.close();
        await hiveDir.delete(recursive: true);
      });

      test('sets cross-referenced partnerId on both persons in Firestore',
          () async {
        final a =
            await repository.addPerson(makePerson(id: 'a', firstName: 'Anna'));
        final b =
            await repository.addPerson(makePerson(id: 'b', firstName: 'Bob'));

        await repository.linkPartner('user-1', a.id, b.id);

        final docA = await personsRef('user-1').doc(a.id).get();
        final docB = await personsRef('user-1').doc(b.id).get();
        expect(docA.data()?['partnerId'], equals(b.id));
        expect(docB.data()?['partnerId'], equals(a.id));
      });

      test('sets partnerLinkedAt on both persons in Firestore', () async {
        final a =
            await repository.addPerson(makePerson(id: 'a', firstName: 'Anna'));
        final b =
            await repository.addPerson(makePerson(id: 'b', firstName: 'Bob'));

        await repository.linkPartner('user-1', a.id, b.id);

        final docA = await personsRef('user-1').doc(a.id).get();
        final docB = await personsRef('user-1').doc(b.id).get();
        expect(docA.data()?['partnerLinkedAt'], isNotNull);
        expect(docB.data()?['partnerLinkedAt'], isNotNull);
      });
    });
  });
}
