// lib/presentation/providers/add_meeting_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/activity_category.dart';
import '../../data/models/meeting.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';

class AddMeetingProvider extends ChangeNotifier {
  final PersonRepository _personRepository;
  final ActivityCategoryRepository _categoryRepository;
  final MeetingRepository _meetingRepository;
  final AuthService _authService;

  // If provided, provider operates in edit mode
  final Meeting? initialMeeting;

  AddMeetingProvider({
    PersonRepository? personRepository,
    ActivityCategoryRepository? categoryRepository,
    MeetingRepository? meetingRepository,
    AuthService? authService,
    this.initialMeeting,
  })  : _personRepository = personRepository ?? PersonRepository(),
        _categoryRepository =
            categoryRepository ?? ActivityCategoryRepository(),
        _meetingRepository = meetingRepository ?? MeetingRepository(),
        _authService = authService ?? AuthService() {
    if (initialMeeting != null) {
      _initializeFromMeeting(initialMeeting!);
    }
  }

  // --- Name & Date ---
  String _name = '';
  String? _nameError;
  DateTime _date = DateTime.now();

  // --- Weight ---
  static const List<int> weightValues = [1, 2, 3, 5, 8, 13, 21];
  int _weightIndex = 2;

  // --- Participants state ---
  List<Person> _availablePersons = [];
  List<Person> _selectedPersons = [];
  bool _isLoadingPersons = false;
  String? _participantsError;

  // --- Activities/Categories error state ---
  String? _activitiesError;

  // --- Categories state ---
  List<ActivityCategory> _availableCategories = [];
  // Leaf categories displayed as chips in the UI.
  List<ActivityCategory> _selectedCategories = [];
  // All selected IDs including ancestor IDs for storage.
  List<String> _selectedCategoryIds = [];

  // --- Save state ---
  bool _isSaving = false;
  Meeting? _savedMeeting;

  // --- Name & Date getters ---
  String get name => _name;
  String? get nameError => _nameError;
  DateTime get date => _date;

  // --- Weight getters ---
  int get weight => weightValues[_weightIndex];
  bool get canDecrement => _weightIndex > 0;
  bool get canIncrement => _weightIndex < weightValues.length - 1;

  // --- Participants getters ---
  List<Person> get availablePersons => List.unmodifiable(_availablePersons);
  List<Person> get selectedPersons => List.unmodifiable(_selectedPersons);
  bool get isLoadingPersons => _isLoadingPersons;
  String? get participantsError => _participantsError;

  // --- Activities/Categories getters ---
  String? get activitiesError => _activitiesError;

  // --- Categories getters ---
  List<ActivityCategory> get availableCategories =>
      List.unmodifiable(_availableCategories);
  List<ActivityCategory> get selectedCategories =>
      List.unmodifiable(_selectedCategories);
  List<String> get selectedCategoryIds =>
      List.unmodifiable(_selectedCategoryIds);

  // --- Save getters ---
  bool get isSaving => _isSaving;
  bool get isEditMode => initialMeeting != null;

  // Returns the meeting after successful save or update
  Meeting? get savedMeeting => _savedMeeting;

  // --- Name & Date methods ---
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

  // --- Weight methods ---
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

  // --- Participants methods ---

  // Loads all persons for the given user from Firestore
  Future<void> loadPersons(String userId) async {
    _isLoadingPersons = true;
    _participantsError = null;
    notifyListeners();

    try {
      _availablePersons = await _personRepository.getPersonsByUser(userId);
    } catch (e) {
      _participantsError = 'Failed to load contacts';
    } finally {
      _isLoadingPersons = false;
      notifyListeners();
    }
  }

  // Returns persons matching the query, excluding already selected ones
  List<Person> searchPersons(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _availablePersons
        .where((p) => !_selectedPersons.contains(p))
        .where((p) => p.fullName.toLowerCase().contains(lower))
        .toList();
  }

  // Adds person to selected list, prevents duplicates
  void selectPerson(Person person) {
    if (_selectedPersons.contains(person)) return;
    _selectedPersons.add(person);
    _participantsError = null;
    notifyListeners();
  }

  // Removes person from selected list
  void removePerson(Person person) {
    _selectedPersons.remove(person);
    notifyListeners();
  }

