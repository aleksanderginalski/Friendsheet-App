import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MeetingRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = MeetingRepository(firestore: fakeFirestore);
  });

  // Helper: creates a valid Meeting for tests
  Meeting makeMeeting({
    String id = 'test-id',
    String userId = 'user-1',
    String name = 'Coffee with Anna',
    int weight = 3,
    List<String> participantIds = const ['person-1'],
  }) {
    final now = DateTime(2026, 2, 20);
    return Meeting(
      id: id,
      userId: userId,
      name: name,
      date: now,
      weight: weight,
      participantIds: participantIds,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Helper: returns the meetings subcollection reference for a given userId.
  CollectionReference<Map<String, dynamic>> meetingsRef(String userId) =>
      fakeFirestore.collection('users').doc(userId).collection('meetings');

  group('MeetingRepository', () {
    test('saveMeeting returns a non-empty document ID', () async {
      final meeting = makeMeeting();
      final id = await repository.saveMeeting(meeting);
      expect(id, isNotEmpty);
    });

    test('saveMeeting stores document in subcollection', () async {
      final meeting = makeMeeting(userId: 'user-1');
      final id = await repository.saveMeeting(meeting);

      final doc = await meetingsRef('user-1').doc(id).get();
      expect(doc.exists, isTrue);
    });

    test('saveMeeting stores correct userId', () async {
      final meeting = makeMeeting(userId: 'user-42');
      final id = await repository.saveMeeting(meeting);

      final doc = await meetingsRef('user-42').doc(id).get();
      expect(doc.data()?['userId'], equals('user-42'));
    });

    test('saveMeeting stores correct name', () async {
      final meeting = makeMeeting(name: 'Lunch with Bob');
      final id = await repository.saveMeeting(meeting);

      final doc = await meetingsRef('user-1').doc(id).get();
      expect(doc.data()?['name'], equals('Lunch with Bob'));
    });

    test('saveMeeting stores correct weight', () async {
      final meeting = makeMeeting(weight: 8);
      final id = await repository.saveMeeting(meeting);

      final doc = await meetingsRef('user-1').doc(id).get();
      expect(doc.data()?['weight'], equals(8));
    });

    test('saveMeeting stores correct participantIds', () async {
      final meeting = makeMeeting(participantIds: ['p-1', 'p-2']);
      final id = await repository.saveMeeting(meeting);

      final doc = await meetingsRef('user-1').doc(id).get();
      expect(doc.data()?['participantIds'], equals(['p-1', 'p-2']));
    });

    test('each saved meeting gets a unique ID', () async {
      final meeting = makeMeeting();
      final id1 = await repository.saveMeeting(meeting);
      final id2 = await repository.saveMeeting(meeting);
      expect(id1, isNot(equals(id2)));
    });

    group('getMeetingsByParticipant', () {
      test('returns meetings where person is participant, newest first',
          () async {
        final older = makeMeeting(
          userId: 'user-1',
          name: 'Older',
          participantIds: ['person-1'],
        ).copyWith(date: DateTime(2025, 1, 1));
        final newer = makeMeeting(
          userId: 'user-1',
          name: 'Newer',
          participantIds: ['person-1'],
        ).copyWith(date: DateTime(2026, 1, 1));

        await repository.saveMeeting(older);
        await repository.saveMeeting(newer);

        final results =
            await repository.getMeetingsByParticipant('user-1', 'person-1');

        expect(results.length, equals(2));
        expect(results.first.name, equals('Newer'));
        expect(results.last.name, equals('Older'));
      });

      test('returns empty list when person has no meetings', () async {
        await repository.saveMeeting(
            makeMeeting(userId: 'user-1', participantIds: ['person-2']));

        final results =
            await repository.getMeetingsByParticipant('user-1', 'person-1');
        expect(results, isEmpty);
      });

      test('does not return meetings belonging to a different user', () async {
        await repository.saveMeeting(
            makeMeeting(userId: 'user-2', participantIds: ['person-1']));

        final results =
            await repository.getMeetingsByParticipant('user-1', 'person-1');
        expect(results, isEmpty);
      });
    });

    group('getMeetingsCountForPerson', () {
      test('returns correct count when person is a participant', () async {
        await repository.saveMeeting(
            makeMeeting(userId: 'user-1', participantIds: ['person-1']));
        await repository.saveMeeting(makeMeeting(
            userId: 'user-1', participantIds: ['person-1', 'person-2']));

        final count =
            await repository.getMeetingsCountForPerson('user-1', 'person-1');
        expect(count, equals(2));
      });

      test('returns 0 when no meetings match', () async {
        await repository.saveMeeting(
            makeMeeting(userId: 'user-1', participantIds: ['person-2']));

        final count =
            await repository.getMeetingsCountForPerson('user-1', 'person-1');
        expect(count, equals(0));
      });

      test('does not count meetings belonging to a different user', () async {
        await repository.saveMeeting(
            makeMeeting(userId: 'user-2', participantIds: ['person-1']));

        final count =
            await repository.getMeetingsCountForPerson('user-1', 'person-1');
        expect(count, equals(0));
      });
    });

    group('getLastMeetingWithoutNotes', () {
      test('returns null when no meetings exist in range', () async {
        final since = DateTime(2026, 1, 1);
        final result =
            await repository.getLastMeetingWithoutNotes('user-1', since);
        expect(result, isNull);
      });

      test('returns null when all meetings in range have notes', () async {
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1').copyWith(
            date: DateTime(2026, 2, 1),
            notes: ['Some note'],
          ),
        );
        final result = await repository.getLastMeetingWithoutNotes(
            'user-1', DateTime(2026, 1, 1));
        expect(result, isNull);
      });

      test('returns most recent meeting without notes', () async {
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'Older')
              .copyWith(date: DateTime(2026, 2, 1), notes: []),
        );
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'Newer')
              .copyWith(date: DateTime(2026, 3, 1), notes: []),
        );
        final result = await repository.getLastMeetingWithoutNotes(
            'user-1', DateTime(2026, 1, 1));
        expect(result?.name, equals('Newer'));
      });

      test('skips meetings with notes and returns first one without', () async {
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'Newest')
              .copyWith(date: DateTime(2026, 3, 1), notes: ['has note']),
        );
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'Older')
              .copyWith(date: DateTime(2026, 2, 1), notes: []),
        );
        final result = await repository.getLastMeetingWithoutNotes(
            'user-1', DateTime(2026, 1, 1));
        expect(result?.name, equals('Older'));
      });

      test('does not return meetings before since date', () async {
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'TooOld')
              .copyWith(date: DateTime(2025, 12, 31), notes: []),
        );
        final result = await repository.getLastMeetingWithoutNotes(
            'user-1', DateTime(2026, 1, 1));
        expect(result, isNull);
      });
    });

    group('getRecentMeetingsWithoutNotes', () {
      test(
          'happy path — returns meetings without notes within since, ordered newest first',
          () async {
        final since = DateTime(2026, 1, 1);
        // Within range, no notes
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'Recent')
              .copyWith(date: DateTime(2026, 3, 1), notes: []),
        );
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'Older')
              .copyWith(date: DateTime(2026, 2, 1), notes: []),
        );

        final results =
            await repository.getRecentMeetingsWithoutNotes('user-1', since);

        expect(results.length, 2);
        expect(results.first.name, equals('Recent'));
        expect(results.last.name, equals('Older'));
      });

      test('returns empty list when all meetings have notes', () async {
        final since = DateTime(2026, 1, 1);
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'WithNote')
              .copyWith(date: DateTime(2026, 3, 1), notes: ['some note']),
        );

        final results =
            await repository.getRecentMeetingsWithoutNotes('user-1', since);

        expect(results, isEmpty);
      });

      test('respects the limit parameter', () async {
        final since = DateTime(2026, 1, 1);
        for (var i = 1; i <= 5; i++) {
          await repository.saveMeeting(
            makeMeeting(userId: 'user-1', name: 'M$i')
                .copyWith(date: DateTime(2026, 3, i), notes: []),
          );
        }

        final results = await repository
            .getRecentMeetingsWithoutNotes('user-1', since, limit: 2);

        expect(results.length, 2);
      });

      test('does not return meetings on or before since date', () async {
        final since = DateTime(2026, 2, 1);
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'TooOld')
              .copyWith(date: DateTime(2026, 1, 31), notes: []),
        );

        final results =
            await repository.getRecentMeetingsWithoutNotes('user-1', since);

        expect(results, isEmpty);
      });
    });

    group('replaceCategoryInMeetings', () {
      test('replaces sourceId with targetId and removes sourceId', () async {
        final id = await repository.saveMeeting(
          makeMeeting(userId: 'user-1')
              .copyWith(categoryIds: ['cat-source', 'cat-other']),
        );

        await repository.replaceCategoryInMeetings(
            'user-1', 'cat-source', 'cat-target');

        final doc = await meetingsRef('user-1').doc(id).get();
        final ids = List<String>.from(doc.data()!['categoryIds'] as List);
        expect(ids, containsAll(['cat-other', 'cat-target']));
        expect(ids, isNot(contains('cat-source')));
      });

      test('does not duplicate targetId when already present in meeting',
          () async {
        final id = await repository.saveMeeting(
          makeMeeting(userId: 'user-1')
              .copyWith(categoryIds: ['cat-source', 'cat-target']),
        );

        await repository.replaceCategoryInMeetings(
            'user-1', 'cat-source', 'cat-target');

        final doc = await meetingsRef('user-1').doc(id).get();
        final ids = List<String>.from(doc.data()!['categoryIds'] as List);
        expect(ids.where((e) => e == 'cat-target').length, equals(1));
        expect(ids, isNot(contains('cat-source')));
      });

      test('no-op when no meetings contain sourceId', () async {
        final id = await repository.saveMeeting(
          makeMeeting(userId: 'user-1').copyWith(categoryIds: ['cat-other']),
        );

        await repository.replaceCategoryInMeetings(
            'user-1', 'cat-source', 'cat-target');

        final doc = await meetingsRef('user-1').doc(id).get();
        final ids = List<String>.from(doc.data()!['categoryIds'] as List);
        expect(ids, equals(['cat-other']));
      });

      test('updates all meetings that contain sourceId', () async {
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'M1')
              .copyWith(categoryIds: ['cat-source']),
        );
        await repository.saveMeeting(
          makeMeeting(userId: 'user-1', name: 'M2')
              .copyWith(categoryIds: ['cat-source', 'cat-other']),
        );

        await repository.replaceCategoryInMeetings(
            'user-1', 'cat-source', 'cat-target');

        final snapshot = await meetingsRef('user-1').get();
        for (final doc in snapshot.docs) {
          final ids = List<String>.from(doc.data()['categoryIds'] as List);
          expect(ids, isNot(contains('cat-source')));
          expect(ids, contains('cat-target'));
        }
      });
    });
  });
}
