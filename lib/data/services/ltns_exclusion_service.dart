import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the set of person IDs excluded from the Long Time No See feature.
///
/// Uses SharedPreferences for local storage. Inject [prefs] in tests to avoid
/// hitting the real SharedPreferences instance.
class LtnsExclusionService {
  LtnsExclusionService({SharedPreferences? prefs}) : _prefs = prefs;

  static const _key = 'buddy_ltns_excluded_ids';

  // Null until lazily resolved via getInstance().
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns the set of person IDs currently excluded from LTNS.
  /// Returns an empty set when no exclusions have been saved.
  Future<Set<String>> getExcludedIds() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final list = (json.decode(raw) as List).cast<String>();
    return list.toSet();
  }

  /// Adds or removes [personId] from the exclusion list.
  /// [excluded] = true → person is excluded (hidden from LTNS).
  /// [excluded] = false → person is included (shown in LTNS).
  Future<void> setExcluded(String personId, {required bool excluded}) async {
    final prefs = await _getPrefs();
    final ids = await getExcludedIds();
    if (excluded) {
      ids.add(personId);
    } else {
      ids.remove(personId);
    }
    await prefs.setString(_key, json.encode(ids.toList()));
  }
}
