import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/catch_up_topic.dart';
import 'package:friendsheet/data/repositories/catch_up_topic_repository.dart';
import 'package:friendsheet/l10n/app_localizations.dart';
import 'package:friendsheet/presentation/persons/couple_separation_dialog.dart';

void main() {
  CatchUpTopic makeTopic({
    String id = 't1',
    String text = 'Topic text',
  }) {
    return CatchUpTopic(
      id: id,
      text: text,
      createdAt: DateTime(2026, 4, 10),
    );
  }

  Future<Map<String, TopicRedistributionDecision>?> openDialog(
    WidgetTester tester, {
    List<CatchUpTopic> topics = const [],
    String personAName = 'Anna',
    String personBName = 'Bob',
  }) async {
    Map<String, TopicRedistributionDecision>? result;

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () async {
            result = await showDialog<Map<String, TopicRedistributionDecision>>(
              context: ctx,
              builder: (_) => CoupleSeparationDialog(
                personAName: personAName,
                personBName: personBName,
                postLinkTopics: topics,
              ),
            );
          },
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    return result;
  }

  group('CoupleSeparationDialog', () {
    testWidgets('shows Redistribute topics title', (tester) async {
      await openDialog(tester);

      expect(find.text('Redistribute topics'), findsOneWidget);
    });

    testWidgets('shows topic text for each post-link topic', (tester) async {
      final topics = [makeTopic(id: 't1', text: 'Topic A')];
      await openDialog(tester, topics: topics);

      expect(find.text('Topic A'), findsOneWidget);
    });

    testWidgets('shows ToggleButtons with 4 options per topic', (tester) async {
      final topics = [makeTopic()];
      await openDialog(tester, topics: topics);

      expect(find.byType(ToggleButtons), findsOneWidget);
      // 4 options: personA, Shared, personB, Delete
      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Shared'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('returns null when Cancel tapped', (tester) async {
      Map<String, TopicRedistributionDecision>? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              result =
                  await showDialog<Map<String, TopicRedistributionDecision>>(
                context: ctx,
                builder: (_) => CoupleSeparationDialog(
                  personAName: 'Anna',
                  personBName: 'Bob',
                  postLinkTopics: [makeTopic()],
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('returns decisions map with shared default when Confirm tapped',
        (tester) async {
      Map<String, TopicRedistributionDecision>? result;
      final topic = makeTopic(id: 't1');

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              result =
                  await showDialog<Map<String, TopicRedistributionDecision>>(
                context: ctx,
                builder: (_) => CoupleSeparationDialog(
                  personAName: 'Anna',
                  personBName: 'Bob',
                  postLinkTopics: [topic],
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['t1'], equals(TopicRedistributionDecision.shared));
    });

    testWidgets('selecting a ToggleButtons option updates decision',
        (tester) async {
      Map<String, TopicRedistributionDecision>? result;
      final topic = makeTopic(id: 't1', text: 'Topic');

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              result =
                  await showDialog<Map<String, TopicRedistributionDecision>>(
                context: ctx,
                builder: (_) => CoupleSeparationDialog(
                  personAName: 'Anna',
                  personBName: 'Bob',
                  postLinkTopics: [topic],
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap 'Delete' (index 3) in the ToggleButtons.
      await tester.tap(find.text('Delete'));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result!['t1'], equals(TopicRedistributionDecision.delete));
    });

    testWidgets('shows no ToggleButtons when postLinkTopics is empty',
        (tester) async {
      await openDialog(tester, topics: []);

      expect(find.byType(ToggleButtons), findsNothing);
    });
  });
}
