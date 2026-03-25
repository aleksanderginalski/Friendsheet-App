import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/meeting.dart';
import 'meeting_detail_provider.dart';

/// Inline notes editor for MeetingDetailScreen.
/// Each note is a separate string in the list.
/// Tapping "+" adds the note and immediately saves to Firestore.
/// Tapping "X" on an existing note removes it and immediately saves.
class MeetingNotesSection extends StatefulWidget {
  final Meeting meeting;
  final void Function(Meeting updated) onMeetingUpdated;

  const MeetingNotesSection({
    super.key,
    required this.meeting,
    required this.onMeetingUpdated,
  });

  @override
  State<MeetingNotesSection> createState() => _MeetingNotesSectionState();
}

class _MeetingNotesSectionState extends State<MeetingNotesSection> {
  late List<String> _notes;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notes = List<String>.from(widget.meeting.notes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final updated = [..._notes, text];
    _controller.clear();
    setState(() => _notes = updated);
    await _persist(updated);
  }

  Future<void> _removeNote(int index) async {
    final updated = List<String>.from(_notes)..removeAt(index);
    setState(() => _notes = updated);
    await _persist(updated);
  }

  // Saves the given notes list to Firestore and propagates the updated meeting.
  Future<void> _persist(List<String> notes) async {
    final provider = context.read<MeetingDetailProvider>();
    final updated = await provider.saveNotes(widget.meeting, notes);
    if (!mounted) return;
    if (updated != null) {
      widget.onMeetingUpdated(updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save notes. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeetingDetailProvider>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Existing notes list
        if (_notes.isNotEmpty)
          ..._notes.asMap().entries.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notes, size: 20),
              title: Text(entry.value),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                // Disable while a save is in progress to prevent concurrent writes
                onPressed:
                    provider.isSavingNotes ? null : () => _removeNote(entry.key),
              ),
            ),
          ),
        // Input row: text field + add-and-save button
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                // Submit via keyboard triggers the same add-and-save flow
                onSubmitted: (_) => _addNote(),
                decoration: const InputDecoration(
                  hintText: 'What happened? Worth noting?',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Round green button with white icon — tapping adds and saves immediately
            _AddButton(
              isSaving: provider.isSavingNotes,
              onPressed: _addNote,
            ),
          ],
        ),
      ],
    );
  }
}

/// Round green "+" button that shows a spinner while saving.
class _AddButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _AddButton({required this.isSaving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isSaving ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
