import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../providers/statistics_provider.dart';
import 'activity_breakdown_widget.dart';
import 'activity_selector_dialog.dart';
import 'who_per_activity_widget.dart';
import 'year_stepper.dart';

/// Displays the year selector and statistics content for the Home tab.
/// Reads StatisticsProvider from context — no repository knowledge here.
class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();

    return SingleChildScrollView(
      child: Column(
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
            ActivityBreakdownWidget(entries: provider.activityBreakdown),
            WhoPerActivityWidget(
              entries: provider.whoPerActivity,
              categories: provider.allCategories,
              selectedCategoryId: provider.selectedActivityId,
              hiddenPersonIds: provider.hiddenPersonsActivity,
              hiddenCount: provider.hiddenCountForActivity,
              onSelectActivity: () => _openActivitySelector(context, provider),
              onToggleHidden: (personId, _) =>
                  provider.toggleHiddenPerson(personId),
            ),
          ],
        ],
      ),
    );
  }
}
