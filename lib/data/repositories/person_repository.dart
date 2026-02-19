// lib/data/repositories/person_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';

class PersonRepository {
  final FirebaseFirestore _firestore;

  PersonRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
}
