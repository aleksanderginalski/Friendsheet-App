import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/calendar_event.dart';
import '../../data/models/google_calendar.dart';
import '../../data/models/import_candidate.dart';
import '../../data/services/google_calendar_service.dart';

enum CalendarEventsStatus { idle, loading, loaded, error }

/// Provider managing state for CalendarEventsScreen.
/// Handles event fetching, filtering, and selection.
class CalendarEventsProvider extends ChangeNotifier {
  final GoogleCalendarService _calendarService;
  final List<GoogleCalendar> availableCalendars;

  CalendarEventsProvider({
    required this.availableCalendars,
    GoogleCalendarService? calendarService,
  }) : _calendarService = calendarService ?? GoogleCalendarService() {
    // Default: select primary calendar, or first if none is primary
    final primary = availableCalendars.where((c) => c.isPrimary).take(1);
    if (primary.isNotEmpty) {
      _selectedCalendarIds = {primary.first.id};
    } else if (availableCalendars.isNotEmpty) {
      _selectedCalendarIds = {availableCalendars.first.id};
    } else {
      _selectedCalendarIds = {};
    }
  }

  final _uuid = const Uuid();

  CalendarEventsStatus _status = CalendarEventsStatus.idle;
  List<CalendarEvent> _events = [];
  final Set<String> _selectedEventIds = {};
  String? _errorMessage;

  // Filter state
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 365));
  DateTime _dateTo = DateTime.now();
  late Set<String> _selectedCalendarIds;
  bool _excludeAllDay = true;

  // Getters
  CalendarEventsStatus get status => _status;
  List<CalendarEvent> get events => _events;
  Set<String> get selectedEventIds => _selectedEventIds;
  String? get errorMessage => _errorMessage;
  DateTime get dateFrom => _dateFrom;
  DateTime get dateTo => _dateTo;
  Set<String> get selectedCalendarIds => _selectedCalendarIds;
  bool get excludeAllDay => _excludeAllDay;
  int get selectedCount => _selectedEventIds.length;
  bool get hasEvents => _events.isNotEmpty;

  bool isSelected(String eventId) => _selectedEventIds.contains(eventId);

  bool get allSelected =>
      _events.isNotEmpty && _selectedEventIds.length == _events.length;

  /// Fetches events using current filter state.
  Future<void> loadEvents() async {
    if (_selectedCalendarIds.isEmpty) {
      _events = [];
      _selectedEventIds.clear();
      _status = CalendarEventsStatus.loaded;
      notifyListeners();
      return;
    }

    _status = CalendarEventsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _calendarService.fetchEvents(
        calendarIds: _selectedCalendarIds.toList(),
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        excludeAllDay: _excludeAllDay,
      );
      // Remove selections for events no longer in the list
      _selectedEventIds.retainWhere(
        (id) => _events.any((e) => e.id == id),
      );
      _status = CalendarEventsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = CalendarEventsStatus.error;
    }

    notifyListeners();
  }

  void toggleEventSelection(String eventId) {
    if (_selectedEventIds.contains(eventId)) {
      _selectedEventIds.remove(eventId);
    } else {
      _selectedEventIds.add(eventId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedEventIds.addAll(_events.map((e) => e.id));
    notifyListeners();
  }

  void deselectAll() {
    _selectedEventIds.clear();
    notifyListeners();
  }

  void setDateRange(DateTime from, DateTime to) {
    _dateFrom = from;
    _dateTo = to;
    notifyListeners();
  }

  void toggleCalendar(String calendarId) {
    if (_selectedCalendarIds.contains(calendarId)) {
      _selectedCalendarIds.remove(calendarId);
    } else {
      _selectedCalendarIds.add(calendarId);
    }
    notifyListeners();
  }

  void setExcludeAllDay(bool value) {
    _excludeAllDay = value;
    notifyListeners();
  }

  /// Converts selected events to ImportCandidate list.
  /// Called when user taps "Import (N)".
  List<ImportCandidate> buildImportCandidates() {
    return _events
        .where((e) => _selectedEventIds.contains(e.id))
        .map(
          (e) => ImportCandidate(
            id: _uuid.v4(),
            title: e.title,
            date: e.startDate,
            attendeeEmails: e.attendeeEmails,
            sourceType: ImportSourceType.calendar,
          ),
        )
        .toList();
  }
}
