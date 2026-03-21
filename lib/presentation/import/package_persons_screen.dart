import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/pending_meeting_package.dart';
import '../../data/models/person.dart';
import '../providers/shared_package_inbox_provider.dart';
import 'share_import_success_screen.dart';

/// Step 2b of package import: resolves person name conflicts and lets the user
/// opt out of individual persons. Only shown when person conflicts exist.
class PackagePersonsScreen extends StatefulWidget {
  final PendingMeetingPackage package;
  final String userId;

  const PackagePersonsScreen({
    super.key,
    required this.package,
    required this.userId,
  });

  @override
  State<PackagePersonsScreen> createState() => _PackagePersonsScreenState();
}

class _PackagePersonsScreenState extends State<PackagePersonsScreen> {
  bool _isImporting = false;

  String get _senderName {
    final p = widget.package;
    final nick = p.senderNickname != null ? ' (${p.senderNickname})' : '';
    return '${p.senderFirstName} ${p.senderLastName}$nick';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SharedPackageInboxProvider>();
    final packageId = widget.package.id;
    final persons = provider.uniquePersonsFor(packageId);
    final personConflicts = provider.personConflictsFor(packageId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Persons'),
            Text(
              'From $_senderName',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final entry in persons.entries)
                  _buildPersonTile(
                      provider, packageId, entry.key, entry.value,
                      personConflicts),
                if (persons.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No persons to import.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          _buildConfirmButton(context, provider, packageId),
        ],
      ),
    );
  }

  Widget _buildPersonTile(
    SharedPackageInboxProvider provider,
    String packageId,
    String personKey,
    SharedPerson sharedPerson,
    Map<String, Person> conflicts,
  ) {
    final existing = conflicts[personKey];
    if (existing != null) {
      return _PersonConflictTile(
        packageId: packageId,
        personKey: personKey,
        sharedPerson: sharedPerson,
        existingPerson: existing,
        provider: provider,
      );
    }
    return _PersonOptInTile(
      packageId: packageId,
      personKey: personKey,
      sharedPerson: sharedPerson,
      provider: provider,
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    SharedPackageInboxProvider provider,
    String packageId,
  ) {
    final canConfirm = provider.canProceedPersons(packageId) && !_isImporting;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canConfirm ? _onConfirm : null,
            child: _isImporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm'),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isImporting = true);
    try {
      final summary = await context
          .read<SharedPackageInboxProvider>()
          .importPackage(widget.package.id, widget.userId);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ShareImportSuccessScreen(summary: summary),
        ),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}

// Switch tile for a person with no name conflict.
// Toggle off to skip importing this person; name shown with strikethrough when off.
class _PersonOptInTile extends StatelessWidget {
  final String packageId;
  final String personKey;
  final SharedPerson sharedPerson;
  final SharedPackageInboxProvider provider;

  const _PersonOptInTile({
    required this.packageId,
    required this.personKey,
    required this.sharedPerson,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final name = sharedPerson.lastName != null
        ? '${sharedPerson.firstName} ${sharedPerson.lastName}'
        : sharedPerson.firstName;
    final isIncluded = !provider.isPersonOptedOut(packageId, personKey);
    return SwitchListTile(
      title: Text(
        name,
        style: isIncluded
            ? null
            : const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      value: isIncluded,
      onChanged: (val) =>
          provider.setPersonOptOut(packageId, personKey, !val),
    );
  }
}

// Card for a person whose first+last name matches an existing contact.
class _PersonConflictTile extends StatefulWidget {
  final String packageId;
  final String personKey;
  final SharedPerson sharedPerson;
  final Person existingPerson;
  final SharedPackageInboxProvider provider;

  const _PersonConflictTile({
    required this.packageId,
    required this.personKey,
    required this.sharedPerson,
    required this.existingPerson,
    required this.provider,
  });

  @override
  State<_PersonConflictTile> createState() => _PersonConflictTileState();
}

class _PersonConflictTileState extends State<_PersonConflictTile> {
  final _controller = TextEditingController();
  bool _showField = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitNickname() {
    final nick = _controller.text.trim();
    if (nick.isEmpty) return;
    widget.provider.resolvePersonConflict(widget.packageId, widget.personKey,
        PersonResolution.nickname(nick));
    setState(() => _showField = false);
  }

  @override
  Widget build(BuildContext context) {
    final resolution = widget.provider
        .personResolutionFor(widget.packageId, widget.personKey);
    final isNickname = resolution?.isNickname ?? false;
    final isLink = resolution != null && !resolution.isNickname;

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
            Text(
              '⚠️ Name conflict with existing contact: '
              '${widget.existingPerson.fullName}',
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _actionButton(
                  label: 'Add with nickname',
                  selected: isNickname,
                  onPressed: () => setState(() => _showField = true),
                ),
                _actionButton(
                  label: 'Link to existing: ${widget.existingPerson.fullName}',
                  selected: isLink,
                  onPressed: () {
                    widget.provider.resolvePersonConflict(
                      widget.packageId,
                      widget.personKey,
                      PersonResolution.link(widget.existingPerson.id),
                    );
                    setState(() => _showField = false);
                  },
                ),
              ],
            ),
            if (_showField) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nickname to distinguish them',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _submitNickname(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _submitNickname,
                  ),
                ],
              ),
            ],
            if (resolution != null) ...[
              const SizedBox(height: 4),
              Text(
                isNickname
                    ? '→ Adding as new with nickname: ${resolution.nickname}'
                    : '→ Linked to: ${widget.existingPerson.fullName}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    if (selected) {
      return FilledButton(onPressed: onPressed, child: Text(label));
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
