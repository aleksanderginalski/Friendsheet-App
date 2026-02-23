import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting.dart';

/// Handles all Firestore operations for the meetings collection.
class MeetingRepository {
  final FirebaseFirestore _firestore;

  MeetingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Saves a new meeting document to Firestore.
  /// Returns the generated document ID on success.
  Future<String> saveMeeting(Meeting meeting) async {
    final docRef =
        await _firestore.collection('meetings').add(meeting.toFirestore());
    return docRef.id;
  }

  /// Returns a real-time stream of meetings for a given user,
  /// ordered by date descending (newest first).
  Stream<List<Meeting>> getMeetingsByUser(String userId) {
    return _firestore
        .collection('meetings')
        .where('userId', isEqualTo: userId)
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

    await _firestore.collection('meetings').doc(meeting.id).update(data);
  }

  /// Deletes a meeting document from Firestore by its ID.
  Future<void> deleteMeeting(String meetingId) async {
    await _firestore.collection('meetings').doc(meetingId).delete();
  }

  /// Returns the number of meetings for a given user that include the given person.
  Future<int> getMeetingsCountForPerson(String userId, String personId) async {
    final snapshot = await _firestore
        .collection('meetings')
        .where('userId', isEqualTo: userId)
        .where('participantIds', arrayContains: personId)
        .get();
    return snapshot.docs.length;
  }
}
