import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StatisticsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = StatisticsRepository(firestore: fakeFirestore);
  });

  // Helper: inserts a meeting document with the given date into Firestore.
  Future<void> addMeeting(String userId, DateTime date) async {
    final now = Timestamp.now();
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('meetings')
        .add({
      'userId': userId,
      'name': 'Test Meeting',
      'date': Timestamp.fromDate(date),
      'weight': 3,
      'participantIds': ['person-1'],
      'categoryIds': [],
      'createdAt': now,
      'updatedAt': now,
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
  });
}
