import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/presentation/providers/package_import_types.dart';
import 'package:friendsheet/presentation/providers/package_importer.dart';
import 'package:friendsheet/presentation/providers/shared_package_inbox_provider.dart'
    show ConflictResolution;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package_importer_test.mocks.dart';

@GenerateMocks([
  MeetingRepository,
  PersonRepository,
  ActivityCategoryRepository,
])
void main() {
  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;
  late PackageImporter importer;

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

  Person makePerson({
    String id = 'p-sender',
    String firstName = 'Ania',
    String lastName = 'Kowalska',
  }) =>
      Person(
        id: id,
        userId: 'u1',
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime(2026),
        nicknames: const [],
      );

  PendingMeetingPackage makePackage({
    List<SharedPerson> participants = const [],
    List<String> categoryNames = const [],
    String? senderNickname,
  }) =>
      PendingMeetingPackage(
        id: 'pkg1',
        senderUid: 'sender-uid',
        senderFirstName: 'Ania',
        senderLastName: 'Kowalska',
        senderNickname: senderNickname,
        sentAt: DateTime(2026, 3, 20),
        meetings: [
          SharedMeeting(
            name: 'Kino',
            date: DateTime(2026, 3, 21),
            weight: 3,
            categoryNames: categoryNames,
            participants: participants,
          ),
        ],
      );

  Meeting makeSavedMeeting({String id = 'm-new'}) => Meeting(
        id: id,
        userId: 'u1',
        name: 'Kino',
        date: DateTime(2026, 3, 21),
        weight: 3,
        participantIds: const [],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  setUp(() {
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
    importer = PackageImporter(
      meetingRepo: mockMeetingRepo,
      personRepo: mockPersonRepo,
      categoryRepo: mockCategoryRepo,
    );
  });

  group('happy path — no conflicts', () {
    test('imports meeting, returns correct summary', () async {
      final pkg = makePackage();
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      expect(summary.meetingsAdded, 1);
      expect(summary.personsAdded, 1); // sender always added
      expect(summary.activitiesAdded, 0);
    });

    test('sender is always included in meeting participantIds', () async {
      final pkg = makePackage();
      when(mockPersonRepo.addPerson(any))
          .thenAnswer((_) async => makePerson(id: 'p-sender'));
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      final captured = verify(mockMeetingRepo.saveMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(captured.participantIds, contains('p-sender'));
    });
  });

  group('meeting conflict resolutions', () {
    test('skip resolution excludes meeting from import', () async {
      final pkg = makePackage();
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {0: makeSavedMeeting()},
        meetingResolutions: {0: ConflictResolution.skip},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      verifyNever(mockMeetingRepo.saveMeeting(any));
      expect(summary.meetingsAdded, 0);
    });

    test('merge resolution excludes meeting from import', () async {
      final pkg = makePackage();
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {0: makeSavedMeeting()},
        meetingResolutions: {0: ConflictResolution.merge},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      verifyNever(mockMeetingRepo.saveMeeting(any));
      expect(summary.meetingsAdded, 0);
    });

    test('addAsNew resolution imports meeting despite conflict', () async {
      final pkg = makePackage();
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {0: makeSavedMeeting()},
        meetingResolutions: {0: ConflictResolution.addAsNew},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      verify(mockMeetingRepo.saveMeeting(any)).called(1);
      expect(summary.meetingsAdded, 1);
    });
  });

  group('activity import', () {
    test('creates new category when no resolution', () async {
      final pkg = makePackage(categoryNames: ['Hiking']);
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());
      when(mockCategoryRepo.createSelectableCategory(
              name: anyNamed('name'), userId: anyNamed('userId')))
          .thenAnswer((_) async => makeCategory());
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      verify(mockCategoryRepo.createSelectableCategory(
              name: anyNamed('name'), userId: anyNamed('userId')))
          .called(1);
      expect(summary.activitiesAdded, 1);
    });

    test('links to existing category when ActivityResolution.link given',
        () async {
      final pkg = makePackage(categoryNames: ['Hiking']);
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {
          'hiking': const ActivityResolution.link('cat-existing')
        },
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      verifyNever(mockCategoryRepo.createSelectableCategory(
          name: anyNamed('name'), userId: anyNamed('userId')));
      expect(summary.activitiesAdded, 0);
      final meeting = verify(mockMeetingRepo.saveMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(meeting.categoryIds, contains('cat-existing'));
    });

    test('skips activity when opted out', () async {
      final pkg = makePackage(categoryNames: ['Hiking']);
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {'hiking'},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      verifyNever(mockCategoryRepo.createSelectableCategory(
          name: anyNamed('name'), userId: anyNamed('userId')));
      expect(summary.activitiesAdded, 0);
    });

    test(
        'skips activity and excludes from categoryIds when ActivityResolution.skip given',
        () async {
      final pkg = makePackage(categoryNames: ['Hiking']);
      when(mockPersonRepo.addPerson(any)).thenAnswer((_) async => makePerson());
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {
          'hiking': const ActivityResolution.skip(),
        },
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      verifyNever(mockCategoryRepo.createSelectableCategory(
          name: anyNamed('name'), userId: anyNamed('userId')));
      expect(summary.activitiesAdded, 0);
      final meeting = verify(mockMeetingRepo.saveMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(meeting.categoryIds, isEmpty);
    });
  });

  group('person import', () {
    test('links to existing person when PersonResolution.link given', () async {
      final pkg = makePackage();
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {
          'ania kowalska': const PersonResolution.link('p-existing')
        },
        personOptOut: {},
        userId: 'u1',
      );

      verifyNever(mockPersonRepo.addPerson(any));
      expect(summary.personsAdded, 0);
      final meeting = verify(mockMeetingRepo.saveMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(meeting.participantIds, contains('p-existing'));
    });

    test('creates person with nickname when PersonResolution.nickname given',
        () async {
      final pkg = makePackage();
      when(mockPersonRepo.addPerson(any))
          .thenAnswer((_) async => makePerson(id: 'p-new'));
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {
          'ania kowalska': const PersonResolution.nickname('Anka')
        },
        personOptOut: {},
        userId: 'u1',
      );

      final captured = verify(mockPersonRepo.addPerson(captureAny))
          .captured
          .single as Person;
      expect(captured.nicknames, contains('Anka'));
      expect(summary.personsAdded, 1);
    });

    test('skips person when opted out', () async {
      final pkg = makePackage();
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {'ania kowalska'},
        userId: 'u1',
      );

      verifyNever(mockPersonRepo.addPerson(any));
      expect(summary.personsAdded, 0);
    });

    test(
        'skips person and excludes from participantIds when PersonResolution.skip given',
        () async {
      final pkg = makePackage();
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {
          'ania kowalska': const PersonResolution.skip(),
        },
        personOptOut: {},
        userId: 'u1',
      );

      verifyNever(mockPersonRepo.addPerson(any));
      expect(summary.personsAdded, 0);
      final meeting = verify(mockMeetingRepo.saveMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(meeting.participantIds, isEmpty);
    });

    test('saves sender nickname from package when no resolution given',
        () async {
      final pkg = makePackage(senderNickname: 'Anka');
      when(mockPersonRepo.addPerson(any))
          .thenAnswer((_) async => makePerson(id: 'p-new'));
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {},
        personOptOut: {},
        userId: 'u1',
      );

      final captured = verify(mockPersonRepo.addPerson(captureAny))
          .captured
          .single as Person;
      expect(captured.nicknames, contains('Anka'));
    });

    test(
        'explicit PersonResolution.nickname overrides sender suggested nickname',
        () async {
      final pkg = makePackage(senderNickname: 'Anka');
      when(mockPersonRepo.addPerson(any))
          .thenAnswer((_) async => makePerson(id: 'p-new'));
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {
          'ania kowalska': const PersonResolution.nickname('Aneczka'),
        },
        personOptOut: {},
        userId: 'u1',
      );

      final captured = verify(mockPersonRepo.addPerson(captureAny))
          .captured
          .single as Person;
      expect(captured.nicknames, contains('Aneczka'));
      expect(captured.nicknames, isNot(contains('Anka')));
    });

    test(
        'creates person with no nickname when PersonResolution.createNew given',
        () async {
      final pkg = makePackage();
      when(mockPersonRepo.addPerson(any))
          .thenAnswer((_) async => makePerson(id: 'p-new'));
      when(mockMeetingRepo.saveMeeting(any)).thenAnswer((_) async => 'm-new');

      final summary = await importer.run(
        package: pkg,
        meetingConflicts: {},
        meetingResolutions: {},
        activityResolutions: {},
        activityOptOut: {},
        personResolutions: {
          'ania kowalska': const PersonResolution.createNew(),
        },
        personOptOut: {},
        userId: 'u1',
      );

      final captured = verify(mockPersonRepo.addPerson(captureAny))
          .captured
          .single as Person;
      expect(captured.nicknames, isEmpty);
      expect(summary.personsAdded, 1);
    });
  });
}
