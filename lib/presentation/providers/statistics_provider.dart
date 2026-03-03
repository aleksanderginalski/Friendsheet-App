import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/activity_category.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../data/services/auth_service.dart';

/// Card types shown in the statistics carousel.
enum StatCardType { activityBreakdown, whoPerActivity, interactionDistribution }

const _kHiddenPersonsKey = 'stats_hidden_persons_activity';
const _kHiddenActivitiesKey = 'stats_hidden_activities_breakdown';
const _kHiddenPersonsDistributionKey = 'stats_hidden_persons_distribution';
const _kHiddenCardsKey = 'stats_carousel_hidden_cards';

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
  Set<String> _hiddenActivities = {};
  List<InteractionDistributionEntry> _distributionEntries = [];
  bool _isCumulativeMode = false;
  Set<String> _hiddenPersonsDistribution = {};
  bool _isDistributionLoading = false;
  List<StatCardType> _hiddenCards = [];

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
  Set<String> get hiddenActivities => _hiddenActivities;
  List<InteractionDistributionEntry> get distributionEntries =>
      _distributionEntries;
  bool get isCumulativeMode => _isCumulativeMode;
  Set<String> get hiddenPersonsDistribution => _hiddenPersonsDistribution;
  bool get isDistributionLoading => _isDistributionLoading;

  /// Cards currently visible in the carousel — hidden cards excluded.
  List<StatCardType> get visibleCards =>
      StatCardType.values.where((c) => !_hiddenCards.contains(c)).toList();

  /// True when every card has been hidden by the user.
  bool get allCardsHidden => visibleCards.isEmpty;

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
      await loadHiddenActivities();
      await loadHiddenCards();
    } catch (e) {
      _errorMessage = 'Failed to load statistics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Load distribution independently — always runs regardless of earlier failures.
    // loadHiddenPersonsDistribution depends on _distributionEntries being populated
    // (auto-select top 10 reads the list), so it must follow loadDistribution().
    await loadDistribution();
    await loadHiddenPersonsDistribution();
  }

  /// Updates the selected year, resets breakdowns immediately, then
  /// reloads all stats for the new year (keeping current activity selection).
  Future<void> selectYear(int year) async {
    _selectedYear = year;
    _activityBreakdown = [];
    _distributionEntries = [];
    notifyListeners();

    final userId = _authService.currentUserId;
    if (userId == null) return;

    // Load breakdown and who-per-activity — failures do not block distribution.
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

    // Load distribution independently — always runs regardless of breakdown result.
    await loadDistribution();
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

  /// Toggles [categoryId] in the hidden-activities set and persists to
  /// SharedPreferences so the preference survives app restarts.
  Future<void> toggleHiddenActivity(String categoryId) async {
    if (_hiddenActivities.contains(categoryId)) {
      _hiddenActivities.remove(categoryId);
    } else {
      _hiddenActivities.add(categoryId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kHiddenActivitiesKey,
      _hiddenActivities.toList(),
    );
  }

  /// Returns the top-10 visible category IDs from [entries].
  ///
  /// Eligible entries are leaves: isSelectableAsActivity == true, OR a
  /// parent whose children do NOT appear in the breakdown.
  /// Parents that have at least one child in [entries] are always excluded —
  /// they represent aggregate buckets, not individual activities.
  ///
  /// [entries] is expected sorted descending by currentYearWeight.
  Set<String> _computeTop10Ids(
    List<ActivityBreakdownEntry> entries,
    List<ActivityCategory> allCats,
  ) {
    final entryIds = {for (final e in entries) e.categoryId};

    // Pre-compute the set of entry categoryIds that act as parents within
    // this breakdown: a category is a "parent in breakdown" when at least
    // one of its direct children also appears in the breakdown.
    final parentsInBreakdown = <String>{};
    for (final c in allCats) {
      final parentId = c.parentCategoryId;
      if (parentId != null &&
          entryIds.contains(parentId) &&
          entryIds.contains(c.id)) {
        parentsInBreakdown.add(parentId);
      }
    }

    // Leaf = any entry NOT acting as a parent within this breakdown.
    // isSelectableAsActivity is ignored — hierarchy alone determines eligibility.
    final leafEntries = entries.where(
      (e) => !parentsInBreakdown.contains(e.categoryId),
    );

    return leafEntries.take(10).map((e) => e.categoryId).toSet();
  }

  /// Applies the top-10 default selection: hides all entries except the top 10
  /// leaf activities by currentYearWeight. Persists result to SharedPreferences.
  /// Returns the new hidden set so callers (e.g. dialog) can update local state.
  Future<Set<String>> applyTop10Selection() async {
    if (_activityBreakdown.isEmpty) return Set.from(_hiddenActivities);

    final top10Ids = _computeTop10Ids(_activityBreakdown, _allCategories);
    _hiddenActivities = {
      for (final e in _activityBreakdown)
        if (!top10Ids.contains(e.categoryId)) e.categoryId,
    };
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kHiddenActivitiesKey,
      _hiddenActivities.toList(),
    );
    return Set.from(_hiddenActivities);
  }

  /// Reads the persisted hidden-activities list from SharedPreferences.
  /// Called once during initialize(), after activityBreakdown is populated.
  ///
  /// First launch (key absent): auto-applies top-10 default selection.
  /// Subsequent launches (key present, even if empty): uses stored value as-is.
  Future<void> loadHiddenActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_kHiddenActivitiesKey);
      if (stored == null) {
        // Key absent = first launch: auto-apply top-10 default.
        await applyTop10Selection();
      } else {
        _hiddenActivities = stored.toSet();
      }
    } catch (_) {
      // Non-critical: leave hidden set empty on read failure.
      _hiddenActivities = {};
    }
  }

  /// Loads distribution data for the selected year.
  /// Uses yearly or cumulative mode based on [_isCumulativeMode].
  /// No-op when no user is signed in or no year is selected.
  Future<void> loadDistribution() async {
    final userId = _authService.currentUserId;
    if (userId == null || _selectedYear == null) return;

    _isDistributionLoading = true;
    notifyListeners();

    try {
      if (_isCumulativeMode) {
        _distributionEntries = await _repository.getCumulativeInteractions(
          _selectedYear!,
          userId,
        );
      } else {
        _distributionEntries = await _repository.getInteractionDistribution(
          _selectedYear!,
          userId,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load distribution';
    } finally {
      _isDistributionLoading = false;
      notifyListeners();
    }
  }

  /// Toggles between yearly and cumulative mode, then reloads distribution.
  Future<void> toggleDistributionMode() async {
    _isCumulativeMode = !_isCumulativeMode;
    notifyListeners();
    await loadDistribution();
  }

  /// Reads the persisted hidden-persons-distribution list from SharedPreferences.
  /// Called once during initialize(), after loadDistribution() is populated.
  ///
  /// First launch (key absent): auto-applies top-10 default selection.
  /// Subsequent launches (key present, even if empty): uses stored value as-is.
  Future<void> loadHiddenPersonsDistribution() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_kHiddenPersonsDistributionKey);
      if (stored == null) {
        // Key absent = first launch: auto-apply top-10 default.
        await autoSelectTopPersonsDistribution();
      } else {
        _hiddenPersonsDistribution = stored.toSet();
      }
    } catch (_) {
      // Non-critical: leave hidden set empty on read failure.
      _hiddenPersonsDistribution = {};
    }
  }

  /// Toggles [personId] in the hidden-persons-distribution set and persists
  /// to SharedPreferences so the preference survives app restarts.
  Future<void> togglePersonDistributionVisibility(String personId) async {
    if (_hiddenPersonsDistribution.contains(personId)) {
      _hiddenPersonsDistribution.remove(personId);
    } else {
      _hiddenPersonsDistribution.add(personId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kHiddenPersonsDistributionKey,
      _hiddenPersonsDistribution.toList(),
    );
  }

  /// Hides all persons except the top 10 by currentYearWeight.
  /// Uses [_distributionEntries] (yearly mode data) for selection logic.
  /// Persists result to SharedPreferences.
  Future<void> autoSelectTopPersonsDistribution() async {
    if (_distributionEntries.isEmpty) return;

    final top10Ids =
        _distributionEntries.take(10).map((e) => e.personId).toSet();
    _hiddenPersonsDistribution = {
      for (final e in _distributionEntries)
        if (!top10Ids.contains(e.personId)) e.personId,
    };
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kHiddenPersonsDistributionKey,
      _hiddenPersonsDistribution.toList(),
    );
  }

  /// Reads the persisted hidden-cards list from SharedPreferences.
  /// Called once during initialize(). Key absent or empty → all cards visible.
  Future<void> loadHiddenCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_kHiddenCardsKey);
      if (stored == null) {
        _hiddenCards = [];
      } else {
        _hiddenCards = stored
            .where((name) => StatCardType.values.any((c) => c.name == name))
            .map(
                (name) => StatCardType.values.firstWhere((c) => c.name == name))
            .toList();
      }
    } catch (_) {
      // Non-critical: leave hidden set empty on read failure.
      _hiddenCards = [];
    }
  }

  /// Toggles [card] in the hidden-cards list and persists to SharedPreferences.
  Future<void> toggleCardVisibility(StatCardType card) async {
    if (_hiddenCards.contains(card)) {
      _hiddenCards.remove(card);
    } else {
      _hiddenCards.add(card);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kHiddenCardsKey,
      _hiddenCards.map((c) => c.name).toList(),
    );
  }

  /// Restores all cards to visible and clears the persisted hidden-cards key.
  Future<void> restoreAllCards() async {
    _hiddenCards = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHiddenCardsKey);
  }
}
