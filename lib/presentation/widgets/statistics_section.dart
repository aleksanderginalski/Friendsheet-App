import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../providers/statistics_provider.dart';
import 'activity_breakdown_widget.dart';
import 'activity_selector_dialog.dart';
import 'activity_visibility_dialog.dart';
import 'interaction_distribution_widget.dart';
import 'person_visibility_dialog.dart';
import 'statistics_visibility_dialog.dart';
import 'who_per_activity_person_filter_dialog.dart';
import 'who_per_activity_widget.dart';
import 'year_stepper.dart';

/// Displays year selector and statistics cards in a swipeable PageView.
/// YearStepper is pinned above the carousel — single global year selector.
/// The settings icon in the header opens StatisticsVisibilityDialog to
/// show/hide individual cards. Hidden state is persisted in SharedPreferences.
class StatisticsSection extends StatefulWidget {
  const StatisticsSection({super.key});

  @override
  State<StatisticsSection> createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<StatisticsSection> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openActivitySelector(
    BuildContext context,
    StatisticsProvider provider,
  ) async {
    final result = await showDialog<ActivityCategory>(
      context: context,
      builder: (_) => ActivitySelectorDialog(
        categories: provider.allCategories,
        selectedCategoryId: provider.selectedActivityId,
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;
    context.read<StatisticsProvider>().selectActivity(result.id);
  }

  void _openVisibilityDialog(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => ActivityVisibilityDialog(
        entries: provider.activityBreakdown,
        categories: provider.allCategories,
        hiddenActivities: provider.hiddenActivities,
        onToggle: provider.toggleHiddenActivity,
        onAutoSelectTop10: provider.applyTop10Selection,
        onToggleSelectAll: () => provider.hiddenActivities.isEmpty
            ? provider.setAllActivitiesVisibility(false)
            : provider.setAllActivitiesVisibility(true),
      ),
    );
  }

  void _openPersonVisibilityDialog(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => PersonVisibilityDialog(
        allEntries: provider.distributionEntries,
        hiddenPersons: provider.hiddenPersonsDistribution,
        onToggle: provider.togglePersonDistributionVisibility,
        onAutoSelectTop10: provider.autoSelectTopPersonsDistribution,
        onToggleSelectAll: () => provider.hiddenPersonsDistribution.isEmpty
            ? provider.setAllPersonsVisibility(false)
            : provider.setAllPersonsVisibility(true),
      ),
    );
  }

  void _openWhoPerActivityFilterDialog(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => WhoPerActivityPersonFilterDialog(
        allEntries: provider.whoPerActivity,
        hiddenPersonIds: provider.hiddenPersonsActivity,
        onTogglePersonVisibility: provider.toggleHiddenPerson,
        onToggleSelectAll: (bool selectAll) =>
            provider.setAllPersonsActivityVisibility(selectAll),
        onAutoSelectTop10: provider.autoSelectTop10ForActivity,
      ),
    );
  }

  // Navigates the carousel by [direction] steps (-1 = left, +1 = right),
  // wrapping around and skipping hidden cards.
  void _navigateCarousel(int direction, int visibleCount) {
    if (!_pageController.hasClients || visibleCount == 0) return;
    final currentPage = _pageController.page?.round() ?? 0;
    final nextPage = (currentPage + direction + visibleCount) % visibleCount;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openCardsVisibilityDialog(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => StatisticsVisibilityDialog(
        hiddenCards: provider.hiddenCards,
        onToggleCard: provider.toggleCardVisibility,
        onToggleSelectAll: (selectAll) {
          if (selectAll) {
            provider.restoreAllCards();
          } else {
            // Hide all cards except the first (activityBreakdown) — min-1 preserved.
            for (final card in StatCardType.values.skip(1)) {
              if (!provider.hiddenCards.contains(card)) {
                provider.toggleCardVisibility(card);
              }
            }
          }
        },
      ),
    );
  }

  // Returns the inner content widget for a given card type.
  Widget _cardContent(StatCardType card, StatisticsProvider provider) {
    switch (card) {
      case StatCardType.activityBreakdown:
        return ActivityBreakdownWidget(
          entries: provider.activityBreakdown,
          hiddenActivities: provider.hiddenActivities,
          onOpenVisibilityDialog: () =>
              _openVisibilityDialog(context, provider),
        );
      case StatCardType.whoPerActivity:
        return WhoPerActivityWidget(
          entries: provider.whoPerActivity,
          categories: provider.allCategories,
          selectedCategoryId: provider.selectedActivityId,
          hiddenPersonIds: provider.hiddenPersonsActivity,
          onSelectActivity: () => _openActivitySelector(context, provider),
          onOpenFilterDialog: () =>
              _openWhoPerActivityFilterDialog(context, provider),
        );
      case StatCardType.interactionDistribution:
        return InteractionDistributionWidget(
          entries: provider.distributionEntries,
          hiddenPersons: provider.hiddenPersonsDistribution,
          isCumulativeMode: provider.isCumulativeMode,
          isLoading: provider.isDistributionLoading,
          onOpenVisibilityDialog: () =>
              _openPersonVisibilityDialog(context, provider),
          onToggleMode: provider.toggleDistributionMode,
        );
    }
  }

  // Wraps a card content in a SingleChildScrollView.
  // _CarouselPage keeps the State alive while the card is off-screen so
  // widget state (e.g. color maps) survives swipe navigation.
  Widget _buildCard(StatCardType card, StatisticsProvider provider) {
    return _CarouselPage(
      child: SingleChildScrollView(
        child: _cardContent(card, provider),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_outlined, size: 48),
          const SizedBox(height: 8),
          const Text('All statistics hidden'),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () =>
                context.read<StatisticsProvider>().restoreAllCards(),
            child: const Text('Restore all'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              label: 'Previous statistic',
              child: IconButton(
                key: const Key('carousel_arrow_left'),
                icon: const Icon(Icons.chevron_left),
                onPressed: provider.visibleCards.length > 1
                    ? () => _navigateCarousel(-1, provider.visibleCards.length)
                    : null,
              ),
            ),
            const Expanded(
              child: Text(
                'Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Semantics(
              label: 'Statistics card visibility',
              child: IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Show/hide statistics cards',
                onPressed: () => _openCardsVisibilityDialog(context, provider),
              ),
            ),
            Semantics(
              label: 'Next statistic',
              child: IconButton(
                key: const Key('carousel_arrow_right'),
                icon: const Icon(Icons.chevron_right),
                onPressed: provider.visibleCards.length > 1
                    ? () => _navigateCarousel(1, provider.visibleCards.length)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.isLoading)
          const CircularProgressIndicator()
        else if (!provider.hasData)
          const Text('No meetings found')
        else ...[
          YearStepper(
            selectedYear: provider.selectedYear!,
            availableYears: provider.availableYears,
            onYearChanged: provider.selectYear,
          ),
          Expanded(
            child: provider.allCardsHidden
                ? _buildEmptyState()
                : PageView(
                    controller: _pageController,
                    children: provider.visibleCards
                        .map((card) => _buildCard(card, provider))
                        .toList(),
                  ),
          ),
        ],
      ],
    );
  }
}

/// Wraps a PageView page to keep its State alive when scrolled off-screen.
/// AutomaticKeepAliveClientMixin with wantKeepAlive = true tells PageView not
/// to dispose off-screen pages, so their State (e.g. color maps, animations)
/// survives swipe navigation.
class _CarouselPage extends StatefulWidget {
  final Widget child;

  const _CarouselPage({required this.child});

  @override
  State<_CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<_CarouselPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
