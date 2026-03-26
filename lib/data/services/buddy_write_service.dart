import '../repositories/meeting_repository.dart';

/// The only permitted write path from the Buddy chat interface.
/// Wraps MeetingRepository — AIChatProvider never holds a direct repo reference.
class BuddyWriteService {
  BuddyWriteService({MeetingRepository? meetingRepository})
      : _meetingRepository = meetingRepository ?? MeetingRepository();

  final MeetingRepository _meetingRepository;

  /// Appends [notes] to the meeting identified by [meetingId].
  /// Fetches current meeting, merges note lists, then updates — never overwrites other fields.
  Future<void> saveNotes(
    String userId,
    String meetingId,
    List<String> notes,
  ) async {
    final allMeetings =
        await _meetingRepository.getMeetingsByUser(userId).first;
    final meeting = allMeetings.firstWhere((m) => m.id == meetingId);
    await _meetingRepository
        .updateMeeting(meeting.copyWith(notes: [...meeting.notes, ...notes]));
  }
}
