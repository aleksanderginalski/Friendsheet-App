import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/calendar_event.dart';
import '../models/google_calendar.dart';

// Private typedef for the HTTP GET function — injected in tests to avoid
// platform channel calls and to simulate specific HTTP status codes.
typedef _HttpGetFn = Future<(int, String)> Function(Uri uri, String authToken);

/// Service for Google Calendar OAuth access and calendar list retrieval.
/// Stores the OAuth access token in flutter_secure_storage.
///
/// Both [fetchCalendars] and [fetchEvents] use [_withTokenRetry]: on HTTP 401
/// they attempt a silent token refresh once before surfacing a
/// [CalendarAuthException] to the caller. Non-auth errors are rethrown as-is.
class GoogleCalendarService {
  static final GoogleCalendarService _instance =
      GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;

  GoogleCalendarService._internal()
      : _secureStorage = const FlutterSecureStorage(),
        _googleSignIn = GoogleSignIn(scopes: [_calendarScope]),
        _httpGet = _defaultHttpGet {
    _initConnectionState();
  }

  /// Test-only constructor — allows injecting storage, sign-in, and HTTP
  /// to avoid platform channels and control responses in unit tests.
  @visibleForTesting
  GoogleCalendarService.forTesting({
    required FlutterSecureStorage secureStorage,
    required GoogleSignIn googleSignIn,
    Future<(int, String)> Function(Uri, String)? httpGet,
  })  : _secureStorage = secureStorage,
        _googleSignIn = googleSignIn,
        _httpGet = httpGet ?? _defaultHttpGet {
    _initConnectionState();
  }

  static const _tokenKey = 'google_calendar_access_token';
  static const _calendarScope =
      'https://www.googleapis.com/auth/calendar.readonly';

  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;
  final _HttpGetFn _httpGet;

  /// Notifies listeners when calendar connection state changes.
  /// Initialized to false; updated after token save and revoke.
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);

  bool _initialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  Future<void> _initConnectionState() async {
    final token = await _secureStorage.read(key: _tokenKey);
    isConnectedNotifier.value = token != null;
    _initialized = true;
    if (!_initCompleter.isCompleted) _initCompleter.complete();
  }

  /// Waits until the persisted token state has been read from secure storage.
  /// Safe to call multiple times — resolves immediately if already initialized.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _initCompleter.future;
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
  /// On HTTP 401, attempts a silent token refresh and retries once.
  /// Throws [CalendarAuthException] if refresh fails or retry also returns 401.
  Future<List<GoogleCalendar>> fetchCalendars() async {
    return _withTokenRetry(_doFetchCalendars);
  }

  Future<List<GoogleCalendar>> _doFetchCalendars() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) {
      throw const CalendarAuthException('Not connected to Google Calendar');
    }

    final uri = Uri.parse(
      'https://www.googleapis.com/calendar/v3/users/me/calendarList',
    );

    final (statusCode, body) = await _httpGet(uri, token);

    if (statusCode == 401) {
      // Token expired — _withTokenRetry will handle the refresh and retry.
      throw const CalendarAuthException('Access token expired (HTTP 401)');
    }
    if (statusCode != 200) {
      // Non-auth API error — throw a plain exception so _withTokenRetry does
      // not attempt a silent refresh for server-side or network errors.
      throw Exception('Calendar API error: $statusCode');
    }

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
  }

  /// Fetches events from the specified calendars within the given date range.
  /// Returns past events only (startDate < now).
  /// On HTTP 401, attempts a silent token refresh and retries once.
  /// Throws [CalendarAuthException] if refresh fails or retry also returns 401.
  /// Non-auth errors (network, timeout) are rethrown unchanged.
  Future<List<CalendarEvent>> fetchEvents({
    required List<String> calendarIds,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool excludeAllDay,
  }) async {
    return _withTokenRetry(
      () => _doFetchEvents(
        calendarIds: calendarIds,
        dateFrom: dateFrom,
        dateTo: dateTo,
        excludeAllDay: excludeAllDay,
      ),
    );
  }

  Future<List<CalendarEvent>> _doFetchEvents({
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

  /// Executes [call] and, on the first [CalendarAuthException], refreshes the
  /// access token silently and retries [call] once.
  /// If refresh or the retry also fails, the exception propagates to the caller.
  Future<T> _withTokenRetry<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on CalendarAuthException {
      await _refreshAccessToken();
      return await call();
    }
  }

  /// Performs a silent sign-in and writes the fresh access token to storage.
  /// Throws [CalendarAuthException] if silent sign-in fails or returns null.
  Future<void> _refreshAccessToken() async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) {
      throw const CalendarAuthException('Silent sign-in returned null');
    }
    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) {
      throw const CalendarAuthException(
        'Failed to obtain access token after silent sign-in',
      );
    }
    await _saveToken(accessToken);
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

    final (statusCode, body) = await _httpGet(uri, token);

    if (statusCode == 401) {
      // Token expired — caller (_doFetchEvents via _withTokenRetry) handles refresh.
      throw const CalendarAuthException('Access token expired (HTTP 401)');
    }
    if (statusCode != 200) {
      // Non-auth error — skip this calendar without failing the whole fetch.
      return [];
    }

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

  /// Default HTTP GET implementation using dart:io HttpClient.
  static Future<(int, String)> _defaultHttpGet(
    Uri uri,
    String authToken,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $authToken');
      final response = await request.close();
      final statusCode = response.statusCode;
      final body = await response.transform(utf8.decoder).join();
      return (statusCode, body);
    } finally {
      client.close();
    }
  }
}
