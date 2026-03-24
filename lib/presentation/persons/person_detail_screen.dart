import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/sharing_token_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/meeting_package_service.dart';
import '../activities/activity_icons.dart';
import '../sharing/share_meetings_provider.dart';
import '../sharing/share_meetings_screen.dart';
import 'friend_groups_provider.dart';
import 'nicknames_section.dart';
import 'person_detail_provider.dart';
import 'person_meetings_screen.dart';

/// Displays full details of a single person and supports edit, delete, and account linking.
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
      body: _PersonDetailBody(
        provider: provider,
        person: person,
        onLinkTap: () => _showLinkDialog(provider),
        onSendTap: () => _openShareMeetingsScreen(person),
        onMeetingsTap: () => _openPersonMeetingsScreen(person),
      ),
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

  // Opens PersonMeetingsScreen and refreshes meeting count on return.
  // Refresh is required because the user may have deleted meetings.
  void _openPersonMeetingsScreen(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonMeetingsScreen(person: person),
      ),
    ).then((_) {
      if (!mounted) return;
      context.read<PersonDetailProvider>().refreshMeetingCount();
    });
  }

  // Opens ShareMeetingsScreen for the linked person.
  // Method lives on State so context is always alive after async operations.
  void _openShareMeetingsScreen(Person person) {
    final provider = ShareMeetingsProvider(
      meetingRepository: MeetingRepository(),
      personRepository: PersonRepository(),
      categoryRepository: ActivityCategoryRepository(),
      authService: AuthService(),
      meetingPackageService: MeetingPackageService(),
      targetPersonId: person.id,
      recipientUid: person.linkedUserId!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: ShareMeetingsScreen(person: person),
        ),
      ),
    );
  }

  // Opens the token input dialog and handles linking result.
  // Method lives on State so context is always alive (not from a closure).
  Future<void> _showLinkDialog(PersonDetailProvider provider) async {
    final tokenController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter sharing token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ask your friend to generate a token in Friendsheet and enter it below.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenController,
              decoration:
                  const InputDecoration(labelText: 'Token (6 characters)'),
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [_UpperCaseTextFormatter()],
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
            child: const Text('Link'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await provider.linkFriendAccount(tokenController.text);
    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account linked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final message = switch (result.error!) {
        TokenValidationError.notFound =>
          'Invalid token. Check the code and try again.',
        TokenValidationError.expired =>
          'This token has expired. Ask your friend to generate a new one.',
        TokenValidationError.alreadyUsed => 'This token has already been used.',
        TokenValidationError.serverError =>
          'Something went wrong. Check your connection and try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}

class _PersonDetailBody extends StatelessWidget {
  final PersonDetailProvider provider;
  final Person person;
  final VoidCallback onLinkTap;
  final VoidCallback onSendTap;
  final VoidCallback onMeetingsTap;

  const _PersonDetailBody({
    required this.provider,
    required this.person,
    required this.onLinkTap,
    required this.onSendTap,
    required this.onMeetingsTap,
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${provider.meetingCount}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'View meetings',
                onPressed: onMeetingsTap,
              ),
            ],
          ),
        ),
        NicknamesSection(provider: provider, person: person),
        _GroupsSection(person: person),
        _SharingSection(
          provider: provider,
          person: person,
          onLinkTap: onLinkTap,
          onSendTap: onSendTap,
        ),
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

// Sharing section — "Share meetings with friend" when unlinked, "Send meetings" when linked.
// Callbacks come from _PersonDetailScreenState to avoid stale context.
class _SharingSection extends StatelessWidget {
  final PersonDetailProvider provider;
  final Person person;
  final VoidCallback onLinkTap;
  final VoidCallback onSendTap;

  const _SharingSection({
    required this.provider,
    required this.person,
    required this.onLinkTap,
    required this.onSendTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLinked = person.linkedUserId != null;

    return ListTile(
      leading: Icon(isLinked ? Icons.send : Icons.share),
      title: Text(isLinked ? 'Send meetings' : 'Share meetings with friend'),
      subtitle: isLinked ? const Text('Account linked') : null,
      enabled: isLinked ? true : !provider.isLinking,
      onTap: isLinked ? onSendTap : onLinkTap,
    );
  }
}

// Forces all typed characters to uppercase for the token input field.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
