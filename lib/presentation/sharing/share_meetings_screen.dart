import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/person.dart';
import 'share_meetings_provider.dart';

/// Screen where user A selects meetings to share with linked friend C.
/// Provider must be injected at the call-site via ChangeNotifierProvider.value.
class ShareMeetingsScreen extends StatefulWidget {
  final Person person;

  const ShareMeetingsScreen({super.key, required this.person});

  @override
  State<ShareMeetingsScreen> createState() => _ShareMeetingsScreenState();
}

class _ShareMeetingsScreenState extends State<ShareMeetingsScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _nicknameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ShareMeetingsProvider>();
      await provider.initialize();
      if (!mounted) return;
      // Sync pre-filled sender name into controllers after initialize.
      _firstNameController.text = provider.senderFirstName;
      _lastNameController.text = provider.senderLastName;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _onSendTap() async {
    final provider = context.read<ShareMeetingsProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy notice'),
        content: const Text(
          'You are about to share data about people in your contacts, '
          'including their first and last names. Proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await provider.sendPackage();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meetings sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to send meetings.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShareMeetingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Send meetings to ${widget.person.fullName}'),
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, ShareMeetingsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(provider.errorMessage!),
        ),
      );
    }

    if (provider.meetings.isEmpty) {
      return Center(
        child: Text('No meetings with ${widget.person.firstName} yet.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _SenderSignatureCard(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                nicknameController: _nicknameController,
                onFirstNameChanged: provider.setSenderFirstName,
                onLastNameChanged: provider.setSenderLastName,
                onNicknameChanged: provider.setSenderNickname,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: provider.isAllSelected,
                onChanged: (_) => provider.toggleAll(),
                title: const Text('Select All'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              ...provider.meetings.map(
                (meeting) => CheckboxListTile(
                  value: provider.selectedMeetingIds.contains(meeting.id),
                  onChanged: (_) => provider.toggleMeeting(meeting.id),
                  title: Text(meeting.name),
                  subtitle: Text(
                    '${DateFormat('d MMM yyyy').format(meeting.date)}  ·  weight ${meeting.weight}',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 8),
              _OptionsCard(
                includePersons: provider.includePersons,
                includeActivities: provider.includeActivities,
                onIncludePersonsChanged: provider.setIncludePersons,
                onIncludeActivitiesChanged: provider.setIncludeActivities,
              ),
            ],
          ),
        ),
        _SendButton(
          enabled: provider.canSend && !provider.isSending,
          isSending: provider.isSending,
          onTap: _onSendTap,
        ),
      ],
    );
  }
}

class _SenderSignatureCard extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController nicknameController;
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onNicknameChanged;

  const _SenderSignatureCard({
    required this.firstNameController,
    required this.lastNameController,
    required this.nicknameController,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onNicknameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your signature',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                isDense: true,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: onFirstNameChanged,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                isDense: true,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: onLastNameChanged,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname (optional)',
                isDense: true,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: onNicknameChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  final bool includePersons;
  final bool includeActivities;
  final ValueChanged<bool> onIncludePersonsChanged;
  final ValueChanged<bool> onIncludeActivitiesChanged;

  const _OptionsCard({
    required this.includePersons,
    required this.includeActivities,
    required this.onIncludePersonsChanged,
    required this.onIncludeActivitiesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            value: includePersons,
            onChanged: onIncludePersonsChanged,
            title: const Text('Include other participants'),
          ),
          SwitchListTile(
            value: includeActivities,
            onChanged: onIncludeActivitiesChanged,
            title: const Text('Include activities'),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool isSending;
  final VoidCallback onTap;

  const _SendButton({
    required this.enabled,
    required this.isSending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          child: isSending
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ),
    );
  }
}
