import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/providers/buddy_widget_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'buddy_widget_provider_test.mocks.dart';

@GenerateMocks([MeetingRepository, PersonRepository])
void main() {
  late MockMeetingRepository mockMeetingRepository;
  late MockPersonRepository mockPersonRepository;
  late BuddyWidgetProvider provider;

  final testMeeting = Meeting(
    id: 'm1',
    userId: 'user-1',
    name: 'Gloomhaven',
    date: DateTime(2026, 3, 1),
    weight: 3,
    participantIds: const [],
    createdAt: DateTime(2026, 3, 1),
    updatedAt: DateTime(2026, 3, 1),
  );

  setUp(() {
    mockMeetingRepository = MockMeetingRepository();
    mockPersonRepository = MockPersonRepository();
    // Default stub: no persons — no birthday logic runs.
    // ignore: argument_type_not_assignable
    when(mockPersonRepository.getPersonsByUser(any))
        .thenAnswer((_) async => <Person>[]);
    // Default stubs for LTNS detection (new in US-102).
    // ignore: argument_type_not_assignable
    when(mockMeetingRepository.getPersonIdsSeenSince(any, any))
        .thenAnswer((_) async => <String>{});
    // ignore: argument_type_not_assignable
    when(mockMeetingRepository.getRecentMeetingsByPerson(
      any,
      any,
      // ignore: argument_type_not_assignable
      limit: anyNamed('limit'),
    )).thenAnswer((_) async => <Meeting>[]);
  });

  tearDown(() {
    provider.dispose();
  });

  group('BuddyWidgetProvider', () {
    test('initial state: not initialized, expanded, no suggested meetings', () {
      provider = BuddyWidgetProvider(
        meetingRepository: mockMeetingRepository,
        personRepository: mockPersonRepository,
      );

      expect(provider.isInitialized, isFalse);
      expect(provider.isExpanded, isTrue);
      expect(provider.suggestedMeetings, isEmpty);
    });

    test(
        'initialize sets suggestedMeetings and isInitialized when meetings found',
        () async {
      // ignore: argument_type_not_assignable
      when(mockMeetingRepository.getRecentMeetingsWithoutNotes(any, any))
          .thenAnswer((_) async => [testMeeting]);

      provider = BuddyWidgetProvider(
        meetingRepository: mockMeetingRepository,
        personRepository: mockPersonRepository,
      );
      await provider.initialize('user-1');

      expect(provider.isInitialized, isTrue);
      expect(provider.suggestedMeetings, equals([testMeeting]));
    });

    test('initialize sets isInitialized with empty meetings when none found',
        () async {
      // ignore: argument_type_not_assignable
      when(mockMeetingRepository.getRecentMeetingsWithoutNotes(any, any))
          .thenAnswer((_) async => <Meeting>[]);

      provider = BuddyWidgetProvider(
        meetingRepository: mockMeetingRepository,
        personRepository: mockPersonRepository,
      );
      await provider.initialize('user-1');

      expect(provider.isInitialized, isTrue);
      expect(provider.suggestedMeetings, isEmpty);
    });

    test('collapse sets isExpanded to false', () async {
      // ignore: argument_type_not_assignable
      when(mockMeetingRepository.getRecentMeetingsWithoutNotes(any, any))
          .thenAnswer((_) async => <Meeting>[]);

      provider = BuddyWidgetProvider(
        meetingRepository: mockMeetingRepository,
        personRepository: mockPersonRepository,
      );
      await provider.initialize('user-1');

      provider.collapse();

      expect(provider.isExpanded, isFalse);
    });

    test('expand restores isExpanded to true after collapse', () async {
      // ignore: argument_type_not_assignable
      when(mockMeetingRepository.getRecentMeetingsWithoutNotes(any, any))
          .thenAnswer((_) async => <Meeting>[]);

      provider = BuddyWidgetProvider(
        meetingRepository: mockMeetingRepository,
        personRepository: mockPersonRepository,
      );
      await provider.initialize('user-1');
      provider.collapse();
      provider.expand();

      expect(provider.isExpanded, isTrue);
    });

    group('LTNS detection', () {
      Person makeLapsedPerson(String id, String firstName) => Person(
            id: id,
            userId: 'user-1',
            firstName: firstName,
            createdAt: DateTime(2026, 1, 1),
          );

      setUp(() {
        // ignore: argument_type_not_assignable
        when(mockMeetingRepository.getRecentMeetingsWithoutNotes(any, any))
            .thenAnswer((_) async => <Meeting>[]);
      });

      test('happy path — person not seen in 90+ days appears in lapsedPersons',
          () async {
        final person = makeLapsedPerson('p-lapsed', 'Lapsed');
        // ignore: argument_type_not_assignable
        when(mockPersonRepository.getPersonsByUser(any))
            .thenAnswer((_) async => [person]);
        // Person not seen recently → not in recentIds.
        // ignore: argument_type_not_assignable
        when(mockMeetingRepository.getPersonIdsSeenSince(any, any))
            .thenAnswer((_) async => <String>{});
        // Has one historical meeting 100 days ago.
        final oldMeeting = testMeeting.copyWith(
          participantIds: ['p-lapsed'],
          date: DateTime.now().subtract(const Duration(days: 100)),
        );
        // ignore: argument_type_not_assignable
        when(mockMeetingRepository.getRecentMeetingsByPerson(
          any,
          any,
          // ignore: argument_type_not_assignable
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => [oldMeeting]);

        provider = BuddyWidgetProvider(
          meetingRepository: mockMeetingRepository,
          personRepository: mockPersonRepository,
        );
        await provider.initialize('user-1');

        expect(provider.lapsedPersons.length, 1);
        expect(provider.lapsedPersons.first.person.id, 'p-lapsed');
        expect(provider.lapsedPersons.first.daysSinceLastMeeting,
            greaterThanOrEqualTo(100));
      });

      test('person seen recently is excluded from lapsedPersons', () async {
        final person = makeLapsedPerson('p-recent', 'Recent');
        // ignore: argument_type_not_assignable
        when(mockPersonRepository.getPersonsByUser(any))
            .thenAnswer((_) async => [person]);
        // Person IS in recentIds → excluded.
        // ignore: argument_type_not_assignable
        when(mockMeetingRepository.getPersonIdsSeenSince(any, any))
            .thenAnswer((_) async => <String>{'p-recent'});

        provider = BuddyWidgetProvider(
          meetingRepository: mockMeetingRepository,
          personRepository: mockPersonRepository,
        );
        await provider.initialize('user-1');

        expect(provider.lapsedPersons, isEmpty);
      });

      test(
          'person never met (no historical meetings) excluded from lapsedPersons',
          () async {
        final person = makeLapsedPerson('p-never', 'Never');
        // ignore: argument_type_not_assignable
        when(mockPersonRepository.getPersonsByUser(any))
            .thenAnswer((_) async => [person]);
        // Not in recentIds but also no historical meetings.
        // ignore: argument_type_not_assignable
        when(mockMeetingRepository.getPersonIdsSeenSince(any, any))
            .thenAnswer((_) async => <String>{});
        // ignore: argument_type_not_assignable
        when(mockMeetingRepository.getRecentMeetingsByPerson(
          any,
          any,
          // ignore: argument_type_not_assignable
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => <Meeting>[]);

        provider = BuddyWidgetProvider(
          meetingRepository: mockMeetingRepository,
          personRepository: mockPersonRepository,
        );
        await provider.initialize('user-1');

        expect(provider.lapsedPersons, isEmpty);
      });
    });

    group('birthday detection', () {
      Person makePerson({
        required String id,
        required String firstName,
        String? birthDayMonth,
      }) =>
          Person(
            id: id,
            userId: 'user-1',
            firstName: firstName,
            createdAt: DateTime(2026, 1, 1),
            birthDayMonth: birthDayMonth,
          );

      setUp(() {
        // ignore: argument_type_not_assignable
        when(mockMeetingRepository.getRecentMeetingsWithoutNotes(any, any))
            .thenAnswer((_) async => <Meeting>[]);
      });

      test(
          'happy path — populates upcomingBirthdayInfo, daysUntilBirthday and urgentBirthdayPersons',
          () async {
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        // Birthday 2 days from today → urgent (< 5). Use explicit datetime
        // arithmetic to avoid DST-induced off-by-one in Duration(days: N).
        final soonDate = DateTime(today.year, today.month, today.day + 2);
        final soonBdm =
            '${soonDate.month.toString().padLeft(2, '0')}-${soonDate.day.toString().padLeft(2, '0')}';
        // Birthday 30 days from today → not urgent.
        final laterDate = DateTime(today.year, today.month, today.day + 30);
        final laterBdm =
            '${laterDate.month.toString().padLeft(2, '0')}-${laterDate.day.toString().padLeft(2, '0')}';

        final personSoon =
            makePerson(id: 'p-soon', firstName: 'Soon', birthDayMonth: soonBdm);
        final personLater = makePerson(
            id: 'p-later', firstName: 'Later', birthDayMonth: laterBdm);

        // ignore: argument_type_not_assignable
        when(mockPersonRepository.getPersonsByUser(any))
            .thenAnswer((_) async => [personSoon, personLater]);

        provider = BuddyWidgetProvider(
          meetingRepository: mockMeetingRepository,
          personRepository: mockPersonRepository,
        );
        await provider.initialize('user-1');

        expect(provider.upcomingBirthdayInfo.length, 2);
        // soonBdm person should have daysUntil < laterBdm person → sorted first.
        expect(provider.upcomingBirthdayInfo.first.person.id, 'p-soon');
        final soonDays = provider.daysUntilBirthday['p-soon']!;
        final laterDays = provider.daysUntilBirthday['p-later']!;
        expect(soonDays, lessThan(5)); // urgent threshold
        expect(laterDays, greaterThan(soonDays));
        // urgent: only person within next 5 days
        expect(provider.urgentBirthdayPersons.length, 1);
        expect(provider.urgentBirthdayPersons.first.id, 'p-soon');
      });

      test('persons without birthDayMonth are excluded from birthday lists',
          () async {
        final personNoBirth = makePerson(id: 'p-no', firstName: 'NoBirth');

        // ignore: argument_type_not_assignable
        when(mockPersonRepository.getPersonsByUser(any))
            .thenAnswer((_) async => [personNoBirth]);

        provider = BuddyWidgetProvider(
          meetingRepository: mockMeetingRepository,
          personRepository: mockPersonRepository,
        );
        await provider.initialize('user-1');

        expect(provider.upcomingBirthdayInfo, isEmpty);
        expect(provider.urgentBirthdayPersons, isEmpty);
        expect(provider.daysUntilBirthday, isEmpty);
      });

      test('birthday today is treated as upcoming (daysUntil == 0)', () async {
        final today = DateTime.now();
        final bdm =
            '${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final person =
            makePerson(id: 'p-today', firstName: 'Today', birthDayMonth: bdm);

        // ignore: argument_type_not_assignable
        when(mockPersonRepository.getPersonsByUser(any))
            .thenAnswer((_) async => [person]);

        provider = BuddyWidgetProvider(
          meetingRepository: mockMeetingRepository,
          personRepository: mockPersonRepository,
        );
        await provider.initialize('user-1');

        expect(provider.daysUntilBirthday['p-today'], 0);
        expect(provider.urgentBirthdayPersons, contains(person));
      });
    });
  });
}
