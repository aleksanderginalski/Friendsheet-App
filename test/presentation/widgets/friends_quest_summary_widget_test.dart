import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friends_quest.dart';
import 'package:friendsheet/presentation/widgets/friends_quest_summary_widget.dart';

void main() {
  FriendsQuest makeQuest(String id) => FriendsQuest(
        id: id,
        name: 'Quest $id',
        participantIds: [],
        createdAt: DateTime(2026),
      );

  Widget buildWidget({
    required List<FriendsQuest> quests,
    VoidCallback? onViewAll,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FriendsQuestSummaryWidget(
          activeQuests: quests,
          onViewAll: onViewAll ?? () {},
        ),
      ),
    );
  }

  group('FriendsQuestSummaryWidget', () {
    testWidgets('shows singular label for 1 quest', (tester) async {
      await tester.pumpWidget(buildWidget(quests: [makeQuest('q1')]));

      expect(find.text('1 active quest'), findsOneWidget);
    });

    testWidgets('shows plural label for multiple quests', (tester) async {
      await tester.pumpWidget(
        buildWidget(
            quests: [makeQuest('q1'), makeQuest('q2'), makeQuest('q3')]),
      );

      expect(find.text('3 active quests'), findsOneWidget);
    });

    testWidgets('shows View all button', (tester) async {
      await tester.pumpWidget(buildWidget(quests: [makeQuest('q1')]));

      expect(find.text('View all →'), findsOneWidget);
    });

    testWidgets('tapping View all calls onViewAll', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildWidget(
          quests: [makeQuest('q1')],
          onViewAll: () => tapped = true,
        ),
      );

      await tester.tap(find.text('View all →'));
      expect(tapped, true);
    });

    testWidgets('tapping tile also calls onViewAll', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildWidget(
          quests: [makeQuest('q1')],
          onViewAll: () => tapped = true,
        ),
      );

      await tester.tap(find.text('1 active quest'));
      expect(tapped, true);
    });
  });
}
