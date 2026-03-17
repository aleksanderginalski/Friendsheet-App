import 'package:flutter/foundation.dart';

import '../../core/utils/person_search_helper.dart';
import '../../data/models/activity_category.dart';
import '../../data/models/import_candidate.dart';
import '../../data/models/meeting.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';

/// Provider for the per-candidate edit form in the Meeting Inbox flow.
/// Initialised from an [ImportCandidate], independent of [AddMeetingProvider].
class InboxItemEditProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;
  final PersonRepository _personRepository;
  final ActivityCategoryRepository _categoryRepository;

  InboxItemEditProvider({
    required MeetingRepository meetingRepository,
    required PersonRepository personRepository,
    ActivityCategoryRepository? categoryRepository,
  })  : _meetingRepository = meetingRepository,
        _personRepository = personRepository,
        _categoryRepository =
            categoryRepository ?? ActivityCategoryRepository();

  String _name = '';
  String? _nameError;
  DateTime _date = DateTime.now();

  static const List<int> weightValues = [1, 2, 3, 5, 8, 13, 21];
  int _weightIndex = 2;

  List<String> _attendeeEmailSuggestions = [];

  List<Person> _availablePersons = [];
  List<Person> _selectedPersons = [];
  bool _isLoadingPersons = false;
  String? _participantsError;

  List<ActivityCategory> _availableCategories = [];
  List<ActivityCategory> _selectedCategories = [];
  List<String> _selectedCategoryIds = [];
  String? _activitiesError;

  bool _isSaving = false;

  String get name => _name;
  String? get nameError => _nameError;
  DateTime get date => _date;

  int get weight => weightValues[_weightIndex];
  bool get canDecrement => _weightIndex > 0;
  bool get canIncrement => _weightIndex < weightValues.length - 1;

  List<String> get attendeeEmailSuggestions =>
      List.unmodifiable(_attendeeEmailSuggestions);

  List<Person> get availablePersons => List.unmodifiable(_availablePersons);
  List<Person> get selectedPersons => List.unmodifiable(_selectedPersons);
  bool get isLoadingPersons => _isLoadingPersons;
  String? get participantsError => _participantsError;

  List<ActivityCategory> get availableCategories =>
      List.unmodifiable(_availableCategories);
  List<ActivityCategory> get selectedCategories =>
      List.unmodifiable(_selectedCategories);
  String? get activitiesError => _activitiesError;

  bool get isSaving => _isSaving;

  /// Pre-fills form fields from the [ImportCandidate].
  void initialize(ImportCandidate candidate) {
    _name = candidate.title;
    _date = candidate.date;
    _weightIndex = 2;
    _attendeeEmailSuggestions = List<String>.from(candidate.attendeeEmails);
    _selectedPersons = [];
    _selectedCategories = [];
    _selectedCategoryIds = [];
    _nameError = null;
    _participantsError = null;
    _activitiesError = null;
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    if (_nameError != null) {
      _nameError = null;
      notifyListeners();
    }
  }

  bool validateName() {
    if (_name.isEmpty) {
      _nameError = 'Meeting name is required';
    } else if (_name.length > 50) {
      _nameError = 'Name cannot exceed 50 characters';
    } else {
      _nameError = null;
    }
    notifyListeners();
    return _nameError == null;
  }

  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  void incrementWeight() {
    if (canIncrement) {
      _weightIndex++;
      notifyListeners();
    }
  }

  void decrementWeight() {
    if (canDecrement) {
      _weightIndex--;
      notifyListeners();
    }
  }

  Future<void> loadPersons(String userId) async {
    _isLoadingPersons = true;
    _participantsError = null;
    notifyListeners();
    try {
      _availablePersons = await _personRepository.getPersonsByUser(userId);
    } catch (_) {
      _participantsError = 'Failed to load contacts';
    } finally {
      _isLoadingPersons = false;
      notifyListeners();
    }
  }

  // Returns persons matching the query, excluding already selected ones.
  // Matches against firstName, lastName, and any nickname.
  List<Person> searchPersons(String query) {
    if (query.trim().isEmpty) return [];
    return _availablePersons
        .where((p) => !_selectedPersons.contains(p))
        .where((p) => PersonSearchHelper.matches(p, query))
        .toList();
  }

  void addPerson(Person person) {
    if (_selectedPersons.contains(person)) return;
    _selectedPersons.add(person);
    _participantsError = null;
    notifyListeners();
  }

  void removePerson(Person person) {
    _selectedPersons.remove(person);
    notifyListeners();
  }

  /// Returns true if any loaded person has the same firstName + lastName.
  /// Used by AddPersonDialog to gate the save when a duplicate is detected.
  bool personNameExists(String firstName, String lastName) {
    final normalizedFirst = firstName.trim().toLowerCase();
    final normalizedLast = lastName.trim().toLowerCase();
    return _availablePersons.any((p) =>
        p.firstName.trim().toLowerCase() == normalizedFirst &&
        (p.lastName?.trim().toLowerCase() ?? '') == normalizedLast);
  }

  // [nickname] — optional; added when a duplicate name was detected in the dialog.
  Future<void> addNewPerson({
    required String userId,
    required String firstName,
    String? lastName,
    String? nickname,
  }) async {
    final person = Person(
      id: '',
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      nicknames: nickname != null ? [nickname] : [],
      createdAt: DateTime.now(),
    );
    final saved = await _personRepository.addPerson(person);
    _availablePersons.add(saved);
    addPerson(saved);
  }

  bool validateParticipants() {
    if (_selectedPersons.isEmpty) {
      _participantsError = 'Add at least one participant';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> loadCategories(String userId) async {
    try {
      _availableCategories =
          await _categoryRepository.getSelectableCategories(userId);
      notifyListeners();
    } catch (_) {
      // Non-critical: categories enhance but do not block the form.
    }
  }

  List<ActivityCategory> searchCategories(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _availableCategories
        .where((c) => !_selectedCategories.contains(c))
        .where((c) => c.name.toLowerCase().contains(lower))
        .toList();
  }

  String? getParentName(ActivityCategory category) {
    if (category.parentCategoryId == null) return null;
    try {
      return _availableCategories
          .firstWhere((c) => c.id == category.parentCategoryId)
          .name;
    } catch (_) {
      return null;
    }
  }

  Future<void> addCategory(ActivityCategory category, String userId) async {
    if (_selectedCategories.contains(category)) return;
    final ancestorIds =
        await _categoryRepository.getAncestorIds(category.id, userId);
    for (final id in ancestorIds) {
      if (!_selectedCategoryIds.contains(id)) _selectedCategoryIds.add(id);
    }
    _selectedCategories.add(category);
    _activitiesError = null;
    notifyListeners();
  }

  Future<void> addNewActivity(String name, String userId) async {
    final category = await _categoryRepository.createSelectableCategory(
      name: name,
      userId: userId,
    );
    _availableCategories.add(category);
    if (!_selectedCategoryIds.contains(category.id)) {
      _selectedCategoryIds.add(category.id);
    }
    _selectedCategories.add(category);
    _activitiesError = null;
    notifyListeners();
  }

  void removeCategory(ActivityCategory category) {
    _selectedCategories.remove(category);
    _selectedCategoryIds.remove(category.id);
    notifyListeners();
  }

  bool validateActivities() {
    if (_selectedCategories.isEmpty) {
      _activitiesError = 'Add at least one activity';
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Validates and saves the meeting to Firestore.
  /// Calls [onSuccess] on success. Returns true on success, false otherwise.
  Future<bool> save({
    required String userId,
    required VoidCallback onSuccess,
  }) async {
    final nameOk = validateName();
    final personsOk = validateParticipants();
    final activitiesOk = validateActivities();
    if (!nameOk || !personsOk || !activitiesOk) return false;

    _isSaving = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      await _meetingRepository.saveMeeting(Meeting(
        id: '',
        userId: userId,
        name: _name,
        date: _date,
        weight: weight,
        participantIds: _selectedPersons.map((p) => p.id).toList(),
        categoryIds: List<String>.from(_selectedCategoryIds),
        createdAt: now,
        updatedAt: now,
      ));
      onSuccess();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
