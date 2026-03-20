// test/data/repositories/statistics_repository_distribution_test.dart
//
// Tests for StatisticsRepository distribution methods:
// getInteractionDistribution, getCumulativeInteractions.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/friend_group_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/services/hive_service.dart';
import 'package:hive/hive.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityCategoryRepository categoryRepository;
  late PersonRepository personRepository;
  late StatisticsRepository repository;
  late Directory hiveDir;

  setUp(() async {
    // Each test gets its own Hive instance in a fresh temp directory so that
    // Hive state never leaks between tests.
    hiveDir = await Directory.systemTemp.createTemp('hive_stats_test_');
    await HiveService.initialize(testPath: hiveDir.path);

    fakeFirestore = FakeFirebaseFirestore();
    categoryRepository = ActivityCategoryRepository(firestore: fakeFirestore);
    personRepository = PersonRepository(
      firestore: fakeFirestore,
      meetingRepository: MeetingRepository(firestore: fakeFirestore),
      friendGroupRepository: FriendGroupRepository(firestore: fakeFirestore),
    );
    repository = StatisticsRepository(
      firestore: fakeFirestore,
      categoryRepository: categoryRepository,
      personRepository: personRepository,
    );
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  // Helper: inserts a meeting document into the user's subcollection.
  Future<void> addMeeting(
    String userId,
    DateTime date, {
    int weight = 3,
    List<String> categoryIds = const [],
    List<String> participantIds = const ['person-1'],
  }) async {
    final now = Timestamp.now();
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('meetings')
        .add({
      'userId': userId,
      'name': 'Test Meeting',
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'participantIds': participantIds,
      'categoryIds': categoryIds,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // Helper: inserts a person document with an explicit ID.
  Future<void> addPerson(
    String userId,
    String personId,
    String firstName,
  ) async {
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('persons')
        .doc(personId)
        .set({
      'userId': userId,
      'firstName': firstName,
      'createdAt': Timestamp.now(),
    });
  }

  group('StatisticsRepository', () {
    group('getInteractionDistribution()', () {
      test('happy path: sums weights per person across all meetings', () async {
        await addPerson('user-1', 'person-a', 'Alice');
        await addPerson('user-1', 'person-b', 'Bob');

        // Alice in both meetings, Bob only in the first.
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          participantIds: ['person-a', 'person-b'],
        );
        await addMeeting(
          'user-1',
          DateTime(2026, 6, 1),
          weight: 3,
          participantIds: ['person-a'],
        );

        final result =
            await repository.getInteractionDistribution(2026, 'user-1');

        expect(result, hasLength(2));
        final alice = result.firstWhere((e) => e.personId == 'person-a');
        final bob = result.firstWhere((e) => e.personId == 'person-b');
        // Alice: 5 + 3 = 8, Bob: 5
        expect(alice.currentYearWeight, equals(8));
        expect(bob.currentYearWeight, equals(5));
        // Sorted descending — Alice first.
        expect(result.first.personId, equals('person-a'));
      });

      test('previous year data included and delta computed correctly',
          () async {
        await addPerson('user-1', 'person-a', 'Alice');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 8,
          participantIds: ['person-a'],
        );
        await addMeeting(
          'user-1',
          DateTime(2025, 5, 1),
          weight: 3,
          participantIds: ['person-a'],
        );

        final result =
            await repository.getInteractionDistribution(2026, 'user-1');

        expect(result, hasLength(1));
        expect(result.first.currentYearWeight, equals(8));
        expect(result.first.previousYearWeight, equals(3));
        expect(result.first.delta, equals(5));
      });

      test(
          'person only in previous year: appears at bottom with currentYearWeight 0',
          () async {
        await addPerson('user-1', 'person-a', 'Alice');
        await addPerson('user-1', 'person-b', 'Bob');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          participantIds: ['person-a'],
        );
        await addMeeting(
          'user-1',
          DateTime(2025, 3, 1),
          weight: 7,
          participantIds: ['person-b'],
        );

        final result =
            await repository.getInteractionDistribution(2026, 'user-1');

        expect(result, hasLength(2));
        expect(result.first.personId, equals('person-a'));
        expect(result.last.personId, equals('person-b'));
        expect(result.last.currentYearWeight, equals(0));
        expect(result.last.previousYearWeight, equals(7));
      });

      test('ties broken alphabetically by name', () async {
        await addPerson('user-1', 'person-z', 'Zara');
        await addPerson('user-1', 'person-a', 'Anna');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          participantIds: ['person-z', 'person-a'],
        );

        final result =
            await repository.getInteractionDistribution(2026, 'user-1');

        expect(result, hasLength(2));
        // Same weight — Anna before Zara alphabetically.
        expect(result.first.name, equals('Anna'));
        expect(result.last.name, equals('Zara'));
      });

      test('unknown personId: entry skipped when person not found', () async {
        await addPerson('user-1', 'person-a', 'Alice');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          participantIds: ['person-a', 'person-missing'],
        );

        final result =
            await repository.getInteractionDistribution(2026, 'user-1');

        expect(result, hasLength(1));
        expect(result.first.personId, equals('person-a'));
      });

      test('empty result when no meetings exist for year', () async {
        await addPerson('user-1', 'person-a', 'Alice');

        final result =
            await repository.getInteractionDistribution(2026, 'user-1');

        expect(result, isEmpty);
      });

      test('does not include meetings from a different user', () async {
        await addPerson('user-2', 'person-a', 'Alice');
        await addMeeting(
          'user-2',
          DateTime(2026, 3, 1),
          weight: 5,
          participantIds: ['person-a'],
        );

        final result =
            await repository.getInteractionDistribution(2026, 'user-1');

        expect(result, isEmpty);
      });
    });

    group('getCumulativeInteractions()', () {
      test('sums weights across all years up to and including given year',
          () async {
        await addPerson('user-1', 'person-a', 'Alice');

        await addMeeting(
          'user-1',
          DateTime(2024, 6, 1),
          weight: 2,
          participantIds: ['person-a'],
        );
        await addMeeting(
          'user-1',
          DateTime(2025, 3, 1),
          weight: 3,
          participantIds: ['person-a'],
        );
        await addMeeting(
          'user-1',
          DateTime(2026, 1, 1),
          weight: 5,
          participantIds: ['person-a'],
        );

        final result =
            await repository.getCumulativeInteractions(2026, 'user-1');

        expect(result, hasLength(1));
        // 2 + 3 + 5 = 10
        expect(result.first.currentYearWeight, equals(10));
        expect(result.first.previousYearWeight, equals(0));
      });

      test('excludes meetings after the given year', () async {
        await addPerson('user-1', 'person-a', 'Alice');

        await addMeeting(
          'user-1',
          DateTime(2025, 6, 1),
          weight: 4,
          participantIds: ['person-a'],
        );
        // Future meeting — must be excluded.
        await addMeeting(
          'user-1',
          DateTime(2027, 1, 1),
          weight: 10,
          participantIds: ['person-a'],
        );

        final result =
            await repository.getCumulativeInteractions(2026, 'user-1');

        expect(result, hasLength(1));
        expect(result.first.currentYearWeight, equals(4));
      });

      test('previousYearWeight is always 0', () async {
        await addPerson('user-1', 'person-a', 'Alice');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          participantIds: ['person-a'],
        );

        final result =
            await repository.getCumulativeInteractions(2026, 'user-1');

        expect(result.first.previousYearWeight, equals(0));
        expect(result.first.delta, equals(5));
      });

      test('returns empty list when no meetings exist', () async {
        final result =
            await repository.getCumulativeInteractions(2026, 'user-1');

        expect(result, isEmpty);
      });

      test('sorted descending by weight then alphabetically by name', () async {
        await addPerson('user-1', 'person-z', 'Zara');
        await addPerson('user-1', 'person-a', 'Anna');
        await addPerson('user-1', 'person-c', 'Carl');

        await addMeeting(
          'user-1',
          DateTime(2026, 1, 1),
          weight: 3,
          participantIds: ['person-c'],
        );
        // Zara and Anna have the same total weight — sorted alphabetically.
        await addMeeting(
          'user-1',
          DateTime(2026, 2, 1),
          weight: 1,
          participantIds: ['person-z', 'person-a'],
        );

        final result =
            await repository.getCumulativeInteractions(2026, 'user-1');

        expect(result, hasLength(3));
        expect(result.first.name, equals('Carl'));
        expect(result[1].name, equals('Anna'));
        expect(result.last.name, equals('Zara'));
      });
    });
  });
}
