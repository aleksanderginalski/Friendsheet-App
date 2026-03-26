import 'package:flutter_test/flutter_test.dart';
import 'package:friendsheet/data/models/meeting.dart';
import 'package:friendsheet/data/repositories/meeting_repository.dart';
import 'package:friendsheet/data/services/buddy_write_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'buddy_write_service_test.mocks.dart';

@GenerateMocks([MeetingRepository])
void main() {
  late MockMeetingRepository mockMeetingRepo;
  late BuddyWriteService service;

  final now = DateTime(2026, 3, 10);

  Meeting makeMeeting({
    String id = 'm1',
    List<String> notes = const [],
  }) =>
      Meeting(
        id: id,
        userId: 'user-1',
        name: 'Meeting $id',
        date: now,
        weight: 3,
        participantIds: const ['p1'],
        categoryIds: const [],
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    mockMeetingRepo = MockMeetingRepository();
    service = BuddyWriteService(meetingRepository: mockMeetingRepo);
  });

  group('saveNotes', () {
    test('appends new notes to existing meeting notes', () async {
      final existing = makeMeeting(id: 'm1', notes: ['old note']);
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.value([existing]));
      when(mockMeetingRepo.updateMeeting(any)).thenAnswer((_) async => null);

      await service.saveNotes('user-1', 'm1', ['new note A', 'new note B']);

      final captured = verify(mockMeetingRepo.updateMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(captured.notes, ['old note', 'new note A', 'new note B']);
    });

    test('appends to empty notes list', () async {
      final existing = makeMeeting(id: 'm1', notes: []);
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.value([existing]));
      when(mockMeetingRepo.updateMeeting(any)).thenAnswer((_) async => null);

      await service.saveNotes('user-1', 'm1', ['first note']);

      final captured = verify(mockMeetingRepo.updateMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(captured.notes, ['first note']);
    });

    test('does not modify other meeting fields', () async {
      final existing = makeMeeting(id: 'm1', notes: ['original']);
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.value([existing]));
      when(mockMeetingRepo.updateMeeting(any)).thenAnswer((_) async => null);

      await service.saveNotes('user-1', 'm1', ['extra']);

      final captured = verify(mockMeetingRepo.updateMeeting(captureAny))
          .captured
          .single as Meeting;
      expect(captured.id, 'm1');
      expect(captured.name, 'Meeting m1');
      expect(captured.participantIds, ['p1']);
    });

    test('throws StateError when meetingId not found', () async {
      when(mockMeetingRepo.getMeetingsByUser('user-1'))
          .thenAnswer((_) => Stream.value([]));

      expect(
        () => service.saveNotes('user-1', 'nonexistent', ['note']),
        throwsStateError,
      );
    });
  });
}
