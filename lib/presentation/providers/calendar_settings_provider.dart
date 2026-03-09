import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/google_calendar.dart';
import '../../data/services/google_calendar_service.dart';

/// Manages Google Calendar connection state and per-calendar preferences.
/// Persists selected calendar IDs and the all-day toggle in SharedPreferences.
class CalendarSettingsProvider extends ChangeNotifier {
  CalendarSettingsProvider({required this.calendarService});

  final GoogleCalendarService calendarService;

  static const _selectedIdsKey = 'calendar_selected_ids';
  static const _includeAllDayKey = 'calendar_include_all_day';

  bool _isConnected = false;
  List<GoogleCalendar> _availableCalendars = [];
  Set<String> _selectedCalendarIds = {};
  bool _includeAllDay = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isConnected => _isConnected;
  List<GoogleCalendar> get availableCalendars => _availableCalendars;
  Set<String> get selectedCalendarIds => _selectedCalendarIds;
  bool get includeAllDay => _includeAllDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads connection state and persisted preferences.
  /// If connected and no calendars are selected, auto-selects the primary.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isConnected = await calendarService.isConnected();
    _includeAllDay = prefs.getBool(_includeAllDayKey) ?? false;

    final savedIds = prefs.getStringList(_selectedIdsKey);
    _selectedCalendarIds = savedIds != null ? Set.from(savedIds) : {};

    if (_isConnected) {
      try {
        _availableCalendars = await calendarService.fetchCalendars();
        if (_selectedCalendarIds.isEmpty) {
          final primaryId = _availableCalendars
              .where((c) => c.isPrimary)
              .map((c) => c.id)
              .firstOrNull;
          if (primaryId != null) {
            _selectedCalendarIds = {primaryId};
            await prefs.setStringList(_selectedIdsKey, [primaryId]);
          }
        }
      } catch (_) {
        // Non-fatal — keep previously saved selections.
      }
    }

    notifyListeners();
  }

  /// Requests calendar.readonly scope and updates connection state.
  /// Throws [CalendarAuthException] if the user denies or auth fails.
  Future<List<GoogleCalendar>> connectCalendar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final calendars = await calendarService.requestAccess();
      _availableCalendars = calendars;
      _isConnected = true;

      if (_selectedCalendarIds.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final primaryId =
            calendars.where((c) => c.isPrimary).map((c) => c.id).firstOrNull;
        if (primaryId != null) {
          _selectedCalendarIds = {primaryId};
          await prefs.setStringList(_selectedIdsKey, [primaryId]);
        }
      }

      _isLoading = false;
      // Notify before returning — caller may navigate away immediately after.
      // Do NOT use finally here: notifyListeners after navigation triggers
      // a rebuild on a disposed widget and causes a spurious error.
      notifyListeners();
      return calendars;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Adds or removes [calendarId] from the selected set and persists the change.
  Future<void> toggleCalendar(String calendarId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedCalendarIds.contains(calendarId)) {
      _selectedCalendarIds = {..._selectedCalendarIds}..remove(calendarId);
    } else {
      _selectedCalendarIds = {..._selectedCalendarIds, calendarId};
    }
    await prefs.setStringList(_selectedIdsKey, _selectedCalendarIds.toList());
    notifyListeners();
  }

  /// Toggles the all-day events preference and persists it.
  Future<void> toggleAllDay() async {
    final prefs = await SharedPreferences.getInstance();
    _includeAllDay = !_includeAllDay;
    await prefs.setBool(_includeAllDayKey, _includeAllDay);
    notifyListeners();
  }

  /// Revokes calendar access, clears the token, and resets all preferences.
  Future<void> revokeAccess() async {
    _isLoading = true;
    notifyListeners();
    try {
      await calendarService.revokeAccess();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_selectedIdsKey);
      await prefs.remove(_includeAllDayKey);
      _isConnected = false;
      _availableCalendars = [];
      _selectedCalendarIds = {};
      _includeAllDay = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to disconnect: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
