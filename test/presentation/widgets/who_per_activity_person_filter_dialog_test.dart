import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/repositories/statistics_repository.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/widgets/who_per_activity_person_filter_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const alice = PersonActivityEntry(
    personId: 'p-1',
    name: 'Alice',
    weightSum: 10,
  );
  const bob = PersonActivityEntry(
    personId: 'p-2',
    name: 'Bob',
    weightSum: 7,
  );
  const carol = PersonActivityEntry(
    personId: 'p-3',
    name: 'Carol',
    weightSum: 4,
  );
  const ludwik = PersonActivityEntry(
    personId: 'p-4',
    name: 'Ludwik',
    weightSum: 6,
  );
  const lukasz = PersonActivityEntry(
    personId: 'p-5',
    name: 'Łukasz',
    weightSum: 5,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildDialog({
    List<PersonActivityEntry> entries = const [],
    Set<String> hiddenPersonIds = const {},
    void Function(String)? onTogglePersonVisibility,
    void Function(bool)? onToggleSelectAll,
    VoidCallback? onAutoSelectTop10,
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
          child: WhoPerActivityPersonFilterDialog(
            allEntries: entries,
            hiddenPersonIds: hiddenPersonIds,
            onTogglePersonVisibility: onTogglePersonVisibility ?? (_) {},
            onToggleSelectAll: onToggleSelectAll ?? (_) {},
            onAutoSelectTop10: onAutoSelectTop10 ?? () {},
          ),
        ),
      ),
    );
  }

  group('WhoPerActivityPersonFilterDialog', () {
    testWidgets('renders all persons as checked by default', (tester) async {
      await tester.pumpWidget(buildDialog(
        entries: [alice, bob],
        hiddenPersonIds: const {},
      ));

      expect(find.byType(CheckboxListTile), findsNWidgets(2));

      final aliceTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Alice'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      final bobTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Bob'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      expect(aliceTile.value, isTrue);
      expect(bobTile.value, isTrue);
    });

    testWidgets(
        'unchecking a person calls onTogglePersonVisibility with correct id',
        (tester) async {
      String? toggled;
      await tester.pumpWidget(buildDialog(
        entries: [alice, bob],
        onTogglePersonVisibility: (id) => toggled = id,
      ));

      await tester.tap(find.text('Bob'));
      await tester.pump();

      expect(toggled, equals('p-2'));
    });

    testWidgets(
        'three-state toggle: all visible → tap → hides all except first person',
        (tester) async {
      bool? selectAllValue;
      await tester.pumpWidget(buildDialog(
        entries: [alice, bob, carol],
        hiddenPersonIds: const {},
        onToggleSelectAll: (v) => selectAllValue = v,
      ));

      // All visible → icon is check_box.
      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // Tap the toggle icon to deselect all.
      await tester.tap(find.byIcon(Icons.check_box));
      await tester.pump();

      // Provider called with selectAll = false.
      expect(selectAllValue, isFalse);

      // First person (Alice) remains checked; Bob and Carol are hidden.
      final aliceTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Alice'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      final bobTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Bob'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      expect(aliceTile.value, isTrue);
      expect(bobTile.value, isFalse);
    });

    testWidgets('last visible person checkbox is disabled', (tester) async {
      // Only Alice is visible — Bob is hidden.
      await tester.pumpWidget(buildDialog(
        entries: [alice, bob],
        hiddenPersonIds: const {'p-2'},
      ));

      final aliceTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Alice'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      // Last visible person has onChanged == null (disabled).
      expect(aliceTile.onChanged, isNull);
    });

    testWidgets('"Auto-select top 10" button is present', (tester) async {
      await tester.pumpWidget(buildDialog(entries: [alice]));

      expect(find.text('Auto-select top 10'), findsOneWidget);
    });

    testWidgets(
        'tapping "Auto-select top 10" calls onAutoSelectTop10 and closes dialog',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => showDialog<void>(
                  context: ctx,
                  builder: (_) => WhoPerActivityPersonFilterDialog(
                    allEntries: const [alice, bob],
                    hiddenPersonIds: const <String>{},
                    onTogglePersonVisibility: (_) {},
                    onToggleSelectAll: (_) {},
                    onAutoSelectTop10: () => called = true,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Auto-select top 10'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      // Dialog dismissed after tap.
      expect(find.text('Filter by Person'), findsNothing);
    });

    testWidgets('renders persons in alphabetical order with Polish diacritics',
        (tester) async {
      // Input: Łukasz, carol, Ludwik, bob, alice — intentionally unsorted.
      // Expected: Alice, Bob, Carol, Ludwik, Łukasz (ł sorts after l).
      await tester.pumpWidget(buildDialog(
        entries: [lukasz, carol, ludwik, bob, alice],
      ));

      final tiles = tester
          .widgetList<CheckboxListTile>(
            find.byType(CheckboxListTile),
          )
          .toList();

      final names = tiles.map((t) => ((t.title as Text).data!)).toList();

      expect(names, equals(['Alice', 'Bob', 'Carol', 'Ludwik', 'Łukasz']));
    });

    testWidgets('"CLOSE" button dismisses the dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => showDialog<void>(
                  context: ctx,
                  builder: (_) => WhoPerActivityPersonFilterDialog(
                    allEntries: const [alice],
                    hiddenPersonIds: const <String>{},
                    onTogglePersonVisibility: (_) {},
                    onToggleSelectAll: (_) {},
                    onAutoSelectTop10: () {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by Person'), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by Person'), findsNothing);
    });
  });
}
