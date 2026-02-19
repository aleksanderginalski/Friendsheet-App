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
}
