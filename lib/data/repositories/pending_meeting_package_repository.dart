import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pending_meeting_package.dart';

/// Reads and deletes PendingMeetingPackage documents from
/// users/{uid}/pending_meetings/ subcollection.
class PendingMeetingPackageRepository {
  final FirebaseFirestore _firestore;

  PendingMeetingPackageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _pendingRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('pending_meetings');

  /// Returns all pending packages for the given user.
  Future<List<PendingMeetingPackage>> fetchPackages(String userId) async {
    final snapshot = await _pendingRef(userId).get();
    return snapshot.docs
        .map((doc) => PendingMeetingPackage.fromFirestore(doc))
        .toList();
  }

  /// Deletes a single package document from Firestore.
  Future<void> deletePackage(String userId, String packageId) async {
    await _pendingRef(userId).doc(packageId).delete();
  }
}
