import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/screens/login_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  // Helper: builds LoginScreen with injected mock
  Widget buildLoginScreen() {
    return MaterialApp(
      home: LoginScreen(authService: mockAuthService),
    );
  }

  group('LoginScreen', () {
    testWidgets('displays app name', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Friendsheet'), findsOneWidget);
    });

    testWidgets('displays tagline', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Track Your Social Life'), findsOneWidget);
    });

    testWidgets('displays Sign in with Google button', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('displays encouraging message', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('One tap to get started! 🚀'), findsOneWidget);
    });

    testWidgets('displays terms of service and privacy policy links',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      // Both links live inside a single RichText — check plain text content
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('Terms of Service') &&
              widget.text.toPlainText().contains('Privacy Policy'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays login illustration', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/images/login_illustration.png',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator when signing in', (tester) async {
      // Use Completer to control when Future completes
      final completer = Completer<void>();
      when(mockAuthService.signInWithGoogle()).thenAnswer(
        (_) async {
          await completer.future;
          return null;
        },
      );

      await tester.pumpWidget(buildLoginScreen());
      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign in with Google'), findsNothing);

      // Complete the future to clean up pending async operations
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('hides loading indicator after cancelled sign-in',
        (tester) async {
      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => null);

      await tester.pumpWidget(buildLoginScreen());
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Sign in with Google'), findsOneWidget);
    });
  });
}
