import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/services/local_cache_service.dart';
import 'package:friendsheet/services/hive_service.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  const userId = 'user-1';
  final cache = LocalCacheService();

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('local_cache_test');
    await HiveService.initialize(testPath: tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    await HiveService.clearUserData(userId);
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Meeting makeMeeting({
    String id = 'm1',
    String name = 'Coffee',
    int weight = 3,
    List<String> participantIds = const ['p1'],
    List<String> notes = const [],
    DateTime? date,
  }) {
    final d = date ?? DateTime(2026, 3, 1);
    return Meeting(
      id: id,
      userId: userId,
      name: name,
      date: d,
      weight: weight,
      participantIds: participantIds,
      notes: notes,
      createdAt: d,
      updatedAt: d,
    );
  }

  Person makePerson({
    String id = 'p1',
    String firstName = 'Anna',
    String? lastName = 'Kowalska',
    List<String> nicknames = const [],
  }) {
    return Person(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      nicknames: nicknames,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  ActivityCategory makeCategory({
    String id = 'cat1',
    String name = 'Sport',
    bool isSelectableAsActivity = true,
  }) {
    return ActivityCategory(
      id: id,
      userId: userId,
      name: name,
      iconIdentifier: 'sport',
      isGlobal: false,
      isSelectableAsActivity: isSelectableAsActivity,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Meetings
  // ---------------------------------------------------------------------------

  group('LocalCacheService — meetings', () {
    test('cold cache returns empty list', () async {
      expect(await cache.getAllMeetings(userId), isEmpty);
    });

    test('upsert inserts new meeting; getAllMeetings returns it', () async {
      await cache.upsertMeeting(userId, makeMeeting());

      final result = await cache.getAllMeetings(userId);
      expect(result.length, 1);
      expect(result.first.id, 'm1');
      expect(result.first.name, 'Coffee');
      expect(result.first.weight, 3);
    });

    test('upsert replaces existing meeting with same id', () async {
      await cache.upsertMeeting(userId, makeMeeting(name: 'Old'));
      await cache.upsertMeeting(userId, makeMeeting(name: 'New'));

      final result = await cache.getAllMeetings(userId);
      expect(result.length, 1);
      expect(result.first.name, 'New');
    });

    test('removeMeeting removes by id; unrelated meeting survives', () async {
      await cache.upsertMeeting(userId, makeMeeting(id: 'm1'));
      await cache.upsertMeeting(userId, makeMeeting(id: 'm2', name: 'Lunch'));

      await cache.removeMeeting(userId, 'm1');

      final result = await cache.getAllMeetings(userId);
      expect(result.length, 1);
      expect(result.first.id, 'm2');
    });

    test('removeMeeting is a no-op for unknown id', () async {
      await cache.upsertMeeting(userId, makeMeeting());

      await cache.removeMeeting(userId, 'nonexistent');

      expect(await cache.getAllMeetings(userId), hasLength(1));
    });
  });

  // ---------------------------------------------------------------------------
  // Persons
  // ---------------------------------------------------------------------------

  group('LocalCacheService — persons', () {
    test('cold cache returns empty list', () async {
      expect(await cache.getAllPersons(userId), isEmpty);
    });

    test('upsert inserts new person; getAllPersons returns it', () async {
      await cache.upsertPerson(userId, makePerson());

      final result = await cache.getAllPersons(userId);
      expect(result.length, 1);
      expect(result.first.id, 'p1');
      expect(result.first.firstName, 'Anna');
    });

    test('upsert replaces existing person with same id', () async {
      await cache.upsertPerson(userId, makePerson(firstName: 'Old'));
      await cache.upsertPerson(userId, makePerson(firstName: 'New'));

      final result = await cache.getAllPersons(userId);
      expect(result.length, 1);
      expect(result.first.firstName, 'New');
    });

    test('removePerson removes by id; unrelated person survives', () async {
      await cache.upsertPerson(userId, makePerson(id: 'p1'));
      await cache.upsertPerson(userId, makePerson(id: 'p2', firstName: 'Bob'));

      await cache.removePerson(userId, 'p1');

      final result = await cache.getAllPersons(userId);
      expect(result.length, 1);
      expect(result.first.id, 'p2');
    });
  });

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  group('LocalCacheService — categories', () {
    test('cold cache returns empty list', () async {
      expect(await cache.getAllCategories(userId), isEmpty);
    });

    test('upsert inserts new category; getAllCategories returns it', () async {
      await cache.upsertCategory(userId, makeCategory());

      final result = await cache.getAllCategories(userId);
      expect(result.length, 1);
      expect(result.first.id, 'cat1');
      expect(result.first.name, 'Sport');
    });

    test('upsert replaces existing category with same id', () async {
      await cache.upsertCategory(userId, makeCategory(name: 'Old'));
      await cache.upsertCategory(userId, makeCategory(name: 'New'));

      final result = await cache.getAllCategories(userId);
      expect(result.length, 1);
      expect(result.first.name, 'New');
    });

    test('removeCategory removes by id; unrelated category survives', () async {
      await cache.upsertCategory(userId, makeCategory(id: 'cat1'));
      await cache.upsertCategory(
          userId, makeCategory(id: 'cat2', name: 'Music'));

      await cache.removeCategory(userId, 'cat1');

      final result = await cache.getAllCategories(userId);
      expect(result.length, 1);
      expect(result.first.id, 'cat2');
    });

    test('removeCategoriesByIds batch-removes matching ids', () async {
      await cache.upsertCategory(userId, makeCategory(id: 'cat1', name: 'A'));
      await cache.upsertCategory(userId, makeCategory(id: 'cat2', name: 'B'));
      await cache.upsertCategory(userId, makeCategory(id: 'cat3', name: 'C'));

      await cache.removeCategoriesByIds(userId, ['cat1', 'cat3']);

      final result = await cache.getAllCategories(userId);
      expect(result.length, 1);
      expect(result.first.id, 'cat2');
    });
  });

  // ---------------------------------------------------------------------------
  // resolvePerson
  // ---------------------------------------------------------------------------

  group('LocalCacheService — resolvePerson', () {
    setUp(() async {
      await cache.upsertPerson(
        userId,
        makePerson(
            id: 'p1',
            firstName: 'Anna',
            lastName: 'Kowalska',
            nicknames: ['Ania']),
      );
      await cache.upsertPerson(
        userId,
        makePerson(id: 'p2', firstName: 'Bob', lastName: 'Smith'),
      );
    });

    test('matches by firstName substring (case-insensitive)', () async {
      final result = await cache.resolvePerson(userId, 'ann');
      expect(result.length, 1);
      expect(result.first.id, 'p1');
    });

    test('matches by lastName substring', () async {
      final result = await cache.resolvePerson(userId, 'smith');
      expect(result.length, 1);
      expect(result.first.id, 'p2');
    });

    test('matches by nickname', () async {
      final result = await cache.resolvePerson(userId, 'Ania');
      expect(result.length, 1);
      expect(result.first.id, 'p1');
    });

    test('returns empty list when no match', () async {
      final result = await cache.resolvePerson(userId, 'xyz');
      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getMeetingsByPersonAndYear
  // ---------------------------------------------------------------------------

  group('LocalCacheService — getMeetingsByPersonAndYear', () {
    test('returns only meetings for given person in given year', () async {
      await cache.upsertMeeting(
        userId,
        makeMeeting(
            id: 'm1', participantIds: ['p1'], date: DateTime(2026, 3, 1)),
      );
      await cache.upsertMeeting(
        userId,
        makeMeeting(
            id: 'm2', participantIds: ['p1'], date: DateTime(2025, 3, 1)),
      );
      await cache.upsertMeeting(
        userId,
        makeMeeting(
            id: 'm3', participantIds: ['p2'], date: DateTime(2026, 3, 1)),
      );

      final result = await cache.getMeetingsByPersonAndYear(userId, 'p1', 2026);

      expect(result.length, 1);
      expect(result.first.id, 'm1');
    });

    test('returns empty list when cache is cold', () async {
      final result = await cache.getMeetingsByPersonAndYear(userId, 'p1', 2026);
      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getMeetingsByDateRange
  // ---------------------------------------------------------------------------

  group('LocalCacheService — getMeetingsByDateRange', () {
    test('returns meetings within inclusive range, excludes outside', () async {
      await cache.upsertMeeting(
          userId, makeMeeting(id: 'in1', date: DateTime(2026, 1, 1)));
      await cache.upsertMeeting(
          userId, makeMeeting(id: 'in2', date: DateTime(2026, 6, 15)));
      await cache.upsertMeeting(
          userId, makeMeeting(id: 'in3', date: DateTime(2026, 12, 31)));
      await cache.upsertMeeting(
          userId, makeMeeting(id: 'out1', date: DateTime(2025, 12, 31)));
      await cache.upsertMeeting(
          userId, makeMeeting(id: 'out2', date: DateTime(2027, 1, 1)));

      final result = await cache.getMeetingsByDateRange(
        userId,
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
      );

      expect(result.length, 3);
      expect(result.map((m) => m.id), containsAll(['in1', 'in2', 'in3']));
    });
  });

  // ---------------------------------------------------------------------------
  // getMeetingNotes
  // ---------------------------------------------------------------------------

  group('LocalCacheService — getMeetingNotes', () {
    test('returns notes for known meetingId', () async {
      await cache.upsertMeeting(
        userId,
        makeMeeting(id: 'm1', notes: ['Note A', 'Note B']),
      );

      final notes = await cache.getMeetingNotes(userId, 'm1');
      expect(notes, equals(['Note A', 'Note B']));
    });

    test('returns empty list for unknown meetingId', () async {
      final notes = await cache.getMeetingNotes(userId, 'unknown');
      expect(notes, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getPersonSummary
  // ---------------------------------------------------------------------------

  group('LocalCacheService — getPersonSummary', () {
    test('returns null when person not in cache', () async {
      final result = await cache.getPersonSummary(userId, 'p1');
      expect(result, isNull);
    });

    test('returns null when person has no meetings', () async {
      await cache.upsertPerson(userId, makePerson(id: 'p1'));

      final result = await cache.getPersonSummary(userId, 'p1');
      expect(result, isNull);
    });

    test('happy path — all summary fields are computed correctly', () async {
      await cache.upsertPerson(userId, makePerson(id: 'p1', firstName: 'Anna'));
      await cache.upsertMeeting(
        userId,
        makeMeeting(
            id: 'm1',
            participantIds: ['p1'],
            weight: 3,
            date: DateTime(2026, 1, 1)),
      );
      await cache.upsertMeeting(
        userId,
        makeMeeting(
            id: 'm2',
            participantIds: ['p1'],
            weight: 5,
            date: DateTime(2026, 3, 1)),
      );
      // Meeting for different person — must not affect summary.
      await cache.upsertMeeting(
        userId,
        makeMeeting(
            id: 'm3',
            participantIds: ['p2'],
            weight: 10,
            date: DateTime(2026, 2, 1)),
      );

      final summary = await cache.getPersonSummary(userId, 'p1');

      expect(summary, isNotNull);
      expect(summary!.person.firstName, 'Anna');
      expect(summary.totalMeetingCount, 2);
      expect(summary.totalWeight, 8);
      expect(summary.firstMeetingDate, DateTime(2026, 1, 1));
      expect(summary.lastMeetingDate, DateTime(2026, 3, 1));
    });
  });
}
