import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/screens/home_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    // Default stubs for user data
    when(mockAuthService.userDisplayName).thenReturn('Anna Kowalska');
    when(mockAuthService.userEmail).thenReturn('anna@example.com');
  });

  // Helper: builds HomeScreen with injected mock
  Widget buildHomeScreen() {
    return MaterialApp(
      home: HomeScreen(authService: mockAuthService),
    );
  }

  group('HomeScreen', () {
    group('UI rendering', () {
      testWidgets('displays app name in AppBar', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('FRIENDSHEET'), findsOneWidget);
      });

      testWidgets('displays logout icon button', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        expect(find.byIcon(Icons.logout), findsOneWidget);
      });

      testWidgets('displays welcome message with user name', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('Welcome back, Anna Kowalska! 👋'), findsOneWidget);
      });

      testWidgets('displays user email', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('anna@example.com'), findsOneWidget);
      });

      testWidgets('displays fallback name when displayName is null',
          (tester) async {
        when(mockAuthService.userDisplayName).thenReturn(null);
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('Welcome back, Friend! 👋'), findsOneWidget);
      });

      testWidgets('displays ADD NEW MEETING button', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        expect(find.text('ADD NEW MEETING'), findsOneWidget);
      });
    });

    group('logout flow', () {
      testWidgets('tapping logout shows confirmation dialog', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        expect(find.text('Log Out?'), findsOneWidget);
        expect(find.text('CANCEL'), findsOneWidget);
        expect(find.text('LOG OUT'), findsOneWidget);
      });

      testWidgets('cancelling logout dismisses dialog', (tester) async {
        await tester.pumpWidget(buildHomeScreen());
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        await tester.tap(find.text('CANCEL'));
        await tester.pumpAndSettle();

        expect(find.text('Log Out?'), findsNothing);
        verifyNever(mockAuthService.signOut());
      });

      testWidgets('confirming logout calls signOut', (tester) async {
        when(mockAuthService.signOut()).thenAnswer((_) async {
          return;
        });

        await tester.pumpWidget(buildHomeScreen());
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        await tester.tap(find.text('LOG OUT'));
        await tester.pumpAndSettle();

        verify(mockAuthService.signOut()).called(1);
      });
    });
  });
}
