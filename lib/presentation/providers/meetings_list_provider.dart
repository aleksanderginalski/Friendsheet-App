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
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Groups meetings by year and returns a map sorted by year descending.
  Map<int, List<Meeting>> get meetingsByYear {
    final map = <int, List<Meeting>>{};
    for (final meeting in _meetings) {
      final year = meeting.date.year;
      map.putIfAbsent(year, () => []).add(meeting);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: map[key]!};
  }

  // Filters meetingsByYear by _searchQuery (case-insensitive name match).
  // Returns full meetingsByYear when search is empty.
  Map<int, List<Meeting>> get filteredMeetingsByYear {
    if (_searchQuery.trim().isEmpty) return meetingsByYear;
    final lower = _searchQuery.toLowerCase();
    final result = <int, List<Meeting>>{};
    for (final entry in meetingsByYear.entries) {
      final filtered = entry.value
          .where((m) => m.name.toLowerCase().contains(lower))
          .toList();
      if (filtered.isNotEmpty) result[entry.key] = filtered;
    }
    return result;
  }

  bool isYearExpanded(int year) => _expandedYears.contains(year);

  // Starts listening to the meetings stream for the given user.
  // Sets isLoading to true until the first data event arrives.
  // Automatically expands the current year and the previous year.
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
