import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting.dart';
import '../services/local_cache_service.dart';
import 'cache_invalidator.dart';

/// Handles all Firestore operations for the meetings subcollection.
class MeetingRepository {
  final FirebaseFirestore _firestore;

  /// Optional invalidator — when set, cleared after any write so that
  /// statistics caches reflect the latest meeting data.
  CacheInvalidator? cacheInvalidator;

  MeetingRepository({
    FirebaseFirestore? firestore,
    this.cacheInvalidator,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _meetingsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('meetings');

  /// Saves a new meeting document to Firestore.
  /// Returns the generated document ID on success.
  ///
  /// Cache-first: writes to LocalCacheService immediately so the caller is
  /// never blocked by network latency. The Firestore write runs in the
  /// background — when offline, the SDK queues it and syncs when reconnected.
  Future<String> saveMeeting(Meeting meeting) async {
    // Generate a client-side document ID — no network round-trip needed.
    final docRef = _meetingsRef(meeting.userId).doc();
    final persisted = meeting.copyWith(id: docRef.id);

    // Write to local cache immediately — unblocks the caller even when offline.
    await LocalCacheService().upsertMeeting(meeting.userId, persisted);

    // Firestore write — not awaited so the caller returns before network ACK.
    // When offline, the SDK queues the write and retries when back online.
    docRef.set(persisted.toFirestore()).then((_) async {
      await cacheInvalidator?.invalidateMeetingsCache();
    }).catchError((_) {
      // Offline path: write is queued by Firestore persistence.
    });

    return docRef.id;
  }

  /// Returns a real-time stream of meetings for a given user,
  /// ordered by date descending (newest first).
  // Firestore-primary: stream-based — cache-first migration planned in US-111.
  Stream<List<Meeting>> getMeetingsByUser(String userId) {
    return _meetingsRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList());
  }

  /// Returns a metadata-aware stream of the meetings query snapshot.
  /// Use this when [QuerySnapshot.metadata.hasPendingWrites] is needed
  /// (e.g. pending sync indicator).
  Stream<QuerySnapshot<Object?>> getMeetingsSnapshot(String userId) =>
      _meetingsRef(userId)
          .orderBy('date', descending: true)
          .snapshots(includeMetadataChanges: true);

  /// Returns all meetings for [userId] from local cache; falls back to
  /// Firestore stream when cache is cold. Prefer this over [getMeetingsByUser]
  /// for one-shot reads.
  Future<List<Meeting>> getAllMeetings(String userId) async {
    final cached = await LocalCacheService().getAllMeetings(userId);
    if (cached.isNotEmpty) return cached;
    return getMeetingsByUser(userId).first;
  }

  /// Updates an existing meeting document in Firestore.
  /// Refreshes updatedAt to current timestamp.
  ///
  /// Cache-first: updates LocalCacheService immediately, then syncs to
  /// Firestore in the background so the caller is not blocked when offline.
  Future<void> updateMeeting(Meeting meeting) async {
    await LocalCacheService().upsertMeeting(meeting.userId, meeting);

    final data = meeting.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();

    _meetingsRef(meeting.userId).doc(meeting.id).update(data).then((_) async {
      await cacheInvalidator?.invalidateMeetingsCache();
    }).catchError((_) {
      // Offline path: write is queued by Firestore persistence.
    });
  }

  /// Deletes a meeting document from Firestore by its ID.
  ///
  /// Cache-first: removes from LocalCacheService immediately, then syncs to
  /// Firestore in the background so the caller is not blocked when offline.
  Future<void> deleteMeeting(String userId, String meetingId) async {
    await LocalCacheService().removeMeeting(userId, meetingId);

    _meetingsRef(userId).doc(meetingId).delete().then((_) async {
      await cacheInvalidator?.invalidateMeetingsCache();
    }).catchError((_) {
      // Offline path: write is queued by Firestore persistence.
    });
  }

  /// Returns all meetings for [userId] where [personId] is a participant,
  /// ordered by date descending.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<List<Meeting>> getMeetingsByParticipant(
      String userId, String personId) async {
    final cached = await LocalCacheService().getAllMeetings(userId);
    if (cached.isNotEmpty) {
      return cached.where((m) => m.participantIds.contains(personId)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    // Firestore fallback — used on first run before cache is populated.
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();
    final meetings =
        snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList();
    meetings.sort((a, b) => b.date.compareTo(a.date));
    return meetings;
  }

  /// Returns the number of meetings for a given user that include the given person.
  Future<int> getMeetingsCountForPerson(String userId, String personId) async {
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();
    return snapshot.docs.length;
  }

  /// Replaces [sourceId] with [targetId] in categoryIds of all meetings
  /// that contain [sourceId]. Uses a WriteBatch for atomic update.
  /// If [targetId] is already present in a meeting, only [sourceId] is removed.
  Future<void> replaceCategoryInMeetings(
      String userId, String sourceId, String targetId) async {
    // Write-helper: must read live Firestore state before cascade update — not a candidate for cache.
    final snapshot = await _meetingsRef(userId)
        .where('categoryIds', arrayContains: sourceId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final current = List<String>.from((data['categoryIds'] as List?) ?? []);
      final updated = current.where((id) => id != sourceId).toList();
      if (!updated.contains(targetId)) updated.add(targetId);
      batch.update(doc.reference, {
        'categoryIds': updated,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    await cacheInvalidator?.invalidateMeetingsCache();
  }

  /// Returns the most recently dated meeting (within [since]) that has no notes.
  /// Returns null if every meeting in range has at least one note.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<Meeting?> getLastMeetingWithoutNotes(
      String userId, DateTime since) async {
    final all = await getAllMeetings(userId);
    if (all.isNotEmpty) {
      final candidates = all
          .where((m) => m.date.isAfter(since) && m.notes.isEmpty)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return candidates.isEmpty ? null : candidates.first;
    }
    // Firestore fallback.
    final snapshot = await _meetingsRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('date', descending: true)
        .get();
    for (final doc in snapshot.docs) {
      final meeting = Meeting.fromFirestore(doc);
      if (meeting.notes.isEmpty) return meeting;
    }
    return null;
  }

  /// Returns the [limit] most recent meetings without notes since [since],
  /// ordered by date descending. Used by BuddyWidgetProvider to populate the
  /// 'Save Your Memories' meeting-selection list.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<List<Meeting>> getRecentMeetingsWithoutNotes(
    String userId,
    DateTime since, {
    int limit = 3,
  }) async {
    final all = await getAllMeetings(userId);
    final candidates = all
        .where((m) => m.date.isAfter(since) && m.notes.isEmpty)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return candidates.take(limit).toList();
  }

  /// Returns the set of personIds that appear in at least one meeting since [since].
  /// Used by [BuddyWidgetProvider] to identify recently seen contacts.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<Set<String>> getPersonIdsSeenSince(
      String userId, DateTime since) async {
    final cached = await LocalCacheService().getAllMeetings(userId);
    if (cached.isNotEmpty) {
      return cached
          .where((m) => !m.date.isBefore(since))
          .expand((m) => m.participantIds)
          .toSet();
    }
    // Firestore fallback.
    final snapshot = await _meetingsRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();
    final personIds = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final participants =
          List<String>.from((data['participantIds'] as List?) ?? []);
      personIds.addAll(participants);
    }
    return personIds;
  }

  /// Returns the [limit] most recent meetings where [personId] is a participant,
  /// ordered by date descending.
  /// Reads from local cache; falls back to Firestore when cache is cold.
  Future<List<Meeting>> getRecentMeetingsByPerson(
    String userId,
    String personId, {
    int limit = 4,
  }) async {
    final cached = await LocalCacheService().getAllMeetings(userId);
    if (cached.isNotEmpty) {
      return (cached.where((m) => m.participantIds.contains(personId)).toList()
            ..sort((a, b) => b.date.compareTo(a.date)))
          .take(limit)
          .toList();
    }
    // Firestore fallback.
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();
    final meetings = snapshot.docs
        .map((doc) => Meeting.fromFirestore(doc))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return meetings.take(limit).toList();
  }

  /// Removes personId from participantIds in all meetings that contain them.
  /// Uses a WriteBatch to apply all updates atomically.
  Future<void> removePersonFromMeetings(String userId, String personId) async {
    // Write-helper: must read live Firestore state before cascade update — not a candidate for cache.
    final snapshot = await _meetingsRef(userId)
        .where('participantIds', arrayContains: personId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'participantIds': FieldValue.arrayRemove([personId]),
      });
    }
    await batch.commit();
    await cacheInvalidator?.invalidateMeetingsCache();
  }
}
