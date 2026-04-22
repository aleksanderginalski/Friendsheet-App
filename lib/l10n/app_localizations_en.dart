// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Track Your Social Life';

  @override
  String get loginSignInButton => 'Sign in with Google';

  @override
  String get loginTagline => 'One tap to get started!';

  @override
  String get loginTermsPrefix => 'By signing in you agree to our ';

  @override
  String get loginTermsLink => 'Terms of Service';

  @override
  String get loginTermsMiddle => ' and ';

  @override
  String get loginPrivacyLink => 'Privacy Policy';

  @override
  String loginSignInError(String error) {
    return 'Failed to sign in: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsCalendarSection => 'GOOGLE CALENDAR';

  @override
  String get settingsCalendarNotConnected => 'Not connected';

  @override
  String get settingsCalendarConnect => 'Connect';

  @override
  String get settingsCalendarDisconnectTitle => 'Disconnect Calendar';

  @override
  String get settingsCalendarDisconnectContent =>
      'Are you sure you want to disconnect Google Calendar?';

  @override
  String get settingsCalendarDisconnect => 'DISCONNECT';

  @override
  String get settingsAppLanguage => 'App Language';

  @override
  String get settingsExportData => 'Export Data';

  @override
  String get settingsExportSubtitle => 'Save all data as JSON to device';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Permanently delete your account and data';

  @override
  String get settingsDeleteAccountTitle => 'Delete Account?';

  @override
  String get settingsDeleteAccountContent =>
      'This will permanently delete your account and all your data. This action cannot be undone.';

  @override
  String get settingsDeleteAccountConfirm => 'DELETE';

  @override
  String get settingsDeleteAccountSuccess => 'Account deleted.';

  @override
  String settingsDeleteAccountError(String error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get mainImportShare => 'Import & Share';

  @override
  String get mainShareMeetings => 'Share meetings with a friend';

  @override
  String get mainBrowseImport => 'Browse & Import Events';

  @override
  String get mainImportFromCalendar => 'Import from Calendar';

  @override
  String get mainBuddy => 'Buddy';

  @override
  String get mainFriendsQuest => 'Friends-Quest';

  @override
  String mainPendingMeetings(int count) {
    return 'Pending Meetings ($count)';
  }

  @override
  String get mainSettingsTitle => 'Settings';

  @override
  String get mainLogOut => 'Log Out';

  @override
  String get mainLogOutTitle => 'Log Out?';

  @override
  String get mainLogOutContent =>
      'Are you sure you want to log out?\n\nYou\'ll need to sign in again to access your meetings.';

  @override
  String get mainLogOutConfirm => 'LOG OUT';

  @override
  String mainLogOutError(String error) {
    return 'Failed to log out: $error';
  }

  @override
  String get mainCalendarOfflineMessage =>
      'Google Calendar requires an internet connection';

  @override
  String get mainCalendarAuthExpired =>
      'Calendar access expired — please reconnect';

  @override
  String get mainCalendarLoadError =>
      'Could not load calendars. Check your connection.';

  @override
  String get mainNavHome => 'Home';

  @override
  String get mainNavMeetings => 'Meetings';

  @override
  String get mainNavFriends => 'Friends';

  @override
  String get mainNavActivities => 'Activities';

  @override
  String get homeOfflineMessage => 'Buddy requires an internet connection';

  @override
  String get homeCalendarAccessDenied => 'Calendar access denied';

  @override
  String get meetingsListTitle => 'My Meetings';

  @override
  String get meetingsListSyncing => 'Syncing...';

  @override
  String get meetingsListSearchHint => 'Search meetings...';

  @override
  String get meetingsListSearchClose => 'Close search';

  @override
  String get meetingsListSearch => 'Search';

  @override
  String get meetingsListEmpty =>
      'No meetings yet — tap + to add your first one!';

  @override
  String meetingsListNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String meetingsListMeetingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meetings',
      one: '1 meeting',
    );
    return '$_temp0';
  }

  @override
  String get addMeetingTitleEdit => 'Edit Meeting';

  @override
  String get addMeetingTitleAdd => 'Add Meeting';

  @override
  String get addMeetingWeightSection => 'Meeting Weight *';

  @override
  String get addMeetingParticipantsSection => 'Participants * (min. 1)';

  @override
  String get addMeetingActivitiesSection => 'Activities * (min. 1)';

  @override
  String get addMeetingSaveChanges => 'SAVE CHANGES';

  @override
  String get addMeetingSave => 'SAVE MEETING';

  @override
  String get addMeetingSaved => 'Meeting saved!';

  @override
  String get addMeetingSaveError => 'Failed to save meeting...';

  @override
  String get personsListTitle => 'MY PEOPLE';

  @override
  String get personsListAddPerson => 'Add Person';

  @override
  String get personsListAddGroup => 'Add Group';

  @override
  String get personsListEditGroup => 'Edit group';

  @override
  String get personsListDeleteGroup => 'Delete group';

  @override
  String get personsListDeleteGroupTitle => 'Delete group?';

  @override
  String personsListDeleteGroupContent(String name) {
    return 'Delete \"$name\"?\nPersons will not be deleted.';
  }

  @override
  String get personsListDeleteGroupContentSimple =>
      'Are you sure you want to delete this group?';

  @override
  String get personsListSearchHint => 'Search friends...';

  @override
  String get personsListSearchClose => 'Close search';

  @override
  String get personsListSearch => 'Search';

  @override
  String get personsListAdd => 'Add';

  @override
  String personsListNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get personsListDeleteGroupConfirm => 'DELETE';

  @override
  String get personsListPersonAdded => 'Person added';

  @override
  String get personsListEmpty =>
      'No friends yet — tap + to add your first one!';

  @override
  String get personsListGroupEmpty => 'No friends in this group.';

  @override
  String get personsListAlreadyInGroup =>
      'All friends are already in this group';

  @override
  String get calendarPermissionTitle => 'Calendar Import';

  @override
  String get calendarPermissionHeading => 'Connect Google Calendar';

  @override
  String get calendarPermissionDescription =>
      'Friendsheet can import your Google Calendar events as meeting suggestions. You choose which events to import.';

  @override
  String get calendarPermissionConnectButton => 'Connect Google Calendar';

  @override
  String get calendarPermissionNotNow => 'Not now';

  @override
  String get calendarPermissionError => 'An unexpected error occurred';

  @override
  String get calendarEventsTitle => 'Select Events';

  @override
  String calendarEventsImport(int count) {
    return 'Import ($count)';
  }

  @override
  String get calendarEventsFilters => 'Filters';

  @override
  String get calendarEventsFrom => 'From:';

  @override
  String get calendarEventsTo => 'To:';

  @override
  String get calendarEventsPrimary => 'Primary';

  @override
  String get calendarEventsExcludeAllDay => 'Exclude all-day events';

  @override
  String get calendarEventsApplyFilters => 'Apply Filters';

  @override
  String get calendarEventsSelectAll => 'Select All';

  @override
  String get calendarEventsDeselectAll => 'Deselect All';

  @override
  String get calendarEventsEmpty => 'No events found';

  @override
  String get calendarEventsReconnectPrompt =>
      'Calendar disconnected. Reconnect to import events.';

  @override
  String get calendarEventsRetry => 'Retry';

  @override
  String get calendarEventsReconnect => 'Reconnect';

  @override
  String get aiSettingsTitle => 'AI Assistant';

  @override
  String get aiSettingsDeleteKeyTitle => 'Delete API Key?';

  @override
  String get aiSettingsDeleteKeyContent =>
      'Your OpenAI API key will be removed from this device.';

  @override
  String get aiSettingsDeleteKeyConfirm => 'DELETE';

  @override
  String get aiSettingsApiKeyLabel => 'API Key';

  @override
  String get aiSettingsApiKeyHint => 'sk-...';

  @override
  String get aiSettingsSave => 'Save';

  @override
  String get aiSettingsDeleteKey => 'Delete Key';

  @override
  String get aiSettingsApiKeySection => 'API Key';

  @override
  String get aiConsentTitle => 'AI Assistant — Privacy';

  @override
  String get aiConsentAlwaysSent => 'Always sent to OpenAI';

  @override
  String get aiConsentSentWhenAsked => 'Sent only when you explicitly ask';

  @override
  String get aiConsentNeverSent => 'Never sent to OpenAI';

  @override
  String get aiConsentPrivacyPolicy => 'Read full Privacy Policy';

  @override
  String get aiConsentAgree => 'I understand and agree';

  @override
  String get buddyMenuTitle => 'AI Assistant';

  @override
  String get buddyMenuChatSubtitle => 'Chat with your AI social assistant';

  @override
  String get buddyMenuApiKey => 'API Key';

  @override
  String get buddyMenuApiKeySubtitle => 'Manage your OpenAI API key';

  @override
  String get buddyMenuLtnsFilters => 'LTNS Filters';

  @override
  String get buddyMenuLtnsFiltersSubtitle =>
      'Choose who appears in Long Time No See';

  @override
  String get ltnsFilterTitle => 'LTNS Filters';

  @override
  String get ltnsFilterDescription =>
      'Choose who appears in the Long Time No See section on your home screen.';

  @override
  String get ltnsFilterSearchHint => 'Search by name or nickname…';

  @override
  String get meetingDetailTitle => 'Meeting Detail';

  @override
  String get meetingDetailNoParticipantsWarning =>
      'This meeting has no participants. Tap edit to add someone.';

  @override
  String get meetingDetailNoParticipants =>
      'This meeting has no participants...';

  @override
  String get meetingDetailParticipants => 'Participants';

  @override
  String get meetingDetailActivities => 'Activities';

  @override
  String get meetingDetailNoParticipantsLabel => 'No participants.';

  @override
  String get meetingDetailNoActivities => 'No activities.';

  @override
  String get meetingDetailEditButton => 'Edit Meeting';

  @override
  String get meetingDetailDeleteTitle => 'Delete Meeting';

  @override
  String get meetingDetailDeleteContent =>
      'Are you sure you want to delete this meeting? This action cannot be undone.';

  @override
  String get meetingDetailDeleteCancel => 'Cancel';

  @override
  String get meetingDetailDeleteConfirm => 'Delete';

  @override
  String get meetingDetailDeleteError =>
      'Failed to delete meeting. Please try again.';

  @override
  String get activitiesListTitle => 'Activities';

  @override
  String get activitiesListEmpty =>
      'No activities yet — tap + to create your first category!';

  @override
  String get activitiesListNoResults => 'No activities found';

  @override
  String get activitiesListAddTooltip => 'Add activity category';

  @override
  String get activitiesListAddChildTooltip => 'Add child activity';

  @override
  String get activitiesListSearchHint => 'Search activities...';

  @override
  String get activitiesListSearchClose => 'Close search';

  @override
  String get activitiesListSearch => 'Search';

  @override
  String get activitiesListRetry => 'Retry';

  @override
  String activitiesListMergeContent(String source, String target) {
    return 'Merge \"$source\" into \"$target\"?\n\nAll meetings will be updated. \"$source\" will be deleted.';
  }

  @override
  String get activitiesListMergeTitle => 'Merge categories?';

  @override
  String activitiesListMergedSuccess(String source, String target) {
    return 'Merged \"$source\" into \"$target\"';
  }

  @override
  String get activitiesListDeleteTitle => 'Delete Activity?';

  @override
  String activitiesListDeleteContent(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String activitiesListDeleteError(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String get activitiesListMergeConfirm => 'MERGE';

  @override
  String activitiesListMergeError(String error) {
    return 'Merge failed: $error';
  }

  @override
  String get activitiesListEdit => 'Edit';

  @override
  String get activitiesListDelete => 'Delete';

  @override
  String get activitiesListMergeInto => 'Merge into…';

  @override
  String get meetingInboxTitle => 'Pending Meetings';

  @override
  String get meetingInboxDeletePackageTitle => 'Delete package?';

  @override
  String get meetingInboxDeletePackageContent =>
      'Are you sure you want to delete this package? It cannot be recovered.';

  @override
  String get meetingInboxEmptyTitle => 'No pending meetings';

  @override
  String get meetingInboxEmptySubtitle =>
      'Import events from your calendar or receive shared meetings from a friend to get started.';

  @override
  String meetingInboxProgress(int reviewed, int total) {
    return '$reviewed of $total reviewed';
  }

  @override
  String get meetingInboxSharedByFriends => 'Shared by friends';

  @override
  String meetingInboxConflictCount(int count) {
    return '⚠️ $count conflict(s)';
  }

  @override
  String get offlineBannerMessage => 'No internet connection';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get activityBreakdownTitle => 'Activity Breakdown';

  @override
  String get whoPerActivityTitle => 'Who Per Activity';

  @override
  String get interactionDistributionTitle => 'Interaction Distribution';

  @override
  String get friendsQuestSummaryTitle => 'Friends-Quest';

  @override
  String get sharingCtaTitle => 'Save Your Memories';

  @override
  String get sharingCtaSubtitle => 'Share your meetings with a friend';

  @override
  String get sharingCtaCardTitle => 'Request meetings from a friend';

  @override
  String get sharingCtaCardSubtitle =>
      'Have a friend who uses Friendsheet? Ask them to share your meetings.';

  @override
  String get sharingCtaCardButton => 'Generate token';

  @override
  String get buildMeetingBaseCtaTitle => 'Build your meeting base';

  @override
  String get buildMeetingBaseCtaSubtitle =>
      'Add your first meeting to see statistics';

  @override
  String get buildMeetingBaseCardSubtitle =>
      'You have fewer than 50 meetings. Import from Google Calendar or ask a friend to share your meetings.';

  @override
  String get buildMeetingBaseCardRequest => 'Request from a friend';

  @override
  String get onboardingCalendarCtaTitle => 'Import from Calendar';

  @override
  String get onboardingCalendarCtaSubtitle =>
      'Connect Google Calendar to import events';

  @override
  String get onboardingCalendarCardTitle => 'Import your past meetings';

  @override
  String get onboardingCalendarCardSubtitle =>
      'You have fewer than 50 meetings. Import from Google Calendar to get started faster.';

  @override
  String get activitySelectorDialogTitle => 'Select Activities';

  @override
  String get activityVisibilityDialogTitle => 'Show / Hide Activities';

  @override
  String get statisticsVisibilityDialogTitle => 'Show / Hide Statistics';

  @override
  String get personVisibilityDialogTitle => 'Show / Hide Friends';

  @override
  String get whoPerActivityPersonFilterDialogTitle => 'Filter by Person';

  @override
  String get noVisibleActivities => 'No visible activities';

  @override
  String get noVisiblePersons => 'No visible persons';

  @override
  String activitiesHiddenCount(int count) {
    return '$count activities hidden';
  }

  @override
  String personsHiddenCount(int count) {
    return '$count persons hidden';
  }

  @override
  String get statisticsAllHidden => 'All statistics hidden';

  @override
  String get statisticsRestoreAll => 'Restore all';

  @override
  String get statisticsNoMeetings => 'No meetings found';

  @override
  String get statisticsMinOneCard => 'At least one card must remain visible';

  @override
  String get visibilityAutoSelectTop10 => 'Auto-select top 10';

  @override
  String get visibilityMinOnePerson =>
      'At least one person must remain visible';

  @override
  String get visibilitySelectAll => 'Select all';

  @override
  String get visibilityDeselectAll => 'Deselect all';

  @override
  String get interactionDistributionInfo =>
      'A meeting with multiple people counts toward each person\'s total. This means percentages across all persons can exceed 100%.';

  @override
  String get interactionCumulative => 'Cumulative';

  @override
  String get interactionYearly => 'Yearly';

  @override
  String get whoSelectActivity =>
      'Select an activity above to see the ranking.';

  @override
  String get whoNoData => 'No data for this activity.';

  @override
  String get meetingCardNoParticipants => 'No participants';

  @override
  String meetingCardPeople(int count) {
    return '$count people';
  }

  @override
  String get friendsQuestViewAll => 'View all →';

  @override
  String friendsQuestActiveQuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active quests',
      one: '1 active quest',
    );
    return '$_temp0';
  }

  @override
  String get statDeltaNew => 'NEW';

  @override
  String get dialogCancel => 'CANCEL';

  @override
  String get dialogClose => 'CLOSE';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogSave => 'SAVE';

  @override
  String get dialogCreate => 'CREATE';

  @override
  String get dialogAdd => 'ADD';

  @override
  String get dialogDelete => 'DELETE';

  @override
  String get aiChatGoToSettings => 'Go to Settings';

  @override
  String get aiChatDismiss => 'Dismiss';

  @override
  String get aiChatRetry => 'Retry';

  @override
  String get personDialogTitle => 'Add New Person';

  @override
  String get personDialogFirstName => 'First name *';

  @override
  String get personDialogLastName => 'Last name (optional)';

  @override
  String get personDialogNickname => 'Nickname (required to distinguish)';

  @override
  String get questScreenTitle => 'Friends-Quests';

  @override
  String get questNewQuestTitle => 'New Quest';

  @override
  String get questNameLabel => 'Quest name';

  @override
  String get questNameHint => 'e.g. Weekend with the crew';

  @override
  String get questParticipantsLabel => 'Participants';

  @override
  String get questNoContacts => 'No contacts yet.';

  @override
  String get questSearchParticipants => 'Search participants...';

  @override
  String get questNoMatches => 'No matches.';

  @override
  String get questEditTaskTitle => 'Edit task';

  @override
  String get questTaskText => 'Task text';

  @override
  String get questCompleteTitle => 'Complete Quest';

  @override
  String get questCompleteContent =>
      'This quest is not linked to a meeting. Complete without saving notes, or select a meeting first?';

  @override
  String get questWithoutNotes => 'WITHOUT NOTES';

  @override
  String get questSelectMeeting => 'SELECT MEETING';

  @override
  String get questLinkToMeeting => 'Link to meeting';

  @override
  String get questTapToChange => 'Tap to change';

  @override
  String get questMeetingLinked => 'Meeting linked';

  @override
  String get questNoTasks => 'No tasks yet. Add one with the + button.';

  @override
  String get questDeleteTitle => 'Delete Quest';

  @override
  String questDeleteContent(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get questNewTaskTitle => 'New task';

  @override
  String get questAssignTo => 'Assign to (optional)';

  @override
  String get questAddParticipantsTitle => 'Add participants';

  @override
  String get questSearch => 'Search...';

  @override
  String get questAllContactsAdded => 'All contacts already added.';

  @override
  String questParticipantsCount(int count) {
    return 'Participants ($count)';
  }

  @override
  String get questNoParticipants => 'No participants.';

  @override
  String get questAddParticipant => 'Add participant';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String get statsFilterSheetTitle => 'Filter persons';

  @override
  String get statsFilterNoGroup => 'No group';

  @override
  String get statsFilterSelectAll => 'Select all';

  @override
  String get statsFilterDeselectAll => 'Deselect all';

  @override
  String get statsFilterSearch => 'Search person...';

  @override
  String get statsFilterAutoSelectTop10 => 'Autoselect Top 10';

  @override
  String get statsFilterClose => 'Close';

  @override
  String statsFilterHiddenHint(int count) {
    return '$count persons hidden';
  }
}
