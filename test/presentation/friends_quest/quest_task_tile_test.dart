import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/friends_quest_task.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/presentation/friends_quest/quest_task_tile.dart';

void main() {
  Person makePerson(String id, String name) => Person(
        id: id,
        userId: 'u1',
        firstName: name,
        createdAt: DateTime(2026),
      );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('QuestTaskTile', () {
    testWidgets('shows task text and interactive checkbox when incomplete',
        (tester) async {
      await tester.pumpWidget(wrap(QuestTaskTile(
        task: const FriendsQuestTask(id: 't1', text: 'Buy milk'),
        personMap: const {},
        onEdit: () {},
        onDelete: () {},
        onComplete: () {},
      )));

      expect(find.text('Buy milk'), findsOneWidget);
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.onChanged, isNotNull);
    });

    testWidgets('shows assigned person names in subtitle', (tester) async {
      await tester.pumpWidget(wrap(QuestTaskTile(
        task: const FriendsQuestTask(
          id: 't1',
          text: 'Task',
          assignedPersonIds: ['p1', 'p2'],
        ),
        personMap: {
          'p1': makePerson('p1', 'Alice'),
          'p2': makePerson('p2', 'Bob')
        },
        onEdit: () {},
        onDelete: () {},
        onComplete: () {},
      )));

      expect(find.text('Alice, Bob'), findsOneWidget);
    });

    testWidgets('shows names and contextLabel combined in subtitle',
        (tester) async {
      await tester.pumpWidget(wrap(QuestTaskTile(
        task: const FriendsQuestTask(
          id: 't1',
          text: 'Task',
          assignedPersonIds: ['p1'],
          contextLabel: 'Dinner',
        ),
        personMap: {'p1': makePerson('p1', 'Alice')},
        onEdit: () {},
        onDelete: () {},
        onComplete: () {},
      )));

      expect(find.text('Alice · Dinner'), findsOneWidget);
    });

    testWidgets('edit and delete buttons trigger callbacks', (tester) async {
      var edited = false;
      var deleted = false;
      await tester.pumpWidget(wrap(QuestTaskTile(
        task: const FriendsQuestTask(id: 't1', text: 'Task'),
        personMap: const {},
        onEdit: () => edited = true,
        onDelete: () => deleted = true,
        onComplete: () {},
      )));

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.tap(find.byIcon(Icons.delete_outline));

      expect(edited, true);
      expect(deleted, true);
    });

    testWidgets('completed task shows strikethrough text', (tester) async {
      await tester.pumpWidget(wrap(QuestTaskTile(
        task: const FriendsQuestTask(id: 't1', text: 'Done', isCompleted: true),
        personMap: const {},
        onEdit: () {},
        onDelete: () {},
        onComplete: () {},
      )));

      final textWidget = tester.widget<Text>(find.text('Done'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });
  });
}
