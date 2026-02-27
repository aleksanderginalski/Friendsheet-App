import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityCategoryRepository categoryRepository;
  late StatisticsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    categoryRepository = ActivityCategoryRepository(firestore: fakeFirestore);
    repository = StatisticsRepository(
      firestore: fakeFirestore,
      categoryRepository: categoryRepository,
    );
  });

  // Helper: inserts a meeting document into the user's subcollection.
  Future<void> addMeeting(
    String userId,
    DateTime date, {
    int weight = 3,
    List<String> categoryIds = const [],
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
      'participantIds': ['person-1'],
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
  });
}
