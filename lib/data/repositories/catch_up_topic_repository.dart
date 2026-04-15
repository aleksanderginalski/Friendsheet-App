import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/catch_up_topic.dart';
import '../services/local_cache_service.dart';

class CatchUpTopicRepository {
  final FirebaseFirestore _firestore;

  CatchUpTopicRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _topicsRef(String userId, String personId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('persons')
      .doc(personId)
      .collection('catch_up_topics');

  /// Adds a new active topic for [personId]. Returns the generated document ID.
  /// Write-through: also upserts into local cache immediately.
  Future<String> add(
    String userId,
    String personId,
    String text,
    String? contextLabel,
  ) async {
    final ref = _topicsRef(userId, personId).doc();
    final now = DateTime.now();
    final topic = CatchUpTopic(
      id: ref.id,
      text: text,
      contextLabel: contextLabel,
      createdAt: now,
    );
    await ref.set({
      ...topic.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await LocalCacheService().upsertTopic(userId, personId, topic);
    return ref.id;
  }

  /// Returns all active (non-archived) topics for [personId].
  /// Reads from local cache first; falls back to Firestore when cache is cold.
  Future<List<CatchUpTopic>> getActive(
    String userId,
    String personId,
  ) async {
    final cached = await LocalCacheService().getActiveTopics(userId, personId);
    if (cached.isNotEmpty) return cached;

    // Fetch all topics and filter/sort in Dart to avoid a composite index requirement.
    final snap = await _topicsRef(userId, personId).get();
    final all = snap.docs.map(CatchUpTopic.fromFirestore).toList();
    final active = all.where((t) => !t.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // Populate cache so subsequent reads are instant.
    for (final t in all) {
      await LocalCacheService().upsertTopic(userId, personId, t);
    }
    return active;
  }

  /// Updates the text and contextLabel of an existing topic.
  /// Write-through: updates Firestore and local cache.
  Future<void> update(
    String userId,
    String personId,
    String topicId,
    String text,
    String? contextLabel,
  ) async {
    await _topicsRef(userId, personId).doc(topicId).update({
      'text': text,
      'contextLabel': contextLabel,
    });
    // Re-fetch the stored topic to merge the updated fields into cache.
    final snap = await _topicsRef(userId, personId).doc(topicId).get();
    if (snap.exists) {
      await LocalCacheService()
          .upsertTopic(userId, personId, CatchUpTopic.fromFirestore(snap));
    }
  }

  /// Permanently deletes a topic from Firestore and removes it from local cache.
  Future<void> delete(
    String userId,
    String personId,
    String topicId,
  ) async {
    await _topicsRef(userId, personId).doc(topicId).delete();
    await LocalCacheService().removeTopic(userId, personId, topicId);
  }
}
