import 'package:flutter/material.dart';

import '../../data/repositories/statistics_repository.dart';

/// Displays a ranked list of activity categories by total meeting weight
/// for the selected year, with a delta indicator vs. the previous year.
class ActivityBreakdownWidget extends StatelessWidget {
  final List<ActivityBreakdownEntry> entries;

  const ActivityBreakdownWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Activity Breakdown',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...entries.map((entry) => _ActivityBreakdownRow(entry: entry)),
      ],
    );
  }
}

class _ActivityBreakdownRow extends StatelessWidget {
  final ActivityBreakdownEntry entry;

  const _ActivityBreakdownRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(entry.name),
          ),
          Text(
            entry.currentYearWeight.toString(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: _DeltaLabel(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaLabel extends StatelessWidget {
  final ActivityBreakdownEntry entry;

  const _DeltaLabel({required this.entry});

  @override
  Widget build(BuildContext context) {
    // New activity this year — no previous data to compare against.
    if (entry.previousYearWeight == 0) {
      return const Text(
        'NEW',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }

    if (entry.delta > 0) {
      return Text(
        '▲ +${entry.delta}',
        style: const TextStyle(color: Colors.green, fontSize: 12),
      );
    }

    if (entry.delta < 0) {
      return Text(
        '▼ ${entry.delta}',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      );
    }

    // delta == 0 and previous year had data.
    return const Text(
      '—',
      style: TextStyle(color: Colors.grey, fontSize: 12),
    );
  }
}
