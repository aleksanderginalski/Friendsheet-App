import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/pending_meeting_package_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/providers/shared_package_inbox_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'shared_package_inbox_provider_test.mocks.dart';

@GenerateMocks([
  PendingMeetingPackageRepository,
  MeetingRepository,
  PersonRepository,
  ActivityCategoryRepository,
])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockPendingMeetingPackageRepository mockPackageRepo;
  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;
  late SharedPackageInboxProvider provider;

  Meeting makeMeeting({String id = 'm1', DateTime? date}) => Meeting(
        id: id,
        userId: 'u1',
        name: 'Existing Meeting',
        date: date ?? DateTime(2026, 1, 1),
        weight: 3,
        participantIds: const ['p1'],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  PendingMeetingPackage makePackage({
    String id = 'pkg1',
    DateTime? meetingDate,
    List<String> categoryNames = const [],
    List<SharedPerson> participants = const [],
  }) =>
      PendingMeetingPackage(
        id: id,
        senderUid: 'sender-uid',
        senderFirstName: 'Ania',
        senderLastName: 'Kowalska',
        sentAt: DateTime(2026, 3, 20),
        meetings: [
          SharedMeeting(
            name: 'Kino',
            date: meetingDate ?? DateTime(2026, 3, 15),
            weight: 3,
            categoryNames: categoryNames,
            participants: participants,
          ),
        ],
      );

  ActivityCategory makeCategory({String id = 'cat1', String name = 'Hiking'}) =>
      ActivityCategory(
        id: id,
        userId: 'u1',
        name: name,
        iconIdentifier: 'sports',
        isGlobal: false,
        isSelectableAsActivity: true,
        createdAt: DateTime(2026),
      );

  Person makeExistingPerson({
    String id = 'p1',
    String firstName = 'Jan',
    String lastName = 'Kowalski',
  }) =>
      Person(
        id: id,
        userId: 'u1',
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime(2026),
      );

  void stubEmptyPersonsAndCategories() {
    when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
    when(mockCategoryRepo.getAllCategories(any)).thenAnswer((_) async => []);
  }

  setUp(() {
    mockPackageRepo = MockPendingMeetingPackageRepository();
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
    provider = SharedPackageInboxProvider(
      packageRepository: mockPackageRepo,
      meetingRepository: mockMeetingRepo,
      personRepository: mockPersonRepo,
      categoryRepository: mockCategoryRepo,
    );
  });

  tearDown(() {
    provider.dispose();
  });

  group('initial state', () {
    test('all defaults are correct', () {
      expect(provider.packages, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.hasPackages, isFalse);
    });
  });

  group('initialize', () {
    test('with empty userId returns early without fetching', () async {
      await provider.initialize('');

      verifyNever(mockPackageRepo.fetchPackages(any));
      expect(provider.isLoading, isFalse);
      expect(provider.packages, isEmpty);
    });

    test('with no packages results in empty state', () async {
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => []);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.packages, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.hasPackages, isFalse);
    });

    test('loads packages when they exist', () async {
      final pkg = makePackage();
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.packages, hasLength(1));
      expect(provider.hasPackages, isTrue);
      expect(provider.packages.first.id, 'pkg1');
    });

    test('detects conflict when shared date matches existing meeting date',
        () async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);

      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([existing]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.conflictsFor('pkg1'), hasLength(1));
      expect(provider.conflictsFor('pkg1')[0]!.id, 'm1');
    });

    test('ignores time-of-day when comparing dates', () async {
      // Same calendar day, different times — must still count as conflict.
      final pkg = makePackage(meetingDate: DateTime(2026, 3, 15, 10, 0));
      final existing = makeMeeting(date: DateTime(2026, 3, 15, 22, 30));

      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([existing]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.conflictsFor('pkg1'), hasLength(1));
    });

    test('no conflict when dates differ by one day', () async {
      final pkg = makePackage(meetingDate: DateTime(2026, 3, 15));
      final existing = makeMeeting(date: DateTime(2026, 3, 16));

      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([existing]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.conflictsFor('pkg1'), isEmpty);
    });
  });

  group('canProceed', () {
    test('is true when package has no conflicts', () async {
      final pkg = makePackage();
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.canProceed('pkg1'), isTrue);
    });

    test('is false while conflict is unresolved', () async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);

      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([existing]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.canProceed('pkg1'), isFalse);
    });

    test('is true after all conflicts are resolved', () async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);

      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([existing]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');
      provider.resolveConflict('pkg1', 0, ConflictResolution.merge);

      expect(provider.canProceed('pkg1'), isTrue);
    });
  });

  group('resolveConflict', () {
    test('stores and returns the chosen resolution', () {
      provider.resolveConflict('pkg1', 0, ConflictResolution.addAsNew);

      expect(provider.resolutionFor('pkg1', 0), ConflictResolution.addAsNew);
    });

    test('overrides a previous resolution', () {
      provider.resolveConflict('pkg1', 0, ConflictResolution.merge);
      provider.resolveConflict('pkg1', 0, ConflictResolution.skip);

      expect(provider.resolutionFor('pkg1', 0), ConflictResolution.skip);
    });
  });

  group('dismissPackage', () {
    setUp(() async {
      final conflictDate = DateTime(2026, 3, 15);
      final pkg = makePackage(meetingDate: conflictDate);
      final existing = makeMeeting(date: conflictDate);

      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([existing]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');
      provider.resolveConflict('pkg1', 0, ConflictResolution.merge);
    });

    test('removes the package from the packages list', () {
      provider.dismissPackage('pkg1');

      expect(provider.packages, isEmpty);
      expect(provider.hasPackages, isFalse);
    });

    test('clears conflicts and resolutions for the dismissed package', () {
      provider.dismissPackage('pkg1');

      expect(provider.conflictsFor('pkg1'), isEmpty);
      expect(provider.resolutionFor('pkg1', 0), isNull);
    });

    test('clears activity and person state for the dismissed package', () {
      provider.resolveActivityConflict(
          'pkg1', 'hiking', ActivityResolution.link('c1'));
      provider.resolvePersonConflict(
          'pkg1', 'jan', PersonResolution.link('p1'));
      provider.setActivityOptOut('pkg1', 'hiking', true);
      provider.setPersonOptOut('pkg1', 'jan', true);

      provider.dismissPackage('pkg1');

      expect(provider.activityResolutionFor('pkg1', 'hiking'), isNull);
      expect(provider.personResolutionFor('pkg1', 'jan'), isNull);
      expect(provider.isActivityOptedOut('pkg1', 'hiking'), isFalse);
      expect(provider.isPersonOptedOut('pkg1', 'jan'), isFalse);
    });
  });

  group('sender in unique persons', () {
    test('sender is always included regardless of meeting participants',
        () async {
      final pkg = makePackage();
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      final persons = provider.uniquePersonsFor('pkg1');
      expect(
        persons.values
            .any((p) => p.firstName == 'Ania' && p.lastName == 'Kowalska'),
        isTrue,
      );
    });
  });

  group('activity conflict detection', () {
    test('detects conflict when category name matches case-insensitively',
        () async {
      final pkg = makePackage(categoryNames: ['hiking']);
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
      when(mockCategoryRepo.getAllCategories(any))
          .thenAnswer((_) async => [makeCategory(name: 'Hiking')]);

      await provider.initialize('u1');

      expect(provider.activityConflictsFor('pkg1'), hasLength(1));
      expect(provider.activityConflictsFor('pkg1')['hiking']?.name, 'Hiking');
    });

    test('no conflict when category name does not match', () async {
      final pkg = makePackage(categoryNames: ['hiking']);
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
      when(mockCategoryRepo.getAllCategories(any))
          .thenAnswer((_) async => [makeCategory(name: 'Running')]);

      await provider.initialize('u1');

      expect(provider.activityConflictsFor('pkg1'), isEmpty);
    });
  });

  group('person conflict detection', () {
    test('detects conflict when firstName + lastName match', () async {
      final pkg = makePackage(
        participants: [
          const SharedPerson(firstName: 'Jan', lastName: 'Kowalski')
        ],
      );
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any))
          .thenAnswer((_) async => [makeExistingPerson()]);
      when(mockCategoryRepo.getAllCategories(any)).thenAnswer((_) async => []);

      await provider.initialize('u1');

      expect(provider.personConflictsFor('pkg1'), hasLength(1));
    });

    test('no conflict when names differ', () async {
      final pkg = makePackage(
        participants: [
          const SharedPerson(firstName: 'Piotr', lastName: 'Nowak')
        ],
      );
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any))
          .thenAnswer((_) async => [makeExistingPerson()]);
      when(mockCategoryRepo.getAllCategories(any)).thenAnswer((_) async => []);

      await provider.initialize('u1');

      expect(provider.personConflictsFor('pkg1'), isEmpty);
    });
  });

  group('canProceedActivities', () {
    test('is true when no activity conflicts', () async {
      final pkg = makePackage();
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.canProceedActivities('pkg1'), isTrue);
    });

    test('is false while activity conflict unresolved', () async {
      final pkg = makePackage(categoryNames: ['hiking']);
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
      when(mockCategoryRepo.getAllCategories(any))
          .thenAnswer((_) async => [makeCategory(name: 'Hiking')]);

      await provider.initialize('u1');

      expect(provider.canProceedActivities('pkg1'), isFalse);
    });

    test('is true after activity conflict resolved', () async {
      final pkg = makePackage(categoryNames: ['hiking']);
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any)).thenAnswer((_) async => []);
      when(mockCategoryRepo.getAllCategories(any))
          .thenAnswer((_) async => [makeCategory()]);

      await provider.initialize('u1');
      provider.resolveActivityConflict(
          'pkg1', 'hiking', ActivityResolution.link('cat1'));

      expect(provider.canProceedActivities('pkg1'), isTrue);
    });
  });

  group('canProceedPersons', () {
    test('is true when no person conflicts', () async {
      final pkg = makePackage();
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      stubEmptyPersonsAndCategories();

      await provider.initialize('u1');

      expect(provider.canProceedPersons('pkg1'), isTrue);
    });

    test('is false while person conflict unresolved', () async {
      final pkg = makePackage(
        participants: [
          const SharedPerson(firstName: 'Jan', lastName: 'Kowalski')
        ],
      );
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any))
          .thenAnswer((_) async => [makeExistingPerson()]);
      when(mockCategoryRepo.getAllCategories(any)).thenAnswer((_) async => []);

      await provider.initialize('u1');

      expect(provider.canProceedPersons('pkg1'), isFalse);
    });

    test('is true after person conflict resolved', () async {
      final pkg = makePackage(
        participants: [
          const SharedPerson(firstName: 'Jan', lastName: 'Kowalski')
        ],
      );
      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser(any))
          .thenAnswer((_) async => [makeExistingPerson()]);
      when(mockCategoryRepo.getAllCategories(any)).thenAnswer((_) async => []);

      await provider.initialize('u1');
      provider.resolvePersonConflict(
          'pkg1', 'jan kowalski', PersonResolution.link('p1'));

      expect(provider.canProceedPersons('pkg1'), isTrue);
    });
  });

  group('resolveActivityConflict', () {
    test('stores and returns the chosen resolution', () {
      provider.resolveActivityConflict(
          'pkg1', 'hiking', ActivityResolution.rename('Hike'));

      expect(provider.activityResolutionFor('pkg1', 'hiking')?.renamedName,
          'Hike');
    });

    test('overrides a previous resolution', () {
      provider.resolveActivityConflict(
          'pkg1', 'hiking', ActivityResolution.rename('Hike'));
      provider.resolveActivityConflict(
          'pkg1', 'hiking', ActivityResolution.link('cat-x'));

      expect(provider.activityResolutionFor('pkg1', 'hiking')?.linkedCategoryId,
          'cat-x');
    });
  });

  group('resolvePersonConflict', () {
    test('stores and returns the chosen resolution', () {
      provider.resolvePersonConflict(
          'pkg1', 'jan kowalski', PersonResolution.nickname('JK'));

      expect(
          provider.personResolutionFor('pkg1', 'jan kowalski')?.nickname, 'JK');
    });

    test('overrides a previous resolution', () {
      provider.resolvePersonConflict(
          'pkg1', 'jan kowalski', PersonResolution.nickname('JK'));
      provider.resolvePersonConflict(
          'pkg1', 'jan kowalski', PersonResolution.link('p-x'));

      expect(
          provider.personResolutionFor('pkg1', 'jan kowalski')?.linkedPersonId,
          'p-x');
    });
  });
}
