import 'package:flutter/foundation.dart';

import '../../data/models/person.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/sharing_token_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/relationship_score_service.dart';

// PersonDetailProvider manages state for PersonDetailScreen.
// Responsibilities: hold person data, fetch meeting count, update, delete, link account.
class PersonDetailProvider extends ChangeNotifier {
  final PersonRepository _personRepository;
  final MeetingRepository _meetingRepository;
  final AuthService _authService;
  final SharingTokenRepository _sharingTokenRepository;
  final RelationshipScoreService _relationshipScoreService;

  PersonDetailProvider({
    required PersonRepository personRepository,
    required MeetingRepository meetingRepository,
    required AuthService authService,
    SharingTokenRepository? sharingTokenRepository,
    RelationshipScoreService? relationshipScoreService,
  })  : _personRepository = personRepository,
        _meetingRepository = meetingRepository,
        _authService = authService,
        _sharingTokenRepository =
            sharingTokenRepository ?? SharingTokenRepository(),
        _relationshipScoreService =
            relationshipScoreService ?? RelationshipScoreService();

  Person? _person;
  int _meetingCount = 0;
  RelationshipScore? _score;
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isLinking = false;
  String? _errorMessage;

  Person? get person => _person;
  int get meetingCount => _meetingCount;
  RelationshipScore? get score => _score;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  bool get isLinking => _isLinking;
  String? get errorMessage => _errorMessage;

  // Stores the person, fetches the meeting count, and computes the relationship score.
  Future<void> initialize(Person person) async {
    _person = person;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      _meetingCount =
          await _meetingRepository.getMeetingsCountForPerson(userId, person.id);
      _score = await _relationshipScoreService.computeScore(userId, person.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Silently re-fetches meeting count without setting isLoading.
  // Used to sync the count after returning from PersonMeetingsScreen.
  Future<void> refreshMeetingCount() async {
    final person = _person;
    final userId = _authService.currentUserId;
    if (person == null || userId == null) return;
    try {
      _meetingCount =
          await _meetingRepository.getMeetingsCountForPerson(userId, person.id);
      notifyListeners();
    } catch (_) {
      // Silently ignore — stale count is preferable to an error state.
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

  // Adds a nickname to the person. Silently ignores empty or duplicate values.
  Future<void> addNickname(String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return;
    if (_person!.nicknames.contains(trimmed)) return;
    final updated = _person!.copyWith(
      nicknames: [..._person!.nicknames, trimmed],
    );
    await _personRepository.updatePerson(updated);
    _person = updated;
    notifyListeners();
  }

  // Updates birthDayMonth ("MM-dd" format) for the current person.
  // Passing null clears the birthday.
  Future<void> updateBirthDayMonth(String? value) async {
    final updated = _person!.copyWith(birthDayMonth: value);
    await _personRepository.updatePerson(updated);
    _person = updated;
    notifyListeners();
  }

  // Removes a nickname from the person.
  Future<void> removeNickname(String nickname) async {
    final updated = _person!.copyWith(
      nicknames: _person!.nicknames.where((n) => n != nickname).toList(),
    );
    await _personRepository.updatePerson(updated);
    _person = updated;
    notifyListeners();
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

  // Validates a sharing token and links the friend's account to this Person.
  // On success: saves linkedUserId to Firestore and marks the token as used.
  // Returns TokenValidationResult so the screen can show the correct error message.
  Future<TokenValidationResult> linkFriendAccount(String tokenValue) async {
    _isLinking = true;
    notifyListeners();

    try {
      final result = await _sharingTokenRepository
          .validateAndClaimToken(tokenValue.trim().toUpperCase());
      if (!result.isSuccess) return result;

      final updated = _person!.copyWith(linkedUserId: result.ownerUid);
      await _personRepository.updatePerson(updated);

      // Mark as used only after Person is successfully saved
      await _sharingTokenRepository.markAsUsed(
          result.ownerUid!, result.tokenId!);

      _person = updated;
      notifyListeners();
      return result;
    } catch (_) {
      return const TokenValidationResult.failure(
          TokenValidationError.serverError);
    } finally {
      _isLinking = false;
      notifyListeners();
    }
  }
}
