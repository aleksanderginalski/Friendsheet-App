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
  Meeting makeMeeting({
    required String id,
    required DateTime date,
    String name = 'Test Meeting',
  }) {
    return Meeting(
      id: id,
      userId: 'user-1',
      name: name,
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
    // Stub getMeetingsSnapshot so the metadata subscription in initialize()
    // does not throw MissingStubError. Returns empty stream — hasPendingWrites
    // stays false in all tests that do not explicitly test it.
    when(mockMeetingRepository.getMeetingsSnapshot(any))
        .thenAnswer((_) => const Stream.empty());
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
      test('all defaults', () {
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
        expect(provider.meetingsByYear, isEmpty);
        expect(provider.meetingsByYearAndMonth, isEmpty);
      });
    });

    group('initialize()', () {
      test('isLoading true before stream emits, false after', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        // isLoading must be true immediately — stream has not emitted yet.
        expect(provider.isLoading, isTrue);

        controller.add([]);
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
      test('groups meetings by year, sorted descending', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        final meeting2026a = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
        final meeting2026b = makeMeeting(id: 'm2', date: DateTime(2026, 1, 10));
        final meeting2025 = makeMeeting(id: 'm3', date: DateTime(2025, 12, 25));

        provider.initialize('user-1');
        controller.add([meeting2026a, meeting2026b, meeting2025]);
        await Future.delayed(Duration.zero);

        expect(provider.meetingsByYear[2026], hasLength(2));
        expect(provider.meetingsByYear[2025], hasLength(1));
        expect(provider.meetingsByYear[2026],
            containsAll([meeting2026a, meeting2026b]));
        expect(provider.meetingsByYear[2025], contains(meeting2025));
        expect(provider.meetingsByYear.keys.toList(), equals([2026, 2025]));
      });
    });

    group('meetingsByYearAndMonth', () {
      test('groups meetings by month within a year, months sorted descending',
          () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        final m1 = makeMeeting(id: 'm1', date: DateTime(2026, 3, 1));
        final m2 = makeMeeting(id: 'm2', date: DateTime(2026, 3, 15));
        final m3 = makeMeeting(id: 'm3', date: DateTime(2026, 1, 10));

        provider.initialize('user-1');
        controller.add([m1, m2, m3]);
        await Future.delayed(Duration.zero);

        final byYearAndMonth = provider.meetingsByYearAndMonth;
        expect(byYearAndMonth[2026]?[3], hasLength(2));
        expect(byYearAndMonth[2026]?[1], hasLength(1));
        expect(byYearAndMonth[2026]?[3], containsAll([m1, m2]));
        expect(byYearAndMonth[2026]!.keys.toList(), equals([3, 1]));
      });

      test('filters by searchQuery and still produces two-level map', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        final coffee =
            makeMeeting(id: 'm1', date: DateTime(2026, 3, 1), name: 'Coffee');
        final dinner =
            makeMeeting(id: 'm2', date: DateTime(2026, 3, 15), name: 'Dinner');

        provider.initialize('user-1');
        controller.add([coffee, dinner]);
        await Future.delayed(Duration.zero);

        provider.setSearchQuery('coffee');
        final filtered = provider.meetingsByYearAndMonth;

        expect(filtered[2026]?[3], hasLength(1));
        expect(filtered[2026]?[3]?.first.name, equals('Coffee'));

        // Non-matching query → empty map.
        provider.setSearchQuery('xyz');
        expect(provider.meetingsByYearAndMonth, isEmpty);
      });
    });

    group('default expanded months', () {
      test('current month expanded; arbitrary past month is not', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        provider.initialize('user-1');
        controller.add([]);
        await Future.delayed(Duration.zero);

        final now = DateTime.now();
        final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        expect(provider.isMonthExpanded(key), isTrue);
        expect(provider.isMonthExpanded('2020-01'), isFalse);
      });

      test('most recent past month with data is also expanded', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        // Use a past date that is before the current month.
        final pastDate = DateTime(2020, 6, 1);
        provider.initialize('user-1');
        controller.add([makeMeeting(id: 'm1', date: pastDate)]);
        await Future.delayed(Duration.zero);

        expect(provider.isMonthExpanded('2020-06'), isTrue);
      });
    });

    group('toggleMonth()', () {
      test('expands a collapsed month, then collapses it', () {
        expect(provider.isMonthExpanded('2026-03'), isFalse);
        provider.toggleMonth(2026, 3);
        expect(provider.isMonthExpanded('2026-03'), isTrue);
        provider.toggleMonth(2026, 3);
        expect(provider.isMonthExpanded('2026-03'), isFalse);
      });

      test('does not affect other months', () {
        provider.toggleMonth(2026, 3);
        expect(provider.isMonthExpanded('2026-04'), isFalse);
        expect(provider.isMonthExpanded('2025-03'), isFalse);
      });
    });

    group('toggleYear()', () {
      test('expands a collapsed year, then collapses it', () async {
        final controller = StreamController<List<Meeting>>();
        addTearDown(controller.close);
        when(mockMeetingRepository.getMeetingsByUser(any))
            .thenAnswer((_) => controller.stream);

        // Year 2020 is not expanded before initialize().
        expect(provider.isYearExpanded(2020), isFalse);
        provider.toggleYear(2020);
        expect(provider.isYearExpanded(2020), isTrue);

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

    group('isSearchActive', () {
      test('returns false for empty, short, or whitespace-only query', () {
        provider.setSearchQuery('');
        expect(provider.isSearchActive, isFalse);
        provider.setSearchQuery('ab');
        expect(provider.isSearchActive, isFalse);
        provider.setSearchQuery('  a '); // 1 char after trim
        expect(provider.isSearchActive, isFalse);
      });

      test('returns true when 3 or more characters after trim', () {
        provider.setSearchQuery('abc');
        expect(provider.isSearchActive, isTrue);
        provider.setSearchQuery('abcd');
        expect(provider.isSearchActive, isTrue);
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
