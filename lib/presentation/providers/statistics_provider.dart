import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/activity_category.dart';
import '../../data/models/friend_group.dart';
import '../../data/models/person.dart';
import '../../data/models/stats_data_bundle.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/friend_group_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../data/services/auth_service.dart';

/// Card types shown in the statistics carousel.
enum StatCardType { activityBreakdown, whoPerActivity, interactionDistribution }

const _kSelectedPersonsActivityKey = 'stats_selected_persons_activity';
const _kHiddenActivitiesKey = 'stats_hidden_activities_breakdown';
const _kSelectedPersonsDistributionKey = 'stats_selected_persons_distribution';
const _kHiddenCardsKey = 'stats_carousel_hidden_cards';

/// Manages statistics state: available years, selected year, activity
/// breakdown, who-per-activity, selected persons (whitelist), and loading status.
class StatisticsProvider extends ChangeNotifier {
  final StatisticsRepository _repository;
  final AuthService _authService;
  // Injected for DI consistency; categories are loaded via _repository bundle.
  // ignore: unused_field
  final ActivityCategoryRepository _categoryRepository;
  final PersonRepository _personRepository;
  final FriendGroupRepository _friendGroupRepository;

  List<int> _availableYears = [];
  int? _selectedYear;
  bool _isLoading = false;
  String? _errorMessage;

  /// True after the first successful initialize() completes.
  bool _isInitialized = false;

  /// Year that was selected when _isInitialized was last set to true.
  int? _lastLoadedYear;

  /// Cached bundle for the current year — reused by selectActivity() and
  /// loadDistribution() to avoid additional Firestore reads.
  StatsDataBundle? _currentBundle;

  List<ActivityBreakdownEntry> _activityBreakdown = [];
  List<ActivityCategory> _allCategories = [];
  List<Person> _allPersons = [];
  List<PersonActivityEntry> _whoPerActivity = [];
  String? _selectedActivityId;

  /// Whitelist of person IDs shown in the Who Per Activity chart.
  /// Only persons in this set are rendered. Persists across year changes.
  Set<String> _selectedPersonsActivity = {};
  Set<String> _hiddenActivities = {};
  List<InteractionDistributionEntry> _distributionEntries = [];
  bool _isCumulativeMode = false;

  /// Whitelist of person IDs shown in the Interaction Distribution chart.
  /// Only persons in this set are rendered. Persists across year changes.
  Set<String> _selectedPersonsDistribution = {};
  bool _isDistributionLoading = false;
  List<StatCardType> _hiddenCards = [];
  List<FriendGroup> _personGroups = [];

  StatisticsProvider({
    required StatisticsRepository repository,
    required AuthService authService,
    required ActivityCategoryRepository categoryRepository,
    required PersonRepository personRepository,
    required FriendGroupRepository friendGroupRepository,
  })  : _repository = repository,
        _authService = authService,
        _categoryRepository = categoryRepository,
        _personRepository = personRepository,
        _friendGroupRepository = friendGroupRepository;

  List<int> get availableYears => _availableYears;
  int? get selectedYear => _selectedYear;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ActivityBreakdownEntry> get activityBreakdown => _activityBreakdown;
  List<ActivityCategory> get allCategories => _allCategories;
  List<PersonActivityEntry> get whoPerActivity => _whoPerActivity;
  String? get selectedActivityId => _selectedActivityId;
  List<Person> get allPersons => _allPersons;
  Set<String> get selectedPersonsActivity => _selectedPersonsActivity;
  Set<String> get hiddenActivities => _hiddenActivities;
  List<InteractionDistributionEntry> get distributionEntries =>
      _distributionEntries;
  bool get isCumulativeMode => _isCumulativeMode;
  Set<String> get selectedPersonsDistribution => _selectedPersonsDistribution;
  bool get isDistributionLoading => _isDistributionLoading;
  List<FriendGroup> get personGroups => _personGroups;

  /// Cards currently hidden in the carousel.
  Set<StatCardType> get hiddenCards => Set.from(_hiddenCards);

  /// Cards currently visible in the carousel — hidden cards excluded.
  List<StatCardType> get visibleCards =>
      StatCardType.values.where((c) => !_hiddenCards.contains(c)).toList();

  /// True when every card has been hidden by the user.
  bool get allCardsHidden => visibleCards.isEmpty;

  /// True when years have been loaded and at least one year is available.
  bool get hasData => _availableYears.isNotEmpty;

  /// Number of persons in the who-per-activity list not in the whitelist.
  int get hiddenCountForActivity => _whoPerActivity
      .where((e) => !_selectedPersonsActivity.contains(e.personId))
      .length;

  /// Number of persons in the distribution list not in the whitelist.
  int get hiddenCountForDistribution => _distributionEntries
      .where((e) => !_selectedPersonsDistribution.contains(e.personId))
      .length;

