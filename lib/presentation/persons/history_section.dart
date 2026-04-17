import 'package:flutter/material.dart';

import '../../data/models/catch_up_topic.dart';

// Collapsible "Historia" section showing archived catch-up topics.
// Topics are read-only (no edit). Permanent delete is allowed via trash icon.
// Archived topics are loaded lazily — onLoadArchived is called when the
// section is expanded for the first time (or when the list is still empty).
class HistorySection extends StatefulWidget {
  final List<CatchUpTopic> archivedTopics;
  final bool archivedLoading;
  final VoidCallback onLoadArchived;
  final Future<void> Function(String topicId) onDeleteArchivedTopic;

  const HistorySection({
    super.key,
    required this.archivedTopics,
    required this.archivedLoading,
    required this.onLoadArchived,
    required this.onDeleteArchivedTopic,
  });

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  Future<void> _confirmAndDelete(BuildContext context, String topicId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete topic'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.onDeleteArchivedTopic(topicId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> children;
    if (widget.archivedLoading) {
      children = const [
        Center(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(),
        )),
      ];
    } else if (widget.archivedTopics.isEmpty) {
      children = [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Brak omówionych tematów',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      ];
    } else {
      children = widget.archivedTopics
          .map(
            (topic) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(topic.text),
              subtitle:
                  topic.contextLabel != null ? Text(topic.contextLabel!) : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmAndDelete(context, topic.id),
              ),
            ),
          )
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.history),
        // Title uses a Row so 'Historia' remains as a standalone Text widget —
        // required for find.text('Historia') in widget tests to keep working.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Historia'),
            if (widget.archivedTopics.isNotEmpty) ...[
              const SizedBox(width: 6),
              // Badge matching child activities style (green pill).
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.archivedTopics.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        onExpansionChanged: (expanded) {
          if (expanded &&
              widget.archivedTopics.isEmpty &&
              !widget.archivedLoading) {
            widget.onLoadArchived();
          }
        },
        children: children,
      ),
    );
  }
}
