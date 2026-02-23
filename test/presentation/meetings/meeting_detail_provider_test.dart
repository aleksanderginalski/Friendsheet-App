import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/meetings/meeting_detail_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'meeting_detail_provider_test.mocks.dart';

@GenerateMocks([PersonRepository, ActivityRepository])
void main() {
  late MockPersonRepository mockPersonRepository;
  late MockActivityRepository mockActivityRepository;
  late MeetingDetailProvider provider;

  final testMeeting = Meeting(
    id: 'm1',
    userId: 'u1',
    name: 'Coffee with Anna',
    date: DateTime(2026, 2, 12),
    weight: 8,
    participantIds: ['p1'],
    activityIds: ['a1'],
    createdAt: DateTime(2026, 2, 12),
    updatedAt: DateTime(2026, 2, 12),
  );

  final testPerson = Person(
    id: 'p1',
    userId: 'u1',
    firstName: 'Anna',
    lastName: 'Kowalska',
    createdAt: DateTime(2026, 2, 12),
  );

  final testActivity = Activity(
    id: 'a1',
    userId: 'u1',
    name: 'Coffee',
    isGlobal: false,
    createdAt: DateTime(2026, 2, 12),
  );

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockActivityRepository = MockActivityRepository();
    provider = MeetingDetailProvider(
      personRepository: mockPersonRepository,
      activityRepository: mockActivityRepository,
    );
  });

  group('MeetingDetailProvider', () {
    test('initialize loads participants and activities', () async {
      when(mockPersonRepository.getPersonsByIds(['p1']))
          .thenAnswer((_) async => [testPerson]);
      when(mockActivityRepository.getActivitiesByIds(['a1']))
          .thenAnswer((_) async => [testActivity]);

      await provider.initialize(testMeeting);

      expect(provider.participants, [testPerson]);
      expect(provider.activities, [testActivity]);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
    });

    test('initialize sets errorMessage on failure', () async {
      when(mockPersonRepository.getPersonsByIds(any))
          .thenThrow(Exception('network error'));
      when(mockActivityRepository.getActivitiesByIds(any))
          .thenAnswer((_) async => []);

      await provider.initialize(testMeeting);

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, false);
    });

    test(
        'initialize returns empty lists when meeting has no participants or activities',
        () async {
      final emptyMeeting = testMeeting.copyWith(
        participantIds: [],
        activityIds: [],
      );

      when(mockPersonRepository.getPersonsByIds([]))
          .thenAnswer((_) async => []);
      when(mockActivityRepository.getActivitiesByIds([]))
          .thenAnswer((_) async => []);

      await provider.initialize(emptyMeeting);

      expect(provider.participants, isEmpty);
      expect(provider.activities, isEmpty);
    });
  });
}
