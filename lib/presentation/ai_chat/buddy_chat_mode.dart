import '../../data/models/person.dart';

/// Chat modes for AIChatScreen. Determines the initial greeting and flow.
enum BuddyChatMode {
  freeQuery, // general chat (existing behaviour)
  meetingNotes, // add notes to a specific meeting (existing behaviour)
  meetingNotesList, // show top-3 meetings without notes as selectable actions
  birthdayList, // show upcoming birthdays as selectable actions
  birthdayWishes, // auto-generate stats + AI wish for a specific person
  lapsedFriendsList, // top-3 lapsed friends as selectable action buttons
  lapsedFriendDetail, // Buddy recalls last meetings + activities for one lapsed friend
  greeting, // home entry point: shows all applicable action buttons
}

/// A selectable action rendered as a button in the chat UI.
class BuddyAction {
  const BuddyAction({required this.label, required this.actionId});

  /// Text shown on the button.
  final String label;

  /// Structured identifier consumed by [AIChatProvider.handleAction].
  /// Format: 'birthday_list_select:personId'
  ///         'meeting_notes:meetingId'
  ///         'lapsed_select:personId:daysSinceLastMeeting'
  ///         'greeting_meetings' | 'greeting_birthday' | 'greeting_ltns'
  final String actionId;
}

/// Birthday info passed from [BuddyWidgetProvider] into [AIChatProvider].
class BirthdayPersonInfo {
  const BirthdayPersonInfo({required this.person, required this.daysUntil});

  final Person person;

  /// Days until the next occurrence of this person's birthday (0 = today).
  final int daysUntil;
}

/// LTNS info passed from [BuddyWidgetProvider] into [AIChatProvider].
class LapsedPersonInfo {
  const LapsedPersonInfo({
    required this.person,
    required this.daysSinceLastMeeting,
  });

  final Person person;

  /// Days since the last recorded meeting with this person.
  final int daysSinceLastMeeting;
}
