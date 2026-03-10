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

  /// Returns the number of meetings for a given user that include the given person.
  Future<int> getMeetingsCountForPerson(String userId, String personId) async {
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();
    return snapshot.docs.length;
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
