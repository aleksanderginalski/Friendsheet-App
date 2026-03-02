import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../providers/statistics_provider.dart';
import 'activity_breakdown_widget.dart';
import 'activity_selector_dialog.dart';
import 'activity_visibility_dialog.dart';
import 'interaction_distribution_widget.dart';
import 'person_visibility_dialog.dart';
import 'who_per_activity_widget.dart';
import 'year_stepper.dart';

/// Displays year selector and statistics cards in a swipeable PageView.
/// YearStepper is pinned above the carousel — single global year selector.
/// Long-pressing a card hides it; hidden state is persisted in SharedPreferences.
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
      ),
    );
  }

  // Returns the display label for a card type.
  String _cardLabel(StatCardType card) {
    switch (card) {
      case StatCardType.activityBreakdown:
        return 'Activity Breakdown';
      case StatCardType.whoPerActivity:
        return 'Who Per Activity';
      case StatCardType.interactionDistribution:
        return 'Interaction Distribution';
    }
  }

  // Hides the tapped card immediately and shows a SnackBar feedback.
  void _onCardLongPress(
    BuildContext context,
    StatCardType card,
    StatisticsProvider provider,
  ) {
    final label = _cardLabel(card);
    provider.toggleCardVisibility(card);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label hidden. Long-press any card to restore.'),
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
          hiddenCount: provider.hiddenCountForActivity,
          onSelectActivity: () => _openActivitySelector(context, provider),
          onToggleHidden: (personId, _) =>
              provider.toggleHiddenPerson(personId),
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

  // Wraps a card content in a GestureDetector (page-level long-press) and
  // SingleChildScrollView to handle variable card heights. The GestureDetector
  // is placed above child widgets so individual chart bar long-press handlers
  // in child widgets take priority in the gesture arena.
  // _CarouselPage keeps the State alive while the card is off-screen so
  // widget state (e.g. color maps) survives swipe navigation.
  Widget _buildCard(StatCardType card, StatisticsProvider provider) {
    return _CarouselPage(
      child: GestureDetector(
        onLongPress: () => _onCardLongPress(context, card, provider),
        child: SingleChildScrollView(
          child: _cardContent(card, provider),
        ),
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
          const SizedBox(height: 4),
          const Text('Long-press any card to restore'),
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
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
