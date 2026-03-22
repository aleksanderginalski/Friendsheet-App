import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/presentation/activities/merge_category_picker_screen.dart';

void main() {
  // Source: the category being merged (not in candidates).
  final source = ActivityCategory(
    id: 'src',
    userId: 'u1',
    name: 'Piwko',
    iconIdentifier: 'category',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: null,
    createdAt: DateTime(2026, 1, 1),
  );

  // Candidates: Sport (root with child Bieg) + Piwo (root leaf).
  final rootSport = ActivityCategory(
    id: 'root-sport',
    userId: 'u1',
    name: 'Sport',
    iconIdentifier: 'category',
    isGlobal: false,
    isSelectableAsActivity: false,
    parentCategoryId: null,
    createdAt: DateTime(2026, 1, 2),
  );
  final childBieg = ActivityCategory(
    id: 'child-bieg',
    userId: 'u1',
    name: 'Bieg',
    iconIdentifier: 'category',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: 'root-sport',
    createdAt: DateTime(2026, 1, 3),
  );
  final rootPiwo = ActivityCategory(
    id: 'root-piwo',
    userId: 'u1',
    name: 'Piwo',
    iconIdentifier: 'category',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: null,
    createdAt: DateTime(2026, 1, 4),
  );

  Widget buildPicker() => MaterialApp(
        home: MergeCategoryPickerScreen(
          source: source,
          candidates: [rootSport, childBieg, rootPiwo],
        ),
      );

  group('MergeCategoryPickerScreen', () {
    testWidgets('shows source name in app bar title', (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.pumpAndSettle();

      expect(find.text('Merge "Piwko" into\u2026'), findsOneWidget);
    });

    testWidgets('hierarchy view shows root and child category names',
        (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.pumpAndSettle();

      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('Bieg'), findsOneWidget);
      expect(find.text('Piwo'), findsOneWidget);
    });

    testWidgets('search hides non-matching categories', (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Piwo');
      await tester.pump();

      // Use widgetWithText to match ListTile only (TextField also contains 'Piwo').
      expect(find.widgetWithText(ListTile, 'Piwo'), findsOneWidget);
      expect(find.text('Sport'), findsNothing);
      expect(find.text('Bieg'), findsNothing);
    });

    testWidgets('search shows parent name as subtitle for child category',
        (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Bieg');
      await tester.pump();

      // ListTile shows 'Bieg' as title and 'Sport' as subtitle.
      expect(find.widgetWithText(ListTile, 'Bieg'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
    });
  });
}
