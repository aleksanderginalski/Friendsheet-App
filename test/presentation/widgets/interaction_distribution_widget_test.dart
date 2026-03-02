import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/presentation/widgets/interaction_distribution_widget.dart';

void main() {
  // Helper: builds two sample entries.
  List<InteractionDistributionEntry> twoEntries() => const [
        InteractionDistributionEntry(
          personId: 'p-1',
          name: 'Alice',
          currentYearWeight: 10,
          previousYearWeight: 5,
        ),
        InteractionDistributionEntry(
          personId: 'p-2',
          name: 'Bob',
          currentYearWeight: 7,
          previousYearWeight: 0,
        ),
      ];

  // Helper: wraps the widget in a minimal scrollable app.
  Widget buildWidget({
    List<InteractionDistributionEntry> entries = const [],
    Set<String> hiddenPersons = const {},
    bool isCumulativeMode = false,
    bool isLoading = false,
    VoidCallback? onOpenVisibilityDialog,
    VoidCallback? onToggleMode,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: InteractionDistributionWidget(
            entries: entries,
            hiddenPersons: hiddenPersons,
            isCumulativeMode: isCumulativeMode,
            isLoading: isLoading,
            onOpenVisibilityDialog: onOpenVisibilityDialog ?? () {},
            onToggleMode: onToggleMode ?? () {},
          ),
        ),
      ),
    );
  }

  group('InteractionDistributionWidget', () {
    testWidgets('renders title "Interaction Distribution"', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Interaction Distribution'), findsOneWidget);
    });

    testWidgets('shows person name for each visible entry', (tester) async {
      await tester.pumpWidget(buildWidget(entries: twoEntries()));
      // Advance past the entrance animation so opacity reaches 1.
      await tester.pump(const Duration(milliseconds: 1100));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows "X persons hidden" hint when hiddenPersons non-empty',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        entries: twoEntries(),
        hiddenPersons: const {'p-2'},
      ));
      await tester.pump();

      expect(find.text('1 persons hidden'), findsOneWidget);
    });

    testWidgets('does not show hidden hint when no persons are hidden',
        (tester) async {
      await tester.pumpWidget(buildWidget(entries: twoEntries()));
      await tester.pump();

      expect(find.textContaining('hidden'), findsNothing);
    });

    testWidgets('shows info icon in yearly mode', (tester) async {
      await tester.pumpWidget(
          buildWidget(entries: twoEntries(), isCumulativeMode: false));
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('hides info icon in cumulative mode', (tester) async {
      await tester.pumpWidget(
          buildWidget(entries: twoEntries(), isCumulativeMode: true));
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('toggle button shows "Yearly" in yearly mode', (tester) async {
      await tester.pumpWidget(
          buildWidget(entries: twoEntries(), isCumulativeMode: false));
      await tester.pump();

      expect(find.text('Yearly'), findsOneWidget);
    });

    testWidgets('toggle button shows "Cumulative" in cumulative mode',
        (tester) async {
      await tester.pumpWidget(
          buildWidget(entries: twoEntries(), isCumulativeMode: true));
      await tester.pump();

      expect(find.text('Cumulative'), findsOneWidget);
    });

    testWidgets('tapping toggle button calls onToggleMode', (tester) async {
      var toggled = false;
      await tester.pumpWidget(buildWidget(
        entries: twoEntries(),
        onToggleMode: () => toggled = true,
      ));
      await tester.pump();

      await tester.tap(find.text('Yearly'));

      expect(toggled, isTrue);
    });

    testWidgets('shows "No visible persons." when all persons are hidden',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        entries: twoEntries(),
        hiddenPersons: const {'p-1', 'p-2'},
      ));
      await tester.pump();

      expect(find.text('No visible persons.'), findsOneWidget);
    });

    testWidgets('shows "No visible persons." when entries are empty',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('No visible persons.'), findsOneWidget);
    });

    testWidgets('tapping settings icon calls onOpenVisibilityDialog',
        (tester) async {
      var opened = false;
      await tester.pumpWidget(buildWidget(
        entries: twoEntries(),
        onOpenVisibilityDialog: () => opened = true,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings));

      expect(opened, isTrue);
    });

    testWidgets('isLoading: true renders CircularProgressIndicator in header',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        entries: twoEntries(),
        isLoading: true,
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('isLoading: false does not render CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        entries: twoEntries(),
        isLoading: false,
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
