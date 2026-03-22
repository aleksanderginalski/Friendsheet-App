import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../../data/models/pending_meeting_package.dart';
import '../providers/shared_package_inbox_provider.dart';
import 'activity_picker_screen.dart';
import 'package_persons_screen.dart';
import 'share_import_success_screen.dart';

part 'package_activity_tiles.dart';

/// Step 2a of package import: reviews all activities in the package and lets
/// the user resolve conflicts, accept fuzzy suggestions, or skip/link items.
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
    final conflicts = provider.activityConflictsFor(packageId);
    final fuzzyMatches = provider.activityFuzzyMatchesFor(packageId);

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
                  _buildTile(
                      provider, packageId, name, conflicts, fuzzyMatches),
                if (activityNames.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No activities to import.',
                        textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
          _buildContinueButton(context, provider, packageId),
        ],
      ),
    );
  }

  Widget _buildTile(
    SharedPackageInboxProvider provider,
    String packageId,
    String name,
    Map<String, ActivityCategory> conflicts,
    Map<String, ActivityCategory> fuzzyMatches,
  ) {
    final lower = name.toLowerCase();
    final existing = conflicts[lower];
    if (existing != null) {
      return _ActivityConflictTile(
          packageId: packageId,
          lowerName: lower,
          originalName: name,
          existingCategory: existing,
          provider: provider);
    }
    final fuzzy = fuzzyMatches[lower];
    if (fuzzy != null) {
      return _ActivityFuzzyTile(
          packageId: packageId,
          lowerName: lower,
          originalName: name,
          suggestedCategory: fuzzy,
          provider: provider);
    }
    return _ActivityOptInTile(
        packageId: packageId,
        lowerName: lower,
        displayName: name,
        provider: provider);
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
    final hasPersons = provider.uniquePersonsFor(packageId).isNotEmpty;

    if (hasPersons) {
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
