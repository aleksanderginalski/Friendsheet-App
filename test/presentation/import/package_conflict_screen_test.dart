import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/pending_meeting_package_repository.dart';
import 'package:friendsheet/presentation/import/package_conflict_screen.dart';
import 'package:friendsheet/presentation/providers/shared_package_inbox_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package_conflict_screen_test.mocks.dart';

@GenerateMocks([PendingMeetingPackageRepository, MeetingRepository])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockPendingMeetingPackageRepository mockPackageRepo;
  late MockMeetingRepository mockMeetingRepo;

  Meeting makeMeeting({String id = 'm1', DateTime? date}) => Meeting(
        id: id,
        userId: 'u1',
        name: 'Existing Meeting',
        date: date ?? DateTime(2026, 3, 15),
        weight: 3,
        participantIds: const ['p1'],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  PendingMeetingPackage makePackage({
    String id = 'pkg1',
    DateTime? meetingDate,
    String meetingName = 'Kino',
  }) =>
      PendingMeetingPackage(
        id: id,
        senderUid: 'sender-uid',
        senderFirstName: 'Ania',
        senderLastName: 'Kowalska',
        sentAt: DateTime(2026, 3, 20),
        meetings: [
          SharedMeeting(
            name: meetingName,
            date: meetingDate ?? DateTime(2026, 3, 21),
            weight: 3,
          ),
        ],
      );

  Future<SharedPackageInboxProvider> makeProvider({
    required PendingMeetingPackage pkg,
    List<Meeting> existingMeetings = const [],
  }) async {
    when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
    when(mockMeetingRepo.getMeetingsByUser('u1'))
        .thenAnswer((_) => Stream.value(existingMeetings));

    final provider = SharedPackageInboxProvider(
      packageRepository: mockPackageRepo,
      meetingRepository: mockMeetingRepo,
    );
    await provider.initialize('u1');
    return provider;
  }

  Widget buildScreen(
    SharedPackageInboxProvider provider,
    PendingMeetingPackage pkg,
  ) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        home: PackageConflictScreen(package: pkg),
      ),
    );
  }

  setUp(() {
    mockPackageRepo = MockPendingMeetingPackageRepository();
    mockMeetingRepo = MockMeetingRepository();
  });

  group('no-conflict scenario', () {
    testWidgets('renders title and sender name', (tester) async {
      final pkg = makePackage();
      final provider = await makeProvider(pkg: pkg);

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.text('Review Package'), findsOneWidget);
      expect(find.text('From Ania Kowalska'), findsOneWidget);
    });

    testWidgets('shows check icon and meeting name for non-conflicting meeting',
        (tester) async {
      final pkg = makePackage(meetingName: 'Kino');
      final provider = await makeProvider(pkg: pkg);

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('Kino'), findsOneWidget);
    });

    testWidgets('Continue button is enabled when no conflicts', (tester) async {
      final pkg = makePackage();
      final provider = await makeProvider(pkg: pkg);

      await tester.pumpWidget(buildScreen(provider, pkg));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping Continue dismisses package and pops screen',
        (tester) async {
      final pkg = makePackage();
      final provider = await makeProvider(pkg: pkg);

      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: PackageConflictScreen(package: pkg),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(provider.hasPackages, isFalse);
    });
  });

  group('conflict scenario', () {
    testWidgets('shows Received and Yours headers when conflict exists',
        (tester) async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);
      final provider = await makeProvider(
        pkg: pkg,
        existingMeetings: [existing],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.text('Received'), findsOneWidget);
      expect(find.text('Yours'), findsOneWidget);
    });

    testWidgets('shows Date conflict warning text', (tester) async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);
      final provider = await makeProvider(
        pkg: pkg,
        existingMeetings: [existing],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.textContaining('Date conflict'), findsOneWidget);
    });

    testWidgets('shows all three resolution buttons', (tester) async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);
      final provider = await makeProvider(
        pkg: pkg,
        existingMeetings: [existing],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      expect(find.text('Merge (same meeting)'), findsOneWidget);
      expect(find.text('Add as new'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Continue button is disabled before any resolution is chosen',
        (tester) async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);
      final provider = await makeProvider(
        pkg: pkg,
        existingMeetings: [existing],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'Continue button enabled after resolution chosen and selected button is FilledButton',
        (tester) async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);
      final provider = await makeProvider(
        pkg: pkg,
        existingMeetings: [existing],
      );

      await tester.pumpWidget(buildScreen(provider, pkg));

      await tester.tap(find.text('Merge (same meeting)'));
      await tester.pump();

      final continueButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue'),
      );
      expect(continueButton.onPressed, isNotNull);

      // Merge button should now be a FilledButton (selected state).
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}