  /// Fetches available years, bundle data, activity breakdown, and
  /// who-per-activity for the auto-selected (or previously chosen) activity.
  /// No-op if a fetch is already in progress, or if data for the same year
  /// is already loaded (_isInitialized guard).
  Future<void> initialize() async {
    if (_isLoading) return;
    if (_isInitialized && _lastLoadedYear == _selectedYear) return;

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
      await _loadPersonGroups(userId);
      await _loadAllPersons(userId);

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
        // Single parallel fetch — bundle contains meetings, categories, persons.
        final bundle =
            await _repository.loadAllStatsData(_selectedYear!, userId);
        _currentBundle = bundle;
        _allCategories = bundle.categories;
        _activityBreakdown = _repository.computeActivityBreakdown(bundle);
      }

      // Auto-select top activity only on first load (when nothing is selected).
      if (_activityBreakdown.isNotEmpty && _currentBundle != null) {
        _selectedActivityId ??= _activityBreakdown.first.categoryId;
        _whoPerActivity = _repository.computePersonsForActivity(
          _currentBundle!,
          _selectedActivityId!,
        );
      }

      await loadSelectedPersonsActivity();
      await loadHiddenActivities();
      await loadHiddenCards();
    } catch (e) {
      _errorMessage = 'Failed to load statistics';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      _lastLoadedYear = _selectedYear;
      notifyListeners();
    }

    // Load distribution independently — always runs regardless of earlier failures.
    // loadSelectedPersonsDistribution depends on _distributionEntries being populated,
    // so it must follow loadDistribution().
    await loadDistribution();
    await loadSelectedPersonsDistribution();
  }

  /// Loads all persons for the current user — used as the full roster for the
  /// filter sheet, independent of which persons appear in the selected year.
  Future<void> _loadAllPersons(String userId) async {
    try {
      _allPersons = await _personRepository.getPersonsByUser(userId);
    } catch (_) {
      _allPersons = [];
    }
  }

  /// Loads friend groups for the current user and stores them for the filter sheet.
  Future<void> _loadPersonGroups(String userId) async {
    try {
      _personGroups = await _friendGroupRepository.getGroupsByUser(userId);
    } catch (_) {
      _personGroups = [];
    }
  }

  /// Updates the selected year, resets breakdowns immediately, then
  /// reloads all stats for the new year (keeping current activity selection).
  /// Whitelists are NOT reset — they persist across year changes.
  /// No-op when [year] is already selected and data is initialized.
  Future<void> selectYear(int year) async {
    if (year == _selectedYear && _isInitialized) return;

    _selectedYear = year;
    _activityBreakdown = [];
    _distributionEntries = [];
    _currentBundle = null;
    notifyListeners();

    final userId = _authService.currentUserId;
    if (userId == null) return;

    // Load bundle and compute breakdowns — failures do not block distribution.
    try {
      final bundle = await _repository.loadAllStatsData(year, userId);
      _currentBundle = bundle;
      _allCategories = bundle.categories;
      _activityBreakdown = _repository.computeActivityBreakdown(bundle);

      if (_selectedActivityId != null) {
        _whoPerActivity = _repository.computePersonsForActivity(
          bundle,
          _selectedActivityId!,
        );
      } else if (_activityBreakdown.isNotEmpty) {
        _selectedActivityId = _activityBreakdown.first.categoryId;
        _whoPerActivity = _repository.computePersonsForActivity(
          bundle,
          _selectedActivityId!,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load statistics';
    } finally {
      _isInitialized = true;
      _lastLoadedYear = year;
      notifyListeners();
    }

    // Load distribution independently — always runs regardless of breakdown result.
    await loadDistribution();
  }

  /// Sets the selected activity and computes who-per-activity from the stored
  /// bundle. No Firestore call required — uses _currentBundle.
  Future<void> selectActivity(String categoryId) async {
    _selectedActivityId = categoryId;
    _whoPerActivity = [];
    notifyListeners();

    if (_currentBundle == null) return;

    _whoPerActivity = _repository.computePersonsForActivity(
      _currentBundle!,
      categoryId,
    );
    notifyListeners();
  }

  /// Clears the provider-level initialization state so the next initialize()
  /// re-fetches all data. Call this on logout or user switch.
  void resetCache() {
    _isInitialized = false;
    _lastLoadedYear = null;
    _currentBundle = null;
  }

  /// Toggles [personId] in the who-per-activity whitelist and persists to
  /// SharedPreferences so the preference survives app restarts.
  Future<void> toggleSelectedPerson(String personId) async {
    if (_selectedPersonsActivity.contains(personId)) {
      _selectedPersonsActivity.remove(personId);
    } else {
      _selectedPersonsActivity.add(personId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsActivityKey,
      _selectedPersonsActivity.toList(),
    );
  }

  /// Sets the who-per-activity whitelist to exactly [ids] and persists.
  /// Used for batch operations (group toggle, select-all) to avoid N writes.
  Future<void> setSelectedPersonsActivity(Set<String> ids) async {
    _selectedPersonsActivity = Set.from(ids);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsActivityKey,
      _selectedPersonsActivity.toList(),
    );
  }

  /// Sets the who-per-activity whitelist to the top 10 persons by weightSum.
  /// When fewer than 10 persons exist, all are selected.
  /// Persists updated state to SharedPreferences.
  Future<void> autoSelectTop10ForActivity() async {
    if (_whoPerActivity.isEmpty) return;

    _selectedPersonsActivity =
        _whoPerActivity.take(10).map((e) => e.personId).toSet();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsActivityKey,
      _selectedPersonsActivity.toList(),
    );
  }

  /// Selects all or deselects all persons in the who-per-activity whitelist.
  /// [selectAll] true → whitelist = all persons; false → whitelist = empty.
  Future<void> setAllPersonsActivitySelected(bool selectAll) async {
    if (selectAll) {
      _selectedPersonsActivity = _whoPerActivity.map((e) => e.personId).toSet();
    } else {
      _selectedPersonsActivity = {};
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsActivityKey,
      _selectedPersonsActivity.toList(),
    );
  }

  /// Reads the persisted who-per-activity whitelist from SharedPreferences.
  /// First run (key absent or empty): seeds whitelist with ALL current persons.
  Future<void> loadSelectedPersonsActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_kSelectedPersonsActivityKey) ?? [];
      if (stored.isEmpty) {
        // First run or cleared: default to all persons visible.
        _selectedPersonsActivity =
            _whoPerActivity.map((e) => e.personId).toSet();
      } else {
        _selectedPersonsActivity = stored.toSet();
      }
    } catch (_) {
      _selectedPersonsActivity = _whoPerActivity.map((e) => e.personId).toSet();
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
  ///
  /// Yearly mode uses the stored bundle — no additional Firestore read.
  /// Cumulative mode queries all historical meetings via getCumulativeInteractions().
  Future<void> loadDistribution() async {
    final userId = _authService.currentUserId;
    if (userId == null || _selectedYear == null) return;

    _isDistributionLoading = true;
    notifyListeners();

    try {
      if (_isCumulativeMode) {
        // Cumulative spans all years — requires its own Firestore query.
        _distributionEntries = await _repository.getCumulativeInteractions(
          _selectedYear!,
          userId,
        );
      } else if (_currentBundle != null) {
        // Use the already-loaded bundle — no additional Firestore read.
        _distributionEntries =
            _repository.computeInteractionDistribution(_currentBundle!);
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

  /// Reads the persisted distribution whitelist from SharedPreferences.
  /// First run (key absent or empty): seeds whitelist with ALL current persons.
  Future<void> loadSelectedPersonsDistribution() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored =
          prefs.getStringList(_kSelectedPersonsDistributionKey) ?? [];
      if (stored.isEmpty) {
        // First run or cleared: default to all persons visible.
        _selectedPersonsDistribution =
            _distributionEntries.map((e) => e.personId).toSet();
      } else {
        _selectedPersonsDistribution = stored.toSet();
      }
    } catch (_) {
      _selectedPersonsDistribution =
          _distributionEntries.map((e) => e.personId).toSet();
    }
  }

  /// Toggles [personId] in the distribution whitelist and persists to
  /// SharedPreferences so the preference survives app restarts.
  Future<void> toggleSelectedPersonDistribution(String personId) async {
    if (_selectedPersonsDistribution.contains(personId)) {
      _selectedPersonsDistribution.remove(personId);
    } else {
      _selectedPersonsDistribution.add(personId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsDistributionKey,
      _selectedPersonsDistribution.toList(),
    );
  }

  /// Sets the distribution whitelist to exactly [ids] and persists.
  /// Used for batch operations (group toggle, select-all) to avoid N writes.
  Future<void> setSelectedPersonsDistribution(Set<String> ids) async {
    _selectedPersonsDistribution = Set.from(ids);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsDistributionKey,
      _selectedPersonsDistribution.toList(),
    );
  }

  /// Sets the distribution whitelist to the top 10 persons by currentYearWeight.
  /// When fewer than 10 persons exist, all are selected.
  /// Persists updated state to SharedPreferences.
  Future<void> autoSelectTopPersonsDistribution() async {
    if (_distributionEntries.isEmpty) return;

    _selectedPersonsDistribution =
        _distributionEntries.take(10).map((e) => e.personId).toSet();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsDistributionKey,
      _selectedPersonsDistribution.toList(),
    );
  }

  /// Selects all or deselects all persons in the distribution whitelist.
  /// [selectAll] true → whitelist = all persons; false → whitelist = empty.
  Future<void> setAllPersonsDistributionSelected(bool selectAll) async {
    if (selectAll) {
      _selectedPersonsDistribution =
          _distributionEntries.map((e) => e.personId).toSet();
    } else {
      _selectedPersonsDistribution = {};
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSelectedPersonsDistributionKey,
      _selectedPersonsDistribution.toList(),
    );
  }

  /// Sets all activities as visible (true) or hidden (false).
  /// Persists updated state to SharedPreferences.
  /// Returns the new hidden set so callers (e.g. dialog) can update local state.
  Future<Set<String>> setAllActivitiesVisibility(bool visible) async {
    if (visible) {
      _hiddenActivities = {};
    } else {
      _hiddenActivities = _activityBreakdown.map((e) => e.categoryId).toSet();
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kHiddenActivitiesKey,
      _hiddenActivities.toList(),
    );
    return Set.from(_hiddenActivities);
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