  // Saves new person to Firestore, then adds to available and selected lists
  Future<void> addNewPerson({
    required String firstName,
    String? lastName,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final person = Person(
      id: '',
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
    );

    final saved = await _personRepository.addPerson(person);
    _availablePersons.add(saved);
    selectPerson(saved);
  }

  // Returns true if participants section is valid
  bool validateParticipants() {
    if (_selectedPersons.isEmpty) {
      _participantsError = 'Add at least one participant';
      notifyListeners();
      return false;
    }
    return true;
  }

  // --- Categories methods ---

  // Loads selectable categories for the user from the global library.
  Future<void> loadCategories(String userId) async {
    try {
      _availableCategories =
          await _categoryRepository.getSelectableCategories(userId);
      notifyListeners();
    } catch (_) {
      // Non-critical: categories enhance but do not block the meeting form.
    }
  }

  // Returns categories matching the query, excluding already selected leaf ones.
  List<ActivityCategory> searchCategories(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _availableCategories
        .where((c) => !_selectedCategories.contains(c))
        .where((c) => c.name.toLowerCase().contains(lower))
        .toList();
  }

  // Returns the parent category name for display, or null if root category.
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

  // Selects a category and propagates ancestor IDs into _selectedCategoryIds.
  // Only the leaf category is added to _selectedCategories (chip display).
  Future<void> addCategory(ActivityCategory category, String userId) async {
    if (_selectedCategories.contains(category)) return;

    final ancestorIds =
        await _categoryRepository.getAncestorIds(category.id, userId);

    // Merge ancestor IDs without duplicates.
    for (final id in ancestorIds) {
      if (!_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.add(id);
      }
    }

    _selectedCategories.add(category);
    notifyListeners();
  }

  // Creates a new root selectable category in the user's subcollection and
  // immediately selects it as a chip. Bypasses getAncestorIds because the
  // newly created category is always a root (parentCategoryId: null).
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
    notifyListeners();
  }

  // Removes a category chip. Only the leaf ID is removed; ancestors may still
  // be needed by other selected categories, so they are left in place.
  void removeCategory(ActivityCategory category) {
    _selectedCategories.remove(category);
    _selectedCategoryIds.remove(category.id);
    notifyListeners();
  }

  // Returns true if at least one category is selected.
  bool validateActivities() {
    if (_selectedCategories.isEmpty) {
      _activitiesError = 'Add at least one activity';
      notifyListeners();
      return false;
    }
    return true;
  }

  // Validates all fields and saves or updates the meeting in Firestore.
  // Returns true on success, false if validation fails or save throws.
  Future<bool> saveMeeting() async {
    final isNameValid = validateName();
    final isParticipantsValid = validateParticipants();
    final isActivitiesValid = validateActivities();

    if (!isNameValid || !isParticipantsValid || !isActivitiesValid) {
      return false;
    }

    final userId = _authService.currentUserId;
    if (userId == null) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      if (isEditMode) {
        // Edit mode — update existing document
        final updated = initialMeeting!.copyWith(
          name: _name,
          date: _date,
          weight: weight,
          participantIds: _selectedPersons.map((p) => p.id).toList(),
          categoryIds: List<String>.from(_selectedCategoryIds),
          updatedAt: now,
        );
        await _meetingRepository.updateMeeting(updated);
        _savedMeeting = updated;
      } else {
        // Create mode — save new document
        final meeting = Meeting(
          id: '',
          userId: userId,
          name: _name,
          date: _date,
          weight: weight,
          participantIds: _selectedPersons.map((p) => p.id).toList(),
          categoryIds: List<String>.from(_selectedCategoryIds),
          createdAt: now,
          updatedAt: now,
        );
        await _meetingRepository.saveMeeting(meeting);
        _savedMeeting = meeting;
      }

      return true;
    } catch (e) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Resets the entire form to initial state
  void reset() {
    _name = '';
    _nameError = null;
    _date = DateTime.now();
    _weightIndex = 2;
    _availablePersons = [];
    _selectedPersons = [];
    _isLoadingPersons = false;
    _participantsError = null;
    _activitiesError = null;
    _availableCategories = [];
    _selectedCategories = [];
    _selectedCategoryIds = [];
    _isSaving = false;
    _savedMeeting = null;
    notifyListeners();
  }

  // Pre-fills form fields from existing meeting data (edit mode only)
  void _initializeFromMeeting(Meeting meeting) {
    _name = meeting.name;
    _date = meeting.date;
    _weightIndex = weightValues.indexOf(meeting.weight);
    // Falls back to default index if weight value not found in list
    if (_weightIndex == -1) _weightIndex = 2;
    _selectedCategoryIds = List<String>.from(meeting.categoryIds);
  }

  // Loads full Person objects for pre-filling edit form
  Future<void> initializeEditData() async {
    if (initialMeeting == null) return;

    _isLoadingPersons = true;
    notifyListeners();

    try {
      _selectedPersons = await _personRepository
          .getPersonsByIds(initialMeeting!.participantIds);

      // Restore selected category chips from saved categoryIds.
      // Only leaf categories (isSelectableAsActivity: true) are shown as chips.
      // Ancestor IDs are kept in _selectedCategoryIds for storage only.
      if (_selectedCategoryIds.isNotEmpty) {
        try {
          final allCategories = await _categoryRepository
              .getSelectableCategories(initialMeeting!.userId);
          _selectedCategories = allCategories
              .where((c) => _selectedCategoryIds.contains(c.id))
              .toList();
        } catch (_) {
          // Non-critical: chips won't show but categoryIds are preserved.
        }
      }
    } catch (e) {
      _participantsError = 'Failed to load meeting data';
    } finally {
      _isLoadingPersons = false;
      notifyListeners();
    }
  }
}
