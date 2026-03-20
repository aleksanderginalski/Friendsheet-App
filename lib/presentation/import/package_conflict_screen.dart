import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/meeting.dart';
import '../../data/models/pending_meeting_package.dart';
import '../providers/shared_package_inbox_provider.dart';

/// Shows all meetings in a received package and allows the user to resolve
/// date conflicts before proceeding. Non-conflicting meetings are shown as
/// simple tiles; conflicting ones require a Merge / Add as new / Skip choice.
class PackageConflictScreen extends StatelessWidget {
  final PendingMeetingPackage package;

  const PackageConflictScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SharedPackageInboxProvider>();
    final conflicts = provider.conflictsFor(package.id);
    final senderName = '${package.senderFirstName} ${package.senderLastName}'
        '${package.senderNickname != null ? ' (${package.senderNickname})' : ''}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Package'),
            Text(
              'From $senderName',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: package.meetings.length,
              itemBuilder: (context, index) {
                final sharedMeeting = package.meetings[index];
                final existingMeeting = conflicts[index];

                if (existingMeeting != null) {
                  return _MeetingConflictCard(
                    package: package,
                    meetingIndex: index,
                    sharedMeeting: sharedMeeting,
                    existingMeeting: existingMeeting,
                  );
                }

                // Non-conflicting meeting — simple summary tile.
                return _NonConflictTile(sharedMeeting: sharedMeeting);
              },
            ),
          ),
          _buildContinueButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
      BuildContext context, SharedPackageInboxProvider provider) {
    final canProceed = provider.canProceed(package.id);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed
                ? () {
                    provider.dismissPackage(package.id);
                    Navigator.pop(context);
                  }
                : null,
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

// Simple tile for a meeting that has no date conflict — will be imported as-is.
class _NonConflictTile extends StatelessWidget {
  final SharedMeeting sharedMeeting;

  const _NonConflictTile({required this.sharedMeeting});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return ListTile(
      leading: const Icon(Icons.check_circle_outline, color: Colors.green),
      title: Text(sharedMeeting.name),
      subtitle: Text(
        '${fmt.format(sharedMeeting.date)} · weight ${sharedMeeting.weight}',
      ),
    );
  }
}

// Card shown when a shared meeting date matches an existing meeting in C's data.
// Displays a side-by-side comparison and action buttons (Merge / Add as new / Skip).
class _MeetingConflictCard extends StatelessWidget {
  final PendingMeetingPackage package;
  final int meetingIndex;
  final SharedMeeting sharedMeeting;
  final Meeting existingMeeting;

  const _MeetingConflictCard({
    required this.package,
    required this.meetingIndex,
    required this.sharedMeeting,
    required this.existingMeeting,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SharedPackageInboxProvider>();
    final currentResolution = provider.resolutionFor(package.id, meetingIndex);
    final fmt = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.orange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Date conflict',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Side-by-side comparison row.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MeetingColumn(
                    header: 'Received',
                    name: sharedMeeting.name,
                    date: fmt.format(sharedMeeting.date),
                    weight: sharedMeeting.weight,
                    extra: _buildSharedExtra(sharedMeeting),
                  ),
                ),
                const VerticalDivider(width: 16),
                Expanded(
                  child: _MeetingColumn(
                    header: 'Yours',
                    name: existingMeeting.name,
                    date: fmt.format(existingMeeting.date),
                    weight: existingMeeting.weight,
                    extra:
                        '${existingMeeting.participantIds.length} participant(s)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Resolution buttons.
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _ConflictActionButton(
                  label: 'Merge (same meeting)',
                  resolution: ConflictResolution.merge,
                  currentResolution: currentResolution,
                  onPressed: () => provider.resolveConflict(
                      package.id, meetingIndex, ConflictResolution.merge),
                ),
                _ConflictActionButton(
                  label: 'Add as new',
                  resolution: ConflictResolution.addAsNew,
                  currentResolution: currentResolution,
                  onPressed: () => provider.resolveConflict(
                      package.id, meetingIndex, ConflictResolution.addAsNew),
                ),
                _ConflictActionButton(
                  label: 'Skip',
                  resolution: ConflictResolution.skip,
                  currentResolution: currentResolution,
                  onPressed: () => provider.resolveConflict(
                      package.id, meetingIndex, ConflictResolution.skip),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds the extra info string for the shared meeting side.
  String _buildSharedExtra(SharedMeeting m) {
    final parts = <String>[];
    if (m.participants.isNotEmpty) {
      final names = m.participants.map((p) {
        return p.lastName != null
            ? '${p.firstName} ${p.lastName}'
            : p.firstName;
      }).join(', ');
      parts.add(names);
    }
    if (m.categoryNames.isNotEmpty) {
      parts.add(m.categoryNames.join(', '));
    }
    return parts.join(' · ');
  }
}

// A single column in the side-by-side comparison (Received or Yours).
class _MeetingColumn extends StatelessWidget {
  final String header;
  final String name;
  final String date;
  final int weight;
  final String extra;

  const _MeetingColumn({
    required this.header,
    required this.name,
    required this.date,
    required this.weight,
    required this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(date, style: const TextStyle(fontSize: 12)),
        Text('Weight: $weight', style: const TextStyle(fontSize: 12)),
        if (extra.isNotEmpty)
          Text(
            extra,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}

// Action button for a conflict resolution choice.
// Shows as FilledButton when selected, OutlinedButton otherwise.
class _ConflictActionButton extends StatelessWidget {
  final String label;
  final ConflictResolution resolution;
  final ConflictResolution? currentResolution;
  final VoidCallback onPressed;

  const _ConflictActionButton({
    required this.label,
    required this.resolution,
    required this.currentResolution,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentResolution == resolution;
    if (isSelected) {
      return FilledButton(onPressed: onPressed, child: Text(label));
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
