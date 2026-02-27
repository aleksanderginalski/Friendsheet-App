import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meeting.dart';
import 'activity_category_repository.dart';

/// Display DTO representing one category's weight totals across two years.
/// Not a domain model — plain Dart class, no Freezed.
class ActivityBreakdownEntry {
  final String categoryId;
  final String name;
  final int currentYearWeight;
  final int previousYearWeight;

  const ActivityBreakdownEntry({
    required this.categoryId,
    required this.name,
    required this.currentYearWeight,
    required this.previousYearWeight,
  });

  /// Positive: weight grew vs. previous year. Negative: weight shrank.
  int get delta => currentYearWeight - previousYearWeight;
}

/// Handles statistics-related Firestore queries.
/// Kept separate from MeetingRepository to avoid mixing stream-based
/// and one-shot query responsibilities.
class StatisticsRepository {
  final FirebaseFirestore _firestore;
  final ActivityCategoryRepository _categoryRepository;

  StatisticsRepository({
    FirebaseFirestore? firestore,
    required ActivityCategoryRepository categoryRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _categoryRepository = categoryRepository;

  CollectionReference _meetingsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('meetings');

  /// Returns unique years extracted from meeting dates, sorted descending.
  /// Queries every meeting document for the user; no Firestore index required.
  Future<List<int>> getAvailableYears(String userId) async {
    try {
      final snapshot = await _meetingsRef(userId).get();
      final years = <int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp?;
        if (timestamp != null) {
          years.add(timestamp.toDate().year);
        }
      }
      return years.toList()..sort((a, b) => b.compareTo(a));
    } catch (e) {
      throw Exception('Failed to load available years: $e');
    }
  }

  /// Returns all meetings for a given user that fall within [year].
  /// Uses an inclusive start (Jan 1) and exclusive end (Jan 1 of next year).
  Future<List<Meeting>> getMeetingsForYear(String userId, int year) async {
    try {
      final startDate = Timestamp.fromDate(DateTime(year));
      final endDate = Timestamp.fromDate(DateTime(year + 1));

      final snapshot = await _meetingsRef(userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();

      return snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load meetings for year $year: $e');
    }
  }

  /// Returns a ranked list of activity categories by total meeting weight
  /// for [year], compared to [year - 1].
  ///
  /// Aggregation rule: for each meeting, each unique categoryId in
  /// meeting.categoryIds contributes meeting.weight once.
  /// Categories not found in the user's category list are skipped.
  /// Sorted descending by currentYearWeight; zero-weight entries appear at
  /// bottom sorted by previousYearWeight descending.
  Future<List<ActivityBreakdownEntry>> getActivityWeightBreakdown(
    int year,
    String userId,
  ) async {
    final currentMeetings = await getMeetingsForYear(userId, year);
    final previousMeetings = await getMeetingsForYear(userId, year - 1);
    final categories = await _categoryRepository.getAllCategories(userId);

    // Build a lookup map for fast name resolution.
    final categoryNameById = {for (final c in categories) c.id: c.name};

    final Map<String, int> currentWeights = {};
    for (final meeting in currentMeetings) {
      // Use a set to avoid double-counting duplicate categoryIds per meeting.
      for (final categoryId in meeting.categoryIds.toSet()) {
        currentWeights[categoryId] =
            (currentWeights[categoryId] ?? 0) + meeting.weight;
      }
    }

    final Map<String, int> previousWeights = {};
    for (final meeting in previousMeetings) {
      for (final categoryId in meeting.categoryIds.toSet()) {
        previousWeights[categoryId] =
            (previousWeights[categoryId] ?? 0) + meeting.weight;
      }
    }

    // Include all categoryIds that appear in either year.
    final allCategoryIds = {
      ...currentWeights.keys,
      ...previousWeights.keys,
    };

    final entries = <ActivityBreakdownEntry>[];
    for (final categoryId in allCategoryIds) {
      final name = categoryNameById[categoryId];
      // Skip entries where the category no longer exists.
      if (name == null) continue;

      entries.add(ActivityBreakdownEntry(
        categoryId: categoryId,
        name: name,
        currentYearWeight: currentWeights[categoryId] ?? 0,
        previousYearWeight: previousWeights[categoryId] ?? 0,
      ));
    }

    // Primary sort: descending currentYearWeight.
    // Secondary sort: descending previousYearWeight (relevant for zeros at bottom).
    entries.sort((a, b) {
      if (a.currentYearWeight != b.currentYearWeight) {
        return b.currentYearWeight.compareTo(a.currentYearWeight);
      }
      return b.previousYearWeight.compareTo(a.previousYearWeight);
    });

    return entries;
  }
}
