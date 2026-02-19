import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/add_meeting_provider.dart';
import '../widgets/meeting_name_field.dart';
import '../widgets/meeting_date_field.dart';

/// Screen for adding a new meeting.
/// Provides [AddMeetingProvider] scoped to this screen only.
class AddMeetingScreen extends StatelessWidget {
  const AddMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMeetingProvider(),
      child: const _AddMeetingView(),
    );
  }
}

/// Internal view widget that consumes [AddMeetingProvider].
class _AddMeetingView extends StatelessWidget {
  const _AddMeetingView();

  @override
  Widget build(BuildContext context) {
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
            _WeightStepperPlaceholder(),
            const SizedBox(height: 24),

            // --- Participants ---
            const _SectionHeader(title: 'Participants * (min. 1)'),
            const SizedBox(height: 8),
            _ParticipantsPlaceholder(),
            const SizedBox(height: 24),

            // --- Activities ---
            const _SectionHeader(title: 'Activities * (min. 1)'),
            const SizedBox(height: 8),
            _ActivitiesPlaceholder(),
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

class _WeightStepperPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: null, // implemented in US-012
            icon: Icon(Icons.remove),
          ),
          Text('3', style: TextStyle(fontSize: 20)),
          IconButton(
            onPressed: null, // implemented in US-012
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const TextField(
      enabled: false,
      decoration: InputDecoration(
        hintText: 'Type name... (coming in US-013)',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _ActivitiesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const TextField(
      enabled: false,
      decoration: InputDecoration(
        hintText: 'Add activity... (coming in US-014)',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }
}
