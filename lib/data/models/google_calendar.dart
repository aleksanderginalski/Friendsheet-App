/// Represents a single calendar entry from the Google Calendar API.
class GoogleCalendar {
  final String id;
  final String summary;
  final bool isPrimary;

  const GoogleCalendar({
    required this.id,
    required this.summary,
    required this.isPrimary,
  });
}

/// Thrown when calendar OAuth authorization fails or the user denies access.
class CalendarAuthException implements Exception {
  final String message;
  const CalendarAuthException(this.message);

  @override
  String toString() => 'CalendarAuthException: $message';
}
