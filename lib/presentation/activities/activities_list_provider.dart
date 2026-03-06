import 'package:flutter/foundation.dart';

import '../../data/models/activity_category.dart';
import '../../data/repositories/activity_category_repository.dart';

// Manages state for ActivitiesListScreen.
// Responsibilities: fetch all user categories, tree expansion state,
// search filtering, and CRUD operations delegated to the repository.
class ActivitiesListProvider extends ChangeNotifier {
  final ActivityCategoryRepository _repository;

  ActivitiesListProvider({required ActivityCategoryRepository repository})
      : _repository = repository;

  List<ActivityCategory> _allCategories = [];
  String _searchQuery = '';
  Set<String> _expandedIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Returns level-1 categories (parentCategoryId == null), sorted alphabetically.
  List<ActivityCategory> get rootCategories {
    return _allCategories.where((c) => c.parentCategoryId == null).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Returns children of [parentId], filtered by search query if active,
  // sorted alphabetically by name.
  List<ActivityCategory> childrenOf(String parentId) {
    final query = _searchQuery.toLowerCase().trim();
    return _allCategories.where((c) {
      if (c.parentCategoryId != parentId) return false;
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  bool isExpanded(String categoryId) => _expandedIds.contains(categoryId);

  // Returns false when a non-empty search query matches no child categories.
  // Used by the screen to switch to an empty state instead of showing empty parents.
  bool get hasSearchResults {
    if (_searchQuery.isEmpty) return true;
    return rootCategories.any((root) => childrenOf(root.id).isNotEmpty);
  }

  // Fetches all categories for [userId] from the repository.
  Future<void> initialize(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allCategories = await _repository.getAllCategories(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Expands a collapsed section or collapses an expanded one.
  void toggleExpanded(String categoryId) {
    if (_expandedIds.contains(categoryId)) {
      _expandedIds.remove(categoryId);
    } else {
      _expandedIds.add(categoryId);
    }
    notifyListeners();
  }

  // Updates the search filter. Expands all root sections when query is non-empty
  // so matching children are visible; collapses all when query is cleared.
  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      _expandedIds = rootCategories.map((c) => c.id).toSet();
    } else {
      _expandedIds.clear();
    }
    notifyListeners();
  }

  // Creates a new category and refreshes the list.
  // Level-2 categories (with a parent) are marked isSelectableAsActivity: true.
  Future<void> addCategory(
    String userId,
    String name,
    String iconIdentifier,
    String? parentCategoryId,
  ) async {
    final category = ActivityCategory(
      id: '',
      userId: userId,
      name: name,
      iconIdentifier: iconIdentifier,
      isGlobal: false,
      isSelectableAsActivity: true,
      parentCategoryId: parentCategoryId,
      createdAt: DateTime.now(),
    );
    await _repository.addCategory(category);
    await initialize(userId);
  }

  // Updates an existing category and refreshes the list.
  Future<void> updateCategory(
    String userId,
    String categoryId,
    String name,
    String iconIdentifier,
    String? parentCategoryId,
  ) async {
    final existing = _allCategories.firstWhere((c) => c.id == categoryId);
    final updated = existing.copyWith(
      name: name,
      iconIdentifier: iconIdentifier,
      isSelectableAsActivity: existing.isSelectableAsActivity,
      parentCategoryId: parentCategoryId,
    );
    await _repository.updateCategory(updated);
    await initialize(userId);
  }

  // Deletes the given category and all its direct children, then refreshes the list.
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _repository.deleteWithChildren(userId, categoryId);
    await initialize(userId);
  }
}
