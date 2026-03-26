/// Represents a single meeting in the anonymized AI context.
/// Participant names are replaced with pseudonyms (e.g. Friend_A).
/// Meeting name is included as-is (Option A).
class MeetingContextEntry {
  const MeetingContextEntry({
    required this.name,
    required this.date,
    required this.pseudonymizedParticipants,
    required this.activityNames,
    required this.notes,
  });

  /// Original meeting name — sent to AI as-is.
  final String name;
  final DateTime date;

  /// Participant names replaced by pseudonyms, e.g. ['Friend_A', 'Friend_C'].
  final List<String> pseudonymizedParticipants;

  /// Human-readable activity category names resolved from categoryIds.
  final List<String> activityNames;

  /// Meeting notes as entered by the user.
  final List<String> notes;
}

/// Aggregated statistics for a single friend in the anonymized AI context.
class PersonContextEntry {
  const PersonContextEntry({
    required this.pseudonym,
    required this.meetingCount,
    required this.topActivities,
    this.lastMeetingDate,
    this.mostActivePeriod,
    this.meetingsByYear = const {},
  });

  /// Pseudonym assigned to this person, e.g. 'Friend_A'.
  final String pseudonym;

  /// Number of meetings with this person in the current context window.
  final int meetingCount;

  /// Up to 3 most frequent activity names across meetings with this person.
  final List<String> topActivities;

  /// Date of the most recent meeting with this person.
  final DateTime? lastMeetingDate;

  /// Month with the highest number of meetings, formatted as 'MMMM yyyy'.
  /// e.g. 'March 2024'.
  final String? mostActivePeriod;

  /// Meeting count broken down by year, e.g. {2025: 5, 2026: 31}.
  /// Enables the AI to answer year-specific questions accurately.
  final Map<int, int> meetingsByYear;
}

/// The full anonymized context bundle passed to the AI prompt serializer.
/// Contains the meeting list, per-person summaries, and the bidirectional
/// mapping needed to translate AI responses back to real names.
class BuddyContext {
  const BuddyContext({
    required this.meetings,
    required this.persons,
    required this.pseudonymToRealName,
    required this.personIdToPseudonym,
  });

  final List<MeetingContextEntry> meetings;
  final List<PersonContextEntry> persons;

  /// Maps pseudonym back to the real display name.
  /// e.g. 'Friend_A' -> 'Anna Kowalska'
  final Map<String, String> pseudonymToRealName;

  /// Maps Firestore person document ID to the assigned pseudonym.
  /// e.g. 'abc123' -> 'Friend_A'
  final Map<String, String> personIdToPseudonym;
}
