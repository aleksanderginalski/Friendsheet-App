import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/google_calendar.dart';
import 'package:friendsheet/data/services/google_calendar_service.dart';
import 'package:friendsheet/presentation/providers/calendar_settings_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_settings_provider_test.mocks.dart';

@GenerateMocks([GoogleCalendarService])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  CalendarSettingsProvider buildProvider(MockGoogleCalendarService service) {
    return CalendarSettingsProvider(calendarService: service);
  }

  group('initialize', () {
    test('isConnected is false when no token in storage', () async {
      final service = MockGoogleCalendarService();
      when(service.isConnected()).thenAnswer((_) async => false);

      final provider = buildProvider(service);
      await provider.initialize();

      expect(provider.isConnected, isFalse);
    });

    test('isConnected is true when token exists', () async {
      final service = MockGoogleCalendarService();
      when(service.isConnected()).thenAnswer((_) async => true);
      when(service.fetchCalendars()).thenAnswer((_) async => []);

      final provider = buildProvider(service);
      await provider.initialize();

      expect(provider.isConnected, isTrue);
    });

    test('includeAllDay is false by default', () async {
      final service = MockGoogleCalendarService();
      when(service.isConnected()).thenAnswer((_) async => false);

      final provider = buildProvider(service);
      await provider.initialize();

      expect(provider.includeAllDay, isFalse);
    });
  });

  group('toggleAllDay', () {
    test('changes value and persists in SharedPreferences', () async {
      final service = MockGoogleCalendarService();
      when(service.isConnected()).thenAnswer((_) async => false);

      final provider = buildProvider(service);
      await provider.initialize();

      expect(provider.includeAllDay, isFalse);

      await provider.toggleAllDay();
      expect(provider.includeAllDay, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('calendar_include_all_day'), isTrue);

      await provider.toggleAllDay();
      expect(provider.includeAllDay, isFalse);
      expect(prefs.getBool('calendar_include_all_day'), isFalse);
    });
  });

  group('toggleCalendar', () {
    test('adds calendarId to selectedCalendarIds', () async {
      final service = MockGoogleCalendarService();
      when(service.isConnected()).thenAnswer((_) async => false);

      final provider = buildProvider(service);
      await provider.initialize();

      await provider.toggleCalendar('cal-1');
      expect(provider.selectedCalendarIds, contains('cal-1'));
    });

    test('removes calendarId when already selected', () async {
      final service = MockGoogleCalendarService();
      when(service.isConnected()).thenAnswer((_) async => false);

      final provider = buildProvider(service);
      await provider.initialize();

      await provider.toggleCalendar('cal-1');
      await provider.toggleCalendar('cal-1');

      expect(provider.selectedCalendarIds, isNot(contains('cal-1')));
    });
  });

  group('revokeAccess', () {
    test('clears token and resets state', () async {
      final service = MockGoogleCalendarService();
      when(service.isConnected()).thenAnswer((_) async => true);
      when(service.fetchCalendars()).thenAnswer(
        (_) async => [
          const GoogleCalendar(
              id: 'cal-1', summary: 'My Calendar', isPrimary: true),
        ],
      );
      when(service.revokeAccess()).thenAnswer((_) async {});

      final provider = buildProvider(service);
      await provider.initialize();

      expect(provider.isConnected, isTrue);

      await provider.revokeAccess();

      expect(provider.isConnected, isFalse);
      expect(provider.availableCalendars, isEmpty);
      expect(provider.selectedCalendarIds, isEmpty);
      expect(provider.includeAllDay, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('calendar_selected_ids'), isNull);
      expect(prefs.getBool('calendar_include_all_day'), isNull);

      verify(service.revokeAccess()).called(1);
    });
  });
}
