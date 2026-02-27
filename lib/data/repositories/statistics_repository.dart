import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meeting.dart';

/// Handles statistics-related Firestore queries.
/// Kept separate from MeetingRepository to avoid mixing stream-based
/// and one-shot query responsibilities.
class StatisticsRepository {
  final FirebaseFirestore _firestore;

  StatisticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _meetingsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('meetings');

  /// Returns unique years extracted from meeting dates, sorted descending.
  /// Queries every meeting document for the user; no Firestore index required.
  Future<List<int>> getAvailableYears(String userId) async {
    try {
      final snapshot = await _meetingsRef(userId).get();
      final years = <int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp?;
        if (timestamp != null) {
          years.add(timestamp.toDate().year);
        }
      }
      return years.toList()..sort((a, b) => b.compareTo(a));
    } catch (e) {
      throw Exception('Failed to load available years: $e');
    }
  }

  /// Returns all meetings for a given user that fall within [year].
  /// Uses an inclusive start (Jan 1) and exclusive end (Jan 1 of next year).
  Future<List<Meeting>> getMeetingsForYear(String userId, int year) async {
    try {
      final startDate = Timestamp.fromDate(DateTime(year));
      final endDate = Timestamp.fromDate(DateTime(year + 1));

      final snapshot = await _meetingsRef(userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .get();

      return snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load meetings for year $year: $e');
    }
  }
}
