import 'package:flutter/material.dart';

import '../../data/repositories/statistics_repository.dart';

/// Dialog for toggling person visibility in the Interaction Distribution chart.
/// All entries are shown as a flat checkbox list — persons have no hierarchy.
/// Changes are applied immediately via [onToggle] — no confirm button needed.
class PersonVisibilityDialog extends StatefulWidget {
  final List<InteractionDistributionEntry> allEntries;
  final Set<String> hiddenPersons;
  final VoidCallback onAutoSelectTop10;
  final void Function(String personId) onToggle;

  const PersonVisibilityDialog({
    super.key,
    required this.allEntries,
    required this.hiddenPersons,
    required this.onAutoSelectTop10,
    required this.onToggle,
  });

  @override
  State<PersonVisibilityDialog> createState() => _PersonVisibilityDialogState();
}

class _PersonVisibilityDialogState extends State<PersonVisibilityDialog> {
  // Local copy so checkboxes update immediately without waiting for provider.
  late Set<String> _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = Set.from(widget.hiddenPersons);
  }

  void _toggle(String personId) {
    setState(() {
      if (_hidden.contains(personId)) {
        _hidden.remove(personId);
      } else {
        _hidden.add(personId);
      }
    });
    widget.onToggle(personId);
  }

  /// Delegates auto-select to the provider and closes the dialog because
  /// the local hidden set cannot be refreshed via VoidCallback.
  void _applyTop10() {
    widget.onAutoSelectTop10();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage persons'),
      // SingleChildScrollView + Column required — ListView crashes inside
      // AlertDialog due to IntrinsicWidth incompatibility.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _applyTop10,
              child: const Text('Auto-select top 10'),
            ),
            const SizedBox(height: 8),
            ...widget.allEntries.map((entry) {
              final isVisible = !_hidden.contains(entry.personId);
              return CheckboxListTile(
                value: isVisible,
                onChanged: (_) => _toggle(entry.personId),
                title: Text(entry.name),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}
