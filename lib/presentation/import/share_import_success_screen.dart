import 'package:flutter/material.dart';

import '../providers/package_import_types.dart';

/// Shown after a successful package import.
/// Displays a summary of what was added, then pops back to MeetingInboxScreen.
class ShareImportSuccessScreen extends StatelessWidget {
  final ImportSummary summary;

  const ShareImportSuccessScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 96,
                ),
                const SizedBox(height: 24),
                Text(
                  'Import complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ..._buildSummaryLines(context),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _onDone(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSummaryLines(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final lines = <Widget>[];

    lines.add(Text(
      '${summary.meetingsAdded} '
      'meeting${summary.meetingsAdded == 1 ? '' : 's'} added',
      style: style,
      textAlign: TextAlign.center,
    ));

    if (summary.personsAdded > 0) {
      lines.add(Text(
        '${summary.personsAdded} '
        'person${summary.personsAdded == 1 ? '' : 's'} added',
        style: style,
        textAlign: TextAlign.center,
      ));
    }

    if (summary.activitiesAdded > 0) {
      lines.add(Text(
        '${summary.activitiesAdded} '
        '${summary.activitiesAdded == 1 ? 'activity' : 'activities'} added',
        style: style,
        textAlign: TextAlign.center,
      ));
    }

    return lines;
  }

  // Pops back to MeetingInboxScreen regardless of how deep the import flow went.
  void _onDone(BuildContext context) {
    Navigator.of(context).popUntil(ModalRoute.withName('/meeting_inbox'));
  }
}
