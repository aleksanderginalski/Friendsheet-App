import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/services/local_cache_service.dart';
import 'package:friendsheet/data/services/relationship_score_service.dart';
import 'package:friendsheet/services/hive_service.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  final service = RelationshipScoreService();

  Meeting makeMeeting({
    required String id,
    required DateTime date,
    List<String> participantIds = const ['p1'],
    List<String> categoryIds = const ['cat1'],
    int weight = 3,
  }) =>
      Meeting(
        id: id,
        userId: 'u1',
        name: 'M$id',
        date: date,
        weight: weight,
        participantIds: participantIds,
        categoryIds: categoryIds,
        notes: const [],
        createdAt: date,
        updatedAt: date,
      );

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_rss_test_');
    await HiveService.initialize(testPath: tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await HiveService.clearUserData('u1');
  });

  // ---------------------------------------------------------------------------
  // computeScore
  // ---------------------------------------------------------------------------

  group('computeScore', () {
    test('returns Distant/0 with -1 daysSinceLast when no meetings', () async {
      final result = await service.computeScore('u1', 'p1');

      expect(result.score, 0);
      expect(result.label, 'Distant');
      expect(result.daysSinceLast, -1);
      expect(result.meetingsIn2y, 0);
      expect(result.distinctCategories2y, 0);
      expect(result.distinctWeights2y, 0);
    });

    test('computes correct score and fields for meetings within 2y window',
        () async {
      final now = DateTime.now();
      // 12 meetings, each 10 days apart (0–110 days ago) — all within 730-day window.
      // 3 distinct categories (i%3), 2 distinct weights (3 and 5).
      final meetings = List.generate(
        12,
        (i) => makeMeeting(
          id: 'm$i',
          date: now.subtract(Duration(days: i * 10)),
          categoryIds: ['cat${i % 3}'],
          weight: i % 2 == 0 ? 3 : 5,
        ),
      );
      for (final m in meetings) {
        await LocalCacheService().upsertMeeting('u1', m);
      }

      final result = await service.computeScore('u1', 'p1');

      // Expected partial scores:
      //   freq    = min(12,48)/48 * 35 = 0.25 * 35 = 8.75 → rounds to 9
      //   recency = (360-0)/360 * 30  = 1.0  * 30 = 30.0 → rounds to 30
      //   variety = min(3,10)/10 * 20 = 0.3  * 20 = 6.0  → rounds to 6
      //   weightV = min(2,3)/3 * 15   = 0.667* 15 = 10.0 → rounds to 10
      //   total = 9+30+6+10 = 55
      expect(result.score, 55);
      expect(result.label, 'Good');
      expect(result.meetingsIn2y, 12);
      expect(result.daysSinceLast, 0);
      expect(result.distinctCategories2y, 3);
      expect(result.distinctWeights2y, 2);
    });

    test('uses all-time last meeting for recency — not limited to 2y window',
        () async {
      final now = DateTime.now();
      // Only meeting is 800 days ago — outside the 730-day 2y window.
      await LocalCacheService().upsertMeeting(
        'u1',
        makeMeeting(id: 'old', date: now.subtract(const Duration(days: 800))),
      );

      final result = await service.computeScore('u1', 'p1');

      // daysSinceLast must reflect the real last meeting, not return -1.
      expect(result.daysSinceLast, 800);
      // No meetings within the 2y window.
      expect(result.meetingsIn2y, 0);
      expect(result.distinctCategories2y, 0);
    });

    test('returns Very close / 100 when all factors hit their caps', () async {
      final now = DateTime.now();
      // 48 meetings every 14 days (max 47*14=658 days ago — within 730-day cap).
      // 10 distinct categories, 3 distinct weights.
      final meetings = List.generate(
        48,
        (i) => makeMeeting(
          id: 'm$i',
          date: now.subtract(Duration(days: i * 14)),
          categoryIds: ['cat${i % 10}'],
          weight: [1, 3, 5][i % 3],
        ),
      );
      for (final m in meetings) {
        await LocalCacheService().upsertMeeting('u1', m);
      }

      final result = await service.computeScore('u1', 'p1');

      expect(result.score, 100);
      expect(result.label, 'Very close');
    });

    test('score label boundaries — Fading for score 20–39', () async {
      final now = DateTime.now();
      // One meeting 300 days ago: recency = (360-300)/360 * 30 = 5.0 → 5pts, rest = 0.
      // Score = 5, label = 'Distant' — adjust: need ~20pts.
      // 2 meetings/2y (freq=2/48=0.042→1pt), recency 200d ago (360-200)/360*30=13.3→13pts,
      // 1 category (0.1*20=2→2pts), 1 weight (1/3*15=5→5pts): 1+13+2+5=21pts → 'Fading'.
      await LocalCacheService().upsertMeeting(
        'u1',
        makeMeeting(id: 'm1', date: now.subtract(const Duration(days: 200))),
      );
      await LocalCacheService().upsertMeeting(
        'u1',
        makeMeeting(id: 'm2', date: now.subtract(const Duration(days: 250))),
      );

      final result = await service.computeScore('u1', 'p1');

      expect(result.score, greaterThanOrEqualTo(20));
      expect(result.score, lessThan(40));
      expect(result.label, 'Fading');
    });
  });
}
