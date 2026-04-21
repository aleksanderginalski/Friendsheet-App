// test/presentation/screens/main_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/screens/add_meeting_screen.dart';
import 'package:friendsheet/presentation/screens/home_screen.dart';
import 'package:friendsheet/presentation/screens/main_screen.dart';
import 'package:friendsheet/presentation/screens/meetings_list_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/firebase_test_helpers.dart';
import 'main_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUpAll(() async {
    // Firebase Core mock required because MeetingsListScreen (inside the
    // IndexedStack) creates MeetingRepository and AuthService on first build.
    await setupTestFirebase();
  });

  setUp(() {
    mockAuthService = MockAuthService();
    // HomeScreen reads these getters to render the welcome message.
    when(mockAuthService.userDisplayName).thenReturn('Test User');
    when(mockAuthService.userEmail).thenReturn('test@example.com');
    when(mockAuthService.currentUser).thenReturn(null);
  });

  Widget buildMainScreen() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MainScreen(authService: mockAuthService),
    );
  }

  group('MainScreen', () {
    testWidgets('shows BottomNavigationBar with 4 tabs', (tester) async {
      await tester.pumpWidget(buildMainScreen());
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.items.length, equals(4));
    });

    testWidgets('shows Home tab content by default', (tester) async {
      await tester.pumpWidget(buildMainScreen());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('tapping Meetings tab shows MeetingsListScreen',
        (tester) async {
      await tester.pumpWidget(buildMainScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meetings'));
      await tester.pump();

      // Meetings tab is at index 1 — verify the navigation bar updated.
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, equals(1));
      // MeetingsListScreen is in the IndexedStack at index 1.
      expect(find.byType(MeetingsListScreen), findsOneWidget);
    });

    testWidgets('shows FAB button', (tester) async {
      await tester.pumpWidget(buildMainScreen());

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to AddMeetingScreen', (tester) async {
      await tester.pumpWidget(buildMainScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddMeetingScreen), findsOneWidget);
    });
  });

  group('MainScreen — drawer Import & Share section', () {
    Future<void> openDrawer(WidgetTester tester) async {
      await tester.pumpWidget(buildMainScreen());
      await tester.pumpAndSettle();
      // Open the drawer programmatically to avoid drag-gesture flakiness.
      tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
      await tester.pumpAndSettle();
    }

    testWidgets('drawer contains Import & Share section header',
        (tester) async {
      await openDrawer(tester);
      expect(find.text('Import & Share'), findsOneWidget);
    });

    testWidgets('drawer contains Share meetings with a friend tile',
        (tester) async {
      await openDrawer(tester);
      expect(find.text('Share meetings with a friend'), findsOneWidget);
    });

    testWidgets('drawer contains Import from Calendar tile', (tester) async {
      await openDrawer(tester);
      // Text may be 'Import from Calendar' or 'Browse & Import Events'.
      expect(
        find.textContaining('Calendar'),
        findsWidgets,
      );
    });
  });
}
