// lib/presentation/providers/add_meeting_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';

class AddMeetingProvider extends ChangeNotifier {
  final PersonRepository _personRepository;

  AddMeetingProvider({PersonRepository? personRepository})
      : _personRepository = personRepository ?? PersonRepository();

  // --- Existing fields ---
  String _name = '';
  String? _nameError;
  DateTime _date = DateTime.now();

  static const List<int> weightValues = [1, 2, 3, 5, 8, 13, 21];
  int _weightIndex = 2;

  // --- Participants state ---
  List<Person> _availablePersons = [];
  final List<Person> _selectedPersons = [];
  bool _isLoadingPersons = false;
  String? _participantsError;

  // --- Existing getters ---
  String get name => _name;
  String? get nameError => _nameError;
  DateTime get date => _date;
  int get weight => weightValues[_weightIndex];
  bool get canDecrement => _weightIndex > 0;
  bool get canIncrement => _weightIndex < weightValues.length - 1;

  // --- Participants getters ---
  List<Person> get availablePersons => List.unmodifiable(_availablePersons);
  List<Person> get selectedPersons => List.unmodifiable(_selectedPersons);
  bool get isLoadingPersons => _isLoadingPersons;
  String? get participantsError => _participantsError;

  // --- Existing methods ---
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
    notifyListeners();
  }
}
