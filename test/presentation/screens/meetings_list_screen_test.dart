// test/presentation/screens/meetings_list_screen_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/presentation/providers/meetings_list_provider.dart';
import 'package:friendsheet/presentation/screens/meetings_list_screen.dart';
import 'package:friendsheet/presentation/widgets/empty_state_widget.dart';
import 'package:friendsheet/presentation/widgets/meeting_card.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Firebase Core mock is required because MeetingsListProvider creates
    // AuthService(), which accesses FirebaseAuth.instance at field initialisation.
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  // Helper: creates a Meeting fixture with a controlled date and optional name.
  Meeting makeMeeting({
    required String id,
    required DateTime date,
    String name = 'Coffee with Anna',
  }) {
    return Meeting(
      id: id,
      userId: 'user-1',
      name: name,
      date: date,
      weight: 3,
      participantIds: const ['p-1'],
      createdAt: date,
      updatedAt: date,
    );
  }

  // Helper: wraps MeetingsListScreen with the given stub in a MaterialApp.
  Widget buildScreen(_StubMeetingsListProvider stub) {
    return MaterialApp(
      home: MeetingsListScreen(provider: stub),
    );
  }

  group('MeetingsListScreen', () {
    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (tester) async {
      final stub = _StubMeetingsListProvider(isLoading: true);
      await tester.pumpWidget(buildScreen(stub));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error is not null', (tester) async {
      final stub = _StubMeetingsListProvider(error: 'Failed to load meetings');
      await tester.pumpWidget(buildScreen(stub));

      expect(find.text('Failed to load meetings'), findsOneWidget);
    });

    testWidgets(
        'shows empty state when meetingsByYear is empty and not loading',
        (tester) async {
      final stub = _StubMeetingsListProvider();
      await tester.pumpWidget(buildScreen(stub));

      expect(find.text('No meetings yet — tap + to add your first one!'),
          findsOneWidget);
    });

    testWidgets('shows year header when meetings exist', (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
      // Year is collapsed — header visible but no card.
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {},
      );
      await tester.pumpWidget(buildScreen(stub));

      expect(find.text('2026'), findsOneWidget);
      expect(find.byType(MeetingCard), findsNothing);
    });

    testWidgets('shows month header when year is expanded', (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 3, 15));
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {2026},
      );
      await tester.pumpWidget(buildScreen(stub));

      // Month header label includes month name, year, and meeting count.
      expect(find.textContaining('March 2026'), findsOneWidget);
      expect(find.textContaining('1 meeting'), findsOneWidget);
    });

    testWidgets('shows MeetingCard when year and month are both expanded',
        (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {2026},
        expandedMonths: {'2026-02'},
      );
      await tester.pumpWidget(buildScreen(stub));

      expect(find.byType(MeetingCard), findsOneWidget);
    });

    testWidgets('hides MeetingCard when month is collapsed', (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {2026},
        expandedMonths: {}, // month collapsed
      );
      await tester.pumpWidget(buildScreen(stub));

      expect(find.byType(MeetingCard), findsNothing);
    });

    testWidgets('search icon appears in AppBar when meetings exist',
        (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {},
      );
      await tester.pumpWidget(buildScreen(stub));

      expect(find.byIcon(Icons.search), findsOneWidget);
      // Search field is hidden by default.
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('search field appears after tapping search icon',
        (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {},
      );
      await tester.pumpWidget(buildScreen(stub));

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) =>
            w is TextField && w.decoration?.hintText == 'Search meetings...'),
        findsOneWidget,
      );
    });

    testWidgets('filters meetings by name when search query is entered',
        (tester) async {
      final coffee = makeMeeting(
          id: 'm1', date: DateTime(2026, 2, 15), name: 'Coffee with Anna');
      final dinner = makeMeeting(
          id: 'm2', date: DateTime(2026, 3, 10), name: 'Dinner with Bob');
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [coffee, dinner]
        },
        expandedYears: {2026},
        expandedMonths: {'2026-02', '2026-03'},
      );
      await tester.pumpWidget(buildScreen(stub));

      // Both cards visible before search.
      expect(find.byType(MeetingCard), findsNWidgets(2));

      // Open search and type.
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pump();

      // Only the matching card remains.
      expect(find.byType(MeetingCard), findsOneWidget);
    });

    testWidgets('shows no-results empty state when search yields no matches',
        (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {2026},
        expandedMonths: {'2026-02'},
      );
      await tester.pumpWidget(buildScreen(stub));

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No results for "xyz"'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Manual stub — extends MeetingsListProvider so Consumer<MeetingsListProvider>
// resolves correctly. State is supplied via constructor; no real stream needed.
// ---------------------------------------------------------------------------

class _StubMeetingsListProvider extends MeetingsListProvider {
  final bool _stubIsLoading;
  final String? _stubError;
  final Map<int, List<Meeting>> _stubMeetingsByYear;
  final Set<int> _stubExpandedYears;
  final Set<String> _stubExpandedMonths;
  String _stubSearchQuery = '';

  _StubMeetingsListProvider({
    bool isLoading = false,
    String? error,
    Map<int, List<Meeting>> meetingsByYear = const {},
    Set<int> expandedYears = const {},
    Set<String> expandedMonths = const {},
  })  : _stubIsLoading = isLoading,
        _stubError = error,
        _stubMeetingsByYear = meetingsByYear,
        _stubExpandedYears = Set<int>.from(expandedYears),
        _stubExpandedMonths = Set<String>.from(expandedMonths),
        // Pass a FakeFirebaseFirestore so no real Firestore connection is opened.
        super(
          meetingRepository: MeetingRepository(
            firestore: FakeFirebaseFirestore(),
          ),
        );

  @override
  bool get isLoading => _stubIsLoading;

  @override
  String? get error => _stubError;

  @override
  String get searchQuery => _stubSearchQuery;

  @override
  void setSearchQuery(String query) {
    _stubSearchQuery = query;
    notifyListeners();
  }

  @override
  Map<int, List<Meeting>> get meetingsByYear => _stubMeetingsByYear;

  // Builds the two-level map from the stub's flat data, applying search filter.
  @override
  Map<int, Map<int, List<Meeting>>> get meetingsByYearAndMonth {
    final lower = _stubSearchQuery.trim().toLowerCase();
    final result = <int, Map<int, List<Meeting>>>{};
    for (final yearEntry in _stubMeetingsByYear.entries) {
      for (final meeting in yearEntry.value) {
        if (lower.isEmpty || meeting.name.toLowerCase().contains(lower)) {
          result
              .putIfAbsent(yearEntry.key, () => {})
              .putIfAbsent(meeting.date.month, () => [])
              .add(meeting);
        }
      }
    }
    return result;
  }

  @override
  bool isYearExpanded(int year) => _stubExpandedYears.contains(year);

  @override
  bool isMonthExpanded(String monthKey) =>
      _stubExpandedMonths.contains(monthKey);

  // No-op: state is fully controlled via constructor fields.
  @override
  void initialize(String userId) {}
}
