import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/widgets/build_meeting_base_cta_card.dart';

void main() {
  Widget buildCard({
    VoidCallback? onImport,
    VoidCallback? onShareToken,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BuildMeetingBaseCtaCard(
          onImport: onImport ?? () {},
          onShareToken: onShareToken ?? () {},
        ),
      ),
    );
  }

  group('BuildMeetingBaseCtaCard', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Build your meeting base'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(
        find.textContaining('fewer than 50 meetings'),
        findsOneWidget,
      );
    });

    testWidgets('renders Import from Calendar button', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Import from Calendar'), findsOneWidget);
    });

    testWidgets('renders Request from a friend button', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Request from a friend'), findsOneWidget);
    });

    testWidgets('tapping Import from Calendar calls onImport', (tester) async {
      var called = false;
      await tester.pumpWidget(buildCard(onImport: () => called = true));

      await tester.tap(find.text('Import from Calendar'));
      expect(called, isTrue);
    });

    testWidgets('tapping Request from a friend calls onShareToken',
        (tester) async {
      var called = false;
      await tester.pumpWidget(buildCard(onShareToken: () => called = true));

      await tester.tap(find.text('Request from a friend'));
      expect(called, isTrue);
    });

    testWidgets('both buttons are ElevatedButton', (tester) async {
      await tester.pumpWidget(buildCard());
      // Both actions use ElevatedButton (green background).
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });
  });
}
