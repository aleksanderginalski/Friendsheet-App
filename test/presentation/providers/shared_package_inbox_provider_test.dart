import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/models/pending_meeting_package.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/repositories/pending_meeting_package_repository.dart';
import 'package:friendsheet/presentation/providers/shared_package_inbox_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'shared_package_inbox_provider_test.mocks.dart';

@GenerateMocks([PendingMeetingPackageRepository, MeetingRepository])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockPendingMeetingPackageRepository mockPackageRepo;
  late MockMeetingRepository mockMeetingRepo;
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
          ),
        ],
      );

  setUp(() {
    mockPackageRepo = MockPendingMeetingPackageRepository();
    mockMeetingRepo = MockMeetingRepository();
    provider = SharedPackageInboxProvider(
      packageRepository: mockPackageRepo,
      meetingRepository: mockMeetingRepo,
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

      await provider.initialize('u1');

      expect(provider.conflictsFor('pkg1'), hasLength(1));
    });

    test('no conflict when dates differ by one day', () async {
      final pkg = makePackage(meetingDate: DateTime(2026, 3, 15));
      final existing = makeMeeting(date: DateTime(2026, 3, 16));

      when(mockPackageRepo.fetchPackages('u1')).thenAnswer((_) async => [pkg]);
      when(mockMeetingRepo.getMeetingsByUser('u1'))
          .thenAnswer((_) => Stream.value([existing]));

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
  });
}
