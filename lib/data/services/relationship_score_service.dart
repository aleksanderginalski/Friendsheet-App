import 'dart:math';

import 'local_cache_service.dart';

// Breakdown of a single person's relationship strength score (0–100).
// All fields are final and the class is const-constructible for easy testing.
class RelationshipScore {
  final int score;
  final String label;
  final int meetingsIn2y;
  final int daysSinceLast; // -1 when no meetings exist
  final int distinctCategories2y;
  final int distinctWeights2y;

  const RelationshipScore({
    required this.score,
    required this.label,
    required this.meetingsIn2y,
    required this.daysSinceLast,
    required this.distinctCategories2y,
    required this.distinctWeights2y,
  });
}

// Computes a 0–100 relationship strength score per person from the Hive cache.
// No Firestore reads — reads exclusively via LocalCacheService.
//
// Factors and weights:
//   Frequency    35% — meetings in last 730 days, cap at 48 (2/month)
//   Recency      30% — days since last meeting (all time), 0 at 360 days
//   Variety      20% — distinct category IDs in last 730 days, cap at 10
//   WeightVar    15% — distinct weight values used in last 730 days, cap at 3
class RelationshipScoreService {
  // Computes the relationship strength score for [personId] using cached data.
  // Frequency, variety, and weight variety use a 730-day window.
  // Recency uses the most recent meeting across all time (no window).
  Future<RelationshipScore> computeScore(
    String userId,
    String personId,
  ) async {
    final allMeetings = await LocalCacheService().getAllMeetings(userId);
    final personMeetings =
        allMeetings.where((m) => m.participantIds.contains(personId)).toList();

    if (personMeetings.isEmpty) {
      return const RelationshipScore(
        score: 0,
        label: 'Distant',
        meetingsIn2y: 0,
        daysSinceLast: -1,
        distinctCategories2y: 0,
        distinctWeights2y: 0,
      );
    }

    final now = DateTime.now();
    final cutoff2y = now.subtract(const Duration(days: 730));

    // Recency: use the most recent meeting regardless of time window.
    final lastMeeting = personMeetings.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );
    final daysSinceLast = now.difference(lastMeeting.date).inDays;

    // 2-year window subset.
    final meetings2y =
        personMeetings.where((m) => m.date.isAfter(cutoff2y)).toList();
    final count2y = meetings2y.length;

    // Distinct category IDs across 2-year meetings.
    final categoryIds2y = <String>{};
    for (final m in meetings2y) {
      categoryIds2y.addAll(m.categoryIds);
    }

    // Distinct weight values across 2-year meetings.
    final weightValues2y = <int>{};
    for (final m in meetings2y) {
      weightValues2y.add(m.weight);
    }

    final frequency = min(count2y, 48) / 48;
    final recency = max(0.0, (360 - daysSinceLast) / 360);
    final variety = min(categoryIds2y.length, 10) / 10;
    final weightVar = min(weightValues2y.length, 3) / 3;

    final score =
        (frequency * 35 + recency * 30 + variety * 20 + weightVar * 15).round();

    return RelationshipScore(
      score: score,
      label: _labelForScore(score),
      meetingsIn2y: count2y,
      daysSinceLast: daysSinceLast,
      distinctCategories2y: categoryIds2y.length,
      distinctWeights2y: weightValues2y.length,
    );
  }

  static String _labelForScore(int score) {
    if (score >= 80) return 'Very close';
    if (score >= 60) return 'Strong';
    if (score >= 40) return 'Good';
    if (score >= 20) return 'Fading';
    return 'Distant';
  }
}
