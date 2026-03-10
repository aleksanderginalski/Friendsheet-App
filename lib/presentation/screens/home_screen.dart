import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/google_calendar.dart';
import '../../data/services/google_calendar_service.dart';
import '../providers/home_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/home_loading_screen.dart';
import '../widgets/onboarding_calendar_cta_card.dart';
import '../widgets/statistics_section.dart';
import 'calendar_events_screen.dart';

/// Home tab showing the onboarding CTA or statistics based on meeting count.
///
/// Shows [OnboardingCalendarCtaCard] when the user has fewer than 50 meetings.
/// Switches to [StatisticsSection] automatically once the threshold is reached.
///
/// [HomeProvider] is provided by the parent (MainScreen) following the
/// Provider Navigation Pattern.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, StatisticsProvider>(
      builder: (context, homeProvider, statsProvider, _) {
        if (!homeProvider.isInitialized) {
          return const Scaffold(
            body: SafeArea(child: HomeLoadingScreen()),
          );
        }

        if (homeProvider.shouldShowCta) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: OnboardingCalendarCtaCard(
                  onImport: () async {
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
                          const SnackBar(
                            content: Text('Calendar access denied'),
                          ),
                        );
                        return;
                      }
                    }

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CalendarEventsScreen(calendars: calendars),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }

        // Existing statistics layout — unchanged.
        return const Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: StatisticsSection(),
            ),
          ),
        );
      },
    );
  }
}
