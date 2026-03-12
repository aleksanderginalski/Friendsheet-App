import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/presentation/widgets/activity_selector_dialog.dart';

void main() {
  final createdAt = DateTime(2024);

  ActivityCategory makeCategory({
    required String id,
    required String name,
    String? parentCategoryId,
    String iconIdentifier = '',
  }) {
    return ActivityCategory(
      id: id,
      userId: 'u-1',
      name: name,
      iconIdentifier: iconIdentifier,
      isGlobal: false,
      isSelectableAsActivity: true,
      parentCategoryId: parentCategoryId,
      createdAt: createdAt,
    );
  }

  final sports = makeCategory(id: 'cat-sports', name: 'Sports');
  final running = makeCategory(
    id: 'cat-running',
    name: 'Running',
    parentCategoryId: 'cat-sports',
  );
  final cycling = makeCategory(
    id: 'cat-cycling',
    name: 'Cycling',
    parentCategoryId: 'cat-sports',
  );
  final music = makeCategory(id: 'cat-music', name: 'Music');

  Widget buildDialog({
    List<ActivityCategory> categories = const [],
    String? selectedCategoryId,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ActivitySelectorDialog(
            categories: categories,
            selectedCategoryId: selectedCategoryId,
          ),
        ),
      ),
    );
  }

  group('ActivitySelectorDialog', () {
    testWidgets('renders category headers (root categories)', (tester) async {
      await tester.pumpWidget(buildDialog(
        categories: [sports, running, cycling, music],
      ));

      // Root categories appear with bold font.
      expect(find.text('Sports'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
    });

    testWidgets('renders child activities under correct parent',
        (tester) async {
      await tester.pumpWidget(buildDialog(
        categories: [sports, running, cycling, music],
      ));

      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Cycling'), findsOneWidget);
    });

    testWidgets('tapping a child activity pops with that category',
        (tester) async {
      ActivityCategory? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () async {
                  selected = await showDialog<ActivityCategory>(
                    context: ctx,
                    builder: (_) => ActivitySelectorDialog(
                      categories: [sports, running, cycling],
                      selectedCategoryId: null,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      expect(selected?.id, equals('cat-running'));
    });

    testWidgets('selected activity shows check icon', (tester) async {
      await tester.pumpWidget(buildDialog(
        categories: [sports, running, cycling],
        selectedCategoryId: 'cat-cycling',
      ));

      // Check icon appears next to the selected activity.
      expect(find.byIcon(Icons.check), findsOneWidget);

      // The check is on the Cycling row, not on Running.
      final checkFinder = find.byIcon(Icons.check);
      final cyclingFinder = find.text('Cycling');
      final runningFinder = find.text('Running');

      // Check icon is a sibling of 'Cycling' text in the same Row.
      final cyclingRow = find.ancestor(
        of: cyclingFinder,
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: cyclingRow.first, matching: checkFinder),
        findsOneWidget,
      );

      final runningRow = find.ancestor(
        of: runningFinder,
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: runningRow.first, matching: checkFinder),
        findsNothing,
      );
    });

    testWidgets('shows "No activities found" when categories list is empty',
        (tester) async {
      await tester.pumpWidget(buildDialog(categories: const []));

      expect(find.text('No activities found'), findsOneWidget);
    });
  });
}
