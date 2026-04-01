import 'dart:math';

import 'package:intl/intl.dart';

import '../models/buddy_context.dart';
import '../models/meeting.dart';
import '../repositories/activity_category_repository.dart';
import '../repositories/meeting_repository.dart';
import '../repositories/person_repository.dart';
import 'relationship_score_service.dart';

/// Converts the user's social data from Firestore into an anonymized AI
/// prompt context. Real participant names are replaced with pseudonyms
/// (Friend_A, Friend_B...) before any data leaves this service.
///
/// Designed for constructor injection so it is fully unit testable
/// without a real Firebase connection.
class ContextBuilderService {
  ContextBuilderService({
    MeetingRepository? meetingRepository,
    PersonRepository? personRepository,
    ActivityCategoryRepository? activityCategoryRepository,
    RelationshipScoreService? relationshipScoreService,
  })  : _meetingRepository = meetingRepository ?? MeetingRepository(),
        _personRepository = personRepository ?? PersonRepository(),
        _activityCategoryRepository =
            activityCategoryRepository ?? ActivityCategoryRepository(),
        _relationshipScoreService =
            relationshipScoreService ?? RelationshipScoreService();

  final MeetingRepository _meetingRepository;
  final PersonRepository _personRepository;
  final ActivityCategoryRepository _activityCategoryRepository;
  final RelationshipScoreService _relationshipScoreService;

  static final _monthFormat = DateFormat('MMMM yyyy');
  static final _dateFormat = DateFormat('dd MMM yyyy');

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Builds context from meetings within [from]…now (default: last 12 months).
  /// All participants across the full person list are pseudonymized, even if
  /// they have no meetings in the time window — this keeps the mapping stable.
  Future<BuddyContext> buildFullContext(
    String userId, {
    DateTime? from,
  }) async {
    final cutoff = from ?? DateTime.now().subtract(const Duration(days: 365));

    final maps = await _buildMaps(userId);
    final categoryNames = await _loadCategoryNames(userId);

    final allMeetings =
        await _meetingRepository.getMeetingsByUser(userId).first;
    final filtered = allMeetings.where((m) => m.date.isAfter(cutoff)).toList();

    final meetingEntries = filtered
        .map((m) => _toMeetingEntry(m, maps.personIdToPseudonym, categoryNames))
        .toList();

    final personEntries = _buildPersonEntries(
      filtered,
      maps.personIdToPseudonym,
      categoryNames,
    );

    return BuddyContext(
      meetings: meetingEntries,
      persons: personEntries,
      pseudonymToRealName: maps.pseudonymToRealName,
      personIdToPseudonym: maps.personIdToPseudonym,
    );
  }

  /// Builds context scoped to all meetings where [personId] participated.
  /// No time-window filter — returns full history for that person.
  /// Only persons appearing in those meetings are included in [BuddyContext.persons].
  Future<BuddyContext> buildPersonContext(
    String userId,
    String personId,
  ) async {
    final maps = await _buildMaps(userId);
    final categoryNames = await _loadCategoryNames(userId);

    final meetings = await _meetingRepository.getMeetingsByParticipant(
      userId,
      personId,
    );

    final meetingEntries = meetings
        .map((m) => _toMeetingEntry(m, maps.personIdToPseudonym, categoryNames))
        .toList();

    // Collect only persons who appear in these meetings.
    final participantIds = {
      for (final m in meetings) ...m.participantIds,
    };
    final scopedIdToPseudonym = Map.fromEntries(
      maps.personIdToPseudonym.entries
          .where((e) => participantIds.contains(e.key)),
    );

    final personEntries = _buildPersonEntries(
      meetings,
      scopedIdToPseudonym,
      categoryNames,
    );

    return BuddyContext(
      meetings: meetingEntries,
      persons: personEntries,
      pseudonymToRealName: maps.pseudonymToRealName,
      personIdToPseudonym: maps.personIdToPseudonym,
    );
  }

