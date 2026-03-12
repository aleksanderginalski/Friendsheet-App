import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/google_calendar.dart';
import 'package:friendsheet/data/services/google_calendar_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_calendar_service_test.mocks.dart';

@GenerateMocks([
  FlutterSecureStorage,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  const tokenKey = 'google_calendar_access_token';

  // Minimal JSON bodies returned by the fake HTTP function.
  const emptyItemsBody = '{"items":[]}';
  const singleEventBody = '''
{
  "items": [
    {
      "id": "evt-1",
      "summary": "Team Sync",
      "start": {"dateTime": "2024-06-01T10:00:00Z"},
      "attendees": []
    }
  ]
}
''';

  group('fetchEvents', () {
    test('succeeds on first attempt — signInSilently is never called',
        () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'stored-token');

      int httpCallCount = 0;
      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async {
          httpCallCount++;
          return (200, singleEventBody);
        },
      );

      final events = await service.fetchEvents(
        calendarIds: ['cal-1'],
        dateFrom: DateTime(2024),
        dateTo: DateTime(2025),
        excludeAllDay: false,
      );

      expect(httpCallCount, 1);
      expect(events, hasLength(1));
      verifyNever(signIn.signInSilently());
    });

    test(
        'gets HTTP 401 — signInSilently called, token refreshed, retry succeeds',
        () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();
      final account = MockGoogleSignInAccount();
      final auth = MockGoogleSignInAuthentication();

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'old-token');
      when(
        storage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async {});
      when(signIn.signInSilently()).thenAnswer((_) async => account);
      when(account.authentication).thenAnswer((_) async => auth);
      when(auth.accessToken).thenReturn('new-token');

      int httpCallCount = 0;
      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async {
          httpCallCount++;
          // First call returns 401; retry after refresh returns success.
          if (httpCallCount == 1) return (401, '{}');
          return (200, emptyItemsBody);
        },
      );

      final events = await service.fetchEvents(
        calendarIds: ['cal-1'],
        dateFrom: DateTime(2024),
        dateTo: DateTime(2025),
        excludeAllDay: false,
      );

      expect(httpCallCount, 2);
      verify(signIn.signInSilently()).called(1);
      // New token is persisted so subsequent calls use the refreshed token.
      verify(
        storage.write(key: tokenKey, value: 'new-token'),
      ).called(1);
      expect(events, isEmpty);
    });

    test(
        'gets HTTP 401 and signInSilently returns null — '
        'CalendarAuthException thrown', () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'old-token');
      when(signIn.signInSilently()).thenAnswer((_) async => null);

      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async => (401, '{}'),
      );

      expect(
        () => service.fetchEvents(
          calendarIds: ['cal-1'],
          dateFrom: DateTime(2024),
          dateTo: DateTime(2025),
          excludeAllDay: false,
        ),
        throwsA(isA<CalendarAuthException>()),
      );
    });

    test(
        'gets network error — original exception rethrown, '
        'CalendarAuthException not thrown', () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'stored-token');

      final networkError = Exception('Network failure');

      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async => throw networkError,
      );

      await expectLater(
        () => service.fetchEvents(
          calendarIds: ['cal-1'],
          dateFrom: DateTime(2024),
          dateTo: DateTime(2025),
          excludeAllDay: false,
        ),
        throwsA(same(networkError)),
      );

      // Network errors must not trigger a silent sign-in attempt.
      verifyNever(signIn.signInSilently());
    });

    test('no token in storage — CalendarAuthException thrown without HTTP call',
        () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();

      when(storage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
      // _withTokenRetry catches the "not connected" CalendarAuthException and
      // attempts a silent refresh. With null returned, refresh also throws
      // CalendarAuthException, confirming no HTTP call is ever made.
      when(signIn.signInSilently()).thenAnswer((_) async => null);

      bool httpCalled = false;
      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async {
          httpCalled = true;
          return (200, emptyItemsBody);
        },
      );

      await expectLater(
        () => service.fetchEvents(
          calendarIds: ['cal-1'],
          dateFrom: DateTime(2024),
          dateTo: DateTime(2025),
          excludeAllDay: false,
        ),
        throwsA(isA<CalendarAuthException>()),
      );

      expect(httpCalled, isFalse);
    });
  });

  group('fetchCalendars', () {
    const calendarListBody = '''
{
  "items": [
    {"id": "cal-1", "summary": "My Calendar", "primary": true}
  ]
}
''';

    test(
        'gets HTTP 401 — signInSilently called, token refreshed, retry succeeds',
        () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();
      final account = MockGoogleSignInAccount();
      final auth = MockGoogleSignInAuthentication();

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'old-token');
      when(
        storage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async {});
      when(signIn.signInSilently()).thenAnswer((_) async => account);
      when(account.authentication).thenAnswer((_) async => auth);
      when(auth.accessToken).thenReturn('new-token');

      int httpCallCount = 0;
      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async {
          httpCallCount++;
          // First call returns 401; retry after refresh returns the list.
          if (httpCallCount == 1) return (401, '{}');
          return (200, calendarListBody);
        },
      );

      final calendars = await service.fetchCalendars();

      expect(httpCallCount, 2);
      verify(signIn.signInSilently()).called(1);
      verify(storage.write(key: tokenKey, value: 'new-token')).called(1);
      expect(calendars, hasLength(1));
      expect(calendars.first.id, 'cal-1');
    });

    test(
        'gets HTTP 401 and signInSilently returns null — '
        'CalendarAuthException thrown', () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'old-token');
      when(signIn.signInSilently()).thenAnswer((_) async => null);

      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async => (401, '{}'),
      );

      await expectLater(
        () => service.fetchCalendars(),
        throwsA(isA<CalendarAuthException>()),
      );
    });

    test('succeeds on first attempt — signInSilently is never called',
        () async {
      final storage = MockFlutterSecureStorage();
      final signIn = MockGoogleSignIn();

      when(storage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'stored-token');

      final service = GoogleCalendarService.forTesting(
        secureStorage: storage,
        googleSignIn: signIn,
        httpGet: (uri, token) async => (200, calendarListBody),
      );

      final calendars = await service.fetchCalendars();

      expect(calendars, hasLength(1));
      verifyNever(signIn.signInSilently());
    });
  });
}
