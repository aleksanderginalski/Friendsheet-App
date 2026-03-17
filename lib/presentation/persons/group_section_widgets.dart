import 'package:flutter/material.dart';

import '../../data/models/friend_group.dart';
import '../../data/models/person.dart';
import '../activities/activity_icons.dart';
import 'person_list_tile.dart';

// Collapsible ExpansionTile for a single friend group.
// Long-press triggers [onGroupLongPress] (edit/delete bottom sheet).
// Trailing [onAssignPersonTap] opens person-assignment sheet.
class GroupSection extends StatelessWidget {
  final FriendGroup group;
  final List<Person> persons;
  final ValueChanged<Person> onPersonTap;
  final VoidCallback? onGroupLongPress;
  final VoidCallback? onAssignPersonTap;

  /// Provider-computed display name per person. Falls back to fullName.
  final String Function(Person)? displayNameOf;

  const GroupSection({
    super.key,
    required this.group,
    required this.persons,
    required this.onPersonTap,
    this.onGroupLongPress,
    this.onAssignPersonTap,
    this.displayNameOf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: onGroupLongPress,
      child: ExpansionTile(
        leading: group.iconIdentifier != null
            ? ActivityIcon(identifier: group.iconIdentifier)
            : const Icon(Icons.group),
        title: Text(group.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (persons.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${persons.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            if (onAssignPersonTap != null)
              IconButton(
                icon: const Icon(Icons.person_add, size: 20),
                tooltip: 'Add person to group',
                onPressed: onAssignPersonTap,
              ),
            // Spacer to avoid overlap with the ExpansionTile expand arrow.
            const SizedBox(width: 24),
          ],
        ),
        children: persons
            .map((p) => PersonListTile(
                  person: p,
                  displayName: displayNameOf?.call(p),
                  onTap: () => onPersonTap(p),
                ))
            .toList(),
      ),
    );
  }
}

// Non-collapsible section for persons not assigned to any group.
class UngroupedSection extends StatelessWidget {
  final List<Person> persons;
  final ValueChanged<Person> onPersonTap;

  /// Provider-computed display name per person. Falls back to fullName.
  final String Function(Person)? displayNameOf;

  const UngroupedSection({
    super.key,
    required this.persons,
    required this.onPersonTap,
    this.displayNameOf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Ungrouped',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        ...persons.map(
          (p) => PersonListTile(
            person: p,
            displayName: displayNameOf?.call(p),
            onTap: () => onPersonTap(p),
          ),
        ),
      ],
    );
  }
}
