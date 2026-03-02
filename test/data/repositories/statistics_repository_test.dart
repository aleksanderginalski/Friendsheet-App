import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityCategoryRepository categoryRepository;
  late PersonRepository personRepository;
  late StatisticsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    categoryRepository = ActivityCategoryRepository(firestore: fakeFirestore);
    personRepository = PersonRepository(
      firestore: fakeFirestore,
      meetingRepository: MeetingRepository(firestore: fakeFirestore),
    );
    repository = StatisticsRepository(
      firestore: fakeFirestore,
      categoryRepository: categoryRepository,
      personRepository: personRepository,
    );
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
    group('getAvailableYears()', () {
      test('returns sorted unique years from meetings', () async {
        await addMeeting('user-1', DateTime(2024, 6, 1));
        await addMeeting('user-1', DateTime(2026, 1, 15));
        await addMeeting('user-1', DateTime(2025, 11, 30));
        // Duplicate year — should appear only once.
        await addMeeting('user-1', DateTime(2026, 3, 10));

        final years = await repository.getAvailableYears('user-1');

        expect(years, equals([2026, 2025, 2024]));
      });

      test('returns empty list when no meetings exist', () async {
        final years = await repository.getAvailableYears('user-1');

        expect(years, isEmpty);
      });

      test('does not include years from a different user', () async {
        await addMeeting('user-2', DateTime(2024, 5, 1));

        final years = await repository.getAvailableYears('user-1');

        expect(years, isEmpty);
      });
    });

    group('getMeetingsForYear()', () {
      test('returns only meetings within the given year', () async {
        await addMeeting('user-1', DateTime(2025, 12, 31));
        await addMeeting('user-1', DateTime(2026, 1, 1));
        await addMeeting('user-1', DateTime(2026, 12, 31));
        // This one should be excluded (belongs to 2027).
        await addMeeting('user-1', DateTime(2027, 1, 1));

        final meetings = await repository.getMeetingsForYear('user-1', 2026);

        expect(meetings, hasLength(2));
        expect(meetings.every((m) => m.date.year == 2026), isTrue);
      });

      test('returns empty list when no meetings exist for the year', () async {
        await addMeeting('user-1', DateTime(2024, 6, 1));

        final meetings = await repository.getMeetingsForYear('user-1', 2026);

        expect(meetings, isEmpty);
      });

      test('does not include meetings from a different user', () async {
        await addMeeting('user-2', DateTime(2026, 6, 1));

        final meetings = await repository.getMeetingsForYear('user-1', 2026);

        expect(meetings, isEmpty);
      });
    });

    group('getActivityWeightBreakdown()', () {
      test('happy path: sums weights correctly for 2 meetings', () async {
        await addCategory('user-1', 'cat-a', 'Running');
        await addCategory('user-1', 'cat-b', 'Cycling');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['cat-a', 'cat-b'],
        );
        await addMeeting(
          'user-1',
          DateTime(2026, 6, 1),
          weight: 3,
          categoryIds: ['cat-a'],
        );

        final breakdown =
            await repository.getActivityWeightBreakdown(2026, 'user-1');

        expect(breakdown, hasLength(2));
        // cat-a: 5 + 3 = 8, cat-b: 5
        final catA = breakdown.firstWhere((e) => e.categoryId == 'cat-a');
        final catB = breakdown.firstWhere((e) => e.categoryId == 'cat-b');
        expect(catA.currentYearWeight, equals(8));
        expect(catB.currentYearWeight, equals(5));
        // Sorted descending by currentYearWeight.
        expect(breakdown.first.categoryId, equals('cat-a'));
      });

      test(
          'ancestor counted once per meeting: duplicate categoryId not doubled',
          () async {
        await addCategory('user-1', 'leaf', 'Leaf');
        await addCategory('user-1', 'parent', 'Parent');

        // Meeting has both leaf and parent — each should be counted once.
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['leaf', 'parent', 'leaf'], // duplicate leaf
        );

        final breakdown =
            await repository.getActivityWeightBreakdown(2026, 'user-1');

        final leafEntry = breakdown.firstWhere((e) => e.categoryId == 'leaf');
        final parentEntry =
            breakdown.firstWhere((e) => e.categoryId == 'parent');
        // Each categoryId counted only once per meeting, weight = 5.
        expect(leafEntry.currentYearWeight, equals(5));
        expect(parentEntry.currentYearWeight, equals(5));
      });

      test('previous year data: delta computed correctly', () async {
        await addCategory('user-1', 'cat-a', 'Running');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 8,
          categoryIds: ['cat-a'],
        );
        await addMeeting(
          'user-1',
          DateTime(2025, 5, 1),
          weight: 3,
          categoryIds: ['cat-a'],
        );

        final breakdown =
            await repository.getActivityWeightBreakdown(2026, 'user-1');

        expect(breakdown, hasLength(1));
        expect(breakdown.first.currentYearWeight, equals(8));
        expect(breakdown.first.previousYearWeight, equals(3));
        expect(breakdown.first.delta, equals(5));
      });

      test(
          'zero current year: activity only in previous year appears at bottom',
          () async {
        await addCategory('user-1', 'cat-a', 'Running');
        await addCategory('user-1', 'cat-b', 'Cycling');

        // cat-a only in current year, cat-b only in previous year.
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['cat-a'],
        );
        await addMeeting(
          'user-1',
          DateTime(2025, 3, 1),
          weight: 7,
          categoryIds: ['cat-b'],
        );

        final breakdown =
            await repository.getActivityWeightBreakdown(2026, 'user-1');

        expect(breakdown, hasLength(2));
        // cat-a has currentYearWeight > 0, appears first.
        expect(breakdown.first.categoryId, equals('cat-a'));
        // cat-b has currentYearWeight == 0, appears at bottom.
        expect(breakdown.last.categoryId, equals('cat-b'));
        expect(breakdown.last.currentYearWeight, equals(0));
        expect(breakdown.last.previousYearWeight, equals(7));
      });

      test('unknown categoryId: entry skipped when category not found',
          () async {
        await addCategory('user-1', 'cat-a', 'Running');
        // 'cat-missing' is not in the categories collection.

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['cat-a', 'cat-missing'],
        );

        final breakdown =
            await repository.getActivityWeightBreakdown(2026, 'user-1');

        expect(breakdown, hasLength(1));
        expect(breakdown.first.categoryId, equals('cat-a'));
      });
    });

    group('getPersonsForActivity()', () {
      test('happy path: 2 meetings match, correct weight sums per person',
          () async {
        await addPerson('user-1', 'person-a', 'Alice');
        await addPerson('user-1', 'person-b', 'Bob');

        // Both meetings match 'sport'. Alice is in both; Bob is in one.
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['sport'],
          participantIds: ['person-a', 'person-b'],
        );
        await addMeeting(
          'user-1',
          DateTime(2026, 6, 1),
          weight: 3,
          categoryIds: ['sport'],
          participantIds: ['person-a'],
        );
        // Non-matching meeting — should be excluded.
        await addMeeting(
          'user-1',
          DateTime(2026, 9, 1),
          weight: 8,
          categoryIds: ['tennis'],
          participantIds: ['person-b'],
        );

        final result = await repository.getPersonsForActivity(
          'sport',
          2026,
          'user-1',
        );

        expect(result, hasLength(2));
        final alice = result.firstWhere((e) => e.personId == 'person-a');
        final bob = result.firstWhere((e) => e.personId == 'person-b');
        // Alice: 5 + 3 = 8, Bob: 5
        expect(alice.weightSum, equals(8));
        expect(bob.weightSum, equals(5));
        // Sorted descending — Alice first.
        expect(result.first.personId, equals('person-a'));
      });

      test(
          'ancestor match: selecting parent categoryId matches meetings with child categoryIds',
          () async {
        await addPerson('user-1', 'person-a', 'Alice');

        // Meeting stores both leaf and parent in categoryIds (ancestor chain).
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['rowing', 'sport'], // leaf + parent
          participantIds: ['person-a'],
        );

        // Selecting parent 'sport' matches this meeting.
        final result = await repository.getPersonsForActivity(
          'sport',
          2026,
          'user-1',
        );

        expect(result, hasLength(1));
        expect(result.first.personId, equals('person-a'));
        expect(result.first.weightSum, equals(5));
      });

      test(
          'weight counted once per person per meeting regardless of activity count',
          () async {
        await addPerson('user-1', 'person-a', 'Alice');

        // Meeting has 2 matching activities — Alice's weight should be added once.
        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['running', 'cycling'],
          participantIds: ['person-a'],
        );

        // Select 'running' — Alice gets weight 5, not 10.
        final result = await repository.getPersonsForActivity(
          'running',
          2026,
          'user-1',
        );

        expect(result, hasLength(1));
        expect(result.first.weightSum, equals(5));
      });

      test('person not found in repository: entry skipped gracefully',
          () async {
        await addPerson('user-1', 'person-a', 'Alice');
        // 'person-missing' has no document in persons collection.

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['sport'],
          participantIds: ['person-a', 'person-missing'],
        );

        final result = await repository.getPersonsForActivity(
          'sport',
          2026,
          'user-1',
        );

        // Only Alice is returned; person-missing is skipped.
        expect(result, hasLength(1));
        expect(result.first.personId, equals('person-a'));
      });

      test('empty result: no meetings match selected categoryId', () async {
        await addPerson('user-1', 'person-a', 'Alice');

        await addMeeting(
          'user-1',
          DateTime(2026, 3, 1),
          weight: 5,
          categoryIds: ['tennis'],
          participantIds: ['person-a'],
        );

        final result = await repository.getPersonsForActivity(
          'sport',
          2026,
          'user-1',
        );

        expect(result, isEmpty);
      });
    });

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
