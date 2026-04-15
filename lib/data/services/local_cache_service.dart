import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../services/hive_service.dart';
import '../models/activity_category.dart';
import '../models/catch_up_topic.dart';
import '../models/meeting.dart';
import '../models/person.dart';

/// Local Hive cache for the full user dataset (meetings, persons, categories).
///
/// Acts as the primary read layer for all one-shot data queries.
/// Firestore is used only as the initial sync source — not for individual
/// reads once the cache is warm.
///
/// Box key strategy: userId → JSON-encoded List of all records for that user.
/// Same JSON-bridge strategy as HiveService stats boxes (no @HiveType annotations).
///
/// Write-through pattern: every repository write calls upsert/remove so the
/// cache reflects the latest state immediately without waiting for the next sync.
class LocalCacheService {
  // Singleton — all callers share the same Hive storage.
  static final LocalCacheService _instance = LocalCacheService._internal();

  factory LocalCacheService({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      return LocalCacheService._withFirestore(firestore);
    }
    return _instance;
  }

  LocalCacheService._internal();

  LocalCacheService._withFirestore(FirebaseFirestore firestore)
      : _firestoreOverride = firestore;

  // Lazy: only accessed during syncFromFirestore, never during Hive read/write.
  // Avoids calling FirebaseFirestore.instance at class load time (safe in tests).
  FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  /// Loads all meetings, persons, and activity categories for [userId] from
  /// Firestore and writes them to Hive. Call fire-and-forget on app start.
  Future<void> syncFromFirestore(String userId) async {
    try {
      final meetingsSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meetings')
          .get();
      final personsSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('persons')
          .get();
      final catsSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activity_categories')
          .get();

      final meetings = meetingsSnap.docs.map(Meeting.fromFirestore).toList();
      final persons = personsSnap.docs.map(Person.fromFirestore).toList();
      final cats = catsSnap.docs.map(ActivityCategory.fromFirestore).toList();

      await HiveService.box(HiveService.localMeetingsBox).put(
        userId,
        jsonEncode(meetings.map((m) => m.toJson()).toList()),
      );
      await HiveService.box(HiveService.localPersonsBox).put(
        userId,
        jsonEncode(persons.map((p) => p.toJson()).toList()),
      );
      await HiveService.box(HiveService.localCatsBox).put(
        userId,
        jsonEncode(cats.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('LocalCacheService.syncFromFirestore error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private loaders — return [] on any error (Hive not yet initialised in tests)
  // ---------------------------------------------------------------------------

  List<Meeting> _loadMeetings(String userId) {
    try {
      final raw = HiveService.box(HiveService.localMeetingsBox).get(userId);
      if (raw == null) return [];
      return (jsonDecode(raw as String) as List<dynamic>)
          .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Person> _loadPersons(String userId) {
    try {
      final raw = HiveService.box(HiveService.localPersonsBox).get(userId);
      if (raw == null) return [];
      return (jsonDecode(raw as String) as List<dynamic>)
          .map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<ActivityCategory> _loadCategories(String userId) {
    try {
      final raw = HiveService.box(HiveService.localCatsBox).get(userId);
      if (raw == null) return [];
      return (jsonDecode(raw as String) as List<dynamic>)
          .map((e) => ActivityCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Write-through helpers — called by repositories after every Firestore write
  // ---------------------------------------------------------------------------

  Future<void> upsertMeeting(String userId, Meeting meeting) async {
    try {
      final list = _loadMeetings(userId);
      final idx = list.indexWhere((m) => m.id == meeting.id);
      if (idx >= 0) {
        list[idx] = meeting;
      } else {
        list.add(meeting);
      }
      await HiveService.box(HiveService.localMeetingsBox)
          .put(userId, jsonEncode(list.map((m) => m.toJson()).toList()));
    } catch (e) {
      debugPrint('LocalCacheService.upsertMeeting error: $e');
    }
  }

  Future<void> removeMeeting(String userId, String id) async {
    try {
      final list = _loadMeetings(userId)..removeWhere((m) => m.id == id);
      await HiveService.box(HiveService.localMeetingsBox)
          .put(userId, jsonEncode(list.map((m) => m.toJson()).toList()));
    } catch (e) {
      debugPrint('LocalCacheService.removeMeeting error: $e');
    }
  }

  Future<void> upsertPerson(String userId, Person person) async {
    try {
      final list = _loadPersons(userId);
      final idx = list.indexWhere((p) => p.id == person.id);
      if (idx >= 0) {
        list[idx] = person;
      } else {
        list.add(person);
      }
      await HiveService.box(HiveService.localPersonsBox)
          .put(userId, jsonEncode(list.map((p) => p.toJson()).toList()));
    } catch (e) {
      debugPrint('LocalCacheService.upsertPerson error: $e');
    }
  }

  Future<void> removePerson(String userId, String id) async {
    try {
      final list = _loadPersons(userId)..removeWhere((p) => p.id == id);
      await HiveService.box(HiveService.localPersonsBox)
          .put(userId, jsonEncode(list.map((p) => p.toJson()).toList()));
    } catch (e) {
      debugPrint('LocalCacheService.removePerson error: $e');
    }
  }

  Future<void> upsertCategory(String userId, ActivityCategory category) async {
    try {
      final list = _loadCategories(userId);
      final idx = list.indexWhere((c) => c.id == category.id);
      if (idx >= 0) {
        list[idx] = category;
      } else {
        list.add(category);
      }
      await HiveService.box(HiveService.localCatsBox)
          .put(userId, jsonEncode(list.map((c) => c.toJson()).toList()));
    } catch (e) {
      debugPrint('LocalCacheService.upsertCategory error: $e');
    }
  }

  Future<void> removeCategory(String userId, String id) async {
    try {
      final list = _loadCategories(userId)..removeWhere((c) => c.id == id);
      await HiveService.box(HiveService.localCatsBox)
          .put(userId, jsonEncode(list.map((c) => c.toJson()).toList()));
    } catch (e) {
      debugPrint('LocalCacheService.removeCategory error: $e');
    }
  }

  Future<void> removeCategoriesByIds(String userId, List<String> ids) async {
    try {
      final list = _loadCategories(userId)
        ..removeWhere((c) => ids.contains(c.id));
      await HiveService.box(HiveService.localCatsBox)
          .put(userId, jsonEncode(list.map((c) => c.toJson()).toList()));
    } catch (e) {
      debugPrint('LocalCacheService.removeCategoriesByIds error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Read methods
  // ---------------------------------------------------------------------------

  /// Returns all meetings for [userId] from cache.
  /// Returns empty list if cache is cold (sync not yet completed).
  Future<List<Meeting>> getAllMeetings(String userId) async =>
      _loadMeetings(userId);

  /// Returns all persons for [userId] from cache.
  /// Returns empty list if cache is cold (sync not yet completed).
  Future<List<Person>> getAllPersons(String userId) async =>
      _loadPersons(userId);

  /// Returns all activity categories for [userId] from cache.
  /// Returns empty list if cache is cold (sync not yet completed).
  Future<List<ActivityCategory>> getAllCategories(String userId) async =>
      _loadCategories(userId);

  /// Fuzzy-matches [query] against firstName, lastName, and all nicknames.
  /// Case-insensitive substring match. Returns all matching persons.
  Future<List<Person>> resolvePerson(String userId, String query) async {
    final lower = query.toLowerCase();
    return _loadPersons(userId).where((p) {
      if (p.firstName.toLowerCase().contains(lower)) return true;
      if (p.lastName?.toLowerCase().contains(lower) ?? false) return true;
      return p.nicknames.any((n) => n.toLowerCase().contains(lower));
    }).toList();
  }

  /// Returns all meetings where [personId] is in participantIds and
  /// meeting.date.year == [year].
  Future<List<Meeting>> getMeetingsByPersonAndYear(
    String userId,
    String personId,
    int year,
  ) async {
    return _loadMeetings(userId)
        .where(
            (m) => m.participantIds.contains(personId) && m.date.year == year)
        .toList();
  }

  /// Returns all meetings where date is within [start]..[end] (inclusive).
  Future<List<Meeting>> getMeetingsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    return _loadMeetings(userId)
        .where((m) => !m.date.isBefore(start) && !m.date.isAfter(end))
        .toList();
  }

  /// Returns meeting.notes for the given meetingId.
  /// Returns empty list if meeting not found in cache.
  Future<List<String>> getMeetingNotes(
    String userId,
    String meetingId,
  ) async {
    final match = _loadMeetings(userId)
        .cast<Meeting?>()
        .firstWhere((m) => m?.id == meetingId, orElse: () => null);
    return match?.notes ?? [];
  }

  /// Computes a [PersonSummary] from cached meetings.
  /// Returns null if person not found in cache or has no meetings.
  Future<PersonSummary?> getPersonSummary(
    String userId,
    String personId,
  ) async {
    final person = _loadPersons(userId)
        .cast<Person?>()
        .firstWhere((p) => p?.id == personId, orElse: () => null);
    if (person == null) return null;

    final meetings = _loadMeetings(userId)
        .where((m) => m.participantIds.contains(personId))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (meetings.isEmpty) return null;

    final totalWeight = meetings.fold(0, (acc, m) => acc + m.weight);
    return PersonSummary(
      person: person,
      totalMeetingCount: meetings.length,
      totalWeight: totalWeight,
      firstMeetingDate: meetings.first.date,
      lastMeetingDate: meetings.last.date,
    );
  }

  // ---------------------------------------------------------------------------
  // Catch-up topics cache — box key: "{userId}_{personId}" (person-scoped)
  // ---------------------------------------------------------------------------

  List<CatchUpTopic> _loadTopics(String userId, String personId) {
    try {
      final raw = HiveService.box(HiveService.localCatchUpTopicsBox)
          .get('${userId}_$personId');
      if (raw == null) return [];
      return (jsonDecode(raw as String) as List<dynamic>)
          .map((e) => CatchUpTopic.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertTopic(
    String userId,
    String personId,
    CatchUpTopic topic,
  ) async {
    try {
      final list = _loadTopics(userId, personId);
      final idx = list.indexWhere((t) => t.id == topic.id);
      if (idx >= 0) {
        list[idx] = topic;
      } else {
        list.add(topic);
      }
      await HiveService.box(HiveService.localCatchUpTopicsBox).put(
        '${userId}_$personId',
        jsonEncode(list.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('LocalCacheService.upsertTopic error: $e');
    }
  }

  Future<void> removeTopic(
    String userId,
    String personId,
    String topicId,
  ) async {
    try {
      final list = _loadTopics(userId, personId)
        ..removeWhere((t) => t.id == topicId);
      await HiveService.box(HiveService.localCatchUpTopicsBox).put(
        '${userId}_$personId',
        jsonEncode(list.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('LocalCacheService.removeTopic error: $e');
    }
  }

  /// Returns active (non-archived) topics for [personId], newest first.
  Future<List<CatchUpTopic>> getActiveTopics(
    String userId,
    String personId,
  ) async {
    final all = _loadTopics(userId, personId);
    final active = all.where((t) => !t.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active;
  }
}

/// Computed summary of a person's meeting history. Not a domain model — plain Dart class.
class PersonSummary {
  const PersonSummary({
    required this.person,
    required this.totalMeetingCount,
    required this.totalWeight,
    this.firstMeetingDate,
    this.lastMeetingDate,
  });

  final Person person;
  final int totalMeetingCount;
  final int totalWeight;
  final DateTime? firstMeetingDate;
  final DateTime? lastMeetingDate;
}
