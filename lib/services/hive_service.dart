import 'package:hive_flutter/hive_flutter.dart';

/// Manages Hive box lifecycle and provides a persistent local cache layer
/// for statistics data. Acts as layer 2 in the cache lookup chain:
/// 1. In-memory cache (US-072) — fastest
/// 2. Hive cache (this service) — survives app restarts
/// 3. Firestore — only on true cache miss
class HiveService {
  static const String _meetingsBox = 'stats_meetings';
  static const String _categoriesBox = 'stats_categories';
  static const String _personsBox = 'stats_persons';
  static const String _availableYearsBox = 'stats_available_years';

  // Public constants used by StatisticsRepository to reference box names.
  static const String meetingsBox = _meetingsBox;
  static const String categoriesBox = _categoriesBox;
  static const String personsBox = _personsBox;
  static const String availableYearsBox = _availableYearsBox;

  /// Initializes Hive and opens all statistics boxes.
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
  }

  /// Returns an already-open box by name. Boxes must be opened via [initialize].
  static Box<dynamic> box(String name) => Hive.box<dynamic>(name);

  /// Clears all statistics cache entries for a specific user across all boxes.
  /// Call on logout to prevent stale data being served to the next session.
  static Future<void> clearUserData(String userId) async {
    final meetBox = Hive.box<dynamic>(_meetingsBox);
    final keysToDelete =
        meetBox.keys.where((k) => k.toString().startsWith(userId)).toList();
    await meetBox.deleteAll(keysToDelete);

    await Hive.box<dynamic>(_categoriesBox).delete(userId);
    await Hive.box<dynamic>(_personsBox).delete(userId);
    await Hive.box<dynamic>(_availableYearsBox).delete(userId);
  }
}
