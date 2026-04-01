import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/services/relationship_score_service.dart';
import 'package:friendsheet/presentation/persons/relationship_strength_widget.dart';

void main() {
  Widget buildWidget(RelationshipScore score) => MaterialApp(
        home: Scaffold(body: RelationshipStrengthWidget(score: score)),
      );

  // ---------------------------------------------------------------------------
  // RelationshipStrengthWidget
  // ---------------------------------------------------------------------------

  group('RelationshipStrengthWidget', () {
    testWidgets('renders score, label, title and progress bar', (tester) async {
      const score = RelationshipScore(
        score: 55,
        label: 'Good',
        meetingsIn2y: 10,
        daysSinceLast: 30,
        distinctCategories2y: 3,
        distinctWeights2y: 2,
      );

      await tester.pumpWidget(buildWidget(score));

      expect(find.text('Relationship Strength'), findsOneWidget);
      expect(find.text('55/100'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('progress bar value equals score/100', (tester) async {
      const score = RelationshipScore(
        score: 75,
        label: 'Strong',
        meetingsIn2y: 20,
        daysSinceLast: 14,
        distinctCategories2y: 5,
        distinctWeights2y: 3,
      );

      await tester.pumpWidget(buildWidget(score));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(0.75, 0.001));
    });

    testWidgets('bar color is green for score >= 80', (tester) async {
      const score = RelationshipScore(
        score: 85,
        label: 'Very close',
        meetingsIn2y: 40,
        daysSinceLast: 2,
        distinctCategories2y: 9,
        distinctWeights2y: 3,
      );

      await tester.pumpWidget(buildWidget(score));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.color, Colors.green);
    });

    testWidgets('bar color is red for score < 20', (tester) async {
      const score = RelationshipScore(
        score: 10,
        label: 'Distant',
        meetingsIn2y: 0,
        daysSinceLast: 400,
        distinctCategories2y: 0,
        distinctWeights2y: 0,
      );

      await tester.pumpWidget(buildWidget(score));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.color, Colors.red);
    });
  });
}
