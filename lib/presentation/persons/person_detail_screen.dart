import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/person.dart';
import '../activities/activity_icons.dart';
import 'friend_groups_provider.dart';
import 'nicknames_section.dart';
import 'person_detail_provider.dart';

/// Displays full details of a single person and supports edit and delete.
class PersonDetailScreen extends StatefulWidget {
  final Person person;

  /// Optional duplicate check passed from the list screen.
  /// When provided, an informational banner is shown on the edit dialog
  /// if the person's name collides with another entry in the user's list.
  final bool Function(String firstName, String lastName, {String? excludeId})?
      personNameExists;

  const PersonDetailScreen({
    super.key,
    required this.person,
    this.personNameExists,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch meeting count after the first frame so the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonDetailProvider>().initialize(widget.person);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonDetailProvider>();
    final person = provider.person ?? widget.person;

    return Scaffold(
      appBar: AppBar(
        title: Text(person.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: provider.isDeleting
                ? null
                : () => _handleDelete(context, provider),
          ),
        ],
      ),
      body: _PersonDetailBody(provider: provider, person: person),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, PersonDetailProvider provider) async {
    final person = provider.person ?? widget.person;
    final firstNameController = TextEditingController(text: person.firstName);
    final lastNameController =
        TextEditingController(text: person.lastName ?? '');

    // Show warning banner when: caller provided a check, the name already
    // exists in the list (excluding self), and the person has no nicknames.
    final showDuplicateWarning = widget.personNameExists != null &&
        person.nicknames.isEmpty &&
        widget.personNameExists!(
          person.firstName,
          person.lastName ?? '',
          excludeId: person.id,
        );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDuplicateWarning) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Theme.of(ctx).colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You already have someone with this name. Consider adding a nickname.',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true || !context.mounted) return;

    final success = await provider.updatePerson(
      firstNameController.text,
      lastNameController.text,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Person updated'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update person.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(
      BuildContext context, PersonDetailProvider provider) async {
    final count = provider.meetingCount;

    if (count == 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Person'),
          content: const Text(
              'Are you sure you want to delete this person? This action cannot be undone.'),
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
      if (confirmed != true || !context.mounted) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Person'),
          content: Text(
            'This person appears in $count meeting${count == 1 ? '' : 's'}. '
            'Deleting them will not remove those meetings. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete anyway'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    final success = await provider.deletePerson();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop('deleted');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to delete person.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _PersonDetailBody extends StatelessWidget {
  final PersonDetailProvider provider;
  final Person person;

  const _PersonDetailBody({
    required this.provider,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    return ListView(
      children: [
        ListTile(
          title: const Text('First Name'),
          subtitle: Text(person.firstName),
        ),
        if (person.lastName != null && person.lastName!.isNotEmpty)
          ListTile(
            title: const Text('Last Name'),
            subtitle: Text(person.lastName!),
          ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Meetings together'),
          trailing: Text(
            '${provider.meetingCount}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        NicknamesSection(provider: provider, person: person),
        _GroupsSection(person: person),
      ],
    );
  }
}

// Groups section — shows all friend groups with a checkbox for this person.
// FriendGroupsProvider is injected at the call-site (PersonsListScreen._openPerson).
class _GroupsSection extends StatelessWidget {
  final Person person;

  const _GroupsSection({required this.person});

  @override
  Widget build(BuildContext context) {
    final groupsProvider = context.watch<FriendGroupsProvider>();
    final groups = groupsProvider.groups;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Groups', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (groups.isEmpty)
            Text(
              'No groups yet',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            )
          else
            ...groups.map(
              (group) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: ActivityIcon(
                  identifier: group.iconIdentifier,
                  size: 20,
                ),
                title: Text(group.name),
                value: group.personIds.contains(person.id),
                onChanged: (checked) {
                  if (checked == true) {
                    groupsProvider.addPersonToGroup(group.id, person.id);
                  } else {
                    groupsProvider.removePersonFromGroup(group.id, person.id);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
