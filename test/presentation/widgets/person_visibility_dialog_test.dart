import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/widgets/person_visibility_dialog.dart';

void main() {
  const alice = InteractionDistributionEntry(
    personId: 'p-1',
    name: 'Alice',
    currentYearWeight: 10,
    previousYearWeight: 0,
  );
  const bob = InteractionDistributionEntry(
    personId: 'p-2',
    name: 'Bob',
    currentYearWeight: 7,
    previousYearWeight: 0,
  );
  const charlie = InteractionDistributionEntry(
    personId: 'p-3',
    name: 'Charlie',
    currentYearWeight: 3,
    previousYearWeight: 0,
  );
  const lukasz = InteractionDistributionEntry(
    personId: 'p-4',
    name: 'Łukasz',
    currentYearWeight: 5,
    previousYearWeight: 0,
  );
  const ludwik = InteractionDistributionEntry(
    personId: 'p-5',
    name: 'Ludwik',
    currentYearWeight: 4,
    previousYearWeight: 0,
  );

  // Helper: wraps the dialog widget directly in a MaterialApp so Navigator
  // and Theme are available without needing showDialog.
  Widget buildDialog({
    List<InteractionDistributionEntry> entries = const [],
    Set<String> hiddenPersons = const {},
    VoidCallback? onAutoSelectTop10,
    void Function(String)? onToggle,
    VoidCallback? onToggleSelectAll,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: PersonVisibilityDialog(
            allEntries: entries,
            hiddenPersons: hiddenPersons,
            onAutoSelectTop10: onAutoSelectTop10 ?? () {},
            onToggle: onToggle ?? (_) {},
            onToggleSelectAll: onToggleSelectAll ?? () {},
          ),
        ),
      ),
    );
  }

  group('PersonVisibilityDialog', () {
    testWidgets('renders dialog title "Show / Hide Friends"', (tester) async {
      await tester.pumpWidget(buildDialog(entries: [alice, bob]));

      expect(find.text('Show / Hide Friends'), findsOneWidget);
    });

    testWidgets('renders all person names as CheckboxListTiles',
        (tester) async {
      await tester.pumpWidget(buildDialog(entries: [alice, bob]));

      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('visible person (not hidden) has checked checkbox',
        (tester) async {
      // Bob is hidden; Alice is visible.
      await tester.pumpWidget(buildDialog(
        entries: [alice, bob],
        hiddenPersons: const {'p-2'},
      ));

      final aliceTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Alice'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      expect(aliceTile.value, isTrue);
    });

    testWidgets('hidden person has unchecked checkbox', (tester) async {
      await tester.pumpWidget(buildDialog(
        entries: [alice, bob],
        hiddenPersons: const {'p-2'},
      ));

      final bobTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Bob'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      expect(bobTile.value, isFalse);
    });

    testWidgets('tapping person tile calls onToggle with correct personId',
        (tester) async {
      String? toggled;
      await tester.pumpWidget(buildDialog(
        entries: [alice, bob],
        onToggle: (id) => toggled = id,
      ));

      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(toggled, equals('p-1'));
    });

    testWidgets('tapping person tile updates local checkbox state',
        (tester) async {
      await tester.pumpWidget(buildDialog(entries: [alice, bob]));

      // Alice starts visible (checked).
      final aliceFinder = find.ancestor(
        of: find.text('Alice'),
        matching: find.byType(CheckboxListTile),
      );
      expect(tester.widget<CheckboxListTile>(aliceFinder).value, isTrue);

      // Tap Alice to hide her.
      await tester.tap(find.text('Alice'));
      await tester.pump();

      // Checkbox should now be unchecked.
      expect(tester.widget<CheckboxListTile>(aliceFinder).value, isFalse);
    });

    testWidgets('"Auto-select top 10" button is present', (tester) async {
      await tester.pumpWidget(buildDialog(entries: [alice]));

      expect(find.text('Auto-select top 10'), findsOneWidget);
    });

    testWidgets('tapping "Auto-select top 10" calls onAutoSelectTop10',
        (tester) async {
      var called = false;
      await tester.pumpWidget(buildDialog(
        entries: [alice],
        onAutoSelectTop10: () => called = true,
      ));

      // Auto-select pops the dialog — need a Navigator to handle that.
      // Wrap in a builder so the pop does not throw.
      await tester.tap(find.text('Auto-select top 10'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('"CLOSE" button is present', (tester) async {
      await tester.pumpWidget(buildDialog(entries: [alice]));

      expect(find.text('CLOSE'), findsOneWidget);
    });

    testWidgets('renders persons in alphabetical order with Polish diacritics',
        (tester) async {
      // Input: Łukasz, Charlie, Ludwik, Bob, Alice — intentionally unsorted.
      // Expected: Alice, Bob, Charlie, Ludwik, Łukasz (ł sorts after l).
      await tester.pumpWidget(buildDialog(
        entries: [lukasz, charlie, ludwik, bob, alice],
      ));

      final tiles = tester
          .widgetList<CheckboxListTile>(
            find.byType(CheckboxListTile),
          )
          .toList();

      final names = tiles.map((t) => (t.title as Text).data!).toList();

      expect(names, equals(['Alice', 'Bob', 'Charlie', 'Ludwik', 'Łukasz']));
    });
  });
}
