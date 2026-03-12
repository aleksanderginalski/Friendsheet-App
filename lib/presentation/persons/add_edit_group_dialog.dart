import 'package:flutter/material.dart';

import '../../data/models/friend_group.dart';
import '../activities/activity_icons.dart';

// Dialog for adding or editing a friend group.
// Add mode: [initialGroup] is null. Edit mode: [initialGroup] is pre-filled.
// Uses Dialog (not AlertDialog) to avoid RenderIntrinsicWidth crash with icon row.
class AddEditGroupDialog extends StatefulWidget {
  final FriendGroup? initialGroup;
  final Future<void> Function(String name, String? iconIdentifier) onSave;

  const AddEditGroupDialog({
    super.key,
    this.initialGroup,
    required this.onSave,
  });

  @override
  State<AddEditGroupDialog> createState() => _AddEditGroupDialogState();
}

class _AddEditGroupDialogState extends State<AddEditGroupDialog> {
  late final TextEditingController _nameController;
  String? _selectedIcon;
  bool _isSaving = false;

  bool get _isEditMode => widget.initialGroup != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialGroup?.name ?? '');
    _selectedIcon = widget.initialGroup?.iconIdentifier;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(name, _selectedIcon);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty && !_isSaving;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditMode ? 'Edit Group' : 'Add Group',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text('Icon', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              _GroupIconPicker(
                selected: _selectedIcon,
                onSelected: (id) => setState(() => _selectedIcon = id),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: canSave ? _save : null,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Horizontal scrollable icon picker. "None" (Icons.group) is always first.
// SingleChildScrollView + Row — required inside Dialog to avoid IntrinsicWidth crash.
class _GroupIconPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _GroupIconPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final container = Theme.of(context).colorScheme.primaryContainer;

    Widget cell(bool isSelected, VoidCallback onTap, Widget child) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? container : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: primary, width: 2) : null,
          ),
          child: Center(child: child),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            cell(selected == null, () => onSelected(null),
                const Icon(Icons.group)),
            ...kActivityIcons.keys.map(
              (id) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: cell(
                  selected == id,
                  () => onSelected(id),
                  ActivityIcon(identifier: id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