  /// Builds context scoped to meetings where [personId] participated,
  /// limited to the last 365 days for token optimization.
  /// Use this instead of [buildPersonContext] for birthday wishes generation.
  Future<BuddyContext> buildBirthdayContext(
    String userId,
    String personId,
  ) async {
    final maps = await _buildMaps(userId);
    final categoryNames = await _loadCategoryNames(userId);
    final cutoff = DateTime.now().subtract(const Duration(days: 365));

    final allMeetings = await _meetingRepository.getMeetingsByParticipant(
      userId,
      personId,
    );
    final meetings = allMeetings.where((m) => m.date.isAfter(cutoff)).toList();

    final meetingEntries = meetings
        .map((m) => _toMeetingEntry(m, maps.personIdToPseudonym, categoryNames))
        .toList();

    final participantIds = {
      for (final m in meetings) ...m.participantIds,
    };
    final scopedIdToPseudonym = Map.fromEntries(
      maps.personIdToPseudonym.entries
          .where((e) => participantIds.contains(e.key)),
    );

    final personEntries = _buildPersonEntries(
      meetings,
      scopedIdToPseudonym,
      categoryNames,
    );

    return BuddyContext(
      meetings: meetingEntries,
      persons: personEntries,
      pseudonymToRealName: maps.pseudonymToRealName,
      personIdToPseudonym: maps.personIdToPseudonym,
    );
  }

  /// Builds context scoped to the [limit] most recent meetings with [personId].
  /// Used for the Long Time No See reconnection flow in [AIChatProvider].
  Future<BuddyContext> buildLapsedFriendContext(
    String userId,
    String personId, {
    int limit = 4,
  }) async {
    final maps = await _buildMaps(userId);
    final categoryNames = await _loadCategoryNames(userId);

    final recentMeetings = await _meetingRepository.getRecentMeetingsByPerson(
      userId,
      personId,
      limit: limit,
    );

    final meetingEntries = recentMeetings
        .map((m) => _toMeetingEntry(m, maps.personIdToPseudonym, categoryNames))
        .toList();

    final participantIds = {
      for (final m in recentMeetings) ...m.participantIds,
    };
    final scopedIdToPseudonym = Map.fromEntries(
      maps.personIdToPseudonym.entries
          .where((e) => participantIds.contains(e.key)),
    );

    final personEntries = _buildPersonEntries(
      recentMeetings,
      scopedIdToPseudonym,
      categoryNames,
    );

    return BuddyContext(
      meetings: meetingEntries,
      persons: personEntries,
      pseudonymToRealName: maps.pseudonymToRealName,
      personIdToPseudonym: maps.personIdToPseudonym,
    );
  }

