import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/activity_category.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/person.dart';
import 'package:friendsheet/data/repositories/activity_category_repository.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/person_repository.dart';
import 'package:friendsheet/data/services/export_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'export_service_test.mocks.dart';

@GenerateMocks(
    [MeetingRepository, PersonRepository, ActivityCategoryRepository])
void main() {
  late MockMeetingRepository mockMeetingRepo;
  late MockPersonRepository mockPersonRepo;
  late MockActivityCategoryRepository mockCategoryRepo;
  late Directory tempDir;
  late ExportService service;

  final now = DateTime(2026, 3, 3);

  Meeting makeMeeting(String id) => Meeting(
        id: id,
        userId: 'user-1',
        name: 'Test Meeting',
        date: now,
        weight: 3,
        participantIds: const ['person-1'],
        categoryIds: const [],
        createdAt: now,
        updatedAt: now,
      );

  Person makePerson(String id) => Person(
        id: id,
        userId: 'user-1',
        firstName: 'Anna',
        createdAt: now,
      );

  ActivityCategory makeCategory(String id) => ActivityCategory(
        id: id,
        userId: 'user-1',
        name: 'Sport',
        iconIdentifier: 'sports',
        isGlobal: false,
        isSelectableAsActivity: true,
        createdAt: now,
      );

  setUp(() {
    mockMeetingRepo = MockMeetingRepository();
    mockPersonRepo = MockPersonRepository();
    mockCategoryRepo = MockActivityCategoryRepository();
    tempDir = Directory.systemTemp.createTempSync('export_test_');
    service = ExportService(
      meetingRepository: mockMeetingRepo,
      personRepository: mockPersonRepo,
      activityCategoryRepository: mockCategoryRepo,
      directoryProvider: () async => tempDir,
    );
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('ExportService.exportToDevice()', () {
    test('happy path — writes valid JSON file and returns path', () async {
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.value([makeMeeting('m1')]));
      when(mockPersonRepo.getPersonsByUser('user-1'))
          .thenAnswer((_) async => [makePerson('p1')]);
      when(mockCategoryRepo.getAllCategories('user-1'))
          .thenAnswer((_) async => [makeCategory('c1')]);

      final path = await service.exportToDevice('user-1');

      expect(path, contains('friendsheet_export_'));
      expect(path, endsWith('.json'));

      final file = File(path);
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      expect(content, contains('"version":"1.0"'));
      expect(content, contains('"meetings"'));
      expect(content, contains('"persons"'));
      expect(content, contains('"activityCategories"'));
      expect(content, contains('"m1"'));
      expect(content, contains('"p1"'));
      expect(content, contains('"c1"'));
    });

    test('empty data — writes valid JSON with empty arrays', () async {
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.value([]));
      when(mockPersonRepo.getPersonsByUser('user-1'))
          .thenAnswer((_) async => []);
      when(mockCategoryRepo.getAllCategories('user-1'))
          .thenAnswer((_) async => []);

      final path = await service.exportToDevice('user-1');

      final content = await File(path).readAsString();
      expect(content, contains('"meetings":[]'));
      expect(content, contains('"persons":[]'));
      expect(content, contains('"activityCategories":[]'));
    });

    test('repository throws — ExportService wraps and throws ExportException',
        () async {
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.error(Exception('Firestore error')));

      expect(
        () => service.exportToDevice('user-1'),
        throwsA(isA<ExportException>()),
      );
    });
  });
}
