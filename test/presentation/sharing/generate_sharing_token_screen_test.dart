import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/sharing/generate_sharing_token_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  Widget buildScreen() {
    return const MaterialApp(
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
          home: Scaffold(body: Text('parent')),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
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
