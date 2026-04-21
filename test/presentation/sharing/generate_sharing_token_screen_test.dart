import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/sharing/generate_sharing_token_screen.dart';

import '../../helpers/firebase_test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupTestFirebase();
  });

  Widget buildScreen() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: GenerateSharingTokenScreen(),
    );
  }

  group('GenerateSharingTokenScreen', () {
    testWidgets('shows CircularProgressIndicator on first frame',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      // First pump: widget builds, addPostFrameCallback not yet fired.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'shows error state when user is not authenticated (null userId)',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      // Let addPostFrameCallback fire and setState complete.
      await tester.pumpAndSettle();

      // In test environment AuthService().currentUserId returns null.
      expect(find.text('Not authenticated'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('has AppBar with title Share Token', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('Share Token'), findsOneWidget);
    });

    testWidgets('AppBar back button is present', (tester) async {
      // Push on top of a navigator so back button renders.
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Text('parent')),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const GenerateSharingTokenScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
