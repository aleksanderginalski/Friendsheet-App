import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/auth_service.dart';
import 'package:friendsheet/data/services/meeting_package_service.dart';
import 'package:friendsheet/presentation/sharing/share_meetings_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'share_meetings_provider_test.mocks.dart';

@GenerateMocks([
  MeetingRepository,
  PersonRepository,
  ActivityCategoryRepository,
  AuthService,
  MeetingPackageService,
])
void main() {
  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;
  late MockAuthService mockAuthService;
  late MockMeetingPackageService mockPackageService;
  late ShareMeetingsProvider provider;

  const targetPersonId = 'person-c';
  const recipientUid = 'uid-c';
  const userId = 'uid-a';

  final testMeeting = Meeting(
    id: 'm1',
    userId: userId,
    name: 'Coffee',
    date: DateTime(2026, 3, 1),
    weight: 3,
    participantIds: [targetPersonId, 'person-2'],
    categoryIds: ['cat-1'],
    createdAt: DateTime(2026, 3, 1),
    updatedAt: DateTime(2026, 3, 1),
  );

  final testPerson = Person(
    id: 'person-2',
    userId: userId,
    firstName: 'Bob',
    lastName: 'Jones',
    createdAt: DateTime(2026, 1, 1),
  );

  final testCategory = ActivityCategory(
    id: 'cat-1',
    userId: userId,
    name: 'Sports',
    iconIdentifier: 'sports',
    isGlobal: false,
    isSelectableAsActivity: true,
    createdAt: DateTime(2026, 1, 1),
  );

  void stubDefaults({
    List<Meeting>? meetings,
    List<Person>? persons,
    List<ActivityCategory>? categories,
    String? displayName,
  }) {
    when(mockAuthService.currentUserId).thenReturn(userId);
    when(mockAuthService.userDisplayName).thenReturn(displayName);
    when(mockMeetingRepo.getMeetingsByParticipant(userId, targetPersonId))
        .thenAnswer((_) async => meetings ?? [testMeeting]);
    when(mockPersonRepo.getPersonsByUser(userId))
        .thenAnswer((_) async => persons ?? [testPerson]);
    when(mockCategoryRepo.getCategories(userId))
        .thenAnswer((_) => Stream.value(categories ?? [testCategory]));
  }

  setUp(() {
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
    mockAuthService = MockAuthService();
    mockPackageService = MockMeetingPackageService();

    provider = ShareMeetingsProvider(
      meetingRepository: mockMeetingRepo,
      personRepository: mockPersonRepo,
      categoryRepository: mockCategoryRepo,
      authService: mockAuthService,
      meetingPackageService: mockPackageService,
      targetPersonId: targetPersonId,
      recipientUid: recipientUid,
    );
  });

  group('ShareMeetingsProvider', () {
    test('initial state has correct defaults', () {
      expect(provider.meetings, isEmpty);
      expect(provider.selectedMeetingIds, isEmpty);
      expect(provider.includePersons, isFalse);
      expect(provider.includeActivities, isFalse);
      expect(provider.senderFirstName, equals(''));
      expect(provider.senderLastName, equals(''));
      expect(provider.senderNickname, equals(''));
      expect(provider.isLoading, isFalse);
      expect(provider.isSending, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.canSend, isFalse);
      expect(provider.isAllSelected, isFalse);
    });

    test('initialize loads meetings, selects all, pre-fills sender name',
        () async {
      stubDefaults(displayName: 'Anna Smith');

      await provider.initialize();

      expect(provider.meetings, hasLength(1));
      expect(provider.selectedMeetingIds, equals({'m1'}));
      expect(provider.isAllSelected, isTrue);
      expect(provider.senderFirstName, equals('Anna'));
      expect(provider.senderLastName, equals('Smith'));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('initialize with no meetings leaves selection empty', () async {
      stubDefaults(meetings: [], displayName: null);

      await provider.initialize();

      expect(provider.meetings, isEmpty);
      expect(provider.selectedMeetingIds, isEmpty);
      expect(provider.isAllSelected, isFalse);
    });

    test('initialize sets errorMessage on failure', () async {
      when(mockAuthService.currentUserId).thenReturn(userId);
      when(mockMeetingRepo.getMeetingsByParticipant(any, any))
          .thenThrow(Exception('network error'));

      await provider.initialize();

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('toggleAll cycles all→none→all', () async {
      stubDefaults();
      await provider.initialize();

      expect(provider.isAllSelected, isTrue);

      provider.toggleAll();
      expect(provider.selectedMeetingIds, isEmpty);
      expect(provider.isAllSelected, isFalse);

      provider.toggleAll();
      expect(provider.selectedMeetingIds, equals({'m1'}));
      expect(provider.isAllSelected, isTrue);
    });

    test('toggleMeeting adds and removes meeting from selection', () async {
      stubDefaults();
      await provider.initialize();

      // Deselect m1
      provider.toggleMeeting('m1');
      expect(provider.selectedMeetingIds, isEmpty);

      // Re-select m1
      provider.toggleMeeting('m1');
      expect(provider.selectedMeetingIds, contains('m1'));
    });

    test('canSend is false when firstName is empty', () async {
      stubDefaults();
      await provider.initialize();

      provider.setSenderFirstName('');
      expect(provider.canSend, isFalse);
    });

    test('canSend is true when firstName set and meetings selected', () async {
      stubDefaults();
      await provider.initialize();

      provider.setSenderFirstName('Anna');
      expect(provider.canSend, isTrue);
    });

    test('sendPackage happy path returns true and calls service', () async {
      stubDefaults(displayName: 'Anna Smith');
      when(mockPackageService.sendPackage(any, any)).thenAnswer((_) async {});

      await provider.initialize();
      final success = await provider.sendPackage();

      expect(success, isTrue);
      expect(provider.errorMessage, isNull);
      verify(mockPackageService.sendPackage(any, recipientUid)).called(1);
    });

    test(
        'sendPackage includes participants excluding targetPersonId when includePersons=true',
        () async {
      stubDefaults(displayName: 'Anna');
      when(mockPackageService.sendPackage(captureAny, any))
          .thenAnswer((_) async {});

      await provider.initialize();
      provider.setIncludePersons(true);
      await provider.sendPackage();

      final captured = verify(
        mockPackageService.sendPackage(captureAny, recipientUid),
      ).captured.single as PendingMeetingPackage;

      final sharedMeeting = captured.meetings.first;
      expect(sharedMeeting.participants, hasLength(1));
      expect(sharedMeeting.participants.first.firstName, equals('Bob'));
      expect(sharedMeeting.participants.first.lastName, equals('Jones'));
    });

    test('sendPackage resolves categoryNames when includeActivities=true',
        () async {
      stubDefaults(displayName: 'Anna');
      when(mockPackageService.sendPackage(captureAny, any))
          .thenAnswer((_) async {});

      await provider.initialize();
      provider.setIncludeActivities(true);
      await provider.sendPackage();

      final captured = verify(
        mockPackageService.sendPackage(captureAny, recipientUid),
      ).captured.single as PendingMeetingPackage;

      expect(captured.meetings.first.categoryNames, equals(['Sports']));
    });

    test('sendPackage returns false and sets errorMessage on service failure',
        () async {
      stubDefaults(displayName: 'Anna');
      when(mockPackageService.sendPackage(any, any))
          .thenThrow(Exception('write failed'));

      await provider.initialize();
      final success = await provider.sendPackage();

      expect(success, isFalse);
      expect(provider.errorMessage, isNotNull);
    });
  });
}
