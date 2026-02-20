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
  late MockPersonRepository mockPersonRepository;
  late MockActivityRepository mockActivityRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockAuthService mockAuthService;

  // Reusable test fixtures
  final person1 = Person(
    id: 'p1',
    userId: 'user1',
    firstName: 'Anna',
    lastName: 'Kowalska',
    createdAt: DateTime(2024),
  );

  final person2 = Person(
    id: 'p2',
    userId: 'user1',
    firstName: 'Marek',
    lastName: 'Nowak',
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

  final activity2 = Activity(
    id: 'a2',
    userId: 'user1',
    name: 'Planszówki',
    isGlobal: false,
    categoryId: null,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockActivityRepository = MockActivityRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockAuthService = MockAuthService();
    provider = AddMeetingProvider(
      personRepository: mockPersonRepository,
      activityRepository: mockActivityRepository,
      meetingRepository: mockMeetingRepository,
      authService: mockAuthService,
    );

    // Default stubs used by addNewPerson and addNewActivity
    when(mockAuthService.currentUserId).thenReturn('user1');
    when(mockPersonRepository.addPerson(any)).thenAnswer((_) async => person1);
    when(mockActivityRepository.addActivity(
      userId: anyNamed('userId'),
      name: anyNamed('name'),
    )).thenAnswer((_) async => activity1);
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
    test('selectedPersons is empty by default', () {
      expect(provider.selectedPersons, isEmpty);
    });

    test('addNewPerson saves to Firestore and adds to selected list', () async {
      when(mockPersonRepository.addPerson(any))
          .thenAnswer((_) async => person1);

      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');

      expect(provider.selectedPersons, contains(person1));
      expect(provider.availablePersons, contains(person1));
      verify(mockPersonRepository.addPerson(any)).called(1);
    });

    test('addNewPerson with no lastName passes null to repository', () async {
      when(mockPersonRepository.addPerson(any))
          .thenAnswer((_) async => person1);

      await provider.addNewPerson(firstName: 'Anna');

      verify(mockPersonRepository.addPerson(any)).called(1);
    });

    test('selectPerson prevents duplicates', () async {
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      provider.selectPerson(person1);
      expect(provider.selectedPersons.length, equals(1));
    });

    test('removePerson removes person from selectedPersons', () async {
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      provider.removePerson(person1);
      expect(provider.selectedPersons, isEmpty);
    });

    test('searchPersons returns matching persons', () async {
      when(mockPersonRepository.addPerson(any))
          .thenAnswer((_) async => person1);
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      provider.removePerson(person1);

      when(mockPersonRepository.addPerson(any))
          .thenAnswer((_) async => person2);
      await provider.addNewPerson(firstName: 'Marek', lastName: 'Nowak');
      provider.removePerson(person2);

      final results = provider.searchPersons('anna');
      expect(results, contains(person1));
      expect(results, isNot(contains(person2)));
    });

    test('searchPersons excludes already selected persons', () async {
      when(mockPersonRepository.addPerson(any))
          .thenAnswer((_) async => person1);
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');

      final results = provider.searchPersons('anna');
      expect(results, isNot(contains(person1)));
    });

    test('searchPersons returns empty list for empty query', () async {
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      provider.removePerson(person1);
      expect(provider.searchPersons(''), isEmpty);
    });

    test('validateParticipants returns false when no participants', () {
      expect(provider.validateParticipants(), isFalse);
      expect(provider.participantsError, isNotNull);
    });

    test('validateParticipants returns true when at least one participant',
        () async {
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      expect(provider.validateParticipants(), isTrue);
      expect(provider.participantsError, isNull);
    });

    test('reset clears selectedPersons and availablePersons', () async {
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      provider.reset();
      expect(provider.selectedPersons, isEmpty);
      expect(provider.availablePersons, isEmpty);
    });
  });

  group('AddMeetingProvider - activities', () {
    test('selectedActivities is empty by default', () {
      expect(provider.selectedActivities, isEmpty);
    });

    test('addNewActivity saves to Firestore and adds to selected list',
        () async {
      when(mockActivityRepository.addActivity(
        userId: anyNamed('userId'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => activity1);

      await provider.addNewActivity('Kawusia');

      expect(provider.selectedActivities, contains(activity1));
      expect(provider.availableActivities, contains(activity1));
      verify(mockActivityRepository.addActivity(
        userId: anyNamed('userId'),
        name: anyNamed('name'),
      )).called(1);
    });

    test('selectActivity prevents duplicates', () async {
      await provider.addNewActivity('Kawusia');
      provider.selectActivity(activity1);
      expect(provider.selectedActivities.length, equals(1));
    });

    test('removeActivity removes activity from selectedActivities', () async {
      await provider.addNewActivity('Kawusia');
      provider.removeActivity(activity1);
      expect(provider.selectedActivities, isEmpty);
    });

    test('searchActivities returns matching activities', () async {
      when(mockActivityRepository.addActivity(
        userId: anyNamed('userId'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => activity1);
      await provider.addNewActivity('Kawusia');
      provider.removeActivity(activity1);

      when(mockActivityRepository.addActivity(
        userId: anyNamed('userId'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => activity2);
      await provider.addNewActivity('Planszówki');
      provider.removeActivity(activity2);

      final results = provider.searchActivities('kaw');
      expect(results, contains(activity1));
      expect(results, isNot(contains(activity2)));
    });

    test('searchActivities excludes already selected activities', () async {
      await provider.addNewActivity('Kawusia');
      final results = provider.searchActivities('kaw');
      expect(results, isNot(contains(activity1)));
    });

    test('searchActivities returns empty list for empty query', () async {
      await provider.addNewActivity('Kawusia');
      provider.removeActivity(activity1);
      expect(provider.searchActivities(''), isEmpty);
    });

    test('validateActivities returns false when no activities', () {
      expect(provider.validateActivities(), isFalse);
      expect(provider.activitiesError, isNotNull);
    });

    test('validateActivities returns true when at least one activity',
        () async {
      await provider.addNewActivity('Kawusia');
      expect(provider.validateActivities(), isTrue);
      expect(provider.activitiesError, isNull);
    });

    test('reset clears selectedActivities and availableActivities', () async {
      await provider.addNewActivity('Kawusia');
      provider.reset();
      expect(provider.selectedActivities, isEmpty);
      expect(provider.availableActivities, isEmpty);
    });
  });

  group('AddMeetingProvider - saveMeeting', () {
    // Sets up provider with valid form state ready to save
    Future<void> setupValidForm() async {
      provider.setName('Coffee with Anna');
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      await provider.addNewActivity('Kawusia');
    }

    test('saveMeeting returns false when name is empty', () async {
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      await provider.addNewActivity('Kawusia');

      final result = await provider.saveMeeting();

      expect(result, isFalse);
      expect(provider.nameError, isNotNull);
    });

    test('saveMeeting returns false when no participants', () async {
      provider.setName('Coffee with Anna');
      await provider.addNewActivity('Kawusia');

      final result = await provider.saveMeeting();

      expect(result, isFalse);
      expect(provider.participantsError, isNotNull);
    });

    test('saveMeeting returns false when no activities', () async {
      provider.setName('Coffee with Anna');
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');

      final result = await provider.saveMeeting();

      expect(result, isFalse);
      expect(provider.activitiesError, isNotNull);
    });

    test('saveMeeting returns false when user is not authenticated', () async {
      when(mockAuthService.currentUserId).thenReturn(null);
      await setupValidForm();

      final result = await provider.saveMeeting();

      expect(result, isFalse);
    });

    test('saveMeeting returns true on success', () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');

      final result = await provider.saveMeeting();

      expect(result, isTrue);
    });

    test('saveMeeting calls repository with correct userId', () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');

      await provider.saveMeeting();

      final captured =
          verify(mockMeetingRepository.saveMeeting(captureAny)).captured.first;
      expect(captured.userId, equals('user1'));
    });

    test('saveMeeting returns false when repository throws', () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenThrow(Exception('Firestore error'));

      final result = await provider.saveMeeting();

      expect(result, isFalse);
    });

    test('isSaving is false after successful save', () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');

      await provider.saveMeeting();

      expect(provider.isSaving, isFalse);
    });

    test('isSaving is false after failed save', () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenThrow(Exception('Firestore error'));

      await provider.saveMeeting();

      expect(provider.isSaving, isFalse);
    });
  });
}
