import '../../data/models/meeting.dart';
import '../../data/models/pending_meeting_package.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import 'package_import_types.dart';
import 'shared_package_inbox_provider.dart' show ConflictResolution;

/// Performs the final batch import of a PendingMeetingPackage to Firestore.
///
/// Handles: meeting filtering by resolution, activity category creation/linking,
/// person creation/linking, and meeting creation with mapped IDs.
class PackageImporter {
  final MeetingRepository meetingRepo;
  final PersonRepository personRepo;
  final ActivityCategoryRepository categoryRepo;

  const PackageImporter({
    required this.meetingRepo,
    required this.personRepo,
    required this.categoryRepo,
  });

  /// Runs the import and returns a summary of what was added.
  ///
  /// Only meetings with no date conflict, or with [ConflictResolution.addAsNew],
  /// are imported. Merged and skipped meetings are ignored.
  Future<ImportSummary> run({
    required PendingMeetingPackage package,
    required Map<int, Meeting> meetingConflicts,
    required Map<int, ConflictResolution> meetingResolutions,
    required Map<String, ActivityResolution> activityResolutions,
    required Set<String> activityOptOut,
    required Map<String, PersonResolution> personResolutions,
    required Set<String> personOptOut,
    required String userId,
  }) async {
    final indicesToImport =
        _indicesToImport(package, meetingConflicts, meetingResolutions);

    final (categoryNameToId, activitiesAdded) = await _buildCategoryMap(
      package,
      indicesToImport,
      activityResolutions,
      activityOptOut,
      userId,
    );
    final (personKeyToId, personsAdded) = await _buildPersonMap(
      package,
      indicesToImport,
      personResolutions,
      personOptOut,
      userId,
    );

    // Sender is always added to every imported meeting as a participant.
    final senderKey =
        _personKey(package.senderFirstName, package.senderLastName);
    final senderPersonId = personKeyToId[senderKey];

    var meetingsAdded = 0;
    for (final i in indicesToImport) {
      final sm = package.meetings[i];
      final participantIds = {
        ...sm.participants
            .map((p) => personKeyToId[_personKey(p.firstName, p.lastName)])
            .whereType<String>(),
        if (senderPersonId != null) senderPersonId,
      }.toList();
      final categoryIds = sm.categoryNames
          .map((n) => categoryNameToId[n.toLowerCase()])
          .whereType<String>()
          .toList();
      await meetingRepo.saveMeeting(Meeting(
        id: '',
        userId: userId,
        name: sm.name,
        date: sm.date,
        weight: sm.weight,
        participantIds: participantIds,
        categoryIds: categoryIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      meetingsAdded++;
    }

    return ImportSummary(
      meetingsAdded: meetingsAdded,
      personsAdded: personsAdded,
      activitiesAdded: activitiesAdded,
    );
  }

  List<int> _indicesToImport(
    PendingMeetingPackage package,
    Map<int, Meeting> conflicts,
    Map<int, ConflictResolution> resolutions,
  ) {
    final result = <int>[];
    for (var i = 0; i < package.meetings.length; i++) {
      final hasConflict = conflicts.containsKey(i);
      final resolution = resolutions[i];
      if (!hasConflict || resolution == ConflictResolution.addAsNew) {
        result.add(i);
      }
    }
    return result;
  }

  // Builds lowerName → categoryId map and returns count of newly created categories.
  Future<(Map<String, String>, int)> _buildCategoryMap(
    PendingMeetingPackage package,
    List<int> indicesToImport,
    Map<String, ActivityResolution> resolutions,
    Set<String> optOut,
    String userId,
  ) async {
    final namesToImport = <String>{};
    for (final i in indicesToImport) {
      namesToImport.addAll(package.meetings[i].categoryNames);
    }

    final ids = <String, String>{};
    var added = 0;
    for (final name in namesToImport) {
      final lower = name.toLowerCase();
      final res = resolutions[lower];
      if (optOut.contains(lower) || (res?.isSkip ?? false)) continue;
      if (res != null && res.isLink) {
        ids[lower] = res.linkedCategoryId!;
      } else {
        final finalName = res?.renamedName ?? name;
        final cat = await categoryRepo.createSelectableCategory(
          name: finalName,
          userId: userId,
        );
        ids[lower] = cat.id;
        added++;
      }
    }
    return (ids, added);
  }

  // Builds personKey → personId map and returns count of newly created persons.
  Future<(Map<String, String>, int)> _buildPersonMap(
    PendingMeetingPackage package,
    List<int> indicesToImport,
    Map<String, PersonResolution> resolutions,
    Set<String> optOut,
    String userId,
  ) async {
    final personsToImport = <String, SharedPerson>{};
    // Sender is always imported as a participant.
    personsToImport[
            _personKey(package.senderFirstName, package.senderLastName)] =
        SharedPerson(
      firstName: package.senderFirstName,
      lastName: package.senderLastName,
      nickname: package.senderNickname,
    );
    for (final i in indicesToImport) {
      for (final sp in package.meetings[i].participants) {
        personsToImport.putIfAbsent(
            _personKey(sp.firstName, sp.lastName), () => sp);
      }
    }

    final ids = <String, String>{};
    var added = 0;
    for (final entry in personsToImport.entries) {
      final res = resolutions[entry.key];
      if (optOut.contains(entry.key) || (res?.isSkip ?? false)) continue;
      if (res != null && res.isLink) {
        ids[entry.key] = res.linkedPersonId!;
      } else {
        final sp = entry.value;
        final resolvedNickname = res?.nickname ?? sp.nickname;
        final nicknames = resolvedNickname != null ? [resolvedNickname] : <String>[];
        final person = await personRepo.addPerson(Person(
          id: '',
          userId: userId,
          firstName: sp.firstName,
          lastName: sp.lastName,
          createdAt: DateTime.now(),
          nicknames: nicknames,
        ));
        ids[entry.key] = person.id;
        added++;
      }
    }
    return (ids, added);
  }

  static String _personKey(String firstName, String? lastName) =>
      '${firstName.trim().toLowerCase()} ${(lastName ?? '').trim().toLowerCase()}'
          .trim();
}
