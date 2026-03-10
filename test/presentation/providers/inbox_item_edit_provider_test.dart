import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/import_candidate.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/providers/inbox_item_edit_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'inbox_item_edit_provider_test.mocks.dart';

@GenerateMocks(
    [MeetingRepository, PersonRepository, ActivityCategoryRepository])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late InboxItemEditProvider provider;
  late MockMeetingRepository mockMeetingRepository;
  late MockPersonRepository mockPersonRepository;
  late MockActivityCategoryRepository mockCategoryRepository;

  final testCandidate = ImportCandidate(
    id: 'cand-1',
    title: 'Team offsite',
    date: DateTime(2025, 7, 15),
    attendeeEmails: const ['bob@example.com'],
    sourceType: ImportSourceType.calendar,
  );

  final person1 = Person(
    id: 'p1',
    userId: 'user1',
    firstName: 'Bob',
    lastName: 'Smith',
    createdAt: DateTime(2024),
  );

  final category1 = ActivityCategory(
    id: 'cat1',
    userId: 'user1',
    name: 'Hiking',
    iconIdentifier: 'mountain',
    isGlobal: false,
    isSelectableAsActivity: true,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockMeetingRepository = MockMeetingRepository();
    mockPersonRepository = MockPersonRepository();
    mockCategoryRepository = MockActivityCategoryRepository();

    when(mockCategoryRepository.getAncestorIds(any, any))
        .thenAnswer((_) async => ['cat1']);

    provider = InboxItemEditProvider(
      meetingRepository: mockMeetingRepository,
      personRepository: mockPersonRepository,
      categoryRepository: mockCategoryRepository,
    );
  });

  group('InboxItemEditProvider - initialize', () {
    test('pre-fills name from candidate', () {
      provider.initialize(testCandidate);

      expect(provider.name, equals('Team offsite'));
    });

    test('pre-fills date from candidate', () {
      provider.initialize(testCandidate);

      expect(provider.date, equals(DateTime(2025, 7, 15)));
    });

    test('default weight is 3', () {
      provider.initialize(testCandidate);

      expect(provider.weight, equals(3));
    });

    test('attendeeEmailSuggestions pre-filled from candidate', () {
      provider.initialize(testCandidate);

      expect(provider.attendeeEmailSuggestions, equals(['bob@example.com']));
    });

    test('selectedPersons is empty after initialize', () {
      provider.initialize(testCandidate);

      expect(provider.selectedPersons, isEmpty);
    });
  });

  group('InboxItemEditProvider - validateName', () {
    setUp(() => provider.initialize(testCandidate));

    test('returns false for empty string', () {
      provider.setName('');

      expect(provider.validateName(), isFalse);
      expect(provider.nameError, isNotNull);
    });

    test('returns false for string longer than 50 chars', () {
      provider.setName('A' * 51);

      expect(provider.validateName(), isFalse);
      expect(provider.nameError, isNotNull);
    });

    test('returns true for valid name', () {
      provider.setName('Valid Name');

      expect(provider.validateName(), isTrue);
      expect(provider.nameError, isNull);
    });
  });

  group('InboxItemEditProvider - save', () {
    setUp(() => provider.initialize(testCandidate));

    test('returns false and does not call repository when no persons',
        () async {
      provider.setName('Team offsite');
      await provider.addCategory(category1, 'user1');
      // No persons added.

      final result = await provider.save(userId: 'user1', onSuccess: () {});

      expect(result, isFalse);
      verifyNever(mockMeetingRepository.saveMeeting(any));
    });

    test('returns false and does not call repository when no categories',
        () async {
      provider.setName('Team offsite');
      provider.addPerson(person1);
      // No categories added.

      final result = await provider.save(userId: 'user1', onSuccess: () {});

      expect(result, isFalse);
      verifyNever(mockMeetingRepository.saveMeeting(any));
    });

    test('calls saveMeeting exactly once with valid data', () async {
      when(mockMeetingRepository.saveMeeting(any))
          .thenAnswer((_) async => 'new-meeting-id');

      provider.setName('Team offsite');
      provider.addPerson(person1);
      await provider.addCategory(category1, 'user1');

      final result = await provider.save(userId: 'user1', onSuccess: () {});

      expect(result, isTrue);
      verify(mockMeetingRepository.saveMeeting(any)).called(1);
    });
  });
}
