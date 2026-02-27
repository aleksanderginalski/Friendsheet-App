import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/activity_category.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../data/services/auth_service.dart';

const _kHiddenPersonsKey = 'stats_hidden_persons_activity';

/// Manages statistics state: available years, selected year, activity
/// breakdown, who-per-activity, hidden persons, and loading status.
class StatisticsProvider extends ChangeNotifier {
  final StatisticsRepository _repository;
  final AuthService _authService;
  final ActivityCategoryRepository _categoryRepository;
  // Injected for DI consistency; person lookups are done via _repository.
  // ignore: unused_field
  final PersonRepository _personRepository;

  List<int> _availableYears = [];
  int? _selectedYear;
  bool _isLoading = false;
  String? _errorMessage;
  List<ActivityBreakdownEntry> _activityBreakdown = [];
  List<ActivityCategory> _allCategories = [];
  List<PersonActivityEntry> _whoPerActivity = [];
  String? _selectedActivityId;
  Set<String> _hiddenPersonsActivity = {};

  StatisticsProvider({
    required StatisticsRepository repository,
    required AuthService authService,
    required ActivityCategoryRepository categoryRepository,
    required PersonRepository personRepository,
  })  : _repository = repository,
        _authService = authService,
        _categoryRepository = categoryRepository,
        _personRepository = personRepository;

  List<int> get availableYears => _availableYears;
  int? get selectedYear => _selectedYear;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ActivityBreakdownEntry> get activityBreakdown => _activityBreakdown;
  List<ActivityCategory> get allCategories => _allCategories;
  List<PersonActivityEntry> get whoPerActivity => _whoPerActivity;
  String? get selectedActivityId => _selectedActivityId;
  Set<String> get hiddenPersonsActivity => _hiddenPersonsActivity;

  /// True when years have been loaded and at least one year is available.
  bool get hasData => _availableYears.isNotEmpty;

  /// Number of persons in the current who-per-activity list that are hidden.
  int get hiddenCountForActivity => _whoPerActivity
      .where((e) => _hiddenPersonsActivity.contains(e.personId))
      .length;

  /// Fetches available years, categories, activity breakdown, and
  /// who-per-activity for the auto-selected (or previously chosen) activity.
  /// No-op if a fetch is already in progress.
  Future<void> initialize() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _activityBreakdown = [];
    _allCategories = [];
    _whoPerActivity = [];
    notifyListeners();

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        _availableYears = [];
        _selectedYear = null;
        return;
      }

      _availableYears = await _repository.getAvailableYears(userId);
      _allCategories = await _categoryRepository.getAllCategories(userId);

      final currentYear = DateTime.now().year;
      if (_availableYears.contains(currentYear)) {
        _selectedYear = currentYear;
      } else if (_availableYears.isNotEmpty) {
        // List is sorted descending, so first element is the most recent year.
        _selectedYear = _availableYears.first;
      } else {
        _selectedYear = null;
      }

      if (_selectedYear != null) {
        _activityBreakdown = await _repository.getActivityWeightBreakdown(
          _selectedYear!,
          userId,
        );
      }

      // Auto-select top activity only on first load (when nothing is selected).
      if (_activityBreakdown.isNotEmpty) {
        _selectedActivityId ??= _activityBreakdown.first.categoryId;
        _whoPerActivity = await _repository.getPersonsForActivity(
          _selectedActivityId!,
          _selectedYear!,
          userId,
        );
      }

      await loadHiddenPersons();
    } catch (e) {
      _errorMessage = 'Failed to load statistics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the selected year, resets breakdowns immediately, then
  /// reloads all stats for the new year (keeping current activity selection).
  Future<void> selectYear(int year) async {
    _selectedYear = year;
    _activityBreakdown = [];
    _whoPerActivity = [];
    notifyListeners();

    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      _activityBreakdown = await _repository.getActivityWeightBreakdown(
        year,
        userId,
      );

      if (_selectedActivityId != null) {
        _whoPerActivity = await _repository.getPersonsForActivity(
          _selectedActivityId!,
          year,
          userId,
        );
      } else if (_activityBreakdown.isNotEmpty) {
        _selectedActivityId = _activityBreakdown.first.categoryId;
        _whoPerActivity = await _repository.getPersonsForActivity(
          _selectedActivityId!,
          year,
          userId,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load statistics';
    } finally {
      notifyListeners();
    }
  }

  /// Sets the selected activity and loads who-per-activity for it.
  Future<void> selectActivity(String categoryId) async {
    _selectedActivityId = categoryId;
    _whoPerActivity = [];
    notifyListeners();

    final userId = _authService.currentUserId;
    if (userId == null || _selectedYear == null) return;

    try {
      _whoPerActivity = await _repository.getPersonsForActivity(
        categoryId,
        _selectedYear!,
        userId,
      );
    } catch (e) {
      _errorMessage = 'Failed to load statistics';
    } finally {
      notifyListeners();
    }
  }

  /// Toggles [personId] in the hidden-persons set and persists to
  /// SharedPreferences so the preference survives app restarts.
  Future<void> toggleHiddenPerson(String personId) async {
    if (_hiddenPersonsActivity.contains(personId)) {
      _hiddenPersonsActivity.remove(personId);
    } else {
      _hiddenPersonsActivity.add(personId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kHiddenPersonsKey,
      _hiddenPersonsActivity.toList(),
    );
  }

  /// Reads the persisted hidden-persons list from SharedPreferences.
  /// Called once during initialize().
  Future<void> loadHiddenPersons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_kHiddenPersonsKey) ?? [];
      _hiddenPersonsActivity = stored.toSet();
    } catch (_) {
      // Non-critical: leave hidden set empty on read failure.
      _hiddenPersonsActivity = {};
    }
  }
}
