import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/presentation/widgets/year_stepper.dart';

// Pixels per year matches the file-level constant in year_stepper.dart.
const double _kPixelsPerYear = 50.0;

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

    testWidgets('shows dimmed previous year when available', (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2023, 2024, 2025],
        onYearChanged: (_) {},
      ));

      // Both neighbour years must be visible alongside the active year.
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
    });

    testWidgets('hides neighbour slot when no previous year available',
        (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024, 2025],
        onYearChanged: (_) {},
      ));

      // 2023 is not in availableYears, so it must not appear in the tree.
      expect(find.text('2023'), findsNothing);
    });

    testWidgets('shows no neighbours for single year', (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024],
        onYearChanged: (_) {},
      ));

      // Only the active year label must be present.
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2023'), findsNothing);
      expect(find.text('2025'), findsNothing);
    });

    // --- Continuous drag tests (US-081) ---

    testWidgets('preview year shown during rightward drag toward older year',
        (tester) async {
      // availableYears [2024..2021] → minYear=2021, maxYear=2024.
      // Dragging right (+dx) moves toward older (lower) year.
      // Left neighbour slot shows 2023, so drag 2 steps → preview 2022
      // to avoid a duplicate text match with the neighbour slot.
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024, 2023, 2022, 2021],
        onYearChanged: (_) {},
      ));

      // Drag rightward by 2 × _kPixelsPerYear = 100px → yearDelta=2 → 2022.
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('2024')));
      await gesture.moveBy(const Offset(_kPixelsPerYear * 2, 0));
      await tester.pump();

      // 2022 is not shown in any neighbour slot, so exactly one match.
      expect(find.text('2022'), findsOneWidget);

      await gesture.cancel();
    });

    testWidgets('year committed on drag end', (tester) async {
      int? committed;
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024, 2023, 2022, 2021],
        onYearChanged: (y) => committed = y,
      ));

      // Drag 2 steps to preview 2022, then release.
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('2024')));
      await gesture.moveBy(const Offset(_kPixelsPerYear * 2, 0));
      await tester.pump();

      await gesture.up();
      await tester.pump();

      expect(committed, equals(2022));
    });

    testWidgets('preview resets to widget.selectedYear after drag end',
        (tester) async {
      // The parent does not update selectedYear here, so after drag end
      // the label reverts to the original selectedYear (2024).
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024, 2023, 2022, 2021],
        onYearChanged: (_) {},
      ));

      // Drag 2 steps to preview 2022, then release.
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('2024')));
      await gesture.moveBy(const Offset(_kPixelsPerYear * 2, 0));
      await tester.pump();

      await gesture.up();
      await tester.pump();

      // _previewYear is null → main label returns to widget.selectedYear (2024).
      // Only the main label shows 2024; neighbour slot shows 2023.
      expect(find.text('2024'), findsOneWidget);
    });

    testWidgets('clamp at minYear — label never goes below oldest year',
        (tester) async {
      // selectedYear = minYear = 2021. Dragging right tries to go older.
      await tester.pumpWidget(buildStepper(
        selectedYear: 2021,
        availableYears: const [2024, 2023, 2022, 2021],
        onYearChanged: (_) {},
      ));

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('2021')));
      // Drag rightward by 3 years worth of pixels.
      await gesture.moveBy(const Offset(_kPixelsPerYear * 3, 0));
      await tester.pump();

      // Must still show 2021 — cannot go below minYear.
      expect(find.text('2021'), findsOneWidget);
      expect(find.text('2020'), findsNothing);

      await gesture.cancel();
    });

    testWidgets('clamp at maxYear — label never goes above newest year',
        (tester) async {
      // selectedYear = maxYear = 2024. Dragging left tries to go newer.
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024, 2023, 2022, 2021],
        onYearChanged: (_) {},
      ));

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('2024')));
      // Drag leftward by 3 years worth of pixels (negative dx = newer year).
      await gesture.moveBy(const Offset(-_kPixelsPerYear * 3, 0));
      await tester.pump();

      // Must still show 2024 — cannot go above maxYear.
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2025'), findsNothing);

      await gesture.cancel();
    });

    testWidgets('year range indicator hidden when only one year available',
        (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024],
        onYearChanged: (_) {},
      ));

      // LinearProgressIndicator is used as the range track.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('year range indicator present when multiple years available',
        (tester) async {
      await tester.pumpWidget(buildStepper(
        selectedYear: 2024,
        availableYears: const [2024, 2023, 2022, 2021],
        onYearChanged: (_) {},
      ));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
