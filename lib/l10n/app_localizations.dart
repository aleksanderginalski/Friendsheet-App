import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Social Life'**
  String get loginTitle;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginSignInButton;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'One tap to get started!'**
  String get loginTagline;

  /// No description provided for @loginTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing in you agree to our '**
  String get loginTermsPrefix;

  /// No description provided for @loginTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get loginTermsLink;

  /// No description provided for @loginTermsMiddle.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get loginTermsMiddle;

  /// No description provided for @loginPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get loginPrivacyLink;

  /// No description provided for @loginSignInError.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in: {error}'**
  String loginSignInError(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsCalendarSection.
  ///
  /// In en, this message translates to:
  /// **'GOOGLE CALENDAR'**
  String get settingsCalendarSection;

  /// No description provided for @settingsCalendarNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get settingsCalendarNotConnected;

  /// No description provided for @settingsCalendarConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get settingsCalendarConnect;

  /// No description provided for @settingsCalendarDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Calendar'**
  String get settingsCalendarDisconnectTitle;

  /// No description provided for @settingsCalendarDisconnectContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disconnect Google Calendar?'**
  String get settingsCalendarDisconnectContent;

  /// No description provided for @settingsCalendarDisconnect.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT'**
  String get settingsCalendarDisconnect;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsAppLanguage;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExportData;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save all data as JSON to device'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all your data. This action cannot be undone.'**
  String get settingsDeleteAccountContent;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get settingsDeleteAccountSuccess;

  /// No description provided for @settingsDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String settingsDeleteAccountError(String error);

  /// No description provided for @mainImportShare.
  ///
  /// In en, this message translates to:
  /// **'Import & Share'**
  String get mainImportShare;

  /// No description provided for @mainShareMeetings.
  ///
  /// In en, this message translates to:
  /// **'Share meetings with a friend'**
  String get mainShareMeetings;

  /// No description provided for @mainBrowseImport.
  ///
  /// In en, this message translates to:
  /// **'Browse & Import Events'**
  String get mainBrowseImport;

  /// No description provided for @mainImportFromCalendar.
  ///
  /// In en, this message translates to:
  /// **'Import from Calendar'**
  String get mainImportFromCalendar;

  /// No description provided for @mainBuddy.
  ///
  /// In en, this message translates to:
  /// **'Buddy'**
  String get mainBuddy;

  /// No description provided for @mainFriendsQuest.
  ///
  /// In en, this message translates to:
  /// **'Friends-Quest'**
  String get mainFriendsQuest;

  /// No description provided for @mainPendingMeetings.
  ///
  /// In en, this message translates to:
  /// **'Pending Meetings ({count})'**
  String mainPendingMeetings(int count);

  /// No description provided for @mainSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mainSettingsTitle;

  /// No description provided for @mainLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get mainLogOut;

  /// No description provided for @mainLogOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get mainLogOutTitle;

  /// No description provided for @mainLogOutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?\n\nYou\'ll need to sign in again to access your meetings.'**
  String get mainLogOutContent;

  /// No description provided for @mainLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get mainLogOutConfirm;

  /// No description provided for @mainLogOutError.
  ///
  /// In en, this message translates to:
  /// **'Failed to log out: {error}'**
  String mainLogOutError(String error);

  /// No description provided for @mainCalendarOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar requires an internet connection'**
  String get mainCalendarOfflineMessage;

  /// No description provided for @mainCalendarAuthExpired.
  ///
  /// In en, this message translates to:
  /// **'Calendar access expired — please reconnect'**
  String get mainCalendarAuthExpired;

  /// No description provided for @mainCalendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load calendars. Check your connection.'**
  String get mainCalendarLoadError;

  /// No description provided for @mainNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mainNavHome;

  /// No description provided for @mainNavMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get mainNavMeetings;

  /// No description provided for @mainNavFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get mainNavFriends;

  /// No description provided for @mainNavActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get mainNavActivities;

  /// No description provided for @homeOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Buddy requires an internet connection'**
  String get homeOfflineMessage;

  /// No description provided for @homeCalendarAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Calendar access denied'**
  String get homeCalendarAccessDenied;

  /// No description provided for @meetingsListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Meetings'**
  String get meetingsListTitle;

  /// No description provided for @meetingsListSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get meetingsListSyncing;

  /// No description provided for @meetingsListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search meetings...'**
  String get meetingsListSearchHint;

  /// No description provided for @meetingsListSearchClose.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get meetingsListSearchClose;

  /// No description provided for @meetingsListSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get meetingsListSearch;

  /// No description provided for @meetingsListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No meetings yet — tap + to add your first one!'**
  String get meetingsListEmpty;

  /// No description provided for @meetingsListNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String meetingsListNoResults(String query);

  /// No description provided for @meetingsListMeetingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meeting} other{{count} meetings}}'**
  String meetingsListMeetingCount(int count);

  /// No description provided for @addMeetingTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Meeting'**
  String get addMeetingTitleEdit;

  /// No description provided for @addMeetingTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Meeting'**
  String get addMeetingTitleAdd;

  /// No description provided for @addMeetingWeightSection.
  ///
  /// In en, this message translates to:
  /// **'Meeting Weight *'**
  String get addMeetingWeightSection;

  /// No description provided for @addMeetingParticipantsSection.
  ///
  /// In en, this message translates to:
  /// **'Participants * (min. 1)'**
  String get addMeetingParticipantsSection;

  /// No description provided for @addMeetingActivitiesSection.
  ///
  /// In en, this message translates to:
  /// **'Activities * (min. 1)'**
  String get addMeetingActivitiesSection;

  /// No description provided for @addMeetingSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get addMeetingSaveChanges;

  /// No description provided for @addMeetingSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE MEETING'**
  String get addMeetingSave;

  /// No description provided for @addMeetingSaved.
  ///
  /// In en, this message translates to:
  /// **'Meeting saved!'**
  String get addMeetingSaved;

  /// No description provided for @addMeetingSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save meeting...'**
  String get addMeetingSaveError;

  /// No description provided for @personsListTitle.
  ///
  /// In en, this message translates to:
  /// **'MY PEOPLE'**
  String get personsListTitle;

  /// No description provided for @personsListAddPerson.
  ///
  /// In en, this message translates to:
  /// **'Add Person'**
  String get personsListAddPerson;

  /// No description provided for @personsListAddGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get personsListAddGroup;

  /// No description provided for @personsListEditGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get personsListEditGroup;

  /// No description provided for @personsListDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get personsListDeleteGroup;

  /// No description provided for @personsListDeleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get personsListDeleteGroupTitle;

  /// No description provided for @personsListDeleteGroupContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?\nPersons will not be deleted.'**
  String personsListDeleteGroupContent(String name);

  /// No description provided for @personsListDeleteGroupContentSimple.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this group?'**
  String get personsListDeleteGroupContentSimple;

  /// No description provided for @personsListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search friends...'**
  String get personsListSearchHint;

  /// No description provided for @personsListSearchClose.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get personsListSearchClose;

  /// No description provided for @personsListSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get personsListSearch;

  /// No description provided for @personsListAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get personsListAdd;

  /// No description provided for @personsListNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String personsListNoResults(String query);

  /// No description provided for @personsListDeleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get personsListDeleteGroupConfirm;

  /// No description provided for @personsListPersonAdded.
  ///
  /// In en, this message translates to:
  /// **'Person added'**
  String get personsListPersonAdded;

  /// No description provided for @personsListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No friends yet — tap + to add your first one!'**
  String get personsListEmpty;

  /// No description provided for @personsListGroupEmpty.
  ///
  /// In en, this message translates to:
  /// **'No friends in this group.'**
  String get personsListGroupEmpty;

  /// No description provided for @personsListAlreadyInGroup.
  ///
  /// In en, this message translates to:
  /// **'All friends are already in this group'**
  String get personsListAlreadyInGroup;

  /// No description provided for @calendarPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar Import'**
  String get calendarPermissionTitle;

  /// No description provided for @calendarPermissionHeading.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Calendar'**
  String get calendarPermissionHeading;

  /// No description provided for @calendarPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Friendsheet can import your Google Calendar events as meeting suggestions. You choose which events to import.'**
  String get calendarPermissionDescription;

  /// No description provided for @calendarPermissionConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Calendar'**
  String get calendarPermissionConnectButton;

  /// No description provided for @calendarPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get calendarPermissionNotNow;

  /// No description provided for @calendarPermissionError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get calendarPermissionError;

  /// No description provided for @calendarEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Events'**
  String get calendarEventsTitle;

  /// No description provided for @calendarEventsImport.
  ///
  /// In en, this message translates to:
  /// **'Import ({count})'**
  String calendarEventsImport(int count);

  /// No description provided for @calendarEventsFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get calendarEventsFilters;

  /// No description provided for @calendarEventsFrom.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get calendarEventsFrom;

  /// No description provided for @calendarEventsTo.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get calendarEventsTo;

  /// No description provided for @calendarEventsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get calendarEventsPrimary;

  /// No description provided for @calendarEventsExcludeAllDay.
  ///
  /// In en, this message translates to:
  /// **'Exclude all-day events'**
  String get calendarEventsExcludeAllDay;

  /// No description provided for @calendarEventsApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get calendarEventsApplyFilters;

  /// No description provided for @calendarEventsSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get calendarEventsSelectAll;

  /// No description provided for @calendarEventsDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get calendarEventsDeselectAll;

  /// No description provided for @calendarEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get calendarEventsEmpty;

  /// No description provided for @calendarEventsReconnectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Calendar disconnected. Reconnect to import events.'**
  String get calendarEventsReconnectPrompt;

  /// No description provided for @calendarEventsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get calendarEventsRetry;

  /// No description provided for @calendarEventsReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get calendarEventsReconnect;

  /// No description provided for @aiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiSettingsTitle;

  /// No description provided for @aiSettingsDeleteKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete API Key?'**
  String get aiSettingsDeleteKeyTitle;

  /// No description provided for @aiSettingsDeleteKeyContent.
  ///
  /// In en, this message translates to:
  /// **'Your OpenAI API key will be removed from this device.'**
  String get aiSettingsDeleteKeyContent;

  /// No description provided for @aiSettingsDeleteKeyConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get aiSettingsDeleteKeyConfirm;

  /// No description provided for @aiSettingsApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get aiSettingsApiKeyLabel;

  /// No description provided for @aiSettingsApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-...'**
  String get aiSettingsApiKeyHint;

  /// No description provided for @aiSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get aiSettingsSave;

  /// No description provided for @aiSettingsDeleteKey.
  ///
  /// In en, this message translates to:
  /// **'Delete Key'**
  String get aiSettingsDeleteKey;

  /// No description provided for @aiSettingsApiKeySection.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get aiSettingsApiKeySection;

  /// No description provided for @aiConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant — Privacy'**
  String get aiConsentTitle;

  /// No description provided for @aiConsentAlwaysSent.
  ///
  /// In en, this message translates to:
  /// **'Always sent to OpenAI'**
  String get aiConsentAlwaysSent;

  /// No description provided for @aiConsentSentWhenAsked.
  ///
  /// In en, this message translates to:
  /// **'Sent only when you explicitly ask'**
  String get aiConsentSentWhenAsked;

  /// No description provided for @aiConsentNeverSent.
  ///
  /// In en, this message translates to:
  /// **'Never sent to OpenAI'**
  String get aiConsentNeverSent;

  /// No description provided for @aiConsentPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read full Privacy Policy'**
  String get aiConsentPrivacyPolicy;

  /// No description provided for @aiConsentAgree.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get aiConsentAgree;

  /// No description provided for @buddyMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get buddyMenuTitle;

  /// No description provided for @buddyMenuChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with your AI social assistant'**
  String get buddyMenuChatSubtitle;

  /// No description provided for @buddyMenuApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get buddyMenuApiKey;

  /// No description provided for @buddyMenuApiKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your OpenAI API key'**
  String get buddyMenuApiKeySubtitle;

  /// No description provided for @buddyMenuLtnsFilters.
  ///
  /// In en, this message translates to:
  /// **'LTNS Filters'**
  String get buddyMenuLtnsFilters;

  /// No description provided for @buddyMenuLtnsFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose who appears in Long Time No See'**
  String get buddyMenuLtnsFiltersSubtitle;

  /// No description provided for @ltnsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'LTNS Filters'**
  String get ltnsFilterTitle;

  /// No description provided for @ltnsFilterDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose who appears in the Long Time No See section on your home screen.'**
  String get ltnsFilterDescription;

  /// No description provided for @ltnsFilterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or nickname…'**
  String get ltnsFilterSearchHint;

  /// No description provided for @meetingDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Detail'**
  String get meetingDetailTitle;

  /// No description provided for @meetingDetailNoParticipantsWarning.
  ///
  /// In en, this message translates to:
  /// **'This meeting has no participants. Tap edit to add someone.'**
  String get meetingDetailNoParticipantsWarning;

  /// No description provided for @meetingDetailNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'This meeting has no participants...'**
  String get meetingDetailNoParticipants;

  /// No description provided for @meetingDetailParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get meetingDetailParticipants;

  /// No description provided for @meetingDetailActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get meetingDetailActivities;

  /// No description provided for @meetingDetailNoParticipantsLabel.
  ///
  /// In en, this message translates to:
  /// **'No participants.'**
  String get meetingDetailNoParticipantsLabel;

  /// No description provided for @meetingDetailNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities.'**
  String get meetingDetailNoActivities;

  /// No description provided for @meetingDetailEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Meeting'**
  String get meetingDetailEditButton;

  /// No description provided for @meetingDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Meeting'**
  String get meetingDetailDeleteTitle;

  /// No description provided for @meetingDetailDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meeting? This action cannot be undone.'**
  String get meetingDetailDeleteContent;

  /// No description provided for @meetingDetailDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get meetingDetailDeleteCancel;

  /// No description provided for @meetingDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get meetingDetailDeleteConfirm;

  /// No description provided for @meetingDetailDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meeting. Please try again.'**
  String get meetingDetailDeleteError;

  /// No description provided for @activitiesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesListTitle;

  /// No description provided for @activitiesListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activities yet — tap + to create your first category!'**
  String get activitiesListEmpty;

  /// No description provided for @activitiesListNoResults.
  ///
  /// In en, this message translates to:
  /// **'No activities found'**
  String get activitiesListNoResults;

  /// No description provided for @activitiesListAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add activity category'**
  String get activitiesListAddTooltip;

  /// No description provided for @activitiesListAddChildTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add child activity'**
  String get activitiesListAddChildTooltip;

  /// No description provided for @activitiesListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search activities...'**
  String get activitiesListSearchHint;

  /// No description provided for @activitiesListSearchClose.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get activitiesListSearchClose;

  /// No description provided for @activitiesListSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get activitiesListSearch;

  /// No description provided for @activitiesListRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get activitiesListRetry;

  /// No description provided for @activitiesListMergeContent.
  ///
  /// In en, this message translates to:
  /// **'Merge \"{source}\" into \"{target}\"?\n\nAll meetings will be updated. \"{source}\" will be deleted.'**
  String activitiesListMergeContent(String source, String target);

  /// No description provided for @activitiesListMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge categories?'**
  String get activitiesListMergeTitle;

  /// No description provided for @activitiesListMergedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Merged \"{source}\" into \"{target}\"'**
  String activitiesListMergedSuccess(String source, String target);

  /// No description provided for @activitiesListDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Activity?'**
  String get activitiesListDeleteTitle;

  /// No description provided for @activitiesListDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String activitiesListDeleteContent(String name);

  /// No description provided for @activitiesListDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String activitiesListDeleteError(String error);

  /// No description provided for @activitiesListMergeConfirm.
  ///
  /// In en, this message translates to:
  /// **'MERGE'**
  String get activitiesListMergeConfirm;

  /// No description provided for @activitiesListMergeError.
  ///
  /// In en, this message translates to:
  /// **'Merge failed: {error}'**
  String activitiesListMergeError(String error);

  /// No description provided for @activitiesListEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get activitiesListEdit;

  /// No description provided for @activitiesListDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get activitiesListDelete;

  /// No description provided for @activitiesListMergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge into…'**
  String get activitiesListMergeInto;

  /// No description provided for @meetingInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Meetings'**
  String get meetingInboxTitle;

  /// No description provided for @meetingInboxDeletePackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete package?'**
  String get meetingInboxDeletePackageTitle;

  /// No description provided for @meetingInboxDeletePackageContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this package? It cannot be recovered.'**
  String get meetingInboxDeletePackageContent;

  /// No description provided for @meetingInboxEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending meetings'**
  String get meetingInboxEmptyTitle;

  /// No description provided for @meetingInboxEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import events from your calendar or receive shared meetings from a friend to get started.'**
  String get meetingInboxEmptySubtitle;

  /// No description provided for @meetingInboxProgress.
  ///
  /// In en, this message translates to:
  /// **'{reviewed} of {total} reviewed'**
  String meetingInboxProgress(int reviewed, int total);

  /// No description provided for @meetingInboxSharedByFriends.
  ///
  /// In en, this message translates to:
  /// **'Shared by friends'**
  String get meetingInboxSharedByFriends;

  /// No description provided for @meetingInboxConflictCount.
  ///
  /// In en, this message translates to:
  /// **'⚠️ {count} conflict(s)'**
  String meetingInboxConflictCount(int count);

  /// No description provided for @offlineBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offlineBannerMessage;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @activityBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Breakdown'**
  String get activityBreakdownTitle;

  /// No description provided for @whoPerActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Who Per Activity'**
  String get whoPerActivityTitle;

  /// No description provided for @interactionDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Interaction Distribution'**
  String get interactionDistributionTitle;

  /// No description provided for @friendsQuestSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends-Quest'**
  String get friendsQuestSummaryTitle;

  /// No description provided for @sharingCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Your Memories'**
  String get sharingCtaTitle;

  /// No description provided for @sharingCtaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your meetings with a friend'**
  String get sharingCtaSubtitle;

  /// No description provided for @sharingCtaCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Request meetings from a friend'**
  String get sharingCtaCardTitle;

  /// No description provided for @sharingCtaCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have a friend who uses Friendsheet? Ask them to share your meetings.'**
  String get sharingCtaCardSubtitle;

  /// No description provided for @sharingCtaCardButton.
  ///
  /// In en, this message translates to:
  /// **'Generate token'**
  String get sharingCtaCardButton;

  /// No description provided for @buildMeetingBaseCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your meeting base'**
  String get buildMeetingBaseCtaTitle;

  /// No description provided for @buildMeetingBaseCtaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first meeting to see statistics'**
  String get buildMeetingBaseCtaSubtitle;

  /// No description provided for @buildMeetingBaseCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have fewer than 50 meetings. Import from Google Calendar or ask a friend to share your meetings.'**
  String get buildMeetingBaseCardSubtitle;

  /// No description provided for @buildMeetingBaseCardRequest.
  ///
  /// In en, this message translates to:
  /// **'Request from a friend'**
  String get buildMeetingBaseCardRequest;

  /// No description provided for @onboardingCalendarCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Calendar'**
  String get onboardingCalendarCtaTitle;

  /// No description provided for @onboardingCalendarCtaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Calendar to import events'**
  String get onboardingCalendarCtaSubtitle;

  /// No description provided for @onboardingCalendarCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Import your past meetings'**
  String get onboardingCalendarCardTitle;

  /// No description provided for @onboardingCalendarCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have fewer than 50 meetings. Import from Google Calendar to get started faster.'**
  String get onboardingCalendarCardSubtitle;

  /// No description provided for @activitySelectorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Activities'**
  String get activitySelectorDialogTitle;

  /// No description provided for @activityVisibilityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Show / Hide Activities'**
  String get activityVisibilityDialogTitle;

  /// No description provided for @statisticsVisibilityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Show / Hide Statistics'**
  String get statisticsVisibilityDialogTitle;

  /// No description provided for @personVisibilityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Show / Hide Friends'**
  String get personVisibilityDialogTitle;

  /// No description provided for @whoPerActivityPersonFilterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by Person'**
  String get whoPerActivityPersonFilterDialogTitle;

  /// No description provided for @noVisibleActivities.
  ///
  /// In en, this message translates to:
  /// **'No visible activities'**
  String get noVisibleActivities;

  /// No description provided for @noVisiblePersons.
  ///
  /// In en, this message translates to:
  /// **'No visible persons'**
  String get noVisiblePersons;

  /// No description provided for @activitiesHiddenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} activities hidden'**
  String activitiesHiddenCount(int count);

  /// No description provided for @personsHiddenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} persons hidden'**
  String personsHiddenCount(int count);

  /// No description provided for @statisticsAllHidden.
  ///
  /// In en, this message translates to:
  /// **'All statistics hidden'**
  String get statisticsAllHidden;

  /// No description provided for @statisticsRestoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore all'**
  String get statisticsRestoreAll;

  /// No description provided for @statisticsNoMeetings.
  ///
  /// In en, this message translates to:
  /// **'No meetings found'**
  String get statisticsNoMeetings;

  /// No description provided for @statisticsMinOneCard.
  ///
  /// In en, this message translates to:
  /// **'At least one card must remain visible'**
  String get statisticsMinOneCard;

  /// No description provided for @visibilityAutoSelectTop10.
  ///
  /// In en, this message translates to:
  /// **'Auto-select top 10'**
  String get visibilityAutoSelectTop10;

  /// No description provided for @visibilityMinOnePerson.
  ///
  /// In en, this message translates to:
  /// **'At least one person must remain visible'**
  String get visibilityMinOnePerson;

  /// No description provided for @visibilitySelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get visibilitySelectAll;

  /// No description provided for @visibilityDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get visibilityDeselectAll;

  /// No description provided for @interactionDistributionInfo.
  ///
  /// In en, this message translates to:
  /// **'A meeting with multiple people counts toward each person\'s total. This means percentages across all persons can exceed 100%.'**
  String get interactionDistributionInfo;

  /// No description provided for @interactionCumulative.
  ///
  /// In en, this message translates to:
  /// **'Cumulative'**
  String get interactionCumulative;

  /// No description provided for @interactionYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get interactionYearly;

  /// No description provided for @whoSelectActivity.
  ///
  /// In en, this message translates to:
  /// **'Select an activity above to see the ranking.'**
  String get whoSelectActivity;

  /// No description provided for @whoNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for this activity.'**
  String get whoNoData;

  /// No description provided for @meetingCardNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants'**
  String get meetingCardNoParticipants;

  /// No description provided for @meetingCardPeople.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String meetingCardPeople(int count);

  /// No description provided for @friendsQuestViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all →'**
  String get friendsQuestViewAll;

  /// No description provided for @friendsQuestActiveQuests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active quest} other{{count} active quests}}'**
  String friendsQuestActiveQuests(int count);

  /// No description provided for @statDeltaNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get statDeltaNew;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get dialogCancel;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get dialogClose;

  /// No description provided for @dialogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOk;

  /// No description provided for @dialogSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get dialogSave;

  /// No description provided for @dialogCreate.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get dialogCreate;

  /// No description provided for @dialogAdd.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get dialogAdd;

  /// No description provided for @dialogDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get dialogDelete;

  /// No description provided for @aiChatGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get aiChatGoToSettings;

  /// No description provided for @aiChatDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get aiChatDismiss;

  /// No description provided for @aiChatRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get aiChatRetry;

  /// No description provided for @personDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Person'**
  String get personDialogTitle;

  /// No description provided for @personDialogFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name *'**
  String get personDialogFirstName;

  /// No description provided for @personDialogLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name (optional)'**
  String get personDialogLastName;

  /// No description provided for @personDialogNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname (required to distinguish)'**
  String get personDialogNickname;

  /// No description provided for @questScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends-Quests'**
  String get questScreenTitle;

  /// No description provided for @questNewQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'New Quest'**
  String get questNewQuestTitle;

  /// No description provided for @questNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Quest name'**
  String get questNameLabel;

  /// No description provided for @questNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekend with the crew'**
  String get questNameHint;

  /// No description provided for @questParticipantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get questParticipantsLabel;

  /// No description provided for @questNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet.'**
  String get questNoContacts;

  /// No description provided for @questSearchParticipants.
  ///
  /// In en, this message translates to:
  /// **'Search participants...'**
  String get questSearchParticipants;

  /// No description provided for @questNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches.'**
  String get questNoMatches;

  /// No description provided for @questEditTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get questEditTaskTitle;

  /// No description provided for @questTaskText.
  ///
  /// In en, this message translates to:
  /// **'Task text'**
  String get questTaskText;

  /// No description provided for @questCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Quest'**
  String get questCompleteTitle;

  /// No description provided for @questCompleteContent.
  ///
  /// In en, this message translates to:
  /// **'This quest is not linked to a meeting. Complete without saving notes, or select a meeting first?'**
  String get questCompleteContent;

  /// No description provided for @questWithoutNotes.
  ///
  /// In en, this message translates to:
  /// **'WITHOUT NOTES'**
  String get questWithoutNotes;

  /// No description provided for @questSelectMeeting.
  ///
  /// In en, this message translates to:
  /// **'SELECT MEETING'**
  String get questSelectMeeting;

  /// No description provided for @questLinkToMeeting.
  ///
  /// In en, this message translates to:
  /// **'Link to meeting'**
  String get questLinkToMeeting;

  /// No description provided for @questTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get questTapToChange;

  /// No description provided for @questMeetingLinked.
  ///
  /// In en, this message translates to:
  /// **'Meeting linked'**
  String get questMeetingLinked;

  /// No description provided for @questNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add one with the + button.'**
  String get questNoTasks;

  /// No description provided for @questDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Quest'**
  String get questDeleteTitle;

  /// No description provided for @questDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String questDeleteContent(String name);

  /// No description provided for @questNewTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get questNewTaskTitle;

  /// No description provided for @questAssignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to (optional)'**
  String get questAssignTo;

  /// No description provided for @questAddParticipantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add participants'**
  String get questAddParticipantsTitle;

  /// No description provided for @questSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get questSearch;

  /// No description provided for @questAllContactsAdded.
  ///
  /// In en, this message translates to:
  /// **'All contacts already added.'**
  String get questAllContactsAdded;

  /// No description provided for @questParticipantsCount.
  ///
  /// In en, this message translates to:
  /// **'Participants ({count})'**
  String questParticipantsCount(int count);

  /// No description provided for @questNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants.'**
  String get questNoParticipants;

  /// No description provided for @questAddParticipant.
  ///
  /// In en, this message translates to:
  /// **'Add participant'**
  String get questAddParticipant;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
