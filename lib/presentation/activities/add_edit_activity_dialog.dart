import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../../data/services/auth_service.dart';
import 'activities_list_provider.dart';
import 'activity_icons.dart';

// Dialog for adding or editing an activity category.
// Add mode: [initialCategory] is null.
// Edit mode: [initialCategory] is the category to update.
class AddEditActivityDialog extends StatefulWidget {
  final ActivityCategory? initialCategory;
  final List<ActivityCategory> availableParents;
  final String? preselectedParentId;

  const AddEditActivityDialog({
    super.key,
    this.initialCategory,
    required this.availableParents,
    this.preselectedParentId,
  });

  @override
  State<AddEditActivityDialog> createState() => _AddEditActivityDialogState();
}

class _AddEditActivityDialogState extends State<AddEditActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String? _selectedParentId;
  late String _selectedIcon;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _selectedParentId = cat?.parentCategoryId ?? widget.preselectedParentId;
    _selectedIcon = cat?.iconIdentifier ?? kActivityIconIdentifiers.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.initialCategory != null;

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<ActivitiesListProvider>();
    final userId = AuthService().currentUserId!;
    final name = _nameController.text.trim();

    try {
      if (_isEditMode) {
        await provider.updateCategory(
          userId,
          widget.initialCategory!.id,
          name,
          _selectedIcon,
          _selectedParentId,
        );
      } else {
        await provider.addCategory(
          userId,
          name,
          _selectedIcon,
          _selectedParentId,
        );
      }
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
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
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Activity' : 'Add Activity'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _selectedParentId,
                decoration: const InputDecoration(
                  labelText: 'Parent category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None (top-level)'),
                  ),
                  ...widget.availableParents.map(
                    (cat) => DropdownMenuItem<String?>(
                      value: cat.id,
                      child: Text(cat.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedParentId = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Icon',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              _IconPicker(
                selected: _selectedIcon,
                onSelected: (id) => setState(() => _selectedIcon = id),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _isSaving ? null : () => _save(context),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SAVE'),
        ),
      ],
    );
  }
}

// Horizontal scrollable row of icon buttons from the predefined set.
class _IconPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _IconPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kActivityIconIdentifiers.map((id) {
          final isSelected = id == selected;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
              icon: Icon(resolveActivityIcon(id)),
              color: isSelected ? Colors.white : null,
              style: isSelected
                  ? IconButton.styleFrom(backgroundColor: primary)
                  : null,
              onPressed: () => onSelected(id),
              tooltip: id,
            ),
          );
        }).toList(),
      ),
    );
  }
}
