import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/google_calendar.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/google_calendar_service.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../ai_chat/buddy_chat_mode.dart';
import '../providers/buddy_widget_provider.dart';
import '../providers/home_provider.dart';
import '../providers/statistics_provider.dart';
import '../sharing/generate_sharing_token_screen.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/build_meeting_base_cta_card.dart';
import '../widgets/home_loading_screen.dart';
import '../widgets/statistics_section.dart';
import 'calendar_events_screen.dart';

/// Home tab showing statistics or the onboarding CTA, with a floating Buddy
/// widget anchored at the bottom-left corner.
///
/// [BuddyWidgetProvider], [HomeProvider], and [StatisticsProvider] are
/// provided by MainScreen following the Provider Navigation Pattern.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BuddyWidgetProvider>(
      builder: (context, buddyProvider, _) {
        return Consumer2<HomeProvider, StatisticsProvider>(
          builder: (context, homeProvider, statsProvider, _) {
            final bodyContent = _buildBodyContent(context, homeProvider);
            return _buildScaffold(context, buddyProvider, bodyContent);
          },
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, HomeProvider homeProvider) {
    if (!homeProvider.isInitialized) {
      return const HomeLoadingScreen();
    }

    if (homeProvider.shouldShowCta) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: BuildMeetingBaseCtaCard(
            onImport: () => _handleImport(context),
            onShareToken: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenerateSharingTokenScreen(),
              ),
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: StatisticsSection(),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    BuddyWidgetProvider buddyProvider,
    Widget bodyContent,
  ) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Positioned.fill gives bodyContent tight constraints — same as
            // Scaffold.body used to provide. Required for StatisticsSection which
            // contains an Expanded(PageView) that needs bounded height.
            Positioned.fill(child: bodyContent),
            // Buddy widget — always anchored at bottom-left, icon always visible.
            if (buddyProvider.isInitialized)
              Positioned(
                // Negative bottom compensates for transparent bottom padding
                // in the statistics_illustration asset so the character sits
                // flush with the bottom nav bar.
                bottom: -50,
                left: -50,
                child: BuddyWidget(
                  suggestedMeetings: buddyProvider.suggestedMeetings,
                  urgentBirthdayPersons: buddyProvider.urgentBirthdayPersons,
                  daysUntilBirthday: buddyProvider.daysUntilBirthday,
                  upcomingBirthdayInfo: buddyProvider.upcomingBirthdayInfo,
                  lapsedPersons: buddyProvider.lapsedPersons,
                  isExpanded: buddyProvider.isExpanded,
                  onDismiss: buddyProvider.collapse,
                  onSaveMemoriesTap: () =>
                      _openAIChatSaveMemories(context, buddyProvider),
                  onBirthdayTap: () =>
                      _openAIChatBirthday(context, buddyProvider),
                  onLongTimeNoSeeTap: () =>
                      _openLtnsChat(context, buddyProvider),
                  onIconTap: () => openAIChatGreeting(context, buddyProvider),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Opens AIChatScreen in meeting-notes-list mode (top-3 meeting selection).
void _openAIChatSaveMemories(
  BuildContext context,
  BuddyWidgetProvider provider,
) {
  final userId = AuthService().currentUserId ?? '';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => buildAIChatRoute(
        userId: userId,
        mode: BuddyChatMode.meetingNotesList,
        meetingOptions: provider.suggestedMeetings,
      ),
    ),
  );
}

/// Opens AIChatScreen in the appropriate birthday flow.
///
/// Scenario 2 (exactly one urgent): directly opens birthday-wishes for that person.
/// Scenario 1 & 3 (zero or multiple urgent): opens birthday-list for selection.
void _openAIChatBirthday(
  BuildContext context,
  BuddyWidgetProvider provider,
) {
  final userId = AuthService().currentUserId ?? '';
  final urgent = provider.urgentBirthdayPersons;

  if (urgent.length == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => buildAIChatRoute(
          userId: userId,
          mode: BuddyChatMode.birthdayWishes,
          personId: urgent[0].id,
          birthdayOptions: provider.upcomingBirthdayInfo,
        ),
      ),
    );
  } else {
    // Show urgent persons if any, otherwise the 3 nearest upcoming.
    final options = urgent.isNotEmpty
        ? provider.upcomingBirthdayInfo.where((b) => b.daysUntil < 5).toList()
        : provider.upcomingBirthdayInfo.take(3).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => buildAIChatRoute(
          userId: userId,
          mode: BuddyChatMode.birthdayList,
          birthdayOptions: options,
        ),
      ),
    );
  }
}

/// Opens AIChatScreen in greeting mode (icon tap — shows all contextual actions).
void openAIChatGreeting(BuildContext context, BuddyWidgetProvider provider) {
  final userId = AuthService().currentUserId ?? '';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => buildAIChatRoute(
        userId: userId,
        mode: BuddyChatMode.greeting,
        meetingOptions: provider.suggestedMeetings,
        birthdayOptions: provider.upcomingBirthdayInfo,
        lapsedOptions: provider.lapsedPersons,
      ),
    ),
  );
}

/// Opens AIChatScreen in lapsed-friends-list mode (LTNS button tap).
void _openLtnsChat(BuildContext context, BuddyWidgetProvider provider) {
  final userId = AuthService().currentUserId ?? '';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => buildAIChatRoute(
        userId: userId,
        mode: BuddyChatMode.lapsedFriendsList,
        lapsedOptions: provider.lapsedPersons,
      ),
    ),
  );
}

Future<void> _handleImport(BuildContext context) async {
  final calendarService = GoogleCalendarService();
  final isConnected = await calendarService.isConnected();
  if (!context.mounted) return;

  List<GoogleCalendar> calendars;
  if (isConnected) {
    calendars = await calendarService.fetchCalendars();
  } else {
    try {
      calendars = await calendarService.requestAccess();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendar access denied')),
      );
      return;
    }
  }

  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CalendarEventsScreen(
        calendars: calendars,
        onReconnect: () async {
          try {
            final newCalendars = await GoogleCalendarService().requestAccess();
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CalendarEventsScreen(calendars: newCalendars),
              ),
            );
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calendar access denied')),
            );
          }
        },
      ),
    ),
  );
}
