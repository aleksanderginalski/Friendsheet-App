import 'package:flutter/foundation.dart';

import '../../data/models/meeting.dart';
import '../../data/models/person.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../ai_chat/buddy_chat_mode.dart';

/// Manages state for the HomeScreen Buddy widget.
///
/// Fetches the top-3 most recently dated meetings without notes (last 60 days)
/// and detects upcoming birthdays for all persons with [Person.birthDayMonth] set.
/// Exposes expand/collapse state for the widget card.
class BuddyWidgetProvider extends ChangeNotifier {
  final MeetingRepository _meetingRepository;
  final PersonRepository _personRepository;

  BuddyWidgetProvider({
    MeetingRepository? meetingRepository,
    PersonRepository? personRepository,
  })  : _meetingRepository = meetingRepository ?? MeetingRepository(),
        _personRepository = personRepository ?? PersonRepository();

  List<Meeting> _suggestedMeetings = [];
  List<Person> _urgentBirthdayPersons = [];
  Map<String, int> _daysUntilBirthday = {};
  List<BirthdayPersonInfo> _upcomingBirthdayInfo = [];
  bool _isExpanded = true;
  bool _isInitialized = false;

  /// Top-3 most recent meetings without notes in the last 60 days.
  List<Meeting> get suggestedMeetings => _suggestedMeetings;

  /// Persons whose birthday falls within the next 5 days (urgent threshold).
  List<Person> get urgentBirthdayPersons => _urgentBirthdayPersons;

  /// Maps personId to days until their next birthday.
  Map<String, int> get daysUntilBirthday => _daysUntilBirthday;

  /// All persons with [Person.birthDayMonth] set, sorted by days until birthday.
  List<BirthdayPersonInfo> get upcomingBirthdayInfo => _upcomingBirthdayInfo;

  /// True when the widget card is expanded (visible). Collapsed = only icon shown.
  bool get isExpanded => _isExpanded;

  /// True after the first fetch has completed.
  bool get isInitialized => _isInitialized;

  /// Fetches suggested meetings and detects upcoming birthdays for [userId].
  Future<void> initialize(String userId) async {
    // Load top-3 meetings without notes in the last 60 days.
    final since60 = DateTime.now().subtract(const Duration(days: 60));
    _suggestedMeetings = await _meetingRepository
        .getRecentMeetingsWithoutNotes(userId, since60, limit: 3);

    // Detect upcoming birthdays for all persons with birthDayMonth set.
    final persons = await _personRepository.getPersonsByUser(userId);
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final birthdayInfoList = <BirthdayPersonInfo>[];

    for (final person in persons) {
      if (person.birthDayMonth == null) continue;
      final parts = person.birthDayMonth!.split('-');
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      // Start with this year's date; advance to next year if already passed.
      var next = DateTime(today.year, month, day);
      if (!next.isAfter(today.subtract(const Duration(days: 1)))) {
        next = DateTime(today.year + 1, month, day);
      }
      final days = next.difference(today).inDays;
      birthdayInfoList.add(BirthdayPersonInfo(person: person, daysUntil: days));
    }

    birthdayInfoList.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    _upcomingBirthdayInfo = birthdayInfoList;
    _daysUntilBirthday = {
      for (final b in birthdayInfoList) b.person.id: b.daysUntil,
    };
    // Urgent = birthday within the next 5 days (exclusive).
    _urgentBirthdayPersons = birthdayInfoList
        .where((b) => b.daysUntil < 5)
        .map((b) => b.person)
        .toList();

    _isInitialized = true;
    notifyListeners();
  }

  /// Collapses the widget card; Buddy icon remains visible.
  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }

  /// Re-expands the widget card.
  void expand() {
    _isExpanded = true;
    notifyListeners();
  }
}
