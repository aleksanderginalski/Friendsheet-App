import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_category.dart';
import '../models/meeting.dart';
import '../models/person.dart';
import '../models/stats_data_bundle.dart';
import 'activity_category_repository.dart';
import 'cache_invalidator.dart';
import 'person_repository.dart';

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

/// Display DTO representing one person's total meeting weight for a
/// specific activity in a given year.
/// Not a domain model — plain Dart class, no Freezed.
class PersonActivityEntry {
  final String personId;
  final String name;
  final int weightSum;

  const PersonActivityEntry({
    required this.personId,
    required this.name,
    required this.weightSum,
  });
}

/// Display DTO representing one person's total meeting weight across all
/// meetings for the Interaction Distribution metric.
/// Not a domain model — plain Dart class, no Freezed.
class InteractionDistributionEntry {
  final String personId;
  final String name;
  final int currentYearWeight;
  final int previousYearWeight;

  const InteractionDistributionEntry({
    required this.personId,
    required this.name,
    required this.currentYearWeight,
    required this.previousYearWeight,
  });

  /// Positive: weight grew vs. previous year. Negative: weight shrank.
  int get delta => currentYearWeight - previousYearWeight;
}

/// Handles statistics-related Firestore queries with in-memory caching.
/// Implements [CacheInvalidator] so write repositories can clear stale cache
/// entries without creating circular constructor dependencies.
///
/// Cache keys for meetings: '${userId}_${year}'.
/// Categories and persons are cached globally (user switch resets via invalidateAllCaches).
class StatisticsRepository implements CacheInvalidator {
  final FirebaseFirestore _firestore;
  final ActivityCategoryRepository _categoryRepository;
  final PersonRepository _personRepository;

  // Per-year meeting cache: key = '${userId}_${year}'.
  final Map<String, List<Meeting>> _meetingsCache = {};

  // Single-user caches — invalidated on write or user switch.
  List<ActivityCategory>? _categoriesCache;
  List<Person>? _personsCache;

