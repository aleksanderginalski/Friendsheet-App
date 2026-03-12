import 'package:flutter/foundation.dart';

import '../../core/utils/person_search_helper.dart';
import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';

// PersonsListProvider manages state for PersonsListScreen.
// Responsibilities: fetch all persons, client-side filtering, loading/error state.
class PersonsListProvider extends ChangeNotifier {
  final PersonRepository _personRepository;
  final AuthService _authService;

  PersonsListProvider({
    required PersonRepository personRepository,
    required AuthService authService,
  })  : _personRepository = personRepository,
        _authService = authService;

  List<Person> _allPersons = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Returns alphabetically sorted list filtered by current search query.
  // Matches against firstName, lastName, and any nickname.
  List<Person> get persons {
    final filtered = _searchQuery.trim().isEmpty
        ? List<Person>.from(_allPersons)
        : _allPersons
            .where((p) => PersonSearchHelper.matches(p, _searchQuery))
            .toList();
    filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Fetches all persons for the current user and stores them.
  // Sets errorMessage if the fetch fails.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      _allPersons = await _personRepository.getPersonsByUser(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
