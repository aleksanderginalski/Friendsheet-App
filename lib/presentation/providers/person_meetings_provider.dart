import 'package:flutter/foundation.dart';

import '../../data/models/meeting.dart';
import '../../data/repositories/meeting_repository.dart';

/// Provides filtered meeting list for a single person.
/// Loads meetings once via [loadMeetings] (no real-time stream).
class PersonMeetingsProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;

  PersonMeetingsProvider({MeetingRepository? meetingRepository})
      : _meetingRepository = meetingRepository ?? MeetingRepository();

  List<Meeting> _meetings = [];
  bool _isLoading = false;
  String? _error;
  final Set<int> _expandedYears = {};
  final Set<String> _expandedMonths = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Meeting> get meetings => List.unmodifiable(_meetings);

  // Returns meetings grouped by year → month, sorted descending.
  Map<int, Map<int, List<Meeting>>> get meetingsByYearAndMonth {
    final map = <int, Map<int, List<Meeting>>>{};
    for (final meeting in _meetings) {
      map
          .putIfAbsent(meeting.date.year, () => {})
          .putIfAbsent(meeting.date.month, () => [])
          .add(meeting);
    }
    final sortedYears = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {
      for (final year in sortedYears)
        year: {
          for (final month
              in (map[year]!.keys.toList()..sort((a, b) => b.compareTo(a))))
            month: map[year]![month]!,
        },
    };
  }

  bool isYearExpanded(int year) => _expandedYears.contains(year);

  String _monthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  bool isMonthExpanded(String monthKey) => _expandedMonths.contains(monthKey);

  // Expands or collapses the given year section.
  void toggleYear(int year) {
    if (_expandedYears.contains(year)) {
      _expandedYears.remove(year);
    } else {
      _expandedYears.add(year);
    }
    notifyListeners();
  }

  // Expands or collapses the given month section.
  void toggleMonth(int year, int month) {
    final key = _monthKey(year, month);
    if (_expandedMonths.contains(key)) {
      _expandedMonths.remove(key);
    } else {
      _expandedMonths.add(key);
    }
    notifyListeners();
  }

  // Loads all meetings where personId is a participant for userId.
  Future<void> loadMeetings(String userId, String personId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _meetings = await _meetingRepository.getMeetingsByParticipant(
          userId, personId);
      _initDefaultExpandedSections();
    } catch (_) {
      _error = 'Failed to load meetings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Expands current year and the most recent month that has meetings.
  // Called after meetings are first loaded.
  void _initDefaultExpandedSections() {
    final now = DateTime.now();
    _expandedYears
      ..clear()
      ..add(now.year);

    _expandedMonths
      ..clear()
      ..add(_monthKey(now.year, now.month));

    // Find the most recent meeting month strictly before the current month.
    final currentMonthStart = DateTime(now.year, now.month);
    DateTime? lastWithData;
    for (final m in _meetings) {
      final mMonthStart = DateTime(m.date.year, m.date.month);
      if (mMonthStart.isBefore(currentMonthStart)) {
        if (lastWithData == null || mMonthStart.isAfter(lastWithData)) {
          lastWithData = mMonthStart;
        }
      }
    }
    if (lastWithData != null) {
      _expandedYears.add(lastWithData.year);
      _expandedMonths.add(_monthKey(lastWithData.year, lastWithData.month));
    }
  }
}
