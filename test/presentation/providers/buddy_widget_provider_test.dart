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
  });
}
