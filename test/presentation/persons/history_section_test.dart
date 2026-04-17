import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/catch_up_topic.dart';
import 'package:friendsheet/presentation/persons/history_section.dart';

void main() {
  final archivedTopic = CatchUpTopic(
    id: 't1',
    text: 'Discussed topic',
    contextLabel: 'April 2026',
    createdAt: DateTime(2026, 4, 1),
    isArchived: true,
    archivedAt: DateTime(2026, 4, 10),
  );

  Widget buildSection({
    List<CatchUpTopic> archivedTopics = const [],
    bool archivedLoading = false,
    VoidCallback? onLoadArchived,
    Future<void> Function(String)? onDeleteArchivedTopic,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HistorySection(
          archivedTopics: archivedTopics,
          archivedLoading: archivedLoading,
          onLoadArchived: onLoadArchived ?? () {},
          onDeleteArchivedTopic: onDeleteArchivedTopic ?? (_) async {},
        ),
      ),
    );
  }

  group('HistorySection', () {
    testWidgets('renders Historia ExpansionTile in collapsed state',
        (tester) async {
      await tester.pumpWidget(buildSection());

      expect(find.text('Historia'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('shows empty text when expanded with no archived topics',
        (tester) async {
      await tester.pumpWidget(buildSection());

      await tester.tap(find.text('Historia'));
      await tester.pumpAndSettle();

      expect(find.text('Brak omówionych tematów'), findsOneWidget);
    });

    testWidgets('calls onLoadArchived when expanded and list is empty',
        (tester) async {
      bool called = false;
      await tester
          .pumpWidget(buildSection(onLoadArchived: () => called = true));

      await tester.tap(find.text('Historia'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets(
        'does not call onLoadArchived when expanded with topics present',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(buildSection(
        archivedTopics: [archivedTopic],
        onLoadArchived: () => called = true,
      ));

      await tester.tap(find.text('Historia'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('shows CircularProgressIndicator when archivedLoading is true',
        (tester) async {
      await tester.pumpWidget(buildSection(archivedLoading: true));

      await tester.tap(find.text('Historia'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows topic text and contextLabel when topics present',
        (tester) async {
      await tester.pumpWidget(buildSection(archivedTopics: [archivedTopic]));

      await tester.tap(find.text('Historia'));
      await tester.pumpAndSettle();

      expect(find.text('Discussed topic'), findsOneWidget);
      expect(find.text('April 2026'), findsOneWidget);
    });

    testWidgets('shows delete icon for each archived topic', (tester) async {
      await tester.pumpWidget(buildSection(archivedTopics: [archivedTopic]));

      await tester.tap(find.text('Historia'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('calls onDeleteArchivedTopic after confirming delete dialog',
        (tester) async {
      String? deletedId;
      await tester.pumpWidget(buildSection(
        archivedTopics: [archivedTopic],
        onDeleteArchivedTopic: (id) async => deletedId = id,
      ));

      await tester.tap(find.text('Historia'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deletedId, equals('t1'));
    });

    testWidgets('does not call onDeleteArchivedTopic when cancel pressed',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(buildSection(
        archivedTopics: [archivedTopic],
        onDeleteArchivedTopic: (_) async => called = true,
      ));

      await tester.tap(find.text('Historia'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('shows badge with count when archived topics present',
        (tester) async {
      await tester.pumpWidget(buildSection(archivedTopics: [archivedTopic]));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('does not show badge when archived topics list is empty',
        (tester) async {
      await tester.pumpWidget(buildSection(archivedTopics: []));

      expect(find.text('0'), findsNothing);
    });
  });
}
