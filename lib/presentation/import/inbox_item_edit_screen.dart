import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/import_candidate.dart';
import '../../data/services/auth_service.dart';
import '../providers/inbox_item_edit_provider.dart';
import '../providers/meeting_inbox_provider.dart';
import '../widgets/activity_autocomplete.dart';
import '../widgets/meeting_weight_stepper.dart';
import '../widgets/person_autocomplete.dart';

/// Per-candidate edit form in the Meeting Inbox flow.
/// Both [InboxItemEditProvider] and [MeetingInboxProvider] must be provided
/// above this screen at the call-site (MeetingInboxScreen._openEditScreen).
class InboxItemEditScreen extends StatefulWidget {
  const InboxItemEditScreen({super.key, required this.candidate});

  final ImportCandidate candidate;

  @override
  State<InboxItemEditScreen> createState() => _InboxItemEditScreenState();
}

class _InboxItemEditScreenState extends State<InboxItemEditScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<InboxItemEditProvider>();
      provider.initialize(widget.candidate);
      _nameController.text = widget.candidate.title;
      final userId = AuthService().currentUserId;
      if (userId != null) {
        provider.loadPersons(userId);
        provider.loadCategories(userId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final provider = context.read<InboxItemEditProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      provider.setDate(picked);
    }
  }

  Future<void> _handleConfirm() async {
    final editProvider = context.read<InboxItemEditProvider>();
    final inboxProvider = context.read<MeetingInboxProvider>();
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    final success = await editProvider.save(
      userId: userId,
      onSuccess: () => inboxProvider.markConfirmed(widget.candidate.id),
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save meeting. Please retry.')),
      );
    }
  }

  void _handleSkip() {
    context.read<MeetingInboxProvider>().skip(widget.candidate.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InboxItemEditProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.candidate.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              maxLength: 50,
              decoration: InputDecoration(
                labelText: 'Meeting name *',
                border: const OutlineInputBorder(),
                errorText: provider.nameError,
              ),
              onChanged: provider.setName,
            ),
            const SizedBox(height: 16),
            _InboxDateField(onTap: _pickDate),
            const SizedBox(height: 16),
            Text(
              'Meeting weight',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            MeetingWeightStepper(
              value: provider.weight,
              canDecrement: provider.canDecrement,
              canIncrement: provider.canIncrement,
              onDecrement: provider.decrementWeight,
              onIncrement: provider.incrementWeight,
            ),
            const SizedBox(height: 16),
            if (provider.attendeeEmailSuggestions.isNotEmpty) ...[
              Text(
                'Attendees from calendar',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _AttendeeChips(emails: provider.attendeeEmailSuggestions),
              const SizedBox(height: 16),
            ],
            PersonAutocomplete(
              selectedPersons: provider.selectedPersons,
              onSearch: provider.searchPersons,
              onPersonAdded: provider.addPerson,
              onNewPerson: ({required firstName, lastName}) {
                final userId = AuthService().currentUserId;
                if (userId == null) return Future.value();
                return provider.addNewPerson(
                  userId: userId,
                  firstName: firstName,
                  lastName: lastName,
                );
              },
              onPersonRemoved: provider.removePerson,
              participantsError: provider.participantsError,
            ),
            const SizedBox(height: 16),
            ActivityAutocomplete(
              selectedCategories: provider.selectedCategories,
              onSearch: provider.searchCategories,
              onCategoryAdded: (category) {
                final userId = AuthService().currentUserId ?? '';
                return provider.addCategory(category, userId);
              },
              onNewActivity: (name) {
                final userId = AuthService().currentUserId ?? '';
                return provider.addNewActivity(name, userId);
              },
              onCategoryRemoved: provider.removeCategory,
              onGetParentName: provider.getParentName,
              activitiesError: provider.activitiesError,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.isSaving ? null : _handleSkip,
                    child: const Text('SKIP'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.isSaving ? null : _handleConfirm,
                    child: provider.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('CONFIRM'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxDateField extends StatelessWidget {
  final VoidCallback onTap;

  const _InboxDateField({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = context.select<InboxItemEditProvider, DateTime>((p) => p.date);
    final formatted = DateFormat('dd/MM/yyyy').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting Date *',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(formatted),
          ),
        ),
      ],
    );
  }
}

class _AttendeeChips extends StatelessWidget {
  final List<String> emails;

  const _AttendeeChips({required this.emails});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: emails
          .map(
            (email) => Chip(
              label: Text(email, style: const TextStyle(fontSize: 12)),
              avatar: const Icon(Icons.email_outlined, size: 14),
            ),
          )
          .toList(),
    );
  }
}
