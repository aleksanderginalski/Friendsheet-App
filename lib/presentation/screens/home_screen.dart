import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/onboarding_calendar_cta_card.dart';
import '../widgets/statistics_section.dart';
import 'calendar_permission_screen.dart';

/// Home tab showing the onboarding CTA or statistics based on meeting count.
///
/// Shows [OnboardingCalendarCtaCard] when the user has fewer than 50 meetings
/// and has not dismissed the card. Switches to [StatisticsSection] once either
/// condition is met.
///
/// [HomeProvider] is provided by the parent (MainScreen) following the
/// Provider Navigation Pattern.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, StatisticsProvider>(
      builder: (context, homeProvider, statsProvider, _) {
        if (homeProvider.shouldShowCta) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: OnboardingCalendarCtaCard(
                  onDismiss: homeProvider.dismissCta,
                  onImport: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CalendarPermissionScreen(),
                    ),
                  ),
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
