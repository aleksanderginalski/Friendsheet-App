import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/import_candidate.dart';

const _kPrefsKey = 'meeting_inbox_candidates';

/// Manages the list of ImportCandidates pending review during an import session.
/// Persists the candidate list to SharedPreferences so that app restarts
/// mid-import do not lose pending candidates.
///
/// Lifecycle:
///   1. Call [loadFromPrefs] once on app start (async) to restore persisted state.
///   2. Call [addCandidates] after a calendar import to merge new candidates.
class MeetingInboxProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  List<ImportCandidate> _candidates = [];
  int _confirmedCount = 0;

  List<ImportCandidate> get candidates => List.unmodifiable(_candidates);
  int get confirmedCount => _confirmedCount;
  bool get isEmpty => _candidates.isEmpty;
  // All operations are synchronous — loading state is always false.
  bool get isLoading => false;

  /// Loads persisted candidates from SharedPreferences.
  /// Called once from MainScreen after the provider is created.
  Future<void> loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _candidates = _loadPersisted();
    notifyListeners();
  }

  /// Merges [incoming] candidates with persisted ones, deduplicating by id.
  /// Incoming candidates take precedence on conflict.
  /// Called from CalendarEventsScreen after the user selects events to import.
  void addCandidates(List<ImportCandidate> incoming) {
    final existing = _candidates;

    // Build a map from existing, then overwrite with incoming to deduplicate.
    final map = <String, ImportCandidate>{
      for (final c in existing) c.id: c,
      for (final c in incoming) c.id: c,
    };

    _candidates = map.values.toList();
    _persist();
    notifyListeners();
  }

  /// Removes the candidate and increments [confirmedCount].
  void markConfirmed(String candidateId) {
    _candidates.removeWhere((c) => c.id == candidateId);
    _confirmedCount++;
    _persist();
    notifyListeners();
  }

  /// Removes the candidate without incrementing [confirmedCount].
  void skip(String candidateId) {
    _candidates.removeWhere((c) => c.id == candidateId);
    _persist();
    notifyListeners();
  }

  /// Clears all candidates and resets confirmedCount.
  /// Called after ImportSuccessScreen is shown.
  void clear() {
    _candidates = [];
    _confirmedCount = 0;
    _prefs?.remove(_kPrefsKey);
    notifyListeners();
  }

  // --- Private helpers ---

  List<ImportCandidate> _loadPersisted() {
    final raw = _prefs?.getString(_kPrefsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ImportCandidate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _persist() {
    final json = _candidates.map((c) => c.toJson()).toList();
    _prefs?.setString(_kPrefsKey, jsonEncode(json));
  }
}
