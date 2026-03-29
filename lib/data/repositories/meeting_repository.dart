import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting.dart';
import 'cache_invalidator.dart';

/// Handles all Firestore operations for the meetings subcollection.
class MeetingRepository {
  final FirebaseFirestore _firestore;

  /// Optional invalidator — when set, cleared after any write so that
  /// statistics caches reflect the latest meeting data.
  CacheInvalidator? cacheInvalidator;

  MeetingRepository({
    FirebaseFirestore? firestore,
    this.cacheInvalidator,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _meetingsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('meetings');

  /// Saves a new meeting document to Firestore.
  /// Returns the generated document ID on success.
  Future<String> saveMeeting(Meeting meeting) async {
    final docRef =
        await _meetingsRef(meeting.userId).add(meeting.toFirestore());
    await cacheInvalidator?.invalidateMeetingsCache();
    return docRef.id;
  }

  /// Returns a real-time stream of meetings for a given user,
  /// ordered by date descending (newest first).
  Stream<List<Meeting>> getMeetingsByUser(String userId) {
    return _meetingsRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList());
  }

  /// Updates an existing meeting document in Firestore.
  /// Refreshes updatedAt to current timestamp.
  Future<void> updateMeeting(Meeting meeting) async {
    final data = meeting.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _meetingsRef(meeting.userId).doc(meeting.id).update(data);
    await cacheInvalidator?.invalidateMeetingsCache();
  }

  /// Deletes a meeting document from Firestore by its ID.
  Future<void> deleteMeeting(String userId, String meetingId) async {
    await _meetingsRef(userId).doc(meetingId).delete();
    await cacheInvalidator?.invalidateMeetingsCache();
  }

  /// Returns all meetings for [userId] where [personId] is a participant,
  /// ordered by date descending.
  /// Sorting is done client-side to avoid requiring a composite Firestore index.
  Future<List<Meeting>> getMeetingsByParticipant(
      String userId, String personId) async {
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();
    final meetings =
        snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList();
    meetings.sort((a, b) => b.date.compareTo(a.date));
    return meetings;
  }

  /// Returns the number of meetings for a given user that include the given person.
  Future<int> getMeetingsCountForPerson(String userId, String personId) async {
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();
    return snapshot.docs.length;
  }

  /// Replaces [sourceId] with [targetId] in categoryIds of all meetings
  /// that contain [sourceId]. Uses a WriteBatch for atomic update.
  /// If [targetId] is already present in a meeting, only [sourceId] is removed.
  Future<void> replaceCategoryInMeetings(
      String userId, String sourceId, String targetId) async {
    final snapshot = await _meetingsRef(userId)
        .where('categoryIds', arrayContains: sourceId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final current = List<String>.from((data['categoryIds'] as List?) ?? []);
      final updated = current.where((id) => id != sourceId).toList();
      if (!updated.contains(targetId)) updated.add(targetId);
      batch.update(doc.reference, {
        'categoryIds': updated,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    await cacheInvalidator?.invalidateMeetingsCache();
  }

  /// Returns the most recently dated meeting (within [since]) that has no notes.
  /// Fetches all meetings since [since] ordered by date descending, filters client-side.
  /// Returns null if every meeting in range has at least one note.
  Future<Meeting?> getLastMeetingWithoutNotes(
      String userId, DateTime since) async {
    final snapshot = await _meetingsRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('date', descending: true)
        .get();
    for (final doc in snapshot.docs) {
      final meeting = Meeting.fromFirestore(doc);
      if (meeting.notes.isEmpty) return meeting;
    }
    return null;
  }

  /// Returns the [limit] most recent meetings without notes since [since],
  /// ordered by date descending. Used by BuddyWidgetProvider to populate the
  /// 'Save Your Memories' meeting-selection list.
  Future<List<Meeting>> getRecentMeetingsWithoutNotes(
    String userId,
    DateTime since, {
    int limit = 3,
  }) async {
    final allMeetings = await getMeetingsByUser(userId).first;
    final candidates = allMeetings
        .where((m) => m.date.isAfter(since) && m.notes.isEmpty)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return candidates.take(limit).toList();
  }

  /// Returns the set of personIds that appear in at least one meeting since [since].
  /// Used by [BuddyWidgetProvider] to identify recently seen contacts.
  Future<Set<String>> getPersonIdsSeenSince(
      String userId, DateTime since) async {
    final snapshot = await _meetingsRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();
    final personIds = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final participants =
          List<String>.from((data['participantIds'] as List?) ?? []);
      personIds.addAll(participants);
    }
    return personIds;
  }

  /// Returns the [limit] most recent meetings where [personId] is a participant,
  /// ordered by date descending. Sorting is done client-side to avoid a
  /// composite Firestore index (consistent with [getMeetingsByParticipant]).
  Future<List<Meeting>> getRecentMeetingsByPerson(
    String userId,
    String personId, {
    int limit = 4,
  }) async {
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();
    final meetings = snapshot.docs
        .map((doc) => Meeting.fromFirestore(doc))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return meetings.take(limit).toList();
  }

  /// Removes personId from participantIds in all meetings that contain them.
  /// Uses a WriteBatch to apply all updates atomically.
  Future<void> removePersonFromMeetings(String userId, String personId) async {
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'participantIds': FieldValue.arrayRemove([personId]),
      });
    }
    await batch.commit();
    await cacheInvalidator?.invalidateMeetingsCache();
  }
}
