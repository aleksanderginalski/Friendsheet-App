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
import 'package:friendsheet/presentation/widgets/meeting_card.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Firebase Core mock is required because MeetingsListProvider creates
    // AuthService(), which accesses FirebaseAuth.instance at field initialisation.
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  // Helper: creates a Meeting fixture with a controlled date.
  Meeting makeMeeting({required String id, required DateTime date}) {
    return Meeting(
      id: id,
      userId: 'user-1',
      name: 'Coffee with Anna',
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

    testWidgets('shows MeetingCard when year is expanded', (tester) async {
      final meeting = makeMeeting(id: 'm1', date: DateTime(2026, 2, 15));
      final stub = _StubMeetingsListProvider(
        meetingsByYear: {
          2026: [meeting]
        },
        expandedYears: {2026},
      );
      await tester.pumpWidget(buildScreen(stub));

      expect(find.byType(MeetingCard), findsOneWidget);
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

  _StubMeetingsListProvider({
    bool isLoading = false,
    String? error,
    Map<int, List<Meeting>> meetingsByYear = const {},
    Set<int> expandedYears = const {},
  })  : _stubIsLoading = isLoading,
        _stubError = error,
        _stubMeetingsByYear = meetingsByYear,
        _stubExpandedYears = Set<int>.from(expandedYears),
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
  Map<int, List<Meeting>> get meetingsByYear => _stubMeetingsByYear;

  @override
  bool isYearExpanded(int year) => _stubExpandedYears.contains(year);

  // No-op: state is fully controlled via constructor fields.
  @override
  void initialize(String userId) {}
}
