import 'package:hive_flutter/hive_flutter.dart';

/// Manages Hive box lifecycle and provides a persistent local cache layer.
///
/// Two cache tiers:
///   stats_*  — statistics data (per-year meetings, categories, persons) for
///              the Statistics tab; keyed by '${userId}_${year}'.
///   local_*  — full-dataset cache (all meetings/persons/categories) for
///              instant screen loads and AI tool calls; keyed by userId.
class HiveService {
  // Statistics cache boxes (US-073).
  static const String _meetingsBox = 'stats_meetings';
  static const String _categoriesBox = 'stats_categories';
  static const String _personsBox = 'stats_persons';
  static const String _availableYearsBox = 'stats_available_years';

  // Full-dataset local cache boxes (US-109).
  static const String _localMeetingsBox = 'local_meetings';
  static const String _localPersonsBox = 'local_persons';
  static const String _localCatsBox = 'local_categories';

  // Public constants used by StatisticsRepository to reference box names.
  static const String meetingsBox = _meetingsBox;
  static const String categoriesBox = _categoriesBox;
  static const String personsBox = _personsBox;
  static const String availableYearsBox = _availableYearsBox;

  // Public constants used by LocalCacheService to reference box names.
  static const String localMeetingsBox = _localMeetingsBox;
  static const String localPersonsBox = _localPersonsBox;
  static const String localCatsBox = _localCatsBox;

  /// Initializes Hive and opens all boxes.
  ///
  /// In production, call without arguments — uses [Hive.initFlutter()] which
  /// resolves the app documents directory via path_provider.
  ///
  /// In tests, pass [testPath] to use [Hive.init()] with a temp directory
  /// instead, avoiding the path_provider platform channel entirely.
  static Future<void> initialize({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    await Hive.openBox<dynamic>(_meetingsBox);
    await Hive.openBox<dynamic>(_categoriesBox);
    await Hive.openBox<dynamic>(_personsBox);
    await Hive.openBox<dynamic>(_availableYearsBox);
    await Hive.openBox<dynamic>(_localMeetingsBox);
    await Hive.openBox<dynamic>(_localPersonsBox);
    await Hive.openBox<dynamic>(_localCatsBox);
  }

  /// Returns an already-open box by name. Boxes must be opened via [initialize].
  static Box<dynamic> box(String name) => Hive.box<dynamic>(name);

  /// Clears all cache entries for a specific user across all boxes.
  /// Clears both statistics cache (stats_* boxes) and full-data cache (local_* boxes).
  /// Call on logout to prevent stale data being served to the next session.
  static Future<void> clearUserData(String userId) async {
    final meetBox = Hive.box<dynamic>(_meetingsBox);
    final keysToDelete =
        meetBox.keys.where((k) => k.toString().startsWith(userId)).toList();
    await meetBox.deleteAll(keysToDelete);

    await Hive.box<dynamic>(_categoriesBox).delete(userId);
    await Hive.box<dynamic>(_personsBox).delete(userId);
    await Hive.box<dynamic>(_availableYearsBox).delete(userId);

    await Hive.box<dynamic>(_localMeetingsBox).delete(userId);
    await Hive.box<dynamic>(_localPersonsBox).delete(userId);
    await Hive.box<dynamic>(_localCatsBox).delete(userId);
  }
}
