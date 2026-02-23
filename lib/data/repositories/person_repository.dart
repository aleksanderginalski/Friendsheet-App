// lib/data/repositories/person_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';
import 'meeting_repository.dart';

class PersonRepository {
  final FirebaseFirestore _firestore;
  final MeetingRepository _meetingRepository;

  PersonRepository({
    FirebaseFirestore? firestore,
    MeetingRepository? meetingRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _meetingRepository = meetingRepository ?? MeetingRepository();

  CollectionReference get _persons => _firestore.collection('persons');

  // Returns all persons belonging to the given user
  Future<List<Person>> getPersonsByUser(String userId) async {
    final snapshot = await _persons
        .where('userId', isEqualTo: userId)
        .orderBy('firstName')
        .get();

    return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
  }

  // Saves a new person to Firestore and returns the created instance
  Future<Person> addPerson(Person person) async {
    final docRef = await _persons.add(person.toFirestore());
    return person.copyWith(id: docRef.id);
  }

  /// Returns persons matching the given list of IDs.
  /// Returns empty list if ids is empty.
  Future<List<Person>> getPersonsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snapshot = await _firestore
        .collection('persons')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
  }

  /// Updates an existing person document in Firestore.
  Future<void> updatePerson(Person person) async {
    await _persons.doc(person.id).update(person.toFirestore());
  }

  /// Deletes a person and removes them from all associated meetings atomically.
  Future<void> deletePerson(String userId, String personId) async {
    // Remove personId from participantIds in all meetings before deleting the person
    await _meetingRepository.removePersonFromMeetings(userId, personId);
    await _persons.doc(personId).delete();
  }
}
