import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/meeting.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback? onTap;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM dd, yyyy').format(meeting.date);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle: date • participant count • weight
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall,
                        ),
                        _bullet(context),
                        if (meeting.participantIds.isEmpty) ...[
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'No participants',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ] else
                          Text(
                            '${meeting.participantIds.length} people',
                            style: theme.textTheme.bodySmall,
                          ),
                        _bullet(context),
                        Icon(
                          Icons.scale,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${meeting.weight}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  // Returns a small bullet separator for the subtitle row.
  Widget _bullet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
