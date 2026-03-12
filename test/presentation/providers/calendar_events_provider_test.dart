import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/google_calendar.dart';
import 'package:friendsheet/data/services/google_calendar_service.dart';
import 'package:friendsheet/presentation/providers/calendar_events_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_events_provider_test.mocks.dart';

@GenerateMocks([GoogleCalendarService])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testCalendar = GoogleCalendar(
    id: 'cal-1',
    summary: 'My Calendar',
    isPrimary: true,
  );

  CalendarEventsProvider buildProvider(MockGoogleCalendarService service) {
    return CalendarEventsProvider(
      availableCalendars: [testCalendar],
      calendarService: service,
    );
  }

  group('loadEvents — CalendarAuthException', () {
    test('sets requiresReconnect = true and clears errorMessage', () async {
      final service = MockGoogleCalendarService();
      when(
        service.fetchEvents(
          calendarIds: anyNamed('calendarIds'),
          dateFrom: anyNamed('dateFrom'),
          dateTo: anyNamed('dateTo'),
          excludeAllDay: anyNamed('excludeAllDay'),
        ),
      ).thenThrow(const CalendarAuthException('Token expired'));

      final provider = buildProvider(service);
      await provider.loadEvents();

      expect(provider.requiresReconnect, isTrue);
      expect(provider.errorMessage, isNull);
      expect(provider.status, CalendarEventsStatus.error);
    });

    test('resets requiresReconnect to false on subsequent success', () async {
      final service = MockGoogleCalendarService();
      // First call: auth error.
      when(
        service.fetchEvents(
          calendarIds: anyNamed('calendarIds'),
          dateFrom: anyNamed('dateFrom'),
          dateTo: anyNamed('dateTo'),
          excludeAllDay: anyNamed('excludeAllDay'),
        ),
      ).thenThrow(const CalendarAuthException('Token expired'));

      final provider = buildProvider(service);
      await provider.loadEvents();
      expect(provider.requiresReconnect, isTrue);

      // Second call: success.
      when(
        service.fetchEvents(
          calendarIds: anyNamed('calendarIds'),
          dateFrom: anyNamed('dateFrom'),
          dateTo: anyNamed('dateTo'),
          excludeAllDay: anyNamed('excludeAllDay'),
        ),
      ).thenAnswer((_) async => []);

      await provider.loadEvents();
      expect(provider.requiresReconnect, isFalse);
      expect(provider.status, CalendarEventsStatus.loaded);
    });
  });

  group('loadEvents — generic exception', () {
    test('sets errorMessage and leaves requiresReconnect = false', () async {
      final service = MockGoogleCalendarService();
      when(
        service.fetchEvents(
          calendarIds: anyNamed('calendarIds'),
          dateFrom: anyNamed('dateFrom'),
          dateTo: anyNamed('dateTo'),
          excludeAllDay: anyNamed('excludeAllDay'),
        ),
      ).thenThrow(Exception('No internet'));

      final provider = buildProvider(service);
      await provider.loadEvents();

      expect(provider.requiresReconnect, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(provider.status, CalendarEventsStatus.error);
    });
  });
}
