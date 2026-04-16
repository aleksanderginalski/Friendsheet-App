import 'package:flutter/material.dart';

import '../../data/models/catch_up_topic.dart';

// Displays the catch-up topics list for a single person.
// State is owned by the parent Screen — no ChangeNotifier/InheritedWidget involved.
// Topics can be deleted via swipe (Dismissible) or trash icon, both with confirmation.
class CatchUpListSection extends StatelessWidget {
  final List<CatchUpTopic> topics;
  final bool isLoading;
  final String personId;
  final VoidCallback onAddTap;
  final Future<void> Function(String topicId) onDelete;
  final void Function(CatchUpTopic topic) onEdit;
  final Future<void> Function(String topicId) onArchive;

  const CatchUpListSection({
    super.key,
    required this.topics,
    required this.isLoading,
    required this.personId,
    required this.onAddTap,
    required this.onDelete,
    required this.onEdit,
    required this.onArchive,
  });

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      leading: const Icon(Icons.list_alt_outlined),
      title: const Text('Catch-up List'),
      // "Add" button in trailing so it's always visible without expanding.
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add topic',
            onPressed: onAddTap,
          ),
          // Default expansion arrow rebuilt by ExpansionTile when children present.
          const Icon(Icons.expand_more),
        ],
      ),
      initiallyExpanded: false,
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          )
        else if (topics.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No topics yet',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          )
        else
          ...topics.map((topic) => _TopicTile(
                topic: topic,
                onConfirmDelete: () => _confirmDelete(context),
                onDelete: () => onDelete(topic.id),
                onEdit: () => onEdit(topic),
                onArchive: () => onArchive(topic.id),
              )),
      ],
    );
  }
}

class _TopicTile extends StatelessWidget {
  final CatchUpTopic topic;
  final Future<bool?> Function() onConfirmDelete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const _TopicTile({
    required this.topic,
    required this.onConfirmDelete,
    required this.onDelete,
    required this.onEdit,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(topic.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        title: Text(topic.text),
        subtitle: topic.contextLabel != null ? Text(topic.contextLabel!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Mark as discussed',
              onPressed: onArchive,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit topic',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete topic',
              onPressed: () async {
                final confirmed = await onConfirmDelete();
                if (confirmed == true) onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
