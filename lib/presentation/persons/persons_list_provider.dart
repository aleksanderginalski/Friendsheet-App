import 'package:flutter/foundation.dart';

import '../../core/utils/person_search_helper.dart';
import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';

// Maps Polish diacritics to base Latin equivalents for sort key generation.
// Used only for comparison — does not modify stored data.
String _normalizeForSort(String s) {
  const replacements = {
    'ą': 'a',
    'ć': 'c',
    'ę': 'e',
    'ł': 'l',
    'ń': 'n',
    'ó': 'o',
    'ś': 's',
    'ź': 'z',
    'ż': 'z',
    'Ą': 'A',
    'Ć': 'C',
    'Ę': 'E',
    'Ł': 'L',
    'Ń': 'N',
    'Ó': 'O',
    'Ś': 'S',
    'Ź': 'Z',
    'Ż': 'Z',
  };
  return s.splitMapJoin(
    RegExp('.'),
    onMatch: (m) => replacements[m.group(0)!] ?? m.group(0)!,
  );
}

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
    filtered.sort((a, b) => _normalizeForSort(a.fullName.toLowerCase())
        .compareTo(_normalizeForSort(b.fullName.toLowerCase())));
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
