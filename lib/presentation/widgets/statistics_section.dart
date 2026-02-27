import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/statistics_provider.dart';

/// Displays the year filter chip row for statistics.
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
          Wrap(
            spacing: 8,
            children: provider.availableYears.map((year) {
              final isSelected = year == provider.selectedYear;
              return ChoiceChip(
                label: Text(year.toString()),
                selected: isSelected,
                onSelected: (_) => provider.selectYear(year),
              );
            }).toList(),
          ),
      ],
    );
  }
}
