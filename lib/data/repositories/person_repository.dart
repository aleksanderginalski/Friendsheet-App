// lib/data/repositories/person_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';
import '../services/local_cache_service.dart';
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

  /// Returns all persons belonging to the given user.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<List<Person>> getPersonsByUser(String userId) async {
    final cached = await LocalCacheService().getAllPersons(userId);
    if (cached.isNotEmpty) return cached;
    final snapshot = await _personsRef(userId).orderBy('firstName').get();
    return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
  }

  /// Returns persons matching the given list of IDs from the user's subcollection.
  /// Returns empty list if ids is empty.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<List<Person>> getPersonsByIds(List<String> ids, String userId) async {
    if (ids.isEmpty) return [];
    final cached = await LocalCacheService().getAllPersons(userId);
    if (cached.isNotEmpty) {
      return cached.where((p) => ids.contains(p.id)).toList();
    }
    // Firestore fallback — used on first run before cache is populated.
    final snapshot = await _personsRef(userId)
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
  }

  /// Saves a new person to Firestore and returns the created instance.
  Future<Person> addPerson(Person person) async {
    final docRef = await _personsRef(person.userId).add(person.toFirestore());
    await cacheInvalidator?.invalidatePersonsCache();
    final persisted = person.copyWith(id: docRef.id);
    // Write-through: add the persisted person (with generated ID) to local cache.
    await LocalCacheService().upsertPerson(person.userId, persisted);
    return persisted;
  }

  /// Updates an existing person document in Firestore.
  Future<void> updatePerson(Person person) async {
    await _personsRef(person.userId)
        .doc(person.id)
        .update(person.toFirestore());
    await cacheInvalidator?.invalidatePersonsCache();
    // Write-through: update the cached person entry.
    await LocalCacheService().upsertPerson(person.userId, person);
  }

  /// Returns true if another person with the same firstName + lastName exists.
  /// Comparison is case-insensitive and trimmed.
  /// [excludeId] — omit this person's own document (use during edit).
  Future<bool> isDuplicateName(
    String userId,
    String firstName,
    String lastName, {
    String? excludeId,
  }) async {
    final persons = await getPersonsByUser(userId);
    final normalizedFirst = firstName.trim().toLowerCase();
    final normalizedLast = lastName.trim().toLowerCase();
    return persons.any((p) =>
        p.id != excludeId &&
        p.firstName.trim().toLowerCase() == normalizedFirst &&
        (p.lastName?.trim().toLowerCase() ?? '') == normalizedLast);
  }

  /// Sets partnerId + partnerLinkedAt on both persons using a batch write.
  /// Write-through: re-fetches both persons from Firestore and upserts to Hive.
  Future<void> linkPartner(
    String userId,
    String personId,
    String partnerId,
  ) async {
    final now = DateTime.now();
    final batch = _firestore.batch();

    final personRef = _personsRef(userId).doc(personId);
    final partnerRef = _personsRef(userId).doc(partnerId);

    batch.update(personRef, {
      'partnerId': partnerId,
      'partnerLinkedAt': Timestamp.fromDate(now),
    });
    batch.update(partnerRef, {
      'partnerId': personId,
      'partnerLinkedAt': Timestamp.fromDate(now),
    });

    await batch.commit();

    final personSnap = await personRef.get();
    final partnerSnap = await partnerRef.get();
    if (personSnap.exists) {
      await LocalCacheService()
          .upsertPerson(userId, Person.fromFirestore(personSnap));
    }
    if (partnerSnap.exists) {
      await LocalCacheService()
          .upsertPerson(userId, Person.fromFirestore(partnerSnap));
    }
  }

  /// Clears partnerId + partnerLinkedAt on both persons using a batch write.
  /// Write-through: re-fetches both persons from Firestore and upserts to Hive.
  Future<void> unlinkPartner(
    String userId,
    String personId,
    String partnerId,
  ) async {
    final batch = _firestore.batch();

    final personRef = _personsRef(userId).doc(personId);
    final partnerRef = _personsRef(userId).doc(partnerId);

    batch.update(personRef, {
      'partnerId': FieldValue.delete(),
      'partnerLinkedAt': FieldValue.delete(),
    });
    batch.update(partnerRef, {
      'partnerId': FieldValue.delete(),
      'partnerLinkedAt': FieldValue.delete(),
    });

    await batch.commit();

    final personSnap = await personRef.get();
    final partnerSnap = await partnerRef.get();
    if (personSnap.exists) {
      await LocalCacheService()
          .upsertPerson(userId, Person.fromFirestore(personSnap));
    }
    if (partnerSnap.exists) {
      await LocalCacheService()
          .upsertPerson(userId, Person.fromFirestore(partnerSnap));
    }
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
    // Write-through: remove the person from local cache.
    await LocalCacheService().removePerson(userId, personId);
  }
}
