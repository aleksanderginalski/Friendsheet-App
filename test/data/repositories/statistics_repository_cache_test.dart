// test/data/repositories/statistics_repository_cache_test.dart
//
// Tests for StatisticsRepository caching:
// in-memory cache, Hive persistent cache, CacheInvalidator,
// loadAllStatsData, computeActivityBreakdown, computePersonsForActivity,
// computeInteractionDistribution.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/models/stats_data_bundle.dart';
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

  // Helper: inserts a category document with an explicit ID.
  Future<void> addCategory(
    String userId,
    String categoryId,
    String name,
  ) async {
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('activity_categories')
        .doc(categoryId)
        .set({
      'userId': userId,
      'name': name,
      'iconIdentifier': 'category',
      'isGlobal': false,
      'isSelectableAsActivity': true,
      'createdAt': Timestamp.now(),
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
    // ─── Phase 2: in-memory cache ───────────────────────────────────────────

    group('getMeetingsForYear() — cache', () {
      test('cache hit: second call returns cached data without Firestore read',
          () async {
        await addMeeting('user-1', DateTime(2026, 3, 1), weight: 5);

        // First call populates the cache.
        final first = await repository.getMeetingsForYear('user-1', 2026);
        expect(first, hasLength(1));

        // Remove the document from Firestore — cache should still serve it.
        final snapshot = await fakeFirestore
            .collection('users')
            .doc('user-1')
            .collection('meetings')
            .get();
        await snapshot.docs.first.reference.delete();

        final second = await repository.getMeetingsForYear('user-1', 2026);
        expect(second, hasLength(1)); // returned from cache, not Firestore
      });

      test('invalidateMeetingsCache: next call re-fetches from Firestore',
          () async {
        await addMeeting('user-1', DateTime(2026, 3, 1), weight: 5);

        // Populate cache.
        final before = await repository.getMeetingsForYear('user-1', 2026);
        expect(before, hasLength(1));

        // Delete from Firestore then invalidate cache.
        final snapshot = await fakeFirestore
            .collection('users')
            .doc('user-1')
            .collection('meetings')
            .get();
        await snapshot.docs.first.reference.delete();
        await repository.invalidateMeetingsCache();

        // Now re-fetch — must read empty Firestore.
        final after = await repository.getMeetingsForYear('user-1', 2026);
        expect(after, isEmpty);
      });

      test('invalidateAllCaches clears all three caches', () async {
        await addMeeting('user-1', DateTime(2026, 3, 1));
        await addCategory('user-1', 'cat-a', 'Running');
        await addPerson('user-1', 'person-a', 'Alice');

        // Populate all caches via loadAllStatsData.
        await repository.loadAllStatsData(2026, 'user-1');

        await repository.invalidateAllCaches();

        // After invalidation, deleting from Firestore and re-fetching should
        // return empty results (proves cache was cleared).
        final catSnapshot = await fakeFirestore
            .collection('users')
            .doc('user-1')
            .collection('activity_categories')
            .get();
        for (final doc in catSnapshot.docs) {
          await doc.reference.delete();
        }

        final bundle = await repository.loadAllStatsData(2026, 'user-1');
        expect(bundle.categories, isEmpty); // re-fetched after cache clear
      });
    });

    // ─── Phase 3: StatsDataBundle + compute* ────────────────────────────────

    group('loadAllStatsData()', () {
      test('returns bundle with correct data for given year', () async {
        await addCategory('user-1', 'cat-a', 'Running');
        await addPerson('user-1', 'person-a', 'Alice');
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['cat-a'],
          participantIds: ['person-a'],
        );
        await addMeeting(
          'user-1',
          DateTime(2025, 6, 1), // previous year
          weight: 3,
          categoryIds: ['cat-a'],
          participantIds: ['person-a'],
        );

        final bundle = await repository.loadAllStatsData(2026, 'user-1');

        expect(bundle.currentYearMeetings, hasLength(1));
        expect(bundle.currentYearMeetings.first.weight, equals(5));
        expect(bundle.previousYearMeetings, hasLength(1));
        expect(bundle.previousYearMeetings.first.weight, equals(3));
        expect(bundle.categories, hasLength(1));
        expect(bundle.categories.first.name, equals('Running'));
        expect(bundle.persons, hasLength(1));
        expect(bundle.persons.first.fullName, equals('Alice'));
      });

      test('initialize() → getMeetingsForYear called once per year via cache',
          () async {
        await addCategory('user-1', 'cat-a', 'Running');
        await addPerson('user-1', 'person-a', 'Alice');
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['cat-a'],
          participantIds: ['person-a'],
        );

        // First loadAllStatsData populates cache for 2026 and 2025.
        await repository.loadAllStatsData(2026, 'user-1');

        // Add a new meeting to Firestore AFTER the first fetch.
        await addMeeting(
          'user-1',
          DateTime(2026, 9, 1),
          weight: 8,
          categoryIds: ['cat-a'],
          participantIds: ['person-a'],
        );

        // Second call should return cached data (1 meeting, not 2).
        final bundle = await repository.loadAllStatsData(2026, 'user-1');
        expect(bundle.currentYearMeetings, hasLength(1));
      });
    });

    group('computeActivityBreakdown()', () {
      test('happy path: computes weights from bundle correctly', () async {
        final bundle = StatsDataBundle(
          currentYearMeetings: [
            _makeMeeting(weight: 5, categoryIds: ['cat-a', 'cat-b']),
            _makeMeeting(weight: 3, categoryIds: ['cat-a']),
          ],
          previousYearMeetings: [],
          categories: [
            _makeCategory('cat-a', 'Running'),
            _makeCategory('cat-b', 'Cycling'),
          ],
          persons: [],
        );

        final result = repository.computeActivityBreakdown(bundle);

        expect(result, hasLength(2));
        final catA = result.firstWhere((e) => e.categoryId == 'cat-a');
        final catB = result.firstWhere((e) => e.categoryId == 'cat-b');
        expect(catA.currentYearWeight, equals(8)); // 5+3
        expect(catB.currentYearWeight, equals(5));
        expect(result.first.categoryId, equals('cat-a')); // sorted desc
      });

      test('unknown categoryId: entry skipped', () async {
        final bundle = StatsDataBundle(
          currentYearMeetings: [
            _makeMeeting(weight: 5, categoryIds: ['cat-a', 'cat-missing']),
          ],
          previousYearMeetings: [],
          categories: [_makeCategory('cat-a', 'Running')],
          persons: [],
        );

        final result = repository.computeActivityBreakdown(bundle);

        expect(result, hasLength(1));
        expect(result.first.categoryId, equals('cat-a'));
      });
    });

    group('computePersonsForActivity()', () {
      test('happy path: aggregates weight per person for matching meetings',
          () async {
        final bundle = StatsDataBundle(
          currentYearMeetings: [
            _makeMeeting(
              weight: 5,
              categoryIds: ['sport'],
              participantIds: ['p-a', 'p-b'],
            ),
            _makeMeeting(
              weight: 3,
              categoryIds: ['sport'],
              participantIds: ['p-a'],
            ),
            _makeMeeting(
              weight: 8,
              categoryIds: ['tennis'],
              participantIds: ['p-b'],
            ),
          ],
          previousYearMeetings: [],
          categories: [],
          persons: [
            _makePerson('p-a', 'Alice'),
            _makePerson('p-b', 'Bob'),
          ],
        );

        final result = repository.computePersonsForActivity(bundle, 'sport');

        expect(result, hasLength(2));
        final alice = result.firstWhere((e) => e.personId == 'p-a');
        final bob = result.firstWhere((e) => e.personId == 'p-b');
        expect(alice.weightSum, equals(8)); // 5+3
        expect(bob.weightSum, equals(5));
        expect(result.first.personId, equals('p-a')); // sorted desc
      });
    });

    group('computeInteractionDistribution()', () {
      test('happy path: computes distribution from bundle', () async {
        final bundle = StatsDataBundle(
          currentYearMeetings: [
            _makeMeeting(
              weight: 8,
              participantIds: ['p-a'],
            ),
            _makeMeeting(
              weight: 5,
              participantIds: ['p-a', 'p-b'],
            ),
          ],
          previousYearMeetings: [
            _makeMeeting(weight: 3, participantIds: ['p-a']),
          ],
          categories: [],
          persons: [
            _makePerson('p-a', 'Alice'),
            _makePerson('p-b', 'Bob'),
          ],
        );

        final result = repository.computeInteractionDistribution(bundle);

        expect(result, hasLength(2));
        final alice = result.firstWhere((e) => e.personId == 'p-a');
        final bob = result.firstWhere((e) => e.personId == 'p-b');
        expect(alice.currentYearWeight, equals(13)); // 8+5
        expect(alice.previousYearWeight, equals(3));
        expect(bob.currentYearWeight, equals(5));
        expect(result.first.personId, equals('p-a')); // sorted desc
      });
    });

    // ─── Phase 4: Hive persistent cache (US-073) ────────────────────────────

    group('getMeetingsForYear() — Hive cache hit', () {
      test(
          'returns data from Hive after in-memory cache is cleared (simulates '
          'app restart)', () async {
        await addMeeting('user-1', DateTime(2026, 3, 1), weight: 5);

        // First call — Firestore hit, result written to Hive.
        final first = await repository.getMeetingsForYear('user-1', 2026);
        expect(first, hasLength(1));

        // Delete the document from Firestore to prove next read won't use it.
        final snapshot = await fakeFirestore
            .collection('users')
            .doc('user-1')
            .collection('meetings')
            .get();
        await snapshot.docs.first.reference.delete();

        // Simulate app restart: create a fresh repository instance — empty
        // in-memory cache — but Hive boxes are still open with cached data.
        final restarted = StatisticsRepository(
          firestore: fakeFirestore,
          categoryRepository: categoryRepository,
          personRepository: personRepository,
        );

        // Second call: in-memory miss → Hive hit → returns cached data.
        final second = await restarted.getMeetingsForYear('user-1', 2026);
        expect(second, hasLength(1));
        expect(second.first.weight, equals(5));
      });
    });

    group('getMeetingsForYear() — Hive cache miss', () {
      test('fetches from Firestore on empty Hive and writes result to Hive box',
          () async {
        await addMeeting('user-1', DateTime(2026, 6, 1), weight: 3);

        // Hive is empty (fresh setUp) — first call must hit Firestore.
        await repository.getMeetingsForYear('user-1', 2026);

        // Verify Hive box was populated after the Firestore fetch.
        final raw = HiveService.box(HiveService.meetingsBox).get('user-1_2026');
        expect(raw, isNotNull);
        expect((raw as List).length, equals(1));
      });
    });

    group('invalidateMeetingsCache() — clears both in-memory and Hive', () {
      test('Hive box is empty after invalidation', () async {
        // Populate Hive via a normal read.
        await addMeeting('user-1', DateTime(2026, 3, 1), weight: 5);
        await repository.getMeetingsForYear('user-1', 2026);
        expect(
          HiveService.box(HiveService.meetingsBox).isEmpty,
          isFalse,
        );

        await repository.invalidateMeetingsCache();

        expect(HiveService.box(HiveService.meetingsBox).isEmpty, isTrue);
      });
    });
  });
}

// ─── Bundle construction helpers ──────────────────────────────────────────────

/// Creates a minimal Meeting with the given weight and IDs.
/// Uses fixed timestamps and required non-null fields.
Meeting _makeMeeting({
  int weight = 3,
  List<String> categoryIds = const [],
  List<String> participantIds = const [],
}) {
  final now = DateTime(2026, 1, 1);
  return Meeting(
    id: 'test-meeting',
    userId: 'user-1',
    name: 'Test',
    date: now,
    weight: weight,
    participantIds: participantIds,
    categoryIds: categoryIds,
    createdAt: now,
    updatedAt: now,
  );
}

/// Creates a minimal ActivityCategory with the given id and name.
ActivityCategory _makeCategory(String id, String name) {
  return ActivityCategory(
    id: id,
    userId: 'user-1',
    name: name,
    iconIdentifier: 'category',
    isGlobal: false,
    isSelectableAsActivity: true,
    createdAt: DateTime(2026),
  );
}

/// Creates a minimal Person with the given id and first name.
Person _makePerson(String id, String firstName) {
  return Person(
    id: id,
    userId: 'user-1',
    firstName: firstName,
    createdAt: DateTime(2026),
  );
}
