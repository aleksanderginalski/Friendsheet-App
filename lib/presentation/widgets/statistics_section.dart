import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/statistics_provider.dart';
import 'year_stepper.dart';

/// Displays the year selector and statistics content for the Home tab.
/// Reads StatisticsProvider from context — no repository knowledge here.
class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

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
        else
          YearStepper(
            selectedYear: provider.selectedYear!,
            availableYears: provider.availableYears,
            onYearChanged: provider.selectYear,
          ),
      ],
    );
  }
}
