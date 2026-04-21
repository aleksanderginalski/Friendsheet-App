import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../../data/services/auth_service.dart';
import '../../l10n/app_localizations.dart';
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
  String? _duplicateError;

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _nameController.addListener(() {
      if (_duplicateError != null) {
        setState(() => _duplicateError = null);
      }
    });
    _selectedParentId = cat?.parentCategoryId ?? widget.preselectedParentId;
    _selectedIcon = (cat?.iconIdentifier.isNotEmpty == true)
        ? cat!.iconIdentifier
        : kActivityIcons.keys.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.initialCategory != null;

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ActivitiesListProvider>();
    final name = _nameController.text.trim();
    final excludeId = _isEditMode ? widget.initialCategory!.id : null;

    if (provider.activityNameExists(name, excludeId: excludeId)) {
      setState(
          () => _duplicateError = 'Activity with this name already exists');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = AuthService().currentUserId!;
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
                _isEditMode ? 'Edit Activity' : 'Add Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
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
                        if (_duplicateError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _duplicateError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                          onChanged: (value) =>
                              setState(() => _selectedParentId = value),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Icon',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        _IconPicker(
                          selected: _selectedIcon,
                          onSelected: (id) =>
                              setState(() => _selectedIcon = id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context)!.dialogCancel),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _isSaving ? null : () => _save(context),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(AppLocalizations.of(context)!.dialogSave),
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

// 2D grid of selectable activity icons.
// Selected icon is highlighted with primaryContainer background and a border.
class _IconPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _IconPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final identifiers = kActivityIcons.keys.toList();

    return SizedBox(
      height: 240,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: identifiers.length,
        itemBuilder: (context, index) {
          final id = identifiers[index];
          final isSelected = id == selected;
          return InkWell(
            onTap: () => onSelected(id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? primaryContainer : null,
                borderRadius: BorderRadius.circular(8),
                border:
                    isSelected ? Border.all(color: primary, width: 2) : null,
              ),
              child: ActivityIcon(identifier: id),
            ),
          );
        },
      ),
    );
  }
}