  /// Serializes a [BuddyContext] to a plain-text string ready for use as
  /// AI prompt context.
  ///
  /// Set [includeNotes] to true only for Mode 1 (meeting notes collection) —
  /// notes are excluded by default to honour the consent screen promise.
  String serializeToPrompt(BuddyContext context, {bool includeNotes = false}) {
    final buffer = StringBuffer();
    buffer.writeln('## Social Context');
    buffer.writeln();

    // Meetings section
    buffer.writeln('### Meetings');
    if (context.meetings.isEmpty) {
      buffer.writeln('No meetings in this period.');
    } else {
      for (final m in context.meetings) {
        final dateStr = _dateFormat.format(m.date);
        final participants = m.pseudonymizedParticipants.join(', ');
        final activities = m.activityNames.join(', ');
        final sb = StringBuffer('- ${m.name} on $dateStr');
        if (participants.isNotEmpty) sb.write(': participants [$participants]');
        if (activities.isNotEmpty) sb.write(', activities [$activities]');
        // Only include notes when explicitly requested (Mode 1 — meeting notes collection).
        if (includeNotes && m.notes.isNotEmpty) {
          sb.write(', notes: [${m.notes.join('; ')}]');
        }
        buffer.writeln(sb.toString());
      }
    }
    buffer.writeln();

    // Friend summaries section — sorted by current-year meeting count descending
    // so the AI can identify the most frequent friend without counting.
    buffer.writeln('### Friend Summaries');
    if (context.persons.isEmpty) {
      buffer.writeln('No friend data available.');
    } else {
      final currentYear = DateTime.now().year;
      final sortedPersons = context.persons.toList()
        ..sort((a, b) {
          final aYear = a.meetingsByYear[currentYear] ?? 0;
          final bYear = b.meetingsByYear[currentYear] ?? 0;
          return bYear.compareTo(aYear);
        });
      for (final p in sortedPersons) {
        final sb = StringBuffer('- ${p.pseudonym}: ${p.meetingCount} meetings');
        if (p.totalWeight > 0) sb.write(', total weight: ${p.totalWeight}');
        if (p.meetingsByYear.isNotEmpty) {
          final sorted = p.meetingsByYear.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));
          final breakdown =
              sorted.map((e) => '${e.key}: ${e.value}').join(', ');
          sb.write(' ($breakdown)');
        }
        if (p.topActivities.isNotEmpty) {
          sb.write(', top activities: [${p.topActivities.join(', ')}]');
        }
        if (p.lastMeetingDate != null) {
          sb.write(', last met: ${_dateFormat.format(p.lastMeetingDate!)}');
        }
        if (p.mostActivePeriod != null) {
          sb.write(', most active: ${p.mostActivePeriod}');
        }
        if (p.avgDaysBetweenMeetings != null) {
          sb.write(', avg cadence: every ${p.avgDaysBetweenMeetings} days');
        }
        if (p.daysSinceLastMeeting != null) {
          sb.write(', days since last meeting: ${p.daysSinceLastMeeting}');
        }
        buffer.writeln(sb.toString());
      }
    }

    return buffer.toString().trimRight();
  }

  /// Async variant of [serializeToPrompt] that appends a Relationship Scores
  /// section so Buddy can explain individual scores on request.
  ///
  /// Uses [_relationshipScoreService] to compute a score per person in [context].
  /// Falls back to plain [serializeToPrompt] output if no persons are present.
  Future<String> serializeToPromptWithScores(
    BuddyContext context,
    String userId, {
    bool includeNotes = false,
  }) async {
    final base = serializeToPrompt(context, includeNotes: includeNotes);
    if (context.persons.isEmpty) return base;

    // Build inverse map: pseudonym → personId for score lookup.
    final pseudonymToPersonId = {
      for (final e in context.personIdToPseudonym.entries) e.value: e.key,
    };

    final scoreBuffer = StringBuffer('\n\n### Relationship Scores');
    for (final p in context.persons) {
      final personId = pseudonymToPersonId[p.pseudonym];
      if (personId == null) continue;
      final s = await _relationshipScoreService.computeScore(userId, personId);

      // Compute partial scores matching the four factors.
      final freqPts = (min(s.meetingsIn2y, 48) / 48 * 35).round();
      final recencyPts = s.daysSinceLast == -1
          ? 0
          : (max(0.0, (360 - s.daysSinceLast) / 360) * 30).round();
      final varietyPts = (min(s.distinctCategories2y, 10) / 10 * 20).round();
      final weightPts = (min(s.distinctWeights2y, 3) / 3 * 15).round();

      scoreBuffer.write(
        '\n- ${p.pseudonym}: score ${s.score}/100 (${s.label})'
        ' — freq: $freqPts/35 (${s.meetingsIn2y} meetings/2y)'
        ', recency: $recencyPts/30 (${s.daysSinceLast == -1 ? 'never met' : '${s.daysSinceLast} days ago'})'
        ', variety: $varietyPts/20 (${s.distinctCategories2y} categories)'
        ', weight_variety: $weightPts/15 (${s.distinctWeights2y} weight types)',
      );
    }

    return base + scoreBuffer.toString();
  }

  /// Returns the meeting with [meetingId], or null if not found.
  /// Used by AIChatProvider to display meeting names without direct repo access.
  Future<Meeting?> getMeetingById(String userId, String meetingId) async {
    final allMeetings =
        await _meetingRepository.getMeetingsByUser(userId).first;
    final matches = allMeetings.where((m) => m.id == meetingId);
    return matches.isEmpty ? null : matches.first;
  }

  /// Returns the most recent meeting without notes within [withinDays] days,
  /// or null if none found. Used by AIChatProvider for proactive note prompting.
  Future<Meeting?> findMostRecentMeetingWithoutNotes(
    String userId, {
    int withinDays = 30,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: withinDays));
    final allMeetings =
        await _meetingRepository.getMeetingsByUser(userId).first;
    final candidates = allMeetings
        .where((m) => m.date.isAfter(cutoff) && m.notes.isEmpty)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return candidates.isEmpty ? null : candidates.first;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Loads all activity categories for [userId] and returns a categoryId →
  /// categoryName map.
  Future<Map<String, String>> _loadCategoryNames(String userId) async {
    final categories =
        await _activityCategoryRepository.getCategories(userId).first;
    return {for (final c in categories) c.id: c.name};
  }

  /// Fetches all persons for [userId], sorts alphabetically by fullName for
  /// determinism, and builds the bidirectional pseudonym maps.
  Future<_PseudonymMaps> _buildMaps(String userId) async {
    final persons = await _personRepository.getPersonsByUser(userId);
    persons.sort((a, b) => a.fullName.compareTo(b.fullName));

    final pseudonymToRealName = <String, String>{};
    final personIdToPseudonym = <String, String>{};

    for (var i = 0; i < persons.length; i++) {
      final pseudonym = _pseudonymForIndex(i);
      pseudonymToRealName[pseudonym] = persons[i].fullName;
      personIdToPseudonym[persons[i].id] = pseudonym;
    }

    return _PseudonymMaps(
      pseudonymToRealName: pseudonymToRealName,
      personIdToPseudonym: personIdToPseudonym,
    );
  }

  /// Returns 'Friend_A' for index 0, 'Friend_B' for 1, …
  /// 'Friend_AA' for 26, 'Friend_AB' for 27, etc.
  static String _pseudonymForIndex(int index) {
    const base = 26;
    if (index < base) {
      return 'Friend_${String.fromCharCode(65 + index)}';
    }
    // Two-letter suffix for >26 persons.
    final first = String.fromCharCode(65 + (index ~/ base) - 1);
    final second = String.fromCharCode(65 + (index % base));
    return 'Friend_$first$second';
  }

  MeetingContextEntry _toMeetingEntry(
    Meeting meeting,
    Map<String, String> idToPseudonym,
    Map<String, String> categoryNames,
  ) {
    final pseudoParticipants = meeting.participantIds
        .map<String?>((id) => idToPseudonym[id])
        .whereType<String>()
        .toList();

    final activities = meeting.categoryIds
        .map<String?>((id) => categoryNames[id])
        .whereType<String>()
        .toList();

    return MeetingContextEntry(
      name: meeting.name,
      date: meeting.date,
      pseudonymizedParticipants: pseudoParticipants,
      activityNames: activities,
      notes: meeting.notes,
    );
  }

  /// Computes [PersonContextEntry] for each person in [idToPseudonym]
  /// using the given list of meetings.
  List<PersonContextEntry> _buildPersonEntries(
    List<Meeting> meetings,
    Map<String, String> idToPseudonym,
    Map<String, String> categoryNames,
  ) {
    return idToPseudonym.entries.map((entry) {
      final personId = entry.key;
      final pseudonym = entry.value;

      final personMeetings =
          meetings.where((m) => m.participantIds.contains(personId)).toList();

      if (personMeetings.isEmpty) {
        return PersonContextEntry(
          pseudonym: pseudonym,
          meetingCount: 0,
          topActivities: const [],
        );
      }

      // Count activity frequency across this person's meetings.
      final activityCount = <String, int>{};
      for (final m in personMeetings) {
        for (final catId in m.categoryIds) {
          final name = categoryNames[catId];
          if (name != null) {
            activityCount[name] = (activityCount[name] ?? 0) + 1;
          }
        }
      }
      final sortedActivities = activityCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topActivities = sortedActivities.take(3).map((e) => e.key).toList();

      // Last meeting date.
      final lastMeeting = personMeetings.reduce(
        (a, b) => a.date.isAfter(b.date) ? a : b,
      );

      // Average days between consecutive meetings (chronological order).
      // Requires at least 2 meetings; null otherwise.
      final chronological = personMeetings.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      int? avgDays;
      if (chronological.length >= 2) {
        final gaps = <int>[];
        for (var i = 1; i < chronological.length; i++) {
          gaps.add(
            chronological[i].date.difference(chronological[i - 1].date).inDays,
          );
        }
        avgDays = (gaps.reduce((a, b) => a + b) / gaps.length).round();
      }
      final daysSince = DateTime.now().difference(lastMeeting.date).inDays;

      // Most active month: count meetings per 'MMMM yyyy' label.
      final monthCount = <String, int>{};
      for (final m in personMeetings) {
        final label = _monthFormat.format(m.date);
        monthCount[label] = (monthCount[label] ?? 0) + 1;
      }
      final mostActive = monthCount.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );

      // Year breakdown for accurate year-specific AI answers.
      final meetingsByYear = <int, int>{};
      for (final m in personMeetings) {
        meetingsByYear[m.date.year] = (meetingsByYear[m.date.year] ?? 0) + 1;
      }

      // Sum of meeting weights — used for birthday stats display.
      final totalWeight = personMeetings.fold(0, (sum, m) => sum + m.weight);

      return PersonContextEntry(
        pseudonym: pseudonym,
        meetingCount: personMeetings.length,
        topActivities: topActivities,
        lastMeetingDate: lastMeeting.date,
        mostActivePeriod: mostActive.key,
        meetingsByYear: meetingsByYear,
        totalWeight: totalWeight,
        avgDaysBetweenMeetings: avgDays,
        daysSinceLastMeeting: daysSince,
      );
    }).toList();
  }
}

/// Internal holder for the two pseudonym maps built from the persons list.
class _PseudonymMaps {
  const _PseudonymMaps({
    required this.pseudonymToRealName,
    required this.personIdToPseudonym,
  });

  final Map<String, String> pseudonymToRealName;
  final Map<String, String> personIdToPseudonym;
}
