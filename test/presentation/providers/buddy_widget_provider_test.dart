import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/presentation/providers/buddy_widget_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'buddy_widget_provider_test.mocks.dart';

@GenerateMocks([MeetingRepository])
void main() {
  late MockMeetingRepository mockRepository;
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
    mockRepository = MockMeetingRepository();
  });

  tearDown(() {
    provider.dispose();
  });

  group('BuddyWidgetProvider', () {
    test('initial state: not initialized, expanded, no suggested meeting', () {
      provider = BuddyWidgetProvider(meetingRepository: mockRepository);

      expect(provider.isInitialized, isFalse);
      expect(provider.isExpanded, isTrue);
      expect(provider.suggestedMeeting, isNull);
    });

    test(
        'initialize sets suggestedMeeting and isInitialized when meeting found',
        () async {
      // ignore: argument_type_not_assignable
      when(mockRepository.getLastMeetingWithoutNotes(any, any))
          .thenAnswer((_) async => testMeeting);

      provider = BuddyWidgetProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');

      expect(provider.isInitialized, isTrue);
      expect(provider.suggestedMeeting, equals(testMeeting));
    });

    test('initialize sets isInitialized with null meeting when none found',
        () async {
      // ignore: argument_type_not_assignable
      when(mockRepository.getLastMeetingWithoutNotes(any, any))
          .thenAnswer((_) async => null);

      provider = BuddyWidgetProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');

      expect(provider.isInitialized, isTrue);
      expect(provider.suggestedMeeting, isNull);
    });

    test('collapse sets isExpanded to false', () async {
      // ignore: argument_type_not_assignable
      when(mockRepository.getLastMeetingWithoutNotes(any, any))
          .thenAnswer((_) async => null);

      provider = BuddyWidgetProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');

      provider.collapse();

      expect(provider.isExpanded, isFalse);
    });

    test('expand restores isExpanded to true after collapse', () async {
      // ignore: argument_type_not_assignable
      when(mockRepository.getLastMeetingWithoutNotes(any, any))
          .thenAnswer((_) async => null);

      provider = BuddyWidgetProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');
      provider.collapse();
      provider.expand();

      expect(provider.isExpanded, isTrue);
    });
  });
}
