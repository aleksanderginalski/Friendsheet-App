// test/presentation/providers/meetings_list_provider_test.dart

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/meetings_list_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'meetings_list_provider_test.mocks.dart';

@GenerateMocks([MeetingRepository, AuthService])
void main() {
  late MockMeetingRepository mockMeetingRepository;
  late MockAuthService mockAuthService;
  late MeetingsListProvider provider;

  // Helper: creates a Meeting with a specific date for stream/grouping tests.
  Meeting makeMeeting({required String id, required DateTime date}) {
    return Meeting(
      id: id,
      userId: 'user-1',
      name: 'Test Meeting',
      date: date,
      weight: 3,
      participantIds: const ['person-1'],
      createdAt: date,
      updatedAt: date,
    );
  }

  setUp(() {
    mockMeetingRepository = MockMeetingRepository();
    mockAuthService = MockAuthService();
    provider = MeetingsListProvider(
      meetingRepository: mockMeetingRepository,
      authService: mockAuthService,
    );
  });

  tearDown(() {
    provider.dispose();
  });

  group('MeetingsListProvider', () {
    group('initial state', () {
      test('isLoading is false', () {
        expect(provider.isLoading, isFalse);
      });

      test('error is null', () {
        expect(provider.error, isNull);
      });

      test('meetingsByYear is empty', () {
        expect(provider.meetingsByYear, isEmpty);
      });
    });

    group('initialize()', () {
      test('sets isLoading true before stream emits', () {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');

        // isLoading must be true immediately — stream has not emitted yet.
        expect(provider.isLoading, isTrue);
      });

      test('sets isLoading false after stream emits data', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        controller.add([]);
        // Yield to the event loop so the stream listener runs.
        await Future.delayed(Duration.zero);

        expect(provider.isLoading, isFalse);
      });

      test('current year and previous year are expanded by default', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        controller.add([]);
        await Future.delayed(Duration.zero);

        final currentYear = DateTime.now().year;
        expect(provider.isYearExpanded(currentYear), isTrue);
        expect(provider.isYearExpanded(currentYear - 1), isTrue);
        // Year two steps back is not expanded by default.
        expect(provider.isYearExpanded(currentYear - 2), isFalse);
      });
    });

    group('meetingsByYear', () {
      // Fixtures: two meetings in 2026 and one in 2025.
      late Meeting meeting2026a;
      late Meeting meeting2026b;
      late Meeting meeting2025;

      setUp(() {
        meeting2026a = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
        meeting2026b = makeMeeting(id: 'm2', date: DateTime(2026, 1, 10));
        meeting2025 = makeMeeting(id: 'm3', date: DateTime(2025, 12, 25));
      });

      // Emits the three fixtures and waits for the listener to run.
      Future<void> emitMeetings(
          StreamController<List<Meeting>> controller) async {
        controller.add([meeting2026a, meeting2026b, meeting2025]);
        await Future.delayed(Duration.zero);
      }

      test('groups meetings by year correctly', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        await emitMeetings(controller);

        expect(provider.meetingsByYear[2026], hasLength(2));
        expect(provider.meetingsByYear[2025], hasLength(1));
        expect(provider.meetingsByYear[2026], contains(meeting2026a));
        expect(provider.meetingsByYear[2026], contains(meeting2026b));
        expect(provider.meetingsByYear[2025], contains(meeting2025));
      });

      test('returns years sorted descending', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        await emitMeetings(controller);

        final years = provider.meetingsByYear.keys.toList();
        expect(years, equals([2026, 2025]));
      });
    });

    group('toggleYear()', () {
      test('expands a collapsed year', () {
        // Year 2020 is not in the expanded set before initialize() is called.
        expect(provider.isYearExpanded(2020), isFalse);

        provider.toggleYear(2020);

        expect(provider.isYearExpanded(2020), isTrue);
      });

      test('collapses an expanded year', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        controller.add([]);
        await Future.delayed(Duration.zero);

        // Current year is expanded by default after initialize().
        final currentYear = DateTime.now().year;
        expect(provider.isYearExpanded(currentYear), isTrue);

        provider.toggleYear(currentYear);

        expect(provider.isYearExpanded(currentYear), isFalse);
      });
    });

    group('error handling', () {
      test('error is set when stream emits an error', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        controller.addError(Exception('Firestore error'));
        await Future.delayed(Duration.zero);

        expect(provider.error, equals('Failed to load meetings'));
        expect(provider.isLoading, isFalse);
      });
    });
  });
}
