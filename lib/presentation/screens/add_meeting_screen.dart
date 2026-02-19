// lib/presentation/screens/add_meeting_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../providers/add_meeting_provider.dart';
import '../widgets/activity_autocomplete.dart';
import '../widgets/meeting_date_field.dart';
import '../widgets/meeting_name_field.dart';
import '../widgets/meeting_weight_stepper.dart';
import '../widgets/person_autocomplete.dart';

/// Screen for adding a new meeting.
/// Provides [AddMeetingProvider] scoped to this screen only.
class AddMeetingScreen extends StatelessWidget {
  const AddMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid;
    return ChangeNotifierProvider(
      create: (_) => AddMeetingProvider(),
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
    // Load persons after first frame so Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = widget.userId;
      if (userId != null) {
        context.read<AddMeetingProvider>().loadPersons(userId);
        context.read<AddMeetingProvider>().loadActivities(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddMeetingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meeting'),
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
            const PersonAutocomplete(),
            const SizedBox(height: 24),

            // --- Activities ---
            const _SectionHeader(title: 'Activities * (min. 1)'),
            const SizedBox(height: 8),
            const ActivityAutocomplete(),
            const SizedBox(height: 32),

            // --- Save Button ---
            const FilledButton(
              onPressed: null, // enabled in US-015
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'SAVE MEETING',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Available after filling all required fields',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
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
