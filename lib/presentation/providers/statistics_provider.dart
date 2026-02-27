import 'package:flutter/foundation.dart';

import '../../data/repositories/statistics_repository.dart';
import '../../data/services/auth_service.dart';

/// Manages statistics state: available years, selected year, and loading status.
class StatisticsProvider extends ChangeNotifier {
  final StatisticsRepository _repository;
  final AuthService _authService;

  List<int> _availableYears = [];
  int? _selectedYear;
  bool _isLoading = false;
  String? _errorMessage;

  StatisticsProvider({
    required StatisticsRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  List<int> get availableYears => _availableYears;
  int? get selectedYear => _selectedYear;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// True when years have been loaded and at least one year is available.
  bool get hasData => _availableYears.isNotEmpty;

  /// Fetches available years from Firestore and sets the selected year.
  /// Selects the current calendar year if present; falls back to the most
  /// recent year in the list. Sets selectedYear to null when no data exists.
  /// No-op if a fetch is already in progress (prevents concurrent calls).
  Future<void> initialize() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        _availableYears = [];
        _selectedYear = null;
        return;
      }

      _availableYears = await _repository.getAvailableYears(userId);

      final currentYear = DateTime.now().year;
      if (_availableYears.contains(currentYear)) {
        _selectedYear = currentYear;
      } else if (_availableYears.isNotEmpty) {
        // List is sorted descending, so first element is the most recent year.
        _selectedYear = _availableYears.first;
      } else {
        _selectedYear = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load statistics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the selected year and notifies listeners.
  void selectYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }
}
