import 'package:flutter/foundation.dart';

import '../../data/models/meeting.dart';
import '../../data/models/pending_meeting_package.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/meeting_package_service.dart';

/// Manages state for ShareMeetingsScreen.
/// Loads meetings where the target person (C) participated,
/// tracks selection and send options, and executes the package send.
class ShareMeetingsProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;
  final PersonRepository _personRepository;
  final ActivityCategoryRepository _categoryRepository;
  final AuthService _authService;
  final MeetingPackageService _meetingPackageService;

  /// C's person doc ID — used to filter meetings and exclude C from participants.
  final String targetPersonId;

  /// C's Firestore uid — destination for the package write.
  final String recipientUid;

  ShareMeetingsProvider({
    required MeetingRepository meetingRepository,
    required PersonRepository personRepository,
    required ActivityCategoryRepository categoryRepository,
    required AuthService authService,
    required MeetingPackageService meetingPackageService,
    required this.targetPersonId,
    required this.recipientUid,
  })  : _meetingRepository = meetingRepository,
        _personRepository = personRepository,
        _categoryRepository = categoryRepository,
        _authService = authService,
        _meetingPackageService = meetingPackageService;

  List<Meeting> _meetings = [];
  Map<String, Person> _personsById = {};
  Map<String, String> _categoryNamesById = {};
  Set<String> _selectedMeetingIds = {};
  bool _includePersons = false;
  bool _includeActivities = false;
  String _senderFirstName = '';
  String _senderLastName = '';
  String _senderNickname = '';
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  List<Meeting> get meetings => _meetings;
  Set<String> get selectedMeetingIds => _selectedMeetingIds;
  bool get includePersons => _includePersons;
  bool get includeActivities => _includeActivities;
  String get senderFirstName => _senderFirstName;
  String get senderLastName => _senderLastName;
  String get senderNickname => _senderNickname;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  bool get isAllSelected =>
      _meetings.isNotEmpty &&
      _meetings.every((m) => _selectedMeetingIds.contains(m.id));

  /// At least one meeting selected and sender first name provided.
  bool get canSend =>
      _selectedMeetingIds.isNotEmpty && _senderFirstName.trim().isNotEmpty;

  /// Loads meetings, persons, and categories; pre-selects all meetings.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;

      final meetings = await _meetingRepository.getMeetingsByParticipant(
          userId, targetPersonId);
      final persons = await _personRepository.getPersonsByUser(userId);
      final categories = await _categoryRepository.getCategories(userId).first;

      _meetings = meetings;
      _personsById = {for (final p in persons) p.id: p};
      _categoryNamesById = {
        for (final c in categories) c.id: c.name,
      };

      // Select all meetings by default.
      _selectedMeetingIds = _meetings.map((m) => m.id).toSet();

      // Pre-fill sender name from Google account display name if available.
      final displayName = _authService.userDisplayName;
      if (displayName != null && displayName.trim().isNotEmpty) {
        final parts = displayName.trim().split(' ');
        _senderFirstName = parts[0];
        _senderLastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleAll() {
    if (isAllSelected) {
      _selectedMeetingIds = {};
    } else {
      _selectedMeetingIds = _meetings.map((m) => m.id).toSet();
    }
    notifyListeners();
  }

  void toggleMeeting(String id) {
    final updated = Set<String>.from(_selectedMeetingIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    _selectedMeetingIds = updated;
    notifyListeners();
  }

  void setIncludePersons(bool v) {
    _includePersons = v;
    notifyListeners();
  }

  void setIncludeActivities(bool v) {
    _includeActivities = v;
    notifyListeners();
  }

  void setSenderFirstName(String v) {
    _senderFirstName = v;
    notifyListeners();
  }

  void setSenderLastName(String v) {
    _senderLastName = v;
    notifyListeners();
  }

  void setSenderNickname(String v) {
    _senderNickname = v;
    notifyListeners();
  }

  /// Builds the package from current state and writes it to the recipient's
  /// pending_meetings subcollection. Returns true on success, false on error.
  Future<bool> sendPackage() async {
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final selected =
          _meetings.where((m) => _selectedMeetingIds.contains(m.id)).toList();

      final sharedMeetings = selected.map((meeting) {
        final participants = _includePersons
            ? meeting.participantIds
                .where((id) => id != targetPersonId)
                .map((id) {
                  final person = _personsById[id];
                  if (person == null) return null;
                  return SharedPerson(
                    firstName: person.firstName,
                    lastName: person.lastName,
                  );
                })
                .whereType<SharedPerson>()
                .toList()
            : <SharedPerson>[];

        final categoryNames = _includeActivities
            ? meeting.categoryIds
                .map((id) => _categoryNamesById[id])
                .whereType<String>()
                .toList()
            : <String>[];

        return SharedMeeting(
          name: meeting.name,
          date: meeting.date,
          weight: meeting.weight,
          participants: participants,
          categoryNames: categoryNames,
        );
      }).toList();

      final package = PendingMeetingPackage(
        id: '',
        senderUid: _authService.currentUserId!,
        senderFirstName: _senderFirstName.trim(),
        senderLastName: _senderLastName.trim(),
        senderNickname:
            _senderNickname.trim().isEmpty ? null : _senderNickname.trim(),
        sentAt: DateTime.now(),
        meetings: sharedMeetings,
      );

      await _meetingPackageService.sendPackage(package, recipientUid);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