  StatisticsRepository({
    FirebaseFirestore? firestore,
    required ActivityCategoryRepository categoryRepository,
    required PersonRepository personRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _categoryRepository = categoryRepository,
        _personRepository = personRepository;

  CollectionReference _meetingsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('meetings');

  // ─── Cache invalidation ────────────────────────────────────────────────────

  @override
  void invalidateMeetingsCache() => _meetingsCache.clear();

  @override
  void invalidateCategoriesCache() => _categoriesCache = null;

  @override
  void invalidatePersonsCache() => _personsCache = null;

  /// Clears all caches. Call on user logout or account switch.
  void invalidateAllCaches() {
    invalidateMeetingsCache();
    invalidateCategoriesCache();
    invalidatePersonsCache();
  }

  // ─── Internal cached fetches ───────────────────────────────────────────────

  /// Fetches all meetings for [year] from Firestore (bypasses cache).
  Future<List<Meeting>> _fetchMeetingsForYear(String userId, int year) async {
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

  /// Returns all categories for [userId], using cache when available.
  Future<List<ActivityCategory>> _getCachedCategories(String userId) async {
    if (_categoriesCache != null) return _categoriesCache!;
    _categoriesCache = await _categoryRepository.getAllCategories(userId);
    return _categoriesCache!;
  }

  /// Returns all persons for [userId], using cache when available.
  Future<List<Person>> _getCachedPersons(String userId) async {
    if (_personsCache != null) return _personsCache!;
    _personsCache = await _personRepository.getPersonsByUser(userId);
    return _personsCache!;
  }

  // ─── Public query methods ──────────────────────────────────────────────────

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

  /// Returns all meetings for [year] for [userId], using in-memory cache.
  /// Cache key: '${userId}_${year}'.
  Future<List<Meeting>> getMeetingsForYear(String userId, int year) async {
    final key = '${userId}_$year';
    if (_meetingsCache.containsKey(key)) return _meetingsCache[key]!;
    final meetings = await _fetchMeetingsForYear(userId, year);
    _meetingsCache[key] = meetings;
    return meetings;
  }

  // ─── Bundle loading ────────────────────────────────────────────────────────

  /// Fetches all data required for one year's statistics in a single
  /// parallel round-trip, using caches where available.
  ///
  /// [currentYearMeetings] and [previousYearMeetings] are cached per year.
  /// [categories] and [persons] are cached globally until invalidated.
  Future<StatsDataBundle> loadAllStatsData(int year, String userId) async {
    final results = await Future.wait([
      getMeetingsForYear(userId, year),
      getMeetingsForYear(userId, year - 1),
      _getCachedCategories(userId),
      _getCachedPersons(userId),
    ]);

    return StatsDataBundle(
      currentYearMeetings: results[0] as List<Meeting>,
      previousYearMeetings: results[1] as List<Meeting>,
      categories: results[2] as List<ActivityCategory>,
      persons: results[3] as List<Person>,
    );
  }

  // ─── Pure compute methods (no Firestore) ──────────────────────────────────

  /// Returns a ranked list of activity categories by total meeting weight
  /// for the current year in [bundle], compared to the previous year.
  ///
  /// Aggregation rule: for each meeting, each unique categoryId in
  /// meeting.categoryIds contributes meeting.weight once.
  /// Categories not found in bundle.categories are skipped.
  /// Sorted descending by currentYearWeight; zero-weight entries appear at
  /// bottom sorted by previousYearWeight descending.
  List<ActivityBreakdownEntry> computeActivityBreakdown(
    StatsDataBundle bundle,
  ) {
    final categoryNameById = {
      for (final c in bundle.categories) c.id: c.name,
    };

    final Map<String, int> currentWeights = {};
    for (final meeting in bundle.currentYearMeetings) {
      // Use a set to avoid double-counting duplicate categoryIds per meeting.
      for (final categoryId in meeting.categoryIds.toSet()) {
        currentWeights[categoryId] =
            (currentWeights[categoryId] ?? 0) + meeting.weight;
      }
    }

    final Map<String, int> previousWeights = {};
    for (final meeting in bundle.previousYearMeetings) {
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

  /// Returns persons ranked by total meeting weight for [categoryId] in the
  /// current year, computed from [bundle].
  ///
  /// Filtering: a meeting matches if its categoryIds contains [categoryId].
  /// Aggregation: each participant's weight is counted once per meeting.
  /// Persons not found in bundle.persons are skipped.
  /// Sorted descending by weightSum.
  List<PersonActivityEntry> computePersonsForActivity(
    StatsDataBundle bundle,
    String categoryId,
  ) {
    // Keep only meetings that include the selected category.
    final filtered = bundle.currentYearMeetings
        .where((m) => m.categoryIds.contains(categoryId))
        .toList();

    // Aggregate weight per participant across all filtered meetings.
    final Map<String, int> weightByPerson = {};
    for (final meeting in filtered) {
      for (final personId in meeting.participantIds) {
        weightByPerson[personId] =
            (weightByPerson[personId] ?? 0) + meeting.weight;
      }
    }

    if (weightByPerson.isEmpty) return [];

    final personNameById = {
      for (final p in bundle.persons) p.id: p.fullName,
    };

    final entries = <PersonActivityEntry>[];
    for (final kv in weightByPerson.entries) {
      final name = personNameById[kv.key];
      // Skip persons no longer in the collection.
      if (name == null) continue;
      entries.add(PersonActivityEntry(
        personId: kv.key,
        name: name,
        weightSum: kv.value,
      ));
    }

    entries.sort((a, b) => b.weightSum.compareTo(a.weightSum));
    return entries;
  }

  /// Returns persons ranked by total meeting weight across all meetings,
  /// compared to the previous year, computed from [bundle].
  ///
  /// For each meeting in current year: each participantId accumulates weight.
  /// Persons not found in bundle.persons are skipped.
  /// Sorted descending by currentYearWeight; alphabetically by name for ties.
  List<InteractionDistributionEntry> computeInteractionDistribution(
    StatsDataBundle bundle,
  ) {
    final personNameById = {
      for (final p in bundle.persons) p.id: p.fullName,
    };

    final Map<String, int> currentWeights = {};
    for (final meeting in bundle.currentYearMeetings) {
      for (final personId in meeting.participantIds) {
        currentWeights[personId] =
            (currentWeights[personId] ?? 0) + meeting.weight;
      }
    }

    final Map<String, int> previousWeights = {};
    for (final meeting in bundle.previousYearMeetings) {
      for (final personId in meeting.participantIds) {
        previousWeights[personId] =
            (previousWeights[personId] ?? 0) + meeting.weight;
      }
    }

    // Include persons with weight in either year.
    final allPersonIds = {
      ...currentWeights.keys,
      ...previousWeights.keys,
    };

    final entries = <InteractionDistributionEntry>[];
    for (final personId in allPersonIds) {
      final name = personNameById[personId];
      // Skip persons no longer in the collection.
      if (name == null) continue;

      entries.add(InteractionDistributionEntry(
        personId: personId,
        name: name,
        currentYearWeight: currentWeights[personId] ?? 0,
        previousYearWeight: previousWeights[personId] ?? 0,
      ));
    }

    // Primary sort: descending currentYearWeight.
    // Secondary sort: alphabetically by name for ties.
    entries.sort((a, b) {
      if (a.currentYearWeight != b.currentYearWeight) {
        return b.currentYearWeight.compareTo(a.currentYearWeight);
      }
      return a.name.compareTo(b.name);
    });

    return entries;
  }

  // ─── Backward-compatible async wrappers ───────────────────────────────────

  /// Returns a ranked list of activity categories by weight for [year].
  /// Delegates to [loadAllStatsData] + [computeActivityBreakdown].
  Future<List<ActivityBreakdownEntry>> getActivityWeightBreakdown(
    int year,
    String userId,
  ) async {
    final bundle = await loadAllStatsData(year, userId);
    return computeActivityBreakdown(bundle);
  }

  /// Returns persons ranked by weight for [categoryId] in [year].
  /// Delegates to [loadAllStatsData] + [computePersonsForActivity].
  Future<List<PersonActivityEntry>> getPersonsForActivity(
    String categoryId,
    int year,
    String userId,
  ) async {
    final bundle = await loadAllStatsData(year, userId);
    return computePersonsForActivity(bundle, categoryId);
  }

  /// Returns persons ranked by total meeting weight for [year] vs previous.
  /// Delegates to [loadAllStatsData] + [computeInteractionDistribution].
  Future<List<InteractionDistributionEntry>> getInteractionDistribution(
    int year,
    String userId,
  ) async {
    final bundle = await loadAllStatsData(year, userId);
    return computeInteractionDistribution(bundle);
  }

  /// Returns persons ranked by cumulative meeting weight from all years up to
  /// and including [year].
  ///
  /// previousYearWeight is always 0 — delta is not applicable in cumulative mode.
  /// Sorted descending by currentYearWeight; alphabetically by name for ties.
  /// Uses [_personsCache] but requires a separate all-years Firestore query.
  Future<List<InteractionDistributionEntry>> getCumulativeInteractions(
    int year,
    String userId,
  ) async {
    final endDate = Timestamp.fromDate(DateTime(year + 1));
    final snapshot =
        await _meetingsRef(userId).where('date', isLessThan: endDate).get();
    final meetings =
        snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList();

    final persons = await _getCachedPersons(userId);
    final personNameById = {for (final p in persons) p.id: p.fullName};

    final Map<String, int> weights = {};
    for (final meeting in meetings) {
      for (final personId in meeting.participantIds) {
        weights[personId] = (weights[personId] ?? 0) + meeting.weight;
      }
    }

    if (weights.isEmpty) return [];

    final entries = <InteractionDistributionEntry>[];
    for (final entry in weights.entries) {
      final name = personNameById[entry.key];
      // Skip persons no longer in the collection.
      if (name == null) continue;

      entries.add(InteractionDistributionEntry(
        personId: entry.key,
        name: name,
        currentYearWeight: entry.value,
        previousYearWeight: 0,
      ));
    }

    entries.sort((a, b) {
      if (a.currentYearWeight != b.currentYearWeight) {
        return b.currentYearWeight.compareTo(a.currentYearWeight);
      }
      return a.name.compareTo(b.name);
    });

    return entries;
  }
}
