import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/widgets/year_stepper.dart';

void main() {
  // Helper: wraps YearStepper in a minimal app.
  Widget buildStepper({
    required int selectedYear,
    required List<int> availableYears,
    required ValueChanged<int> onYearChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: YearStepper(
          selectedYear: selectedYear,
          availableYears: availableYears,
          onYearChanged: onYearChanged,
        ),
      ),
    );
  }

  group('YearStepper', () {
    test('widget can be instantiated', () {
      expect(
        () => YearStepper(
          selectedYear: 2026,
          availableYears: const [2026, 2025],
          onYearChanged: (_) {},
        ),
        returnsNormally,
      );
    });

    testWidgets('renders selected year as text', (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2025,
        availableYears: const [2026, 2025, 2024],
        onYearChanged: (_) {},
      ));

      expect(find.text('2025'), findsOneWidget);
    });

    testWidgets('left arrow is disabled when on oldest year', (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2026, 2025, 2024],
        onYearChanged: (_) {},
      ));

      final leftButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(leftButton.onPressed, isNull);
    });

    testWidgets('right arrow is disabled when on newest year', (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2026,
        availableYears: const [2026, 2025, 2024],
        onYearChanged: (_) {},
      ));

      final rightButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(rightButton.onPressed, isNull);
    });

    testWidgets('left arrow is enabled when not on oldest year',
        (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2025,
        availableYears: const [2026, 2025, 2024],
        onYearChanged: (_) {},
      ));

      final leftButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(leftButton.onPressed, isNotNull);
    });

    testWidgets('right arrow is enabled when not on newest year',
        (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2025,
        availableYears: const [2026, 2025, 2024],
        onYearChanged: (_) {},
      ));

      final rightButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(rightButton.onPressed, isNotNull);
    });

    testWidgets('tapping left arrow calls onYearChanged with older year',
        (tester) async {
      int? changed;
      await tester.pumpWidget(buildStepper(
        selectedYear: 2025,
        availableYears: const [2026, 2025, 2024],
        onYearChanged: (year) => changed = year,
      ));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_left));

      expect(changed, equals(2024));
    });

    testWidgets('tapping right arrow calls onYearChanged with newer year',
        (tester) async {
      int? changed;
      await tester.pumpWidget(buildStepper(
        selectedYear: 2025,
        availableYears: const [2026, 2025, 2024],
        onYearChanged: (year) => changed = year,
      ));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));

      expect(changed, equals(2026));
    });

    testWidgets('both arrows disabled when only one year available',
        (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2026,
        availableYears: const [2026],
        onYearChanged: (_) {},
      ));

      final leftButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      final rightButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(leftButton.onPressed, isNull);
      expect(rightButton.onPressed, isNull);
    });
  });
}
