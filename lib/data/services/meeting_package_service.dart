import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pending_meeting_package.dart';

/// Writes a completed PendingMeetingPackage to the recipient's pending_meetings subcollection.
/// Called after sender (A) selects meetings and confirms the GDPR notice.
class MeetingPackageService {
  final FirebaseFirestore _firestore;

  MeetingPackageService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _pendingRef(String recipientUid) => _firestore
      .collection('users')
      .doc(recipientUid)
      .collection('pending_meetings');

  /// Creates a new package document in the recipient's pending_meetings subcollection.
  /// The doc ID is auto-generated and written back into the package via copyWith.
  Future<void> sendPackage(
      PendingMeetingPackage package, String recipientUid) async {
    final docRef = _pendingRef(recipientUid).doc();
    await docRef.set(package.copyWith(id: docRef.id).toFirestore());
  }
}
