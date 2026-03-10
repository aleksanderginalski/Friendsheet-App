import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/meeting.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/services/auth_service.dart';

class MeetingsListProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;
  // ignore: unused_field — kept for future use (e.g. re-authentication)
  final AuthService _authService;

  MeetingsListProvider({
    MeetingRepository? meetingRepository,
    AuthService? authService,
  })  : _meetingRepository = meetingRepository ?? MeetingRepository(),
        _authService = authService ?? AuthService();

  StreamSubscription<List<Meeting>>? _subscription;
  List<Meeting> _meetings = [];
  bool _isLoading = false;
  String? _error;
  final Set<int> _expandedYears = {};
  final Set<String> _expandedMonths = {};
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Groups all meetings by year (unfiltered). Sorted by year descending.
  Map<int, List<Meeting>> get meetingsByYear {
    final map = <int, List<Meeting>>{};
    for (final meeting in _meetings) {
      final year = meeting.date.year;
      map.putIfAbsent(year, () => []).add(meeting);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: map[key]!};
  }

  // Returns meetings grouped by year → month, with search filter applied.
  // Years sorted descending, months sorted descending within each year.
  Map<int, Map<int, List<Meeting>>> get meetingsByYearAndMonth {
    final lower = _searchQuery.trim().toLowerCase();
    final filtered = lower.isEmpty
        ? _meetings
        : _meetings.where((m) => m.name.toLowerCase().contains(lower)).toList();

    final map = <int, Map<int, List<Meeting>>>{};
    for (final meeting in filtered) {
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

  // Returns the canonical "YYYY-MM" key for a year-month pair.
  String _monthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  bool isMonthExpanded(String monthKey) => _expandedMonths.contains(monthKey);

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

  // Expands the current month and the most recent past month that has meetings.
  // Called once after meetings are first loaded.
  void _initDefaultExpandedMonths() {
    _expandedMonths.clear();
    final now = DateTime.now();
    _expandedMonths.add(_monthKey(now.year, now.month));

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
      _expandedMonths.add(_monthKey(lastWithData.year, lastWithData.month));
    }
  }

  // Starts listening to the meetings stream for the given user.
  // Sets isLoading to true until the first data event arrives.
  // Automatically expands the current year, previous year, current month,
  // and the last month that has any meeting data.
  void initialize(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final currentYear = DateTime.now().year;
    _expandedYears.clear();
    _expandedYears.addAll({currentYear, currentYear - 1});

    _subscription?.cancel();
    _subscription = _meetingRepository.getMeetingsByUser(userId).listen(
      (meetings) {
        _meetings = meetings;
        _isLoading = false;
        _error = null;
        _initDefaultExpandedMonths();
        notifyListeners();
      },
      onError: (Object e) {
        _error = 'Failed to load meetings';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Expands a collapsed year or collapses an expanded year.
  void toggleYear(int year) {
    if (_expandedYears.contains(year)) {
      _expandedYears.remove(year);
    } else {
      _expandedYears.add(year);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
