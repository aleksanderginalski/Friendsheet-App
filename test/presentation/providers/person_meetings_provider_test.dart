import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/presentation/providers/person_meetings_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'person_meetings_provider_test.mocks.dart';

@GenerateMocks([MeetingRepository])
void main() {
  late MockMeetingRepository mockRepo;
  late PersonMeetingsProvider provider;

  Meeting makeMeeting({required String id, required DateTime date}) {
    return Meeting(
      id: id,
      userId: 'u1',
      name: 'Meeting $id',
      date: date,
      weight: 3,
      participantIds: const ['p1'],
      createdAt: date,
      updatedAt: date,
    );
  }

  setUp(() {
    mockRepo = MockMeetingRepository();
    provider = PersonMeetingsProvider(meetingRepository: mockRepo);
  });

  tearDown(() => provider.dispose());

  group('PersonMeetingsProvider', () {
    group('initial state', () {
      test('all defaults', () {
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
        expect(provider.meetings, isEmpty);
        expect(provider.meetingsByYearAndMonth, isEmpty);
      });
    });

    group('loadMeetings', () {
      test('happy path: stores meetings and clears loading/error', () async {
        final m = makeMeeting(id: 'm1', date: DateTime(2025, 3, 10));
        when(mockRepo.getMeetingsByParticipant('u1', 'p1'))
            .thenAnswer((_) async => [m]);

        await provider.loadMeetings('u1', 'p1');

        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
        expect(provider.meetings, [m]);
      });

      test('error: sets error message and keeps meetings empty', () async {
        when(mockRepo.getMeetingsByParticipant('u1', 'p1'))
            .thenThrow(Exception('network'));

        await provider.loadMeetings('u1', 'p1');

        expect(provider.isLoading, isFalse);
        expect(provider.error, equals('Failed to load meetings'));
        expect(provider.meetings, isEmpty);
      });

      test('expands current year after successful load', () async {
        when(mockRepo.getMeetingsByParticipant('u1', 'p1'))
            .thenAnswer((_) async => []);

        await provider.loadMeetings('u1', 'p1');

        expect(provider.isYearExpanded(DateTime.now().year), isTrue);
      });
    });

    group('meetingsByYearAndMonth', () {
      test('groups meetings by year then month, sorted descending', () async {
        final m1 = makeMeeting(id: 'm1', date: DateTime(2024, 3, 1));
        final m2 = makeMeeting(id: 'm2', date: DateTime(2024, 3, 15));
        final m3 = makeMeeting(id: 'm3', date: DateTime(2023, 11, 5));
        when(mockRepo.getMeetingsByParticipant('u1', 'p1'))
            .thenAnswer((_) async => [m1, m2, m3]);

        await provider.loadMeetings('u1', 'p1');

        final grouped = provider.meetingsByYearAndMonth;
        final years = grouped.keys.toList();
        expect(years, [2024, 2023]); // descending
        expect(grouped[2024]!.keys.toList(), [3]); // only March
        expect(grouped[2024]![3], hasLength(2)); // m1 + m2
        expect(grouped[2023]![11], hasLength(1)); // m3
      });
    });

    group('toggleYear', () {
      test('expands then collapses on repeated taps', () {
        provider.toggleYear(2025);
        expect(provider.isYearExpanded(2025), isTrue);

        provider.toggleYear(2025);
        expect(provider.isYearExpanded(2025), isFalse);
      });
    });

    group('toggleMonth', () {
      test('expands then collapses on repeated taps', () {
        provider.toggleMonth(2025, 3);
        expect(provider.isMonthExpanded('2025-03'), isTrue);

        provider.toggleMonth(2025, 3);
        expect(provider.isMonthExpanded('2025-03'), isFalse);
      });
    });
  });
}
