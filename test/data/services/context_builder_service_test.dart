import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/buddy_context.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/context_builder_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'context_builder_service_test.mocks.dart';

@GenerateMocks(
    [MeetingRepository, PersonRepository, ActivityCategoryRepository])
void main() {
  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;
  late ContextBuilderService service;

  // Fixed reference date — meetings before this should be filtered out in
  // full context (12-month window), but not in per-person context.
  final now = DateTime(2026, 3, 10);
  final withinWindow = now.subtract(const Duration(days: 30));
  final outsideWindow = now.subtract(const Duration(days: 400));

  Meeting makeMeeting({
    required String id,
    required DateTime date,
    List<String> participantIds = const ['p1'],
    List<String> categoryIds = const ['cat1'],
    List<String> notes = const [],
  }) =>
      Meeting(
        id: id,
        userId: 'user-1',
        name: 'Meeting $id',
        date: date,
        weight: 3,
        participantIds: participantIds,
        categoryIds: categoryIds,
        notes: notes,
        createdAt: date,
        updatedAt: date,
      );

  Person makePerson(String id, String firstName, {String? lastName}) => Person(
        id: id,
        userId: 'user-1',
        firstName: firstName,
        lastName: lastName,
        createdAt: now,
      );

  ActivityCategory makeCategory(String id, String name) => ActivityCategory(
        id: id,
        userId: 'user-1',
        name: name,
        iconIdentifier: 'icon',
        isGlobal: false,
        isSelectableAsActivity: true,
        createdAt: now,
      );

  setUp(() {
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();

    service = ContextBuilderService(
      meetingRepository: mockMeetingRepo,
      personRepository: mockPersonRepo,
      activityCategoryRepository: mockCategoryRepo,
    );
  });

  // ---------------------------------------------------------------------------
  // Pseudonymization
  // ---------------------------------------------------------------------------

  group('pseudonymization', () {
    test('assigns Friend_A to alphabetically first person', () async {
      // "Anna Kowalska" sorts before "Zofia Nowak"
      when(mockPersonRepo.getPersonsByUser('user-1')).thenAnswer(
        (_) async => [
          makePerson('p-zofia', 'Zofia', lastName: 'Nowak'),
          makePerson('p-anna', 'Anna', lastName: 'Kowalska'),
        ],
      );
      when(mockCategoryRepo.getCategories('user-1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.value([]));

      final ctx = await service.buildFullContext(
        'user-1',
        from: now.subtract(const Duration(days: 1)),
      );

      expect(ctx.pseudonymToRealName['Friend_A'], 'Anna Kowalska');
      expect(ctx.pseudonymToRealName['Friend_B'], 'Zofia Nowak');
      expect(ctx.personIdToPseudonym['p-anna'], 'Friend_A');
      expect(ctx.personIdToPseudonym['p-zofia'], 'Friend_B');
    });
  });

  // ---------------------------------------------------------------------------
  // buildFullContext
  // ---------------------------------------------------------------------------

  group('buildFullContext', () {
    test('happy path — filters meetings, resolves names, builds person entry',
        () async {
      when(mockPersonRepo.getPersonsByUser('user-1'))
          .thenAnswer((_) async => [makePerson('p1', 'Anna')]);
      when(mockCategoryRepo.getCategories('user-1')).thenAnswer(
        (_) => Stream.value([makeCategory('cat1', 'Sport')]),
      );
      when(mockMeetingRepo.getMeetingsByUser('user-1')).thenAnswer(
        (_) => Stream.value([
          makeMeeting(id: 'm1', date: withinWindow, notes: ['great day']),
          makeMeeting(id: 'm2', date: outsideWindow), // filtered out
        ]),
      );

      final ctx = await service.buildFullContext('user-1',
          from: now.subtract(const Duration(days: 365)));

      // Only m1 is within window
      expect(ctx.meetings.length, 1);
      final m = ctx.meetings.first;
      expect(m.name, 'Meeting m1');
      expect(m.pseudonymizedParticipants, ['Friend_A']);
      expect(m.activityNames, ['Sport']);
      expect(m.notes, ['great day']);

      // Person entry aggregates
      expect(ctx.persons.length, 1);
      final p = ctx.persons.first;
      expect(p.pseudonym, 'Friend_A');
      expect(p.meetingCount, 1);
      expect(p.topActivities, ['Sport']);
      expect(p.lastMeetingDate, withinWindow);
    });

    test('skips participant not found in person map (deleted person)',
        () async {
      when(mockPersonRepo.getPersonsByUser('user-1'))
          .thenAnswer((_) async => [makePerson('p1', 'Anna')]);
      when(mockCategoryRepo.getCategories('user-1'))
          .thenAnswer((_) => Stream.value([]));
      // Meeting has both known p1 and unknown p-deleted
      when(mockMeetingRepo.getMeetingsByUser('user-1')).thenAnswer(
        (_) => Stream.value([
          makeMeeting(
            id: 'm1',
            date: withinWindow,
            participantIds: ['p1', 'p-deleted'],
            categoryIds: [],
          ),
        ]),
      );

      final ctx = await service.buildFullContext('user-1', from: outsideWindow);

      expect(ctx.meetings.first.pseudonymizedParticipants, ['Friend_A']);
    });

    test('custom from date excludes meetings before it', () async {
      final cutoff = DateTime(2026, 2, 1);
      when(mockPersonRepo.getPersonsByUser('user-1'))
          .thenAnswer((_) async => []);
      when(mockCategoryRepo.getCategories('user-1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockMeetingRepo.getMeetingsByUser('user-1')).thenAnswer(
        (_) => Stream.value([
          makeMeeting(
              id: 'new', date: DateTime(2026, 2, 15), participantIds: []),
          makeMeeting(
              id: 'old', date: DateTime(2026, 1, 15), participantIds: []),
        ]),
      );

      final ctx = await service.buildFullContext('user-1', from: cutoff);

      expect(ctx.meetings.length, 1);
      expect(ctx.meetings.first.name, 'Meeting new');
    });

    test('top activities capped at 3, ordered by frequency', () async {
      when(mockPersonRepo.getPersonsByUser('user-1'))
          .thenAnswer((_) async => [makePerson('p1', 'Anna')]);
      when(mockCategoryRepo.getCategories('user-1')).thenAnswer(
        (_) => Stream.value([
          makeCategory('c1', 'Sport'),
          makeCategory('c2', 'Cinema'),
          makeCategory('c3', 'Coffee'),
          makeCategory('c4', 'Travel'),
        ]),
      );
      // Sport appears 3x, Cinema 2x, Coffee 1x, Travel 1x
      when(mockMeetingRepo.getMeetingsByUser('user-1')).thenAnswer(
        (_) => Stream.value([
          makeMeeting(id: 'm1', date: withinWindow, categoryIds: ['c1', 'c2']),
          makeMeeting(id: 'm2', date: withinWindow, categoryIds: ['c1', 'c2']),
          makeMeeting(
              id: 'm3', date: withinWindow, categoryIds: ['c1', 'c3', 'c4']),
        ]),
      );

      final ctx = await service.buildFullContext('user-1', from: outsideWindow);

      final activities = ctx.persons.first.topActivities;
      expect(activities.length, 3);
      expect(activities.first, 'Sport'); // highest frequency
      expect(activities.contains('Cinema'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // buildPersonContext
  // ---------------------------------------------------------------------------

  group('buildPersonContext', () {
    test('fetches only meetings for personId and scopes person list', () async {
      when(mockPersonRepo.getPersonsByUser('user-1')).thenAnswer(
        (_) async => [
          makePerson('p1', 'Anna'),
          makePerson('p2', 'Bartek'),
        ],
      );
      when(mockCategoryRepo.getCategories('user-1'))
          .thenAnswer((_) => Stream.value([]));
      // getMeetingsByParticipant returns only meetings for p1
      when(mockMeetingRepo.getMeetingsByParticipant('user-1', 'p1'))
          .thenAnswer((_) async => [
                makeMeeting(
                    id: 'm1', date: withinWindow, participantIds: ['p1']),
              ]);

      final ctx = await service.buildPersonContext('user-1', 'p1');

      expect(ctx.meetings.length, 1);
      // persons list contains only p1, not p2 (not in these meetings)
      expect(ctx.persons.length, 1);
      expect(ctx.persons.first.pseudonym, 'Friend_A');
      // Full mapping still includes p2 in personIdToPseudonym
      expect(ctx.personIdToPseudonym.containsKey('p2'), isTrue);
    });

    test('no time window filter — includes old meetings', () async {
      when(mockPersonRepo.getPersonsByUser('user-1'))
          .thenAnswer((_) async => [makePerson('p1', 'Anna')]);
      when(mockCategoryRepo.getCategories('user-1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockMeetingRepo.getMeetingsByParticipant('user-1', 'p1'))
          .thenAnswer((_) async => [
                makeMeeting(
                    id: 'old', date: outsideWindow, participantIds: ['p1']),
              ]);

      final ctx = await service.buildPersonContext('user-1', 'p1');

      // Old meeting is NOT filtered — per-person mode uses full history
      expect(ctx.meetings.length, 1);
      expect(ctx.meetings.first.name, 'Meeting old');
    });
  });

  // ---------------------------------------------------------------------------
  // serializeToPrompt
  // ---------------------------------------------------------------------------

  group('serializeToPrompt', () {
    test('empty context produces fallback messages', () {
      const ctx = BuddyContext(
        meetings: [],
        persons: [],
        pseudonymToRealName: {},
        personIdToPseudonym: {},
      );

      final output = service.serializeToPrompt(ctx);

      expect(output, contains('No meetings in this period.'));
      expect(output, contains('No friend data available.'));
    });

    test('full context includes all fields', () {
      final ctx = BuddyContext(
        meetings: [
          MeetingContextEntry(
            name: 'Lunch',
            date: DateTime(2026, 3, 5),
            pseudonymizedParticipants: const ['Friend_A'],
            activityNames: const ['Sport'],
            notes: const ['was fun'],
          ),
        ],
        persons: [
          PersonContextEntry(
            pseudonym: 'Friend_A',
            meetingCount: 5,
            topActivities: const ['Sport', 'Cinema'],
            lastMeetingDate: DateTime(2026, 3, 5),
            mostActivePeriod: 'March 2026',
          ),
        ],
        pseudonymToRealName: const {'Friend_A': 'Anna'},
        personIdToPseudonym: const {'p1': 'Friend_A'},
      );

      final output = service.serializeToPrompt(ctx, includeNotes: true);

      expect(output, contains('Lunch on 05 Mar 2026'));
      expect(output, contains('participants [Friend_A]'));
      expect(output, contains('activities [Sport]'));
      expect(output, contains('notes: [was fun]'));
      expect(output, contains('Friend_A: 5 meetings'));
      expect(output, contains('top activities: [Sport, Cinema]'));
      expect(output, contains('last met: 05 Mar 2026'));
      expect(output, contains('most active: March 2026'));
    });

    test('omits notes section when notes empty', () {
      final ctx = BuddyContext(
        meetings: [
          MeetingContextEntry(
            name: 'Coffee',
            date: DateTime(2026, 1, 1),
            pseudonymizedParticipants: const ['Friend_A'],
            activityNames: const [],
            notes: const [], // empty
          ),
        ],
        persons: const [],
        pseudonymToRealName: const {},
        personIdToPseudonym: const {},
      );

      final output = service.serializeToPrompt(ctx);

      expect(output, isNot(contains('notes:')));
    });

    test('omits top activities when list empty', () {
      const ctx = BuddyContext(
        meetings: [],
        persons: [
          PersonContextEntry(
            pseudonym: 'Friend_A',
            meetingCount: 2,
            topActivities: [], // empty
          ),
        ],
        pseudonymToRealName: {},
        personIdToPseudonym: {},
      );

      final output = service.serializeToPrompt(ctx);

      expect(output, isNot(contains('top activities:')));
      expect(output, contains('Friend_A: 2 meetings'));
    });
  });
}
