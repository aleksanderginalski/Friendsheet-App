import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/presentation/providers/add_meeting_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_meeting_provider_test.mocks.dart';

@GenerateMocks([
  PersonRepository,
  ActivityCategoryRepository,
  MeetingRepository,
  AuthService,
])
void main() {
  late AddMeetingProvider provider;
  late MockPersonRepository mockPersonRepository;
  late MockActivityCategoryRepository mockCategoryRepository;
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

  final category1 = ActivityCategory(
    id: 'cat1',
    userId: 'user1',
    name: 'Gory',
    iconIdentifier: 'mountain',
    isGlobal: false,
    isSelectableAsActivity: true,
    parentCategoryId: 'cat-sport',
    createdAt: DateTime(2024),
  );

  final newCategory = ActivityCategory(
    id: 'new-cat',
    userId: 'user1',
    name: 'Climbing',
    iconIdentifier: 'category',
    isGlobal: false,
    isSelectableAsActivity: true,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    mockCategoryRepository = MockActivityCategoryRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockAuthService = MockAuthService();
    provider = AddMeetingProvider(
      personRepository: mockPersonRepository,
      categoryRepository: mockCategoryRepository,
      meetingRepository: mockMeetingRepository,
      authService: mockAuthService,
    );

    // Default stubs used by addNewPerson and addCategory
    when(mockAuthService.currentUserId).thenReturn('user1');
    when(mockPersonRepository.addPerson(any)).thenAnswer((_) async => person1);
    when(mockCategoryRepository.getSelectableCategories(any))
        .thenAnswer((_) async => []);
    when(mockCategoryRepository.getAncestorIds(any, any))
        .thenAnswer((_) async => ['cat1', 'cat-sport']);
    when(mockCategoryRepository.createSelectableCategory(
      name: anyNamed('name'),
      userId: anyNamed('userId'),
    )).thenAnswer((_) async => newCategory);
  });

  group('AddMeetingProvider - initial state', () {
    test('all defaults', () {
      expect(provider.name, isEmpty);
      expect(provider.nameError, isNull);
      expect(provider.weight, equals(3));
      expect(provider.canDecrement, isTrue);
      expect(provider.canIncrement, isTrue);
      expect(provider.selectedPersons, isEmpty);
      expect(provider.availablePersons, isEmpty);
      expect(provider.isLoadingPersons, isFalse);
      expect(provider.participantsError, isNull);
      expect(provider.selectedCategories, isEmpty);
      expect(provider.selectedCategoryIds, isEmpty);
      expect(provider.activitiesError, isNull);
      expect(provider.isSaving, isFalse);
      expect(provider.isEditMode, isFalse);
      expect(provider.savedMeeting, isNull);
    });
  });

  group('AddMeetingProvider - weight stepper', () {
    test('cycles through Fibonacci values and respects boundaries', () {
      expect(provider.weight, equals(3));
      provider.incrementWeight();
      expect(provider.weight, equals(5));
      provider.decrementWeight();
      expect(provider.weight, equals(3));
      // Reach minimum
      for (int i = 0; i < 10; i++) {
        provider.decrementWeight();
      }
      expect(provider.weight, equals(1));
      expect(provider.canDecrement, isFalse);
      provider.decrementWeight(); // no-op at minimum
      expect(provider.weight, equals(1));
      // Reach maximum
      for (int i = 0; i < 10; i++) {
        provider.incrementWeight();
      }
      expect(provider.weight, equals(21));
      expect(provider.canIncrement, isFalse);
      provider.incrementWeight(); // no-op at maximum
      expect(provider.weight, equals(21));
    });
  });

  group('AddMeetingProvider - participants', () {
    test('addNewPerson saves to Firestore and adds to selected list', () async {
      when(mockPersonRepository.addPerson(any))
          .thenAnswer((_) async => person1);

      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');

      expect(provider.selectedPersons, contains(person1));
      expect(provider.availablePersons, contains(person1));
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

    test('searchPersons returns matching persons excluding selected', () async {
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

    // selectPerson clears participantsError, enabling combined validation test.
    test('validateParticipants fails without persons, passes with one',
        () async {
      expect(provider.validateParticipants(), isFalse);
      expect(provider.participantsError, isNotNull);

      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      expect(provider.validateParticipants(), isTrue);
      expect(provider.participantsError, isNull);
    });
  });

  group('AddMeetingProvider - categories', () {
    test('addCategory adds chip and propagates ancestor IDs', () async {
      when(mockCategoryRepository.getAncestorIds('cat1', 'user1'))
          .thenAnswer((_) async => ['cat1', 'cat-sport']);

      await provider.addCategory(category1, 'user1');

      expect(provider.selectedCategories, contains(category1));
      expect(provider.selectedCategoryIds, containsAll(['cat1', 'cat-sport']));
    });

    test('addCategory prevents duplicate chips', () async {
      await provider.addCategory(category1, 'user1');
      await provider.addCategory(category1, 'user1');

      expect(provider.selectedCategories.length, equals(1));
    });

    // removeCategory removes the leaf ID but leaves ancestor IDs in place —
    // other selected categories may still depend on the ancestor.
    test('removeCategory removes chip and leaf ID, preserves ancestor ID',
        () async {
      when(mockCategoryRepository.getAncestorIds('cat1', 'user1'))
          .thenAnswer((_) async => ['cat1', 'cat-sport']);

      await provider.addCategory(category1, 'user1');
      provider.removeCategory(category1);

      expect(provider.selectedCategories, isEmpty);
      expect(provider.selectedCategoryIds, isNot(contains('cat1')));
      expect(provider.selectedCategoryIds, contains('cat-sport'));
    });

    test('searchCategories returns matching categories', () async {
      when(mockCategoryRepository.getSelectableCategories('user1'))
          .thenAnswer((_) async => [category1]);
      await provider.loadCategories('user1');

      final results = provider.searchCategories('gor');
      expect(results, contains(category1));
    });

    test('searchCategories returns empty for empty query', () async {
      final results = provider.searchCategories('');
      expect(results, isEmpty);
    });

    // validateActivities does not clear the error on success — kept separate
    // so the positive test starts from a clean provider (no prior error set).
    test('validateActivities returns false when no categories', () {
      expect(provider.validateActivities(), isFalse);
      expect(provider.activitiesError, isNotNull);
    });

    test('validateActivities returns true when at least one category',
        () async {
      await provider.addCategory(category1, 'user1');
      expect(provider.validateActivities(), isTrue);
      expect(provider.activitiesError, isNull);
    });

    test('addNewActivity adds chip, ID, and calls repository', () async {
      await provider.addNewActivity('Climbing', 'user1');

      expect(provider.selectedCategories, contains(newCategory));
      expect(provider.selectedCategoryIds, contains('new-cat'));
      verify(mockCategoryRepository.createSelectableCategory(
        name: 'Climbing',
        userId: 'user1',
      )).called(1);
    });
  });

  group('addNewActivity duplicate validation', () {
    test(
        'blocks save when name matches existing Firestore activity (case-insensitive)',
        () async {
      // Pre-load a 'Climbing' category from Firestore into _availableCategories.
      when(mockCategoryRepository.getSelectableCategories('user1')).thenAnswer(
          (_) async => [newCategory]); // newCategory.name == 'Climbing'
      await provider.loadCategories('user1');

      await provider.addNewActivity('climbing', 'user1');

      expect(provider.activitiesError,
          equals('Activity with this name already exists'));
      verifyNever(mockCategoryRepository.createSelectableCategory(
        name: anyNamed('name'),
        userId: anyNamed('userId'),
      ));
    });

    test(
        'blocks save when name matches activity already added in current session',
        () async {
      // First addNewActivity succeeds and adds to session state.
      await provider.addNewActivity('Climbing', 'user1');
      // Reset mock call count so we can verify no second call.
      clearInteractions(mockCategoryRepository);

      await provider.addNewActivity('CLIMBING', 'user1');

      expect(provider.activitiesError,
          equals('Activity with this name already exists'));
      verifyNever(mockCategoryRepository.createSelectableCategory(
        name: anyNamed('name'),
        userId: anyNamed('userId'),
      ));
    });

    test('allows save when name is unique', () async {
      await provider.addNewActivity('Climbing', 'user1');

      expect(provider.activitiesError, isNull);
      expect(provider.selectedCategories, contains(newCategory));
      verify(mockCategoryRepository.createSelectableCategory(
        name: 'Climbing',
        userId: 'user1',
      )).called(1);
    });
  });

  group('AddMeetingProvider - saveMeeting', () {
    // Sets up provider with valid form state ready to save
    Future<void> setupValidForm() async {
      provider.setName('Coffee with Anna');
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      await provider.addCategory(category1, 'user1');
    }

    test('saveMeeting returns false when validation fails', () async {
      // Missing name
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      await provider.addCategory(category1, 'user1');
      expect(await provider.saveMeeting(), isFalse);
      expect(provider.nameError, isNotNull);

      // Missing participants
      provider.reset();
      provider.setName('Test');
      await provider.addCategory(category1, 'user1');
      expect(await provider.saveMeeting(), isFalse);
      expect(provider.participantsError, isNotNull);

      // Missing categories
      provider.reset();
      provider.setName('Test');
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      expect(await provider.saveMeeting(), isFalse);
      expect(provider.activitiesError, isNotNull);
    });

    test('saveMeeting returns false when user is not authenticated', () async {
      when(mockAuthService.currentUserId).thenReturn(null);
      await setupValidForm();

      final result = await provider.saveMeeting();

      expect(result, isFalse);
    });

    test('saveMeeting happy path: returns true with correct meeting data',
        () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');

      final result = await provider.saveMeeting();

      expect(result, isTrue);
      final captured =
          verify(mockMeetingRepository.saveMeeting(captureAny)).captured.first;
      expect(captured.userId, equals('user1'));
      expect(captured.categoryIds, containsAll(['cat1', 'cat-sport']));
    });

    test('saveMeeting returns false when repository throws', () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenThrow(Exception('Firestore error'));

      final result = await provider.saveMeeting();

      expect(result, isFalse);
    });

    test('isSaving is false after both successful and failed save', () async {
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'meeting-id-123');
      await provider.saveMeeting();
      expect(provider.isSaving, isFalse);

      // Verify isSaving is also false after a failed save
      provider.reset();
      await setupValidForm();
      when(mockMeetingRepository.saveMeeting(any))
          .thenThrow(Exception('Firestore error'));
      await provider.saveMeeting();
      expect(provider.isSaving, isFalse);
    });
  });

  group('AddMeetingProvider - reset', () {
    test('restores all defaults', () async {
      provider.setName('Test');
      await provider.addNewPerson(firstName: 'Anna', lastName: 'Kowalska');
      await provider.addCategory(category1, 'user1');
      provider.incrementWeight();
      provider.incrementWeight();

      provider.reset();

      expect(provider.name, isEmpty);
      expect(provider.weight, equals(3));
      expect(provider.selectedPersons, isEmpty);
      expect(provider.availablePersons, isEmpty);
      expect(provider.selectedCategories, isEmpty);
      expect(provider.selectedCategoryIds, isEmpty);
    });
  });
}
