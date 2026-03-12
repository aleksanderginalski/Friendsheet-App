// lib/data/repositories/person_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';
import 'cache_invalidator.dart';
import 'friend_group_repository.dart';
import 'meeting_repository.dart';

class PersonRepository {
  final FirebaseFirestore _firestore;
  final MeetingRepository _meetingRepository;
  final FriendGroupRepository _friendGroupRepository;

  /// Optional invalidator — when set, cleared after any write so that
  /// statistics caches reflect the latest person data.
  CacheInvalidator? cacheInvalidator;

  PersonRepository({
    FirebaseFirestore? firestore,
    MeetingRepository? meetingRepository,
    FriendGroupRepository? friendGroupRepository,
    this.cacheInvalidator,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _meetingRepository = meetingRepository ?? MeetingRepository(),
        _friendGroupRepository =
            friendGroupRepository ?? FriendGroupRepository();

  CollectionReference _personsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('persons');

  // Returns all persons belonging to the given user
  Future<List<Person>> getPersonsByUser(String userId) async {
    final snapshot = await _personsRef(userId).orderBy('firstName').get();
    return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
  }

  // Saves a new person to Firestore and returns the created instance
  Future<Person> addPerson(Person person) async {
    final docRef = await _personsRef(person.userId).add(person.toFirestore());
    await cacheInvalidator?.invalidatePersonsCache();
    return person.copyWith(id: docRef.id);
  }

  /// Returns persons matching the given list of IDs from the user's subcollection.
  /// Returns empty list if ids is empty.
  Future<List<Person>> getPersonsByIds(List<String> ids, String userId) async {
    if (ids.isEmpty) return [];
    final snapshot = await _personsRef(userId)
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
  }

  /// Updates an existing person document in Firestore.
  Future<void> updatePerson(Person person) async {
    await _personsRef(person.userId)
        .doc(person.id)
        .update(person.toFirestore());
    await cacheInvalidator?.invalidatePersonsCache();
  }

  /// Deletes a person and removes them from all associated meetings atomically.
  Future<void> deletePerson(String userId, String personId) async {
    // Remove personId from meetings and groups before deleting the person
    await Future.wait([
      _meetingRepository.removePersonFromMeetings(userId, personId),
      _friendGroupRepository.removePersonFromAllGroups(userId, personId),
    ]);
    await _personsRef(userId).doc(personId).delete();
    await cacheInvalidator?.invalidatePersonsCache();
  }
}
