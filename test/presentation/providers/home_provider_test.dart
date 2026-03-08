import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/presentation/providers/home_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_provider_test.mocks.dart';

@GenerateMocks([MeetingRepository])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockMeetingRepository mockRepository;
  late HomeProvider provider;

  // Helper: creates a minimal valid Meeting.
  Meeting makeMeeting(String id) => Meeting(
        id: id,
        userId: 'user-1',
        name: 'Test',
        date: DateTime(2026),
        weight: 3,
        participantIds: const [],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockMeetingRepository();
  });

  tearDown(() {
    provider.dispose();
  });

  group('HomeProvider', () {
    test('shouldShowCta is true when count < 50 and not dismissed', () async {
      final controller = StreamController<List<Meeting>>();
      when(mockRepository.getMeetingsByUser('user-1'))
          .thenAnswer((_) => controller.stream);

      provider = HomeProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');

      controller.add(List.generate(10, (i) => makeMeeting('m$i')));
      await Future.microtask(() {});

      expect(provider.shouldShowCta, isTrue);
      controller.close();
    });

    test('shouldShowCta is false when count >= 50', () async {
      final controller = StreamController<List<Meeting>>();
      when(mockRepository.getMeetingsByUser('user-1'))
          .thenAnswer((_) => controller.stream);

      provider = HomeProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');

      controller.add(List.generate(50, (i) => makeMeeting('m$i')));
      await Future.microtask(() {});

      expect(provider.shouldShowCta, isFalse);
      controller.close();
    });

    test('shouldShowCta is false when dismissed even if count < 50', () async {
      final controller = StreamController<List<Meeting>>();
      when(mockRepository.getMeetingsByUser('user-1'))
          .thenAnswer((_) => controller.stream);

      provider = HomeProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');

      controller.add(List.generate(5, (i) => makeMeeting('m$i')));
      await Future.microtask(() {});

      await provider.dismissCta();

      expect(provider.shouldShowCta, isFalse);
      controller.close();
    });

    test('dismissCta() persists the flag to SharedPreferences', () async {
      final controller = StreamController<List<Meeting>>();
      when(mockRepository.getMeetingsByUser('user-1'))
          .thenAnswer((_) => controller.stream);

      provider = HomeProvider(meetingRepository: mockRepository);
      await provider.initialize('user-1');
      await provider.dismissCta();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_calendar_cta_dismissed'), isTrue);
      controller.close();
    });
  });
}
