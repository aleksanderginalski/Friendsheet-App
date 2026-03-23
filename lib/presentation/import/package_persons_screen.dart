import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/pending_meeting_package.dart';
import '../../data/models/person.dart';
import '../providers/shared_package_inbox_provider.dart';
import 'person_picker_screen.dart';
import 'share_import_success_screen.dart';

/// Step 2b of package import: reviews all persons in the package and lets the
/// user resolve conflicts, link to existing contacts, or skip individuals.
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
    final conflicts = provider.personConflictsFor(packageId);

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
                  _buildTile(
                      provider, packageId, entry.key, entry.value, conflicts),
                if (persons.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No persons to import.',
                        textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
          _buildConfirmButton(context, provider, packageId),
        ],
      ),
    );
  }

  Widget _buildTile(
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
          provider: provider);
    }
    return _PersonOptInTile(
        packageId: packageId,
        personKey: personKey,
        sharedPerson: sharedPerson,
        provider: provider);
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

// Card for a person whose name exactly matches an existing contact.
// User MUST choose an option — blocks Confirm until resolved.
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
  bool _showNicknameField = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with sender's suggested nickname if available.
    if (widget.sharedPerson.nickname != null) {
      _controller.text = widget.sharedPerson.nickname!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitNickname() {
    final nick = _controller.text.trim();
    if (nick.isEmpty) return;
    widget.provider.resolvePersonConflict(
        widget.packageId, widget.personKey, PersonResolution.nickname(nick));
    setState(() => _showNicknameField = false);
  }

  Future<void> _pickExisting(BuildContext context) async {
    final result = await Navigator.push<Person?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PersonPickerScreen(persons: widget.provider.existingPersons),
      ),
    );
    if (result != null) {
      widget.provider.resolvePersonConflict(
          widget.packageId, widget.personKey, PersonResolution.link(result.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final res =
        widget.provider.personResolutionFor(widget.packageId, widget.personKey);
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
              '⚠️ Conflict: "${widget.sharedPerson.firstName}" matches '
              '"${widget.existingPerson.fullName}"',
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            if (widget.sharedPerson.nickname != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  'Suggested nickname: ${widget.sharedPerson.nickname}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: [
              _btn('Create as New', selected: res?.isCreateNew ?? false,
                  onPressed: () {
                widget.provider.resolvePersonConflict(widget.packageId,
                    widget.personKey, const PersonResolution.createNew());
                setState(() => _showNicknameField = false);
              }),
              _btn('Add with Nickname',
                  selected: res?.isNickname ?? false,
                  onPressed: () => setState(() => _showNicknameField = true)),
              _btn('Link to: ${widget.existingPerson.fullName}',
                  selected: res?.isLink == true &&
                      res?.linkedPersonId == widget.existingPerson.id,
                  onPressed: () {
                widget.provider.resolvePersonConflict(
                    widget.packageId,
                    widget.personKey,
                    PersonResolution.link(widget.existingPerson.id));
                setState(() => _showNicknameField = false);
              }),
              _btn('Link with Existing',
                  selected: res?.isLink == true &&
                      res?.linkedPersonId != widget.existingPerson.id,
                  onPressed: () => _pickExisting(context)),
              _btn('Skip', selected: res?.isSkip ?? false, onPressed: () {
                widget.provider.resolvePersonConflict(widget.packageId,
                    widget.personKey, const PersonResolution.skip());
                setState(() => _showNicknameField = false);
              }),
            ]),
            if (_showNicknameField) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'Nickname to distinguish them',
                        isDense: true),
                    onSubmitted: (_) => _submitNickname(),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.check), onPressed: _submitNickname),
              ]),
            ],
            if (res != null) ...[
              const SizedBox(height: 4),
              Text(_statusText(res),
                  style: const TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }

  String _statusText(PersonResolution res) {
    if (res.isSkip) return '→ Skipped';
    if (res.isLink) {
      final name = res.linkedPersonId == widget.existingPerson.id
          ? widget.existingPerson.fullName
          : 'selected person';
      return '→ Linked to: $name';
    }
    if (res.isNickname) return '→ Adding as new with nickname: ${res.nickname}';
    return '→ Creating as new person';
  }

  Widget _btn(String label,
      {required bool selected, required VoidCallback onPressed}) {
    if (selected) return FilledButton(onPressed: onPressed, child: Text(label));
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}

// Tile for a person with no name conflict.
// Default is to add as new; user may link to existing or skip.
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

  Future<void> _pickExisting(BuildContext context) async {
    final result = await Navigator.push<Person?>(
      context,
      MaterialPageRoute(
          builder: (_) =>
              PersonPickerScreen(persons: provider.existingPersons)),
    );
    if (result != null) {
      provider.resolvePersonConflict(
          packageId, personKey, PersonResolution.link(result.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = sharedPerson.lastName != null
        ? '${sharedPerson.firstName} ${sharedPerson.lastName}'
        : sharedPerson.firstName;
    final res = provider.personResolutionFor(packageId, personKey);
    final isOptedOut = provider.isPersonOptedOut(packageId, personKey);
    final isDefault = res == null && !isOptedOut;
    return ListTile(
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sharedPerson.nickname != null)
            Text(
              'Suggested nickname: ${sharedPerson.nickname}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          Wrap(spacing: 8, runSpacing: 4, children: [
            _btn('Add new',
                selected: isDefault,
                onPressed: () =>
                    provider.clearPersonResolution(packageId, personKey)),
            _btn('Link with Existing',
                selected: res?.isLink ?? false,
                onPressed: () => _pickExisting(context)),
            _btn('Skip',
                selected: res?.isSkip ?? isOptedOut,
                onPressed: () => provider.resolvePersonConflict(
                    packageId, personKey, const PersonResolution.skip())),
          ]),
        ],
      ),
    );
  }

  Widget _btn(String label,
      {required bool selected, required VoidCallback onPressed}) {
    const style = ButtonStyle(
      padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
      minimumSize: WidgetStatePropertyAll(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
    );
    if (selected) {
      return FilledButton.tonal(
          onPressed: onPressed, style: style, child: Text(label));
    }
    return OutlinedButton(
        onPressed: onPressed, style: style, child: Text(label));
  }
}
