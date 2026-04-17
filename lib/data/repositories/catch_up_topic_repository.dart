import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/catch_up_topic.dart';
import '../services/local_cache_service.dart';

// Redistribution decision for a shared topic during couple separation.
enum TopicRedistributionDecision { personA, shared, personB, delete }

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

  /// Marks a topic as archived (isArchived: true, archivedAt: now).
  /// Write-through: updates Firestore and re-fetches to sync local cache.
  Future<void> archive(
    String userId,
    String personId,
    String topicId,
  ) async {
    await _topicsRef(userId, personId).doc(topicId).update({
      'isArchived': true,
      'archivedAt': FieldValue.serverTimestamp(),
    });
    // Re-fetch to get the server-assigned archivedAt before updating cache.
    final snap = await _topicsRef(userId, personId).doc(topicId).get();
    if (snap.exists) {
      await LocalCacheService()
          .upsertTopic(userId, personId, CatchUpTopic.fromFirestore(snap));
    }
  }

  /// Returns all archived topics for [personId], newest archivedAt first.
  /// Reads from local cache first; falls back to Firestore when cache is cold.
  Future<List<CatchUpTopic>> getArchived(
    String userId,
    String personId,
  ) async {
    final cached =
        await LocalCacheService().getArchivedTopics(userId, personId);
    if (cached.isNotEmpty) return cached;

    // Fetch all topics and filter in Dart to avoid a composite index requirement.
    final snap = await _topicsRef(userId, personId).get();
    final all = snap.docs.map(CatchUpTopic.fromFirestore).toList();
    final archived = all.where((t) => t.isArchived).toList()
      ..sort((a, b) {
        final aAt = a.archivedAt;
        final bAt = b.archivedAt;
        if (aAt == null && bAt == null) return 0;
        if (aAt == null) return 1;
        if (bAt == null) return -1;
        return bAt.compareTo(aAt);
      });
    // Populate cache so subsequent reads are instant.
    for (final t in all) {
      await LocalCacheService().upsertTopic(userId, personId, t);
    }
    return archived;
  }

  /// Copies active topics missing on each side (deduplicates by
  /// case-insensitive text trim). Called only for Scenario 1.0 (merge).
  /// Write-through is handled inside add() for each new topic.
  Future<void> mergeTopics(
    String userId,
    String personId,
    String partnerId,
  ) async {
    final personTopics = await getActive(userId, personId);
    final partnerTopics = await getActive(userId, partnerId);

    final personTexts =
        personTopics.map((t) => t.text.trim().toLowerCase()).toSet();
    final partnerTexts =
        partnerTopics.map((t) => t.text.trim().toLowerCase()).toSet();

    for (final t in partnerTopics) {
      if (!personTexts.contains(t.text.trim().toLowerCase())) {
        await add(userId, personId, t.text, t.contextLabel);
      }
    }

    for (final t in personTopics) {
      if (!partnerTexts.contains(t.text.trim().toLowerCase())) {
        await add(userId, partnerId, t.text, t.contextLabel);
      }
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

  /// Applies redistribution decisions after couple separation.
  /// personId = primary person, partnerId = partner.
  /// postLinkTopics: active topics for personId created on/after partnerLinkedAt.
  /// Partner-side matching: case-insensitive text trim.
  Future<void> applyRedistribution(
    String userId,
    String personId,
    String partnerId,
    List<CatchUpTopic> postLinkTopics,
    Map<String, TopicRedistributionDecision> decisions,
  ) async {
    final partnerTopics = await getActive(userId, partnerId);
    for (final topic in postLinkTopics) {
      final decision =
          decisions[topic.id] ?? TopicRedistributionDecision.shared;
      final normalizedText = topic.text.trim().toLowerCase();
      final partnerMatch = partnerTopics.cast<CatchUpTopic?>().firstWhere(
            (t) => t!.text.trim().toLowerCase() == normalizedText,
            orElse: () => null,
          );
      switch (decision) {
        case TopicRedistributionDecision.personA:
          // Keep on A, delete from B.
          if (partnerMatch != null) {
            await delete(userId, partnerId, partnerMatch.id);
          }
        case TopicRedistributionDecision.shared:
          // Keep both — no action.
          break;
        case TopicRedistributionDecision.personB:
          // Keep on B, delete from A.
          await delete(userId, personId, topic.id);
        case TopicRedistributionDecision.delete:
          // Delete from both.
          await delete(userId, personId, topic.id);
          if (partnerMatch != null) {
            await delete(userId, partnerId, partnerMatch.id);
          }
      }
    }
  }
}
