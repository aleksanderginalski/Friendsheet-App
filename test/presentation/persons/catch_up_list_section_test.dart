import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/catch_up_topic.dart';
import 'package:friendsheet/presentation/persons/catch_up_list_section.dart';

void main() {
  CatchUpTopic makeTopic({String id = 't1', String text = 'Topic'}) {
    return CatchUpTopic(
      id: id,
      text: text,
      createdAt: DateTime(2026, 4, 1),
    );
  }

  Widget buildSection({
    List<CatchUpTopic> topics = const [],
    bool isLoading = false,
    VoidCallback? onAddTap,
    Future<void> Function(String)? onDelete,
    void Function(CatchUpTopic)? onEdit,
    Future<void> Function(String)? onArchive,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CatchUpListSection(
          topics: topics,
          isLoading: isLoading,
          personId: 'p1',
          onAddTap: onAddTap ?? () {},
          onDelete: onDelete ?? (_) async {},
          onEdit: onEdit ?? (_) {},
          onArchive: onArchive ?? (_) async {},
        ),
      ),
    );
  }

  group('CatchUpListSection', () {
    testWidgets('shows Catch-up List title', (tester) async {
      await tester.pumpWidget(buildSection());

      expect(find.text('Catch-up List'), findsOneWidget);
    });

    testWidgets('shows add icon button', (tester) async {
      await tester.pumpWidget(buildSection());

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onAddTap when add button pressed', (tester) async {
      var called = false;
      await tester.pumpWidget(buildSection(onAddTap: () => called = true));

      await tester.tap(find.byIcon(Icons.add));
      expect(called, isTrue);
    });

    testWidgets('shows badge with topic count when topics present',
        (tester) async {
      final topics = [
        makeTopic(id: 't1'),
        makeTopic(id: 't2', text: 'Second'),
      ];
      await tester.pumpWidget(buildSection(topics: topics));

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('does not show badge when topics list is empty', (tester) async {
      await tester.pumpWidget(buildSection(topics: []));

      // No numeric badge — '0' must not appear.
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows topic text when expanded', (tester) async {
      final topics = [makeTopic(text: 'Buy milk')];
      await tester.pumpWidget(buildSection(topics: topics));

      await tester.tap(find.text('Catch-up List'));
      await tester.pumpAndSettle();

      expect(find.text('Buy milk'), findsOneWidget);
    });

    testWidgets('shows "No topics yet" when expanded and empty', (tester) async {
      await tester.pumpWidget(buildSection(topics: []));

      await tester.tap(find.text('Catch-up List'));
      await tester.pumpAndSettle();

      expect(find.text('No topics yet'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(buildSection(isLoading: true));

      await tester.tap(find.text('Catch-up List'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
