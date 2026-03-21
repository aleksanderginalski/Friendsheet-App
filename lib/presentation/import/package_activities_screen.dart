import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../../data/models/pending_meeting_package.dart';
import '../providers/shared_package_inbox_provider.dart';
import 'package_persons_screen.dart';
import 'share_import_success_screen.dart';

/// Step 2a of package import: resolves activity name conflicts and lets the
/// user opt out of individual activities. Only shown when activity conflicts exist.
class PackageActivitiesScreen extends StatefulWidget {
  final PendingMeetingPackage package;
  final String userId;

  const PackageActivitiesScreen({
    super.key,
    required this.package,
    required this.userId,
  });

  @override
  State<PackageActivitiesScreen> createState() =>
      _PackageActivitiesScreenState();
}

class _PackageActivitiesScreenState extends State<PackageActivitiesScreen> {
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
    final activityNames = provider.uniqueActivityNamesFor(packageId);
    final activityConflicts = provider.activityConflictsFor(packageId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Activities'),
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
                for (final name in activityNames)
                  _buildActivityTile(
                      provider, packageId, name, activityConflicts),
                if (activityNames.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No activities to import.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          _buildContinueButton(context, provider, packageId),
        ],
      ),
    );
  }

  Widget _buildActivityTile(
    SharedPackageInboxProvider provider,
    String packageId,
    String name,
    Map<String, ActivityCategory> conflicts,
  ) {
    final lower = name.toLowerCase();
    final existing = conflicts[lower];
    if (existing != null) {
      return _ActivityConflictTile(
        packageId: packageId,
        lowerName: lower,
        originalName: name,
        existingCategory: existing,
        provider: provider,
      );
    }
    return _ActivityOptInTile(
      packageId: packageId,
      lowerName: lower,
      displayName: name,
      provider: provider,
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    SharedPackageInboxProvider provider,
    String packageId,
  ) {
    final canContinue =
        provider.canProceedActivities(packageId) && !_isImporting;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                canContinue ? () => _onContinue(context, provider) : null,
            child: _isImporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue(
      BuildContext context, SharedPackageInboxProvider provider) async {
    final packageId = widget.package.id;
    final hasPersonConflicts =
        provider.personConflictsFor(packageId).isNotEmpty;

    if (hasPersonConflicts) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: PackagePersonsScreen(
              package: widget.package,
              userId: widget.userId,
            ),
          ),
        ),
      );
    } else {
      // No person conflicts — import directly.
      setState(() => _isImporting = true);
      final nav = Navigator.of(context);
      try {
        final summary = await provider.importPackage(packageId, widget.userId);
        if (!mounted) return;
        nav.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ShareImportSuccessScreen(summary: summary),
          ),
        );
      } finally {
        if (mounted) setState(() => _isImporting = false);
      }
    }
  }
}

// Checkbox tile for an activity with no name conflict.
// Unchecking opts out of importing this activity.
class _ActivityOptInTile extends StatelessWidget {
  final String packageId;
  final String lowerName;
  final String displayName;
  final SharedPackageInboxProvider provider;

  const _ActivityOptInTile({
    required this.packageId,
    required this.lowerName,
    required this.displayName,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(displayName),
      value: !provider.isActivityOptedOut(packageId, lowerName),
      onChanged: (checked) =>
          provider.setActivityOptOut(packageId, lowerName, !(checked ?? true)),
    );
  }
}

// Card for an activity whose name matches an existing category (case-insensitive).
class _ActivityConflictTile extends StatefulWidget {
  final String packageId;
  final String lowerName;
  final String originalName;
  final ActivityCategory existingCategory;
  final SharedPackageInboxProvider provider;

  const _ActivityConflictTile({
    required this.packageId,
    required this.lowerName,
    required this.originalName,
    required this.existingCategory,
    required this.provider,
  });

  @override
  State<_ActivityConflictTile> createState() => _ActivityConflictTileState();
}

class _ActivityConflictTileState extends State<_ActivityConflictTile> {
  final _controller = TextEditingController();
  bool _showField = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitRename() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.provider.resolveActivityConflict(
        widget.packageId, widget.lowerName, ActivityResolution.rename(name));
    setState(() => _showField = false);
  }

  @override
  Widget build(BuildContext context) {
    final resolution = widget.provider
        .activityResolutionFor(widget.packageId, widget.lowerName);
    final isRename = resolution?.isRename ?? false;
    final isLink = resolution != null && !resolution.isRename;

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
              '⚠️ Name conflict with existing: ${widget.existingCategory.name}',
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _actionButton(
                  label: 'Rename',
                  selected: isRename,
                  onPressed: () => setState(() => _showField = true),
                ),
                _actionButton(
                  label: 'Link to existing: ${widget.existingCategory.name}',
                  selected: isLink,
                  onPressed: () {
                    widget.provider.resolveActivityConflict(
                      widget.packageId,
                      widget.lowerName,
                      ActivityResolution.link(widget.existingCategory.id),
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
                        hintText: 'New activity name',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _submitRename(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _submitRename,
                  ),
                ],
              ),
            ],
            if (resolution != null) ...[
              const SizedBox(height: 4),
              Text(
                isRename
                    ? '→ Renamed to: ${resolution.renamedName}'
                    : '→ Linked to: ${widget.existingCategory.name}',
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
