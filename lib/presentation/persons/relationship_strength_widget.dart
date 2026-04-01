import 'package:flutter/material.dart';

import '../../data/services/relationship_score_service.dart';

// Displays the relationship strength score as a colored progress bar with a label.
// Score range: 0–100. Color and label are determined by the score value.
class RelationshipStrengthWidget extends StatelessWidget {
  final RelationshipScore score;

  const RelationshipStrengthWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = _barColor(score.score);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Relationship Strength', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score.score / 100,
              color: barColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${score.score}/100'),
              Text(score.label),
            ],
          ),
        ],
      ),
    );
  }
}

Color _barColor(int score) {
  if (score >= 80) return Colors.green;
  if (score >= 60) return Colors.lightGreen;
  if (score >= 40) return Colors.amber;
  if (score >= 20) return Colors.orange;
  return Colors.red;
}
