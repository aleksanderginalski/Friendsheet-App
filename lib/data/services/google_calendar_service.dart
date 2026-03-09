import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/calendar_event.dart';
import '../models/google_calendar.dart';

/// Service for Google Calendar OAuth access and calendar list retrieval.
/// Stores the OAuth access token in flutter_secure_storage.
class GoogleCalendarService {
  static final GoogleCalendarService _instance =
      GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal() {
    _initConnectionState();
  }

  static const _tokenKey = 'google_calendar_access_token';
  static const _calendarScope =
      'https://www.googleapis.com/auth/calendar.readonly';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [_calendarScope],
  );

  /// Notifies listeners when calendar connection state changes.
  /// Initialized to false; updated after token save and revoke.
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);

  Future<void> _initConnectionState() async {
    final token = await _secureStorage.read(key: _tokenKey);
    isConnectedNotifier.value = token != null;
  }

  /// Returns true if a calendar access token exists in secure storage.
  Future<bool> isConnected() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  /// Requests calendar.readonly scope via incremental auth on the existing
  /// Google session. Saves the access token on success.
  /// Throws [CalendarAuthException] if the user denies or auth fails.
  Future<List<GoogleCalendar>> requestAccess() async {
    try {
      final account =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (account == null) {
        throw const CalendarAuthException('No signed-in account found');
      }

      final granted = await _googleSignIn.requestScopes([_calendarScope]);
      if (!granted) {
        throw const CalendarAuthException('Calendar access was denied');
      }

      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      if (accessToken == null) {
        throw const CalendarAuthException('Failed to obtain access token');
      }

      await _saveToken(accessToken);
      return await fetchCalendars();
    } on CalendarAuthException {
      rethrow;
    } catch (e) {
      throw CalendarAuthException('Calendar authorization failed: $e');
    }
  }

  /// Fetches the list of user calendars from the Google Calendar API.
  /// Requires a valid access token stored in secure storage.
  Future<List<GoogleCalendar>> fetchCalendars() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) {
      throw const CalendarAuthException('Not connected to Google Calendar');
    }

    final uri = Uri.parse(
      'https://www.googleapis.com/calendar/v3/users/me/calendarList',
    );
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      final response = await request.close();

      if (response.statusCode != 200) {
        throw CalendarAuthException('API error: ${response.statusCode}');
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      return items.map((item) {
        final map = item as Map<String, dynamic>;
        return GoogleCalendar(
          id: map['id'] as String,
          summary: map['summary'] as String? ?? map['id'] as String,
          isPrimary: map['primary'] as bool? ?? false,
        );
      }).toList();
    } finally {
      client.close();
    }
  }

  /// Fetches events from the specified calendars within the given date range.
  /// Returns past events only (startDate < now).
  /// Excludes all-day events when [excludeAllDay] is true.
  /// Requires a valid access token stored in secure storage.
  Future<List<CalendarEvent>> fetchEvents({
    required List<String> calendarIds,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool excludeAllDay,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) {
      throw const CalendarAuthException('Not connected to Google Calendar');
    }

    final now = DateTime.now();
    final effectiveDateTo = dateTo.isAfter(now) ? now : dateTo;

    final List<CalendarEvent> allEvents = [];

    for (final calendarId in calendarIds) {
      final events = await _fetchEventsForCalendar(
        calendarId: calendarId,
        token: token,
        dateFrom: dateFrom,
        dateTo: effectiveDateTo,
        excludeAllDay: excludeAllDay,
      );
      allEvents.addAll(events);
    }

    // Sort by startDate descending (most recent first)
    allEvents.sort((a, b) => b.startDate.compareTo(a.startDate));
    return allEvents;
  }

  Future<List<CalendarEvent>> _fetchEventsForCalendar({
    required String calendarId,
    required String token,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool excludeAllDay,
  }) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/calendar/v3/calendars/${Uri.encodeComponent(calendarId)}/events',
    ).replace(queryParameters: {
      'timeMin': dateFrom.toUtc().toIso8601String(),
      'timeMax': dateTo.toUtc().toIso8601String(),
      'singleEvents': 'true',
      'orderBy': 'startTime',
      'maxResults': '500',
      if (excludeAllDay) 'timeZone': 'UTC',
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      final response = await request.close();

      if (response.statusCode != 200) {
        // Skip this calendar on error instead of failing the whole fetch
        return [];
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      final events = <CalendarEvent>[];
      for (final item in items) {
        final map = item as Map<String, dynamic>;

        final startMap = map['start'] as Map<String, dynamic>?;
        if (startMap == null) continue;

        final isAllDay =
            startMap.containsKey('date') && !startMap.containsKey('dateTime');
        if (excludeAllDay && isAllDay) continue;

        final startDate = isAllDay
            ? DateTime.parse(startMap['date'] as String)
            : DateTime.parse(startMap['dateTime'] as String).toLocal();

        final attendees = map['attendees'] as List<dynamic>? ?? [];
        final attendeeEmails = attendees
            .map((a) => (a as Map<String, dynamic>)['email'] as String? ?? '')
            .where((e) => e.isNotEmpty)
            .toList();

        events.add(CalendarEvent(
          id: map['id'] as String? ?? '',
          title: map['summary'] as String? ?? '',
          startDate: startDate,
          isAllDay: isAllDay,
          attendeeEmails: attendeeEmails,
          calendarId: calendarId,
        ));
      }
      return events;
    } finally {
      client.close();
    }
  }

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    isConnectedNotifier.value = true;
  }

  /// Removes the stored access token, disconnecting calendar access.
  Future<void> revokeAccess() async {
    await _secureStorage.delete(key: _tokenKey);
    isConnectedNotifier.value = false;
  }
}
