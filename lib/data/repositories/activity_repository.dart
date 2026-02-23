import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;

  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Returns merged list of global and user-private activities
  Future<List<Activity>> getActivitiesByUser(String userId) async {
    final globalQuery = await _firestore
        .collection('activities')
        .where('isGlobal', isEqualTo: true)
        .get();

    final privateQuery = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .where('isGlobal', isEqualTo: false)
        .get();

    final globalActivities =
        globalQuery.docs.map((doc) => Activity.fromFirestore(doc)).toList();

    final privateActivities =
        privateQuery.docs.map((doc) => Activity.fromFirestore(doc)).toList();

    return [...globalActivities, ...privateActivities];
  }

  // Adds new private activity for the current user
  Future<Activity> addActivity({
    required String userId,
    required String name,
  }) async {
    final docRef = await _firestore.collection('activities').add({
      'userId': userId,
      'name': name,
      'isGlobal': false,
      'categoryId': null,
      'createdAt': Timestamp.now(),
    });

    final doc = await docRef.get();
    return Activity.fromFirestore(doc);
  }

  /// Returns activities matching the given list of IDs.
  /// Returns empty list if ids is empty.
  Future<List<Activity>> getActivitiesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snapshot = await _firestore
        .collection('activities')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
  }
}
