// lib/presentation/screens/add_meeting_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/meeting.dart';
import '../../data/services/auth_service.dart';
import '../providers/add_meeting_provider.dart';
import '../widgets/activity_autocomplete.dart';
import '../widgets/meeting_date_field.dart';
import '../widgets/meeting_name_field.dart';
import '../widgets/meeting_weight_stepper.dart';
import '../widgets/person_autocomplete.dart';

/// Screen for adding a new meeting or editing an existing one.
/// When [initialMeeting] is provided, the screen operates in edit mode.
/// Provides [AddMeetingProvider] scoped to this screen only.
class AddMeetingScreen extends StatelessWidget {
  final Meeting? initialMeeting;

  const AddMeetingScreen({super.key, this.initialMeeting});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid;
    return ChangeNotifierProvider(
      create: (_) => AddMeetingProvider(initialMeeting: initialMeeting),
      child: AddMeetingScreenView(userId: userId),
    );
  }
}

/// Internal view widget that consumes [AddMeetingProvider].
/// StatefulWidget is required to trigger loadPersons on init.
/// [userId] is passed explicitly to allow testing without Firebase.
class AddMeetingScreenView extends StatefulWidget {
  final String? userId;

  const AddMeetingScreenView({super.key, this.userId});

  @override
  State<AddMeetingScreenView> createState() => _AddMeetingScreenViewState();
}

class _AddMeetingScreenViewState extends State<AddMeetingScreenView> {
  @override
  void initState() {
    super.initState();
    // Load persons/categories after first frame so Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = widget.userId;
      if (userId != null) {
        context.read<AddMeetingProvider>().loadPersons(userId);
        context.read<AddMeetingProvider>().loadCategories(userId);
      }
      // Load full Person objects when editing an existing meeting
      context.read<AddMeetingProvider>().initializeEditData();
    });
  }

  // Validates form, saves meeting, shows feedback and pops on success
  Future<void> _handleSave(BuildContext context) async {
    final provider = context.read<AddMeetingProvider>();
    final success = await provider.saveMeeting();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting saved!'),
          backgroundColor: Colors.green,
        ),
      );
      // Return saved meeting so callers (e.g. detail screen) can update their state
      Navigator.of(context).pop(provider.savedMeeting);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save meeting. Check all fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddMeetingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.isEditMode ? 'Edit Meeting' : 'Add Meeting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Meeting Name ---
            const MeetingNameField(),
            const SizedBox(height: 24),

            // --- Meeting Date ---
            const MeetingDateField(),
            const SizedBox(height: 24),

            // --- Meeting Weight ---
            const _SectionHeader(title: 'Meeting Weight *'),
            const SizedBox(height: 8),
            MeetingWeightStepper(
              value: provider.weight,
              canDecrement: provider.canDecrement,
              canIncrement: provider.canIncrement,
              onDecrement: provider.decrementWeight,
              onIncrement: provider.incrementWeight,
            ),
            const SizedBox(height: 24),

            // --- Participants ---
            const _SectionHeader(title: 'Participants * (min. 1)'),
            const SizedBox(height: 8),
            PersonAutocomplete(
              selectedPersons: provider.selectedPersons,
              onSearch: provider.searchPersons,
              onPersonAdded: provider.selectPerson,
              onNewPerson: provider.addNewPerson,
              onPersonRemoved: provider.removePerson,
              participantsError: provider.participantsError,
              personNameExists: provider.personNameExists,
            ),
            const SizedBox(height: 24),

            // --- Activities ---
            const _SectionHeader(title: 'Activities * (min. 1)'),
            const SizedBox(height: 8),
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
            const SizedBox(height: 32),

            // --- Save Button ---
            FilledButton(
              // Disable button while saving to prevent double submissions
              onPressed: provider.isSaving ? null : () => _handleSave(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: provider.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        provider.isEditMode ? 'SAVE CHANGES' : 'SAVE MEETING',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
