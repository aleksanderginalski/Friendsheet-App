import 'package:flutter/foundation.dart';

import '../../data/models/person.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';

// PersonDetailProvider manages state for PersonDetailScreen.
// Responsibilities: hold person data, fetch meeting count, update, delete.
class PersonDetailProvider extends ChangeNotifier {
  final PersonRepository _personRepository;
  final MeetingRepository _meetingRepository;
  final AuthService _authService;

  PersonDetailProvider({
    required PersonRepository personRepository,
    required MeetingRepository meetingRepository,
    required AuthService authService,
  })  : _personRepository = personRepository,
        _meetingRepository = meetingRepository,
        _authService = authService;

  Person? _person;
  int _meetingCount = 0;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;

  Person? get person => _person;
  int get meetingCount => _meetingCount;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  // Stores the person and fetches the meeting count for them.
  Future<void> initialize(Person person) async {
    _person = person;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      _meetingCount =
          await _meetingRepository.getMeetingsCountForPerson(userId, person.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validates input, updates person in repository, and refreshes local state.
  // Returns false if firstName is empty or if the repository call fails.
  Future<bool> updatePerson(String firstName, String lastName) async {
    if (firstName.trim().isEmpty) {
      _errorMessage = 'First name must not be empty.';
      notifyListeners();
      return false;
    }

    try {
      final updated = _person!.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim().isEmpty ? null : lastName.trim(),
      );
      await _personRepository.updatePerson(updated);
      _person = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Deletes the person and removes them from all associated meetings.
  // Returns false and resets _isDeleting if the repository call fails.
  Future<bool> deletePerson() async {
    _isDeleting = true;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      // deletePerson also removes the person from all meetings via batch update
      await _personRepository.deletePerson(userId, _person!.id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }
}
