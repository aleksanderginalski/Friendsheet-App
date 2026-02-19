import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_meeting_provider_test.mocks.dart';

@GenerateMocks(
    [PersonRepository, ActivityRepository, MeetingRepository, AuthService])
void main() {
  late AddMeetingProvider provider;
  late MockPersonRepository mockRepository;
  late MockActivityRepository mockActivityRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockAuthService mockAuthService;

  setUp(() {
    mockRepository = MockPersonRepository();
    mockActivityRepository = MockActivityRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockAuthService = MockAuthService();
    provider = AddMeetingProvider(
      personRepository: mockRepository,
      activityRepository: mockActivityRepository,
      meetingRepository: mockMeetingRepository,
      authService: mockAuthService,
    );
  });

  group('AddMeetingProvider - weight', () {
    test('default weight is 3', () {
      expect(provider.weight, equals(3));
    });

    test('canDecrement is true at default value', () {
      expect(provider.canDecrement, isTrue);
    });

    test('canIncrement is true at default value', () {
      expect(provider.canIncrement, isTrue);
    });

    test('incrementWeight moves to next Fibonacci value', () {
      provider.incrementWeight();
      expect(provider.weight, equals(5));
    });

    test('decrementWeight moves to previous Fibonacci value', () {
      provider.decrementWeight();
      expect(provider.weight, equals(2));
    });

    test('canDecrement is false at minimum value 1', () {
      for (int i = 0; i < 10; i++) {
        provider.decrementWeight();
      }
      expect(provider.weight, equals(1));
      expect(provider.canDecrement, isFalse);
    });

    test('canIncrement is false at maximum value 21', () {
      for (int i = 0; i < 10; i++) {
        provider.incrementWeight();
      }
      expect(provider.weight, equals(21));
      expect(provider.canIncrement, isFalse);
    });

    test('weight does not change below minimum', () {
      for (int i = 0; i < 10; i++) {
        provider.decrementWeight();
      }
      provider.decrementWeight();
      expect(provider.weight, equals(1));
    });

    test('weight does not change above maximum', () {
      for (int i = 0; i < 10; i++) {
        provider.incrementWeight();
      }
      provider.incrementWeight();
      expect(provider.weight, equals(21));
    });

    test('reset restores default weight 3', () {
      provider.incrementWeight();
      provider.incrementWeight();
      provider.reset();
      expect(provider.weight, equals(3));
    });
  });

  group('AddMeetingProvider - participants', () {
    final person1 = Person(
      id: '1',
      userId: 'user1',
      firstName: 'Anna',
      lastName: 'Kowalska',
      createdAt: DateTime(2024),
    );

    final person2 = Person(
      id: '2',
      userId: 'user1',
      firstName: 'Marek',
      lastName: 'Nowak',
      createdAt: DateTime(2024),
    );

    test('selectedPersons is empty by default', () {
      expect(provider.selectedPersons, isEmpty);
    });

    test('selectPerson adds person to selectedPersons', () {
      provider.addNewPerson(person1);
      expect(provider.selectedPersons, contains(person1));
    });

    test('selectPerson prevents duplicates', () {
      provider.addNewPerson(person1);
      provider.selectPerson(person1);
      expect(provider.selectedPersons.length, equals(1));
    });

    test('removePerson removes person from selectedPersons', () {
      provider.addNewPerson(person1);
      provider.removePerson(person1);
      expect(provider.selectedPersons, isEmpty);
    });

    test('searchPersons returns matching persons', () {
      provider.addNewPerson(person1);
      provider.addNewPerson(person2);
      provider.removePerson(person1);
      provider.removePerson(person2);
      final results = provider.searchPersons('anna');
      expect(results, contains(person1));
      expect(results, isNot(contains(person2)));
    });

    test('searchPersons excludes already selected persons', () {
      provider.addNewPerson(person1);
      provider.addNewPerson(person2);
      provider.removePerson(person2);
      final results = provider.searchPersons('a');
      expect(results, isNot(contains(person1)));
    });

    test('searchPersons returns empty list for empty query', () {
      provider.addNewPerson(person1);
      provider.removePerson(person1);
      expect(provider.searchPersons(''), isEmpty);
    });

    test('validateParticipants returns false when no participants', () {
      expect(provider.validateParticipants(), isFalse);
      expect(provider.participantsError, isNotNull);
    });

    test('validateParticipants returns true when at least one participant', () {
      provider.addNewPerson(person1);
      expect(provider.validateParticipants(), isTrue);
      expect(provider.participantsError, isNull);
    });

    test('reset clears selectedPersons and availablePersons', () {
      provider.addNewPerson(person1);
      provider.reset();
      expect(provider.selectedPersons, isEmpty);
      expect(provider.availablePersons, isEmpty);
    });
  });

  group('AddMeetingProvider - activities', () {
    final activity1 = Activity(
      id: '1',
      userId: null,
      name: 'Kawusia',
      isGlobal: true,
      categoryId: null,
      createdAt: DateTime(2024),
    );

    final activity2 = Activity(
      id: '2',
      userId: 'user1',
      name: 'Planszówki',
      isGlobal: false,
      categoryId: null,
      createdAt: DateTime(2024),
    );

    test('selectedActivities is empty by default', () {
      expect(provider.selectedActivities, isEmpty);
    });

    test('selectActivity adds activity to selectedActivities', () {
      provider.addNewActivity(activity1);
      expect(provider.selectedActivities, contains(activity1));
    });

    test('selectActivity prevents duplicates', () {
      provider.addNewActivity(activity1);
      provider.selectActivity(activity1);
      expect(provider.selectedActivities.length, equals(1));
    });

    test('removeActivity removes activity from selectedActivities', () {
      provider.addNewActivity(activity1);
      provider.removeActivity(activity1);
      expect(provider.selectedActivities, isEmpty);
    });

    test('searchActivities returns matching activities', () {
      provider.addNewActivity(activity1);
      provider.addNewActivity(activity2);
      provider.removeActivity(activity1);
      provider.removeActivity(activity2);
      final results = provider.searchActivities('kaw');
      expect(results, contains(activity1));
      expect(results, isNot(contains(activity2)));
    });

    test('searchActivities excludes already selected activities', () {
      provider.addNewActivity(activity1);
      provider.addNewActivity(activity2);
      provider.removeActivity(activity2);
      final results = provider.searchActivities('a');
      expect(results, isNot(contains(activity1)));
    });

    test('searchActivities returns empty list for empty query', () {
      provider.addNewActivity(activity1);
      provider.removeActivity(activity1);
      expect(provider.searchActivities(''), isEmpty);
    });

    test('validateActivities returns false when no activities', () {
      expect(provider.validateActivities(), isFalse);
      expect(provider.activitiesError, isNotNull);
    });

    test('validateActivities returns true when at least one activity', () {
      provider.addNewActivity(activity1);
      expect(provider.validateActivities(), isTrue);
      expect(provider.activitiesError, isNull);
    });

    test('reset clears selectedActivities and availableActivities', () {
      provider.addNewActivity(activity1);
      provider.reset();
      expect(provider.selectedActivities, isEmpty);
      expect(provider.availableActivities, isEmpty);
    });
  });

  group('AddMeetingProvider - saveMeeting', () {
    final person1 = Person(
      id: 'p1',
      userId: 'user1',
      firstName: 'Anna',
      lastName: 'Kowalska',
      createdAt: DateTime(2024),
    );

    final activity1 = Activity(
      id: 'a1',
      userId: null,
      name: 'Kawusia',
      isGlobal: true,
      categoryId: null,
      createdAt: DateTime(2024),
    );

    // Sets up provider with valid form state ready to save
    void setupValidForm() {
      provider.setName('Coffee with Anna');
      provider.addNewPerson(person1);
      provider.addNewActivity(activity1);
    }

    test('saveMeeting returns false when name is empty', () async {
      provider.addNewPerson(person1);
      provider.addNewActivity(activity1);
      when(mockAuthService.currentUserId).thenReturn('user1');

      final result = await provider.saveMeeting();

      expect(result, isFalse);
      expect(provider.nameError, isNotNull);
    });

    test('saveMeeting returns false when no participants', () async {
      provider.setName('Coffee with Anna');
      provider.addNewActivity(activity1);
      when(mockAuthService.currentUserId).thenReturn('user1');

      final result = await provider.saveMeeting();

      expect(result, isFalse);
      expect(provider.participantsError, isNotNull);
    });

    test('saveMeeting returns false when no activities', () async {
      provider.setName('Coffee with Anna');
      provider.addNewPerson(person1);
      when(mockAuthService.currentUserId).thenReturn('user1');

      final result = await provider.saveMeeting();

      expect(result, isFalse);
      expect(provider.activitiesError, isNotNull);
    });

    test('saveMeeting returns false when user is not authenticated', () async {
      setupValidForm();
      when(mockAuthService.currentUserId).thenReturn(null);

      final result = await provider.saveMeeting();

      expect(result, isFalse);
    });

    test('saveMeeting returns true on success', () async {
      setupValidForm();
      when(mockAuthService.currentUserId).thenReturn('user1');
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');

      final result = await provider.saveMeeting();

      expect(result, isTrue);
    });

    test('saveMeeting calls repository with correct userId', () async {
      setupValidForm();
      when(mockAuthService.currentUserId).thenReturn('user1');
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');

      await provider.saveMeeting();

      final captured =
          verify(mockMeetingRepository.saveMeeting(captureAny)).captured.first;
      expect(captured.userId, equals('user1'));
    });

    test('saveMeeting returns false when repository throws', () async {
      setupValidForm();
      when(mockAuthService.currentUserId).thenReturn('user1');
      when(mockMeetingRepository.saveMeeting(any))
          .thenThrow(Exception('Firestore error'));

      final result = await provider.saveMeeting();

      expect(result, isFalse);
    });

    test('isSaving is false after successful save', () async {
      setupValidForm();
      when(mockAuthService.currentUserId).thenReturn('user1');
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');

      await provider.saveMeeting();

      expect(provider.isSaving, isFalse);
    });

    test('isSaving is false after failed save', () async {
      setupValidForm();
      when(mockAuthService.currentUserId).thenReturn('user1');
      when(mockMeetingRepository.saveMeeting(any))
          .thenThrow(Exception('Firestore error'));

      await provider.saveMeeting();

      expect(provider.isSaving, isFalse);
    });
  });
}
