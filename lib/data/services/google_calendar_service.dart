import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/google_calendar.dart';

/// Service for Google Calendar OAuth access and calendar list retrieval.
/// Stores the OAuth access token in flutter_secure_storage.
class GoogleCalendarService {
  static final GoogleCalendarService _instance =
      GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  static const _tokenKey = 'google_calendar_access_token';
  static const _calendarScope =
      'https://www.googleapis.com/auth/calendar.readonly';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [_calendarScope],
  );

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

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Removes the stored access token, disconnecting calendar access.
  Future<void> revokeAccess() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
