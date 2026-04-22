import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friend_group.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/widgets/stats_person_filter_sheet.dart';

void main() {
  const PersonEntry alice = (personId: 'p-1', name: 'Alice');
  const PersonEntry bob = (personId: 'p-2', name: 'Bob');
  const PersonEntry carol = (personId: 'p-3', name: 'Carol');

  const closeFriendsGroup = FriendGroup(
    id: 'g-1',
    name: 'Close Friends',
    personIds: ['p-1', 'p-2'],
  );

  // The sheet uses Expanded — it must live inside a bounded-height parent.
  Widget buildSheet({
    List<PersonEntry> allEntries = const [],
    Set<String> selectedPersonIds = const {},
    List<FriendGroup> groups = const [],
    void Function(String)? onTogglePerson,
    void Function(Set<String>)? onReplaceSelection,
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
        body: SizedBox(
          height: 600,
          child: StatsPersonFilterSheet(
            allEntries: allEntries,
            selectedPersonIds: selectedPersonIds,
            groups: groups,
            onTogglePerson: onTogglePerson ?? (_) {},
            onReplaceSelection: onReplaceSelection ?? (_) {},
            onAutoSelectTop10: onAutoSelectTop10 ?? () {},
          ),
        ),
      ),
    );
  }

  group('StatsPersonFilterSheet', () {
    testWidgets('renders title and search field', (tester) async {
      await tester.pumpWidget(buildSheet(allEntries: [alice]));
      await tester.pump();

      expect(find.text('Filter persons'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows "No group" label for ungrouped person', (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice],
        selectedPersonIds: const {'p-1'},
      ));
      await tester.pump();

      expect(find.text('No group'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('shows group row with group name', (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1', 'p-2'},
        groups: [closeFriendsGroup],
      ));
      await tester.pump();

      expect(find.text('Close Friends'), findsOneWidget);
    });

    testWidgets(
        'group members hidden until expanded; expand_more → expand_less',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1', 'p-2'},
        groups: [closeFriendsGroup],
      ));
      await tester.pump();

      // Members not visible before expanding.
      expect(find.text('Alice'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('group checkbox: check_box when all members selected',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1', 'p-2'},
        groups: [closeFriendsGroup],
      ));
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('group checkbox: check_box_outline_blank when none selected',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {},
        groups: [closeFriendsGroup],
      ));
      await tester.pump();

      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets(
        'group checkbox: indeterminate_check_box when partial selection',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1'}, // only Alice
        groups: [closeFriendsGroup],
      ));
      await tester.pump();

      expect(find.byIcon(Icons.indeterminate_check_box), findsOneWidget);
    });

    testWidgets(
        'tapping group checkbox (all→none) calls onReplaceSelection without members',
        (tester) async {
      Set<String>? replaced;
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1', 'p-2'},
        groups: [closeFriendsGroup],
        onReplaceSelection: (ids) => replaced = ids,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check_box));
      await tester.pump();

      expect(replaced, isNotNull);
      expect(replaced, isNot(contains('p-1')));
      expect(replaced, isNot(contains('p-2')));
    });

    testWidgets(
        'tapping group checkbox (none→all) calls onReplaceSelection with all members',
        (tester) async {
      Set<String>? replaced;
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {},
        groups: [closeFriendsGroup],
        onReplaceSelection: (ids) => replaced = ids,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check_box_outline_blank));
      await tester.pump();

      expect(replaced, containsAll(['p-1', 'p-2']));
    });

    testWidgets('tapping person checkbox calls onTogglePerson with correct id',
        (tester) async {
      String? toggled;
      // Expand the group first so member tiles are visible.
      await tester.pumpWidget(buildSheet(
        allEntries: [carol], // ungrouped — always visible
        selectedPersonIds: const {'p-3'},
        onTogglePerson: (id) => toggled = id,
      ));
      await tester.pump();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      expect(toggled, 'p-3');
    });

    testWidgets('hidden hint shown when some persons are not selected',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1'}, // Bob hidden
      ));
      await tester.pump();

      expect(find.textContaining('persons hidden'), findsOneWidget);
    });

    testWidgets('hidden hint absent when all persons are selected',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1', 'p-2'},
      ));
      await tester.pump();

      expect(find.textContaining('persons hidden'), findsNothing);
    });

    testWidgets('search filters list to matching persons only', (tester) async {
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1', 'p-2'},
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Ali');
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
    });

    testWidgets('"Deselect all" calls onReplaceSelection with empty set',
        (tester) async {
      Set<String>? replaced;
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {'p-1', 'p-2'},
        onReplaceSelection: (ids) => replaced = ids,
      ));
      await tester.pump();

      await tester.tap(find.text('Deselect all'));
      await tester.pump();

      expect(replaced, isEmpty);
    });

    testWidgets('"Select all" calls onReplaceSelection with all IDs',
        (tester) async {
      Set<String>? replaced;
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob],
        selectedPersonIds: const {},
        onReplaceSelection: (ids) => replaced = ids,
      ));
      await tester.pump();

      await tester.tap(find.text('Select all'));
      await tester.pump();

      expect(replaced, containsAll(['p-1', 'p-2']));
    });

    testWidgets('"Autoselect Top 10" calls onAutoSelectTop10', (tester) async {
      var called = false;
      await tester.pumpWidget(buildSheet(
        allEntries: [alice],
        selectedPersonIds: const {'p-1'},
        onAutoSelectTop10: () => called = true,
      ));
      await tester.pump();

      await tester.tap(find.text('Autoselect Top 10'));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('ungrouped persons not shown in group section', (tester) async {
      // Carol is not in closeFriendsGroup — must appear in "No group" section.
      await tester.pumpWidget(buildSheet(
        allEntries: [alice, bob, carol],
        selectedPersonIds: const {'p-1', 'p-2', 'p-3'},
        groups: [closeFriendsGroup],
      ));
      await tester.pump();

      expect(find.text('No group'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
      // Alice and Bob are in the group — not visible until expanded.
      expect(find.text('Alice'), findsNothing);
    });
  });
}
