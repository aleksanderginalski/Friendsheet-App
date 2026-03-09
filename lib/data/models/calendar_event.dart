import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event.freezed.dart';

/// Represents a single event fetched from Google Calendar API.
/// Local model only — never persisted to Firestore.
@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String title,
    required DateTime startDate,
    required bool isAllDay,
    required List<String> attendeeEmails,
    required String calendarId,
  }) = _CalendarEvent;
}
