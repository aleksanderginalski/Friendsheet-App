import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/friend_group.dart';

class FriendGroupRepository {
  final FirebaseFirestore _firestore;

  FriendGroupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _groupsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('friend_groups');

  // Returns all groups for the user, ordered by createdAt ascending.
  Future<List<FriendGroup>> getGroupsByUser(String userId) async {
    final snapshot = await _groupsRef(userId).orderBy('createdAt').get();
    return snapshot.docs.map((doc) => FriendGroup.fromFirestore(doc)).toList();
  }

  // Creates a new group. Firestore auto-generates the document ID.
  Future<void> addGroup(String userId, FriendGroup group) async {
    await _groupsRef(userId).add(group.toFirestore());
  }

  // Updates name and/or iconIdentifier of an existing group.
  Future<void> updateGroup(String userId, FriendGroup group) async {
    await _groupsRef(userId).doc(group.id).update(group.toFirestore());
  }

  // Deletes a group document. Does NOT delete or modify any Person documents.
  Future<void> deleteGroup(String userId, String groupId) async {
    await _groupsRef(userId).doc(groupId).delete();
  }

  // Adds a personId to the group's personIds list (idempotent via arrayUnion).
  Future<void> addPersonToGroup(
      String userId, String groupId, String personId) async {
    await _groupsRef(userId).doc(groupId).update({
      'personIds': FieldValue.arrayUnion([personId]),
    });
  }

  // Removes a personId from the group's personIds list.
  Future<void> removePersonFromGroup(
      String userId, String groupId, String personId) async {
    await _groupsRef(userId).doc(groupId).update({
      'personIds': FieldValue.arrayRemove([personId]),
    });
  }

  // Removes a personId from ALL groups that contain it.
  // Uses WriteBatch — call this when deleting a Person.
  Future<void> removePersonFromAllGroups(String userId, String personId) async {
    final snapshot = await _groupsRef(userId)
        .where('personIds', arrayContains: personId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'personIds': FieldValue.arrayRemove([personId]),
      });
    }
    await batch.commit();
  }
}
