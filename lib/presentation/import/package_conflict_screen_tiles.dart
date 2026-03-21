part of 'package_conflict_screen.dart';

// Simple tile for a meeting that has no date conflict.
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

// Card shown when a shared meeting date matches an existing meeting.
// Displays a side-by-side comparison and resolution buttons.
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
