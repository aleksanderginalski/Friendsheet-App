// lib/presentation/providers/add_meeting_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/activity.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/person_repository.dart';

class AddMeetingProvider extends ChangeNotifier {
  final PersonRepository _personRepository;
  final ActivityRepository _activityRepository;

  AddMeetingProvider({
    PersonRepository? personRepository,
    ActivityRepository? activityRepository,
  })  : _personRepository = personRepository ?? PersonRepository(),
        _activityRepository = activityRepository ?? ActivityRepository();

  // --- Name & Date ---
  String _name = '';
  String? _nameError;
  DateTime _date = DateTime.now();

  // --- Weight ---
  static const List<int> weightValues = [1, 2, 3, 5, 8, 13, 21];
  int _weightIndex = 2;

  // --- Participants state ---
  List<Person> _availablePersons = [];
  final List<Person> _selectedPersons = [];
  bool _isLoadingPersons = false;
  String? _participantsError;

  // --- Activities state ---
  List<Activity> _availableActivities = [];
  final List<Activity> _selectedActivities = [];
  bool _isLoadingActivities = false;
  String? _activitiesError;

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

  // --- Activities getters ---
  List<Activity> get availableActivities =>
      List.unmodifiable(_availableActivities);
  List<Activity> get selectedActivities =>
      List.unmodifiable(_selectedActivities);
  bool get isLoadingActivities => _isLoadingActivities;
  String? get activitiesError => _activitiesError;

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

  // Adds newly created person to both available and selected lists
  void addNewPerson(Person person) {
    _availablePersons.add(person);
    selectPerson(person);
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

  // --- Activities methods ---

  // Loads global and user-private activities from Firestore
  Future<void> loadActivities(String userId) async {
    _isLoadingActivities = true;
    _activitiesError = null;
    notifyListeners();

    try {
      _availableActivities =
          await _activityRepository.getActivitiesByUser(userId);
    } catch (e) {
      _activitiesError = 'Failed to load activities';
    } finally {
      _isLoadingActivities = false;
      notifyListeners();
    }
  }

  // Returns activities matching the query, excluding already selected ones
  List<Activity> searchActivities(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _availableActivities
        .where((a) => a.name.toLowerCase().contains(lower))
        .where((a) => !_selectedActivities.contains(a))
        .toList();
  }

  // Adds activity to selected list, prevents duplicates
  void selectActivity(Activity activity) {
    if (_selectedActivities.contains(activity)) return;
    _selectedActivities.add(activity);
    _activitiesError = null;
    notifyListeners();
  }

  // Removes activity from selected list
  void removeActivity(Activity activity) {
    _selectedActivities.remove(activity);
    notifyListeners();
  }

  // Adds newly created activity to both available and selected lists
  void addNewActivity(Activity activity) {
    _availableActivities.add(activity);
    selectActivity(activity);
  }

  // Returns true if activities section is valid
  bool validateActivities() {
    if (_selectedActivities.isEmpty) {
      _activitiesError = 'Add at least one activity';
      notifyListeners();
      return false;
    }
    return true;
  }

  // Resets the entire form to initial state
  void reset() {
    _name = '';
    _nameError = null;
    _date = DateTime.now();
    _weightIndex = 2;
    _availablePersons = [];
    _selectedPersons.clear();
    _isLoadingPersons = false;
    _participantsError = null;
    _availableActivities = [];
    _selectedActivities.clear();
    _isLoadingActivities = false;
    _activitiesError = null;
    notifyListeners();
  }
}
