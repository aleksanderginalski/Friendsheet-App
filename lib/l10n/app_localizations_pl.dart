// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get loginTitle => 'Śledź swoje życie towarzyskie';

  @override
  String get loginSignInButton => 'Zaloguj się przez Google';

  @override
  String get loginTagline => 'Jedno dotknięcie i gotowe!';

  @override
  String get loginTermsPrefix => 'Logując się, akceptujesz nasze ';

  @override
  String get loginTermsLink => 'Warunki korzystania';

  @override
  String get loginTermsMiddle => ' oraz ';

  @override
  String get loginPrivacyLink => 'Politykę prywatności';

  @override
  String loginSignInError(String error) {
    return 'Błąd logowania: $error';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsCalendarSection => 'GOOGLE CALENDAR';

  @override
  String get settingsCalendarNotConnected => 'Nie połączono';

  @override
  String get settingsCalendarConnect => 'Połącz';

  @override
  String get settingsCalendarDisconnectTitle => 'Rozłącz kalendarz';

  @override
  String get settingsCalendarDisconnectContent =>
      'Czy na pewno chcesz rozłączyć Google Calendar?';

  @override
  String get settingsCalendarDisconnect => 'ROZŁĄCZ';

  @override
  String get settingsAppLanguage => 'Język aplikacji';

  @override
  String get settingsExportData => 'Eksport danych';

  @override
  String get settingsExportSubtitle =>
      'Zapisz wszystkie dane jako JSON na urządzeniu';

  @override
  String get settingsDeleteAccount => 'Usuń konto';

  @override
  String get settingsDeleteAccountSubtitle => 'Trwale usuń swoje konto i dane';

  @override
  String get settingsDeleteAccountTitle => 'Usunąć konto?';

  @override
  String get settingsDeleteAccountContent =>
      'Spowoduje to trwałe usunięcie konta i wszystkich danych. Tej operacji nie można cofnąć.';

  @override
  String get settingsDeleteAccountConfirm => 'USUŃ';

  @override
  String get settingsDeleteAccountSuccess => 'Konto usunięte.';

  @override
  String settingsDeleteAccountError(String error) {
    return 'Błąd usuwania konta: $error';
  }

  @override
  String get mainImportShare => 'Import i udostępnianie';

  @override
  String get mainShareMeetings => 'Udostępnij spotkania znajomemu';

  @override
  String get mainBrowseImport => 'Przeglądaj i importuj zdarzenia';

  @override
  String get mainImportFromCalendar => 'Importuj z kalendarza';

  @override
  String get mainBuddy => 'Buddy';

  @override
  String get mainFriendsQuest => 'Friends-Quest';

  @override
  String mainPendingMeetings(int count) {
    return 'Oczekujące spotkania ($count)';
  }

  @override
  String get mainSettingsTitle => 'Ustawienia';

  @override
  String get mainLogOut => 'Wyloguj';

  @override
  String get mainLogOutTitle => 'Wylogować się?';

  @override
  String get mainLogOutContent =>
      'Czy na pewno chcesz się wylogować?\n\nBędziesz musiał zalogować się ponownie, aby uzyskać dostęp do swoich spotkań.';

  @override
  String get mainLogOutConfirm => 'WYLOGUJ';

  @override
  String mainLogOutError(String error) {
    return 'Błąd wylogowania: $error';
  }

  @override
  String get mainCalendarOfflineMessage =>
      'Google Calendar wymaga połączenia z internetem';

  @override
  String get mainCalendarAuthExpired =>
      'Dostęp do kalendarza wygasł — połącz ponownie';

  @override
  String get mainCalendarLoadError =>
      'Nie można załadować kalendarzy. Sprawdź połączenie.';

  @override
  String get mainNavHome => 'Dom';

  @override
  String get mainNavMeetings => 'Spotkania';

  @override
  String get mainNavFriends => 'Znajomi';

  @override
  String get mainNavActivities => 'Aktywności';

  @override
  String get homeOfflineMessage => 'Buddy wymaga połączenia z internetem';

  @override
  String get homeCalendarAccessDenied => 'Brak dostępu do kalendarza';

  @override
  String get meetingsListTitle => 'Moje spotkania';

  @override
  String get meetingsListSyncing => 'Synchronizacja...';

  @override
  String get meetingsListSearchHint => 'Szukaj spotkań...';

  @override
  String get meetingsListSearchClose => 'Zamknij wyszukiwanie';

  @override
  String get meetingsListSearch => 'Szukaj';

  @override
  String get meetingsListEmpty =>
      'Brak spotkań — dotknij +, aby dodać pierwsze!';

  @override
  String meetingsListNoResults(String query) {
    return 'Brak wyników dla \"$query\"';
  }

  @override
  String meetingsListMeetingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spotkań',
      many: '$count spotkań',
      few: '$count spotkania',
      one: '1 spotkanie',
    );
    return '$_temp0';
  }

  @override
  String get addMeetingTitleEdit => 'Edytuj spotkanie';

  @override
  String get addMeetingTitleAdd => 'Dodaj spotkanie';

  @override
  String get addMeetingWeightSection => 'Waga spotkania *';

  @override
  String get addMeetingParticipantsSection => 'Uczestnicy * (min. 1)';

  @override
  String get addMeetingActivitiesSection => 'Aktywności * (min. 1)';

  @override
  String get addMeetingSaveChanges => 'ZAPISZ ZMIANY';

  @override
  String get addMeetingSave => 'ZAPISZ SPOTKANIE';

  @override
  String get addMeetingSaved => 'Spotkanie zapisane!';

  @override
  String get addMeetingSaveError => 'Nie udało się zapisać spotkania...';

  @override
  String get personsListTitle => 'MOJE OSOBY';

  @override
  String get personsListAddPerson => 'Dodaj osobę';

  @override
  String get personsListAddGroup => 'Dodaj grupę';

  @override
  String get personsListEditGroup => 'Edytuj grupę';

  @override
  String get personsListDeleteGroup => 'Usuń grupę';

  @override
  String get personsListDeleteGroupTitle => 'Usunąć grupę?';

  @override
  String personsListDeleteGroupContent(String name) {
    return 'Usunąć \"$name\"?\nOsoby nie zostaną usunięte.';
  }

  @override
  String get personsListDeleteGroupContentSimple =>
      'Czy na pewno chcesz usunąć tę grupę?';

  @override
  String get personsListSearchHint => 'Szukaj znajomych...';

  @override
  String get personsListSearchClose => 'Zamknij wyszukiwanie';

  @override
  String get personsListSearch => 'Szukaj';

  @override
  String get personsListAdd => 'Dodaj';

  @override
  String personsListNoResults(String query) {
    return 'Brak wyników dla \"$query\"';
  }

  @override
  String get personsListDeleteGroupConfirm => 'USUŃ';

  @override
  String get personsListPersonAdded => 'Osoba dodana';

  @override
  String get personsListEmpty =>
      'Brak znajomych — dotknij +, aby dodać pierwszego!';

  @override
  String get personsListGroupEmpty => 'Brak znajomych w tej grupie.';

  @override
  String get personsListAlreadyInGroup => 'Wszyscy znajomi są już w tej grupie';

  @override
  String get calendarPermissionTitle => 'Import kalendarza';

  @override
  String get calendarPermissionHeading => 'Połącz Google Calendar';

  @override
  String get calendarPermissionDescription =>
      'Friendsheet może importować zdarzenia z Google Calendar jako propozycje spotkań. Ty decydujesz, które zdarzenia zaimportować.';

  @override
  String get calendarPermissionConnectButton => 'Połącz Google Calendar';

  @override
  String get calendarPermissionNotNow => 'Nie teraz';

  @override
  String get calendarPermissionError => 'Wystąpił nieoczekiwany błąd';

  @override
  String get calendarEventsTitle => 'Wybierz zdarzenia';

  @override
  String calendarEventsImport(int count) {
    return 'Importuj ($count)';
  }

  @override
  String get calendarEventsFilters => 'Filtry';

  @override
  String get calendarEventsFrom => 'Od:';

  @override
  String get calendarEventsTo => 'Do:';

  @override
  String get calendarEventsPrimary => 'Główny';

  @override
  String get calendarEventsExcludeAllDay => 'Wyklucz całodniowe';

  @override
  String get calendarEventsApplyFilters => 'Zastosuj filtry';

  @override
  String get calendarEventsSelectAll => 'Zaznacz wszystkie';

  @override
  String get calendarEventsDeselectAll => 'Odznacz wszystkie';

  @override
  String get calendarEventsEmpty => 'Brak zdarzeń';

  @override
  String get calendarEventsReconnectPrompt =>
      'Kalendarz rozłączony. Połącz ponownie, aby importować zdarzenia.';

  @override
  String get calendarEventsRetry => 'Ponów';

  @override
  String get calendarEventsReconnect => 'Połącz ponownie';

  @override
  String get aiSettingsTitle => 'Asystent AI';

  @override
  String get aiSettingsDeleteKeyTitle => 'Usunąć klucz API?';

  @override
  String get aiSettingsDeleteKeyContent =>
      'Twój klucz API OpenAI zostanie usunięty z tego urządzenia.';

  @override
  String get aiSettingsDeleteKeyConfirm => 'USUŃ';

  @override
  String get aiSettingsApiKeyLabel => 'Klucz API';

  @override
  String get aiSettingsApiKeyHint => 'sk-...';

  @override
  String get aiSettingsSave => 'Zapisz';

  @override
  String get aiSettingsDeleteKey => 'Usuń klucz';

  @override
  String get aiSettingsApiKeySection => 'Klucz API';

  @override
  String get aiConsentTitle => 'Asystent AI — Prywatność';

  @override
  String get aiConsentAlwaysSent => 'Zawsze wysyłane do OpenAI';

  @override
  String get aiConsentSentWhenAsked => 'Wysyłane tylko gdy wyraźnie prosisz';

  @override
  String get aiConsentNeverSent => 'Nigdy nie wysyłane do OpenAI';

  @override
  String get aiConsentPrivacyPolicy => 'Przeczytaj pełną Politykę prywatności';

  @override
  String get aiConsentAgree => 'Rozumiem i zgadzam się';

  @override
  String get buddyMenuTitle => 'Asystent AI';

  @override
  String get buddyMenuChatSubtitle => 'Porozmawiaj z asystentem AI';

  @override
  String get buddyMenuApiKey => 'Klucz API';

  @override
  String get buddyMenuApiKeySubtitle => 'Zarządzaj kluczem API OpenAI';

  @override
  String get buddyMenuLtnsFilters => 'Filtry LTNS';

  @override
  String get buddyMenuLtnsFiltersSubtitle =>
      'Wybierz kto pojawia się w sekcji Dawno nie widziany';

  @override
  String get ltnsFilterTitle => 'Filtry LTNS';

  @override
  String get ltnsFilterDescription =>
      'Wybierz kto pojawia się w sekcji Dawno nie widziany na ekranie głównym.';

  @override
  String get ltnsFilterSearchHint => 'Szukaj po imieniu lub pseudonimie…';

  @override
  String get meetingDetailTitle => 'Szczegóły spotkania';

  @override
  String get meetingDetailNoParticipantsWarning =>
      'To spotkanie nie ma uczestników. Dotknij edytuj, aby dodać kogoś.';

  @override
  String get meetingDetailNoParticipants =>
      'To spotkanie nie ma uczestników...';

  @override
  String get meetingDetailParticipants => 'Uczestnicy';

  @override
  String get meetingDetailActivities => 'Aktywności';

  @override
  String get meetingDetailNoParticipantsLabel => 'Brak uczestników.';

  @override
  String get meetingDetailNoActivities => 'Brak aktywności.';

  @override
  String get meetingDetailEditButton => 'Edytuj spotkanie';

  @override
  String get meetingDetailDeleteTitle => 'Usuń spotkanie';

  @override
  String get meetingDetailDeleteContent =>
      'Czy na pewno chcesz usunąć to spotkanie? Tej operacji nie można cofnąć.';

  @override
  String get meetingDetailDeleteCancel => 'Anuluj';

  @override
  String get meetingDetailDeleteConfirm => 'Usuń';

  @override
  String get meetingDetailDeleteError =>
      'Nie udało się usunąć spotkania. Spróbuj ponownie.';

  @override
  String get activitiesListTitle => 'Aktywności';

  @override
  String get activitiesListEmpty =>
      'Brak aktywności — dotknij +, aby utworzyć pierwszą kategorię!';

  @override
  String get activitiesListNoResults => 'Nie znaleziono aktywności';

  @override
  String get activitiesListAddTooltip => 'Dodaj kategorię aktywności';

  @override
  String get activitiesListAddChildTooltip => 'Dodaj aktywność podrzędną';

  @override
  String get activitiesListSearchHint => 'Szukaj aktywności...';

  @override
  String get activitiesListSearchClose => 'Zamknij wyszukiwanie';

  @override
  String get activitiesListSearch => 'Szukaj';

  @override
  String get activitiesListRetry => 'Ponów';

  @override
  String activitiesListMergeContent(String source, String target) {
    return 'Połączyć \"$source\" z \"$target\"?\n\nWszystkie spotkania zostaną zaktualizowane. \"$source\" zostanie usunięta.';
  }

  @override
  String get activitiesListMergeTitle => 'Połączyć kategorie?';

  @override
  String activitiesListMergedSuccess(String source, String target) {
    return 'Połączono \"$source\" z \"$target\"';
  }

  @override
  String get activitiesListDeleteTitle => 'Usunąć aktywność?';

  @override
  String activitiesListDeleteContent(String name) {
    return 'Usunąć \"$name\"? Tej operacji nie można cofnąć.';
  }

  @override
  String activitiesListDeleteError(String error) {
    return 'Błąd usuwania: $error';
  }

  @override
  String get activitiesListMergeConfirm => 'POŁĄCZ';

  @override
  String activitiesListMergeError(String error) {
    return 'Błąd łączenia: $error';
  }

  @override
  String get activitiesListEdit => 'Edytuj';

  @override
  String get activitiesListDelete => 'Usuń';

  @override
  String get activitiesListMergeInto => 'Połącz z…';

  @override
  String get meetingInboxTitle => 'Oczekujące spotkania';

  @override
  String get meetingInboxDeletePackageTitle => 'Usunąć paczkę?';

  @override
  String get meetingInboxDeletePackageContent =>
      'Czy na pewno chcesz usunąć tę paczkę? Nie można jej odzyskać.';

  @override
  String get meetingInboxEmptyTitle => 'Brak oczekujących spotkań';

  @override
  String get meetingInboxEmptySubtitle =>
      'Importuj zdarzenia z kalendarza lub otrzymaj spotkania od znajomego, aby zacząć.';

  @override
  String meetingInboxProgress(int reviewed, int total) {
    return '$reviewed z $total przejrzanych';
  }

  @override
  String get meetingInboxSharedByFriends => 'Udostępnione przez znajomych';

  @override
  String meetingInboxConflictCount(int count) {
    return '⚠️ $count konflikt(ów)';
  }

  @override
  String get offlineBannerMessage => 'Brak połączenia z internetem';

  @override
  String get statisticsTitle => 'Statystyki';

  @override
  String get activityBreakdownTitle => 'Podział aktywności';

  @override
  String get whoPerActivityTitle => 'Kto przy aktywności';

  @override
  String get interactionDistributionTitle => 'Rozkład interakcji';

  @override
  String get friendsQuestSummaryTitle => 'Friends-Quest';

  @override
  String get sharingCtaTitle => 'Zapisz wspomnienia';

  @override
  String get sharingCtaSubtitle => 'Udostępnij spotkania znajomemu';

  @override
  String get sharingCtaCardTitle => 'Poproś znajomego o spotkania';

  @override
  String get sharingCtaCardSubtitle =>
      'Masz znajomego używającego Friendsheet? Poproś go o udostępnienie Twoich spotkań.';

  @override
  String get sharingCtaCardButton => 'Generuj token';

  @override
  String get buildMeetingBaseCtaTitle => 'Buduj bazę spotkań';

  @override
  String get buildMeetingBaseCtaSubtitle =>
      'Dodaj pierwsze spotkanie, aby zobaczyć statystyki';

  @override
  String get buildMeetingBaseCardSubtitle =>
      'Masz mniej niż 50 spotkań. Importuj z Google Calendar lub poproś znajomego o udostępnienie.';

  @override
  String get buildMeetingBaseCardRequest => 'Poproś znajomego';

  @override
  String get onboardingCalendarCtaTitle => 'Importuj z kalendarza';

  @override
  String get onboardingCalendarCtaSubtitle =>
      'Połącz Google Calendar, aby importować zdarzenia';

  @override
  String get onboardingCalendarCardTitle => 'Importuj poprzednie spotkania';

  @override
  String get onboardingCalendarCardSubtitle =>
      'Masz mniej niż 50 spotkań. Importuj z Google Calendar, aby zacząć szybciej.';

  @override
  String get activitySelectorDialogTitle => 'Wybierz aktywności';

  @override
  String get activityVisibilityDialogTitle => 'Pokaż / Ukryj aktywności';

  @override
  String get statisticsVisibilityDialogTitle => 'Pokaż / Ukryj statystyki';

  @override
  String get personVisibilityDialogTitle => 'Pokaż / Ukryj znajomych';

  @override
  String get whoPerActivityPersonFilterDialogTitle => 'Filtruj według osoby';

  @override
  String get noVisibleActivities => 'Brak widocznych aktywności';

  @override
  String get noVisiblePersons => 'Brak widocznych osób';

  @override
  String activitiesHiddenCount(int count) {
    return '$count aktywności ukrytych';
  }

  @override
  String personsHiddenCount(int count) {
    return '$count osób ukrytych';
  }

  @override
  String get statisticsAllHidden => 'Wszystkie statystyki ukryte';

  @override
  String get statisticsRestoreAll => 'Przywróć wszystkie';

  @override
  String get statisticsNoMeetings => 'Brak spotkań';

  @override
  String get statisticsMinOneCard =>
      'Co najmniej jedna karta musi być widoczna';

  @override
  String get visibilityAutoSelectTop10 => 'Automatycznie wybierz top 10';

  @override
  String get visibilityMinOnePerson =>
      'Co najmniej jedna osoba musi być widoczna';

  @override
  String get visibilitySelectAll => 'Zaznacz wszystkie';

  @override
  String get visibilityDeselectAll => 'Odznacz wszystkie';

  @override
  String get interactionDistributionInfo =>
      'Spotkanie z wieloma osobami liczy się dla każdej z nich. Oznacza to, że sumy procentowe mogą przekroczyć 100%.';

  @override
  String get interactionCumulative => 'Skumulowane';

  @override
  String get interactionYearly => 'Roczne';

  @override
  String get whoSelectActivity =>
      'Wybierz aktywność powyżej, aby zobaczyć ranking.';

  @override
  String get whoNoData => 'Brak danych dla tej aktywności.';

  @override
  String get meetingCardNoParticipants => 'Brak uczestników';

  @override
  String meetingCardPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osób',
      many: '$count osób',
      few: '$count osoby',
      one: '1 osoba',
    );
    return '$_temp0';
  }

  @override
  String get friendsQuestViewAll => 'Zobacz wszystkie →';

  @override
  String friendsQuestActiveQuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktywnych zadań',
      many: '$count aktywnych zadań',
      few: '$count aktywne zadania',
      one: '1 aktywne zadanie',
    );
    return '$_temp0';
  }

  @override
  String get statDeltaNew => 'NOWY';

  @override
  String get dialogCancel => 'ANULUJ';

  @override
  String get dialogClose => 'ZAMKNIJ';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogSave => 'ZAPISZ';

  @override
  String get dialogCreate => 'UTWÓRZ';

  @override
  String get dialogAdd => 'DODAJ';

  @override
  String get dialogDelete => 'USUŃ';

  @override
  String get aiChatGoToSettings => 'Przejdź do ustawień';

  @override
  String get aiChatDismiss => 'Zamknij';

  @override
  String get aiChatRetry => 'Ponów';

  @override
  String get personDialogTitle => 'Dodaj nową osobę';

  @override
  String get personDialogFirstName => 'Imię *';

  @override
  String get personDialogLastName => 'Nazwisko (opcjonalne)';

  @override
  String get personDialogNickname => 'Pseudonim (wymagany do odróżnienia)';

  @override
  String get questScreenTitle => 'Friends-Quests';

  @override
  String get questNewQuestTitle => 'Nowe zadanie';

  @override
  String get questNameLabel => 'Nazwa zadania';

  @override
  String get questNameHint => 'np. Weekend z ekipą';

  @override
  String get questParticipantsLabel => 'Uczestnicy';

  @override
  String get questNoContacts => 'Brak kontaktów.';

  @override
  String get questSearchParticipants => 'Szukaj uczestników...';

  @override
  String get questNoMatches => 'Brak wyników.';

  @override
  String get questEditTaskTitle => 'Edytuj zadanie';

  @override
  String get questTaskText => 'Treść zadania';

  @override
  String get questCompleteTitle => 'Ukończ zadanie';

  @override
  String get questCompleteContent =>
      'To zadanie nie jest powiązane ze spotkaniem. Ukończyć bez notatek, czy najpierw wybrać spotkanie?';

  @override
  String get questWithoutNotes => 'BEZ NOTATEK';

  @override
  String get questSelectMeeting => 'WYBIERZ SPOTKANIE';

  @override
  String get questLinkToMeeting => 'Powiąż ze spotkaniem';

  @override
  String get questTapToChange => 'Dotknij, aby zmienić';

  @override
  String get questMeetingLinked => 'Spotkanie powiązane';

  @override
  String get questNoTasks => 'Brak zadań. Dodaj pierwsze przyciskiem +.';

  @override
  String get questDeleteTitle => 'Usuń zadanie';

  @override
  String questDeleteContent(String name) {
    return 'Usunąć \"$name\"? Tej operacji nie można cofnąć.';
  }

  @override
  String get questNewTaskTitle => 'Nowe zadanie podrzędne';

  @override
  String get questAssignTo => 'Przypisz do (opcjonalne)';

  @override
  String get questAddParticipantsTitle => 'Dodaj uczestników';

  @override
  String get questSearch => 'Szukaj...';

  @override
  String get questAllContactsAdded => 'Wszyscy kontakty są już dodane.';

  @override
  String questParticipantsCount(int count) {
    return 'Uczestnicy ($count)';
  }

  @override
  String get questNoParticipants => 'Brak uczestników.';

  @override
  String get questAddParticipant => 'Dodaj uczestnika';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';
}
