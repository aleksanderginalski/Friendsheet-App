import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/catch_up_topic.dart';
import '../../data/models/person.dart';
import '../../data/repositories/activity_category_repository.dart';
import '../../data/repositories/catch_up_topic_repository.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/sharing_token_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/meeting_package_service.dart';
import '../activities/activity_icons.dart';
import '../sharing/share_meetings_provider.dart';
import '../sharing/share_meetings_screen.dart';
import 'catch_up_list_section.dart';
import 'couple_link_section.dart';
import 'friend_groups_provider.dart';
import 'history_section.dart';
import 'nicknames_section.dart';
import 'person_detail_provider.dart';
import 'person_meetings_screen.dart';
import 'relationship_strength_widget.dart';

/// Displays full details of a single person and supports edit, delete, and account linking.
class PersonDetailScreen extends StatefulWidget {
  final Person person;

  /// Optional duplicate check passed from the list screen.
  /// When provided, an informational banner is shown on the edit dialog
  /// if the person's name collides with another entry in the user's list.
  final bool Function(String firstName, String lastName, {String? excludeId})?
      personNameExists;

  const PersonDetailScreen({
    super.key,
    required this.person,
    this.personNameExists,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  // Catch-up topic state is managed directly on the State — no ChangeNotifier,
  // no InheritedWidget, no listener callbacks. This prevents the
  // '_dependents.isEmpty: is not true' Flutter assertion that fired when
  // notifyListeners() was called during keyboard-dismissal animation frames.
  List<CatchUpTopic> _topics = [];
  bool _topicsLoading = false;
  List<CatchUpTopic> _archivedTopics = [];
  bool _archivedLoading = false;
  final _catchUpRepo = CatchUpTopicRepository();
  Person? _partnerPerson;
  final _personRepo = PersonRepository();

  @override
  void initState() {
    super.initState();
    // Initialize after the first frame so providers are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonDetailProvider>().initialize(widget.person);
      _loadTopics();
      _loadPartner();
    });
  }

  Future<void> _loadTopics() async {
    if (!mounted) return;
    setState(() => _topicsLoading = true);
    try {
      final userId = AuthService().currentUserId!;
      final topics = await _catchUpRepo.getActive(userId, widget.person.id);
      if (mounted) {
        setState(() {
          _topics = topics;
          _topicsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _topicsLoading = false);
    }
  }

  // Loads the linked partner Person from cache so CoupleLinkSection can
  // display their name.
  Future<void> _loadPartner() async {
    final partnerId = widget.person.partnerId;
    if (partnerId == null) return;
    final userId = AuthService().currentUserId!;
    final results = await _personRepo.getPersonsByIds([partnerId], userId);
    if (mounted && results.isNotEmpty) {
      setState(() => _partnerPerson = results.first);
    }
  }

  // Shows a searchable list of unlinked persons (excluding self).
  // Returns the selected Person, or null if the user cancelled.
  Future<Person?> _showPersonPickerDialog() async {
    final userId = AuthService().currentUserId!;
    final allPersons = await _personRepo.getPersonsByUser(userId);
    final candidates = allPersons
        .where((p) => p.id != widget.person.id && p.partnerId == null)
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    if (!mounted) return null;

    return showDialog<Person>(
      context: context,
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final filtered = query.isEmpty
                ? candidates
                : candidates
                    .where((p) =>
                        p.fullName.toLowerCase().contains(query.toLowerCase()))
                    .toList();

            return AlertDialog(
              title: const Text('Select partner'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (v) => setDialogState(() => query = v),
                    ),
                    const SizedBox(height: 8),
                    if (candidates.isEmpty)
                      const Text('No available contacts to link.')
                    else if (filtered.isEmpty)
                      const Text('No results.')
                    else
                      // ConstrainedBox limits the list height so the dialog
                      // does not overflow the screen on large contact lists.
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => ListTile(
                            title: Text(filtered[i].fullName),
                            onTap: () => Navigator.of(ctx).pop(filtered[i]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Shows merge-or-not dialog after a partner is selected.
  // Returns true (merge), false (no merge), null (Cancel — back to picker).
  Future<bool?> _showMergeDialog(Person partner) async {
    return showDialog<bool?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Merge existing topics?'),
        content: Text(
          '${widget.person.firstName} and ${partner.firstName} will share '
          'their catch-up topics. Duplicates will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No, keep separate'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, merge'),
          ),
        ],
      ),
    );
  }

  // Orchestrates the full couple link flow:
  // Person picker → merge dialog → link + optional merge → state refresh.
  // "Cancel" in the merge dialog loops back to the person picker.
  Future<void> _showCoupleLinkFlow() async {
    while (true) {
      final picked = await _showPersonPickerDialog();
      if (picked == null || !mounted) return;

      final merge = await _showMergeDialog(picked);
      if (!mounted) return;
      if (merge == null) continue; // Cancel → back to picker

      final userId = AuthService().currentUserId!;
      final now = DateTime.now();
      await _personRepo.linkPartner(userId, widget.person.id, picked.id);

      if (merge) {
        await _catchUpRepo.mergeTopics(userId, widget.person.id, picked.id);
        if (mounted) await _loadTopics();
      }

      if (!mounted) return;
      // Update provider immediately so CoupleLinkSection re-renders without
      // requiring the user to leave and re-enter the screen.
      context.read<PersonDetailProvider>().setPartner(picked.id, now);
      setState(() => _partnerPerson = picked);
      return;
    }
  }

  Future<void> _addTopic(String text, String? label) async {
    // Read partnerId before any await to avoid using BuildContext across async gaps.
    final partnerId = context.read<PersonDetailProvider>().person?.partnerId ??
        widget.person.partnerId;
    try {
      final userId = AuthService().currentUserId!;
      final id = await _catchUpRepo.add(userId, widget.person.id, text, label);
      if (!mounted) return;
      final newTopic = CatchUpTopic(
        id: id,
        text: text,
        contextLabel: label,
        createdAt: DateTime.now(),
      );
      setState(() => _topics = [newTopic, ..._topics]);

      if (partnerId != null) {
        // Fire-and-forget — partner propagation failure must not affect the UI.
        _catchUpRepo.add(userId, partnerId, text, label).catchError((_) => '');
      }
    } catch (_) {}
  }

  Future<void> _editTopic(
      String topicId, String newText, String? newLabel) async {
    // Optimistic update so the UI feels instant.
    setState(() {
      _topics = _topics.map((t) {
        if (t.id != topicId) return t;
        return t.copyWith(text: newText, contextLabel: newLabel);
      }).toList();
    });
    try {
      final userId = AuthService().currentUserId!;
      await _catchUpRepo.update(
          userId, widget.person.id, topicId, newText, newLabel);
    } catch (_) {}
  }

  Future<void> _deleteTopic(String topicId) async {
    // Optimistic removal so the UI feels instant.
    setState(() => _topics = _topics.where((t) => t.id != topicId).toList());
    try {
      final userId = AuthService().currentUserId!;
      await _catchUpRepo.delete(userId, widget.person.id, topicId);
    } catch (_) {}
  }

  // Optimistically moves the topic from active to archived list, then archives in Firestore.
  // If the person is linked to a partner, also archives the matching topic on the partner.
  Future<void> _archiveTopic(String topicId) async {
    final topic = _topics.firstWhere((t) => t.id == topicId,
        orElse: () => CatchUpTopic(
              id: topicId,
              text: '',
              createdAt: DateTime.now(),
              isArchived: true,
            ));
    if (!mounted) return;
    setState(() {
      _topics = _topics.where((t) => t.id != topicId).toList();
      _archivedTopics = [
        topic.copyWith(isArchived: true, archivedAt: DateTime.now()),
        ..._archivedTopics,
      ];
    });
    // Read partnerId before any await to avoid using BuildContext across async gaps.
    final partnerId = context.read<PersonDetailProvider>().person?.partnerId ??
        widget.person.partnerId;
    try {
      final userId = AuthService().currentUserId!;
      await _catchUpRepo.archive(userId, widget.person.id, topicId);

      // Mirror archive to partner if linked (fire-and-forget).
      if (partnerId != null && topic.text.isNotEmpty) {
        _archivePartnerTopicByText(userId, partnerId, topic.text);
      }
    } catch (_) {}
  }

  // Finds the matching active topic on the partner by case-insensitive text
  // and archives it. Fire-and-forget — failure must not affect the UI.
  Future<void> _archivePartnerTopicByText(
    String userId,
    String partnerId,
    String text,
  ) async {
    try {
      final partnerTopics = await _catchUpRepo.getActive(userId, partnerId);
      final normalizedText = text.trim().toLowerCase();
      final match = partnerTopics.cast<CatchUpTopic?>().firstWhere(
            (t) => t!.text.trim().toLowerCase() == normalizedText,
            orElse: () => null,
          );
      if (match != null) {
        await _catchUpRepo.archive(userId, partnerId, match.id);
      }
    } catch (_) {}
  }

  // Loads archived topics from cache / Firestore on demand (called when History expands).
  Future<void> _loadArchivedTopics() async {
    if (!mounted) return;
    setState(() => _archivedLoading = true);
    try {
      final userId = AuthService().currentUserId!;
      final archived = await _catchUpRepo.getArchived(userId, widget.person.id);
      if (mounted) {
        setState(() {
          _archivedTopics = archived;
          _archivedLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _archivedLoading = false);
    }
  }

  // Optimistically removes an archived topic from the local list, then deletes from Firestore.
  Future<void> _deleteArchivedTopic(String topicId) async {
    if (!mounted) return;
    setState(() => _archivedTopics =
        _archivedTopics.where((t) => t.id != topicId).toList());
    try {
      final userId = AuthService().currentUserId!;
      await _catchUpRepo.delete(userId, widget.person.id, topicId);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonDetailProvider>();
    final person = provider.person ?? widget.person;

    return Scaffold(
      appBar: AppBar(
        title: Text(person.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: provider.isDeleting
                ? null
                : () => _handleDelete(context, provider),
          ),
        ],
      ),
      body: _PersonDetailBody(
        provider: provider,
        topics: _topics,
        topicsLoading: _topicsLoading,
        person: person,
        onLinkTap: () => _showLinkDialog(provider),
        onSendTap: () => _openShareMeetingsScreen(person),
        onMeetingsTap: () => _openPersonMeetingsScreen(person),
        onBirthdayTap: () => _showBirthdayPicker(person, provider),
        onAddTopicTap: () => _showAddTopicDialog(person),
        onDeleteTopic: _deleteTopic,
        onEditTopic: (CatchUpTopic topic) => _showEditTopicDialog(topic),
        onArchiveTopic: _archiveTopic,
        archivedTopics: _archivedTopics,
        archivedLoading: _archivedLoading,
        onLoadArchived: _loadArchivedTopics,
        onDeleteArchivedTopic: _deleteArchivedTopic,
        partnerPerson: _partnerPerson,
        onCoupleLinkTap: _showCoupleLinkFlow,
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, PersonDetailProvider provider) async {
    final person = provider.person ?? widget.person;
    final firstNameController = TextEditingController(text: person.firstName);
    final lastNameController =
        TextEditingController(text: person.lastName ?? '');

    // Show warning banner when: caller provided a check, the name already
    // exists in the list (excluding self), and the person has no nicknames.
    final showDuplicateWarning = widget.personNameExists != null &&
        person.nicknames.isEmpty &&
        widget.personNameExists!(
          person.firstName,
          person.lastName ?? '',
          excludeId: person.id,
        );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDuplicateWarning) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Theme.of(ctx).colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You already have someone with this name. Consider adding a nickname.',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true || !context.mounted) return;

    final success = await provider.updatePerson(
      firstNameController.text,
      lastNameController.text,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Person updated'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update person.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(
      BuildContext context, PersonDetailProvider provider) async {
    final count = provider.meetingCount;

    if (count == 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Person'),
          content: const Text(
              'Are you sure you want to delete this person? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Person'),
          content: Text(
            'This person appears in $count meeting${count == 1 ? '' : 's'}. '
            'Deleting them will not remove those meetings. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete anyway'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    final success = await provider.deletePerson();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop('deleted');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to delete person.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Opens PersonMeetingsScreen and refreshes meeting count on return.
  // Refresh is required because the user may have deleted meetings.
  void _openPersonMeetingsScreen(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonMeetingsScreen(person: person),
      ),
    ).then((_) {
      if (!mounted) return;
      context.read<PersonDetailProvider>().refreshMeetingCount();
    });
  }

  // Opens ShareMeetingsScreen for the linked person.
  // Method lives on State so context is always alive after async operations.
  void _openShareMeetingsScreen(Person person) {
    final provider = ShareMeetingsProvider(
      meetingRepository: MeetingRepository(),
      personRepository: PersonRepository(),
      categoryRepository: ActivityCategoryRepository(),
      authService: AuthService(),
      meetingPackageService: MeetingPackageService(),
      targetPersonId: person.id,
      recipientUid: person.linkedUserId!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: ShareMeetingsScreen(person: person),
        ),
      ),
    );
  }

  // Opens a month/day picker dialog. Year is never stored (GDPR).
  // StatefulBuilder manages dropdown state; day list is clamped to month max.
  // Method lives on State so context is always alive after async gaps.
  Future<void> _showBirthdayPicker(
      Person person, PersonDetailProvider provider) async {
    int? selectedMonth;
    int? selectedDay;
    if (person.birthDayMonth != null) {
      final parts = person.birthDayMonth!.split('-');
      selectedMonth = int.parse(parts[0]);
      selectedDay = int.parse(parts[1]);
    }

    // Max days per month using leap year (Feb = 29).
    const maxDays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final int currentMax =
              selectedMonth != null ? maxDays[selectedMonth! - 1] : 31;

          return AlertDialog(
            title: const Text('Birthday'),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Month'),
                      DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        hint: const Text('Month'),
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(monthNames[i]),
                          ),
                        ),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedMonth = val;
                            // Clamp day to new month's max days.
                            if (selectedDay != null && selectedMonth != null) {
                              final max = maxDays[selectedMonth! - 1];
                              if (selectedDay! > max) selectedDay = max;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Day'),
                      DropdownButton<int>(
                        value: selectedDay,
                        isExpanded: true,
                        hint: const Text('Day'),
                        items: List.generate(
                          currentMax,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (val) {
                          setDialogState(() => selectedDay = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (person.birthDayMonth != null)
                TextButton(
                  onPressed: () async {
                    await provider.updateBirthDayMonth(null);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Clear'),
                ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: selectedMonth != null && selectedDay != null
                    ? () async {
                        final formatted =
                            '${selectedMonth!.toString().padLeft(2, '0')}-'
                            '${selectedDay!.toString().padLeft(2, '0')}';
                        await provider.updateBirthDayMonth(formatted);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      }
                    : null,
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Opens the add-topic dialog: required topic text + optional month/year picker.
  // Method lives on State so context is always alive after async gaps.
  //
  // Design note: the Confirm button uses ValueListenableBuilder instead of
  // onChanged + setDialogState. This avoids calling StatefulBuilder's setState
  // during IME callbacks that Android fires when the keyboard dismisses — those
  // callbacks can arrive on a partially-deactivated dialog element and trigger
  // '_dependents.isEmpty: is not true' / 'dirty widget in wrong build scope'.
  Future<void> _showAddTopicDialog(Person person) async {
    final textController = TextEditingController();
    int? selectedMonth;
    int? selectedYear;

    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - 1 + i);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        // StatefulBuilder is used ONLY for the dropdown state (month, year).
        // The text field does NOT call setDialogState — see Confirm button below.
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Add topic'),
            // SizedBox(width: maxFinite) prevents IntrinsicWidth from
            // expanding the dialog as the user types in the TextField.
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Topic'),
                    textCapitalization: TextCapitalization.sentences,
                    // No onChanged → no setDialogState calls from the keyboard path.
                    // Confirm button reactivity is handled by ValueListenableBuilder.
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'When? (optional)',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          hint: const Text('Month'),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text(monthNames[i]),
                            ),
                          ),
                          onChanged: (v) =>
                              setDialogState(() => selectedMonth = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          hint: const Text('Year'),
                          items: years
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text('$y'),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => selectedYear = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              // ValueListenableBuilder watches the controller directly.
              // It rebuilds only when text changes — independent of StatefulBuilder.
              // Its own State properly removes the listener in dispose(), so no
              // setState is called after the dialog element is deactivated.
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: textController,
                builder: (_, value, __) => TextButton(
                  onPressed: value.text.trim().isEmpty
                      ? null
                      : () {
                          final text = value.text.trim();
                          String? label;
                          if (selectedMonth != null && selectedYear != null) {
                            label =
                                '${monthNames[selectedMonth! - 1]} $selectedYear';
                          }
                          // Dismiss keyboard before popping so Android IME cannot
                          // fire further input callbacks on the closing dialog.
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(ctx).pop();
                          if (!mounted) return;
                          _addTopic(text, label);
                        },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          );
        },
      ),
    );
    // Do NOT call textController.dispose() here.
    // showDialog() returns as soon as the route is popped, but the dialog's
    // exit animation is still in progress. TextField and ValueListenableBuilder
    // both hold listeners on the controller during that animation. Disposing
    // early causes 'TextEditingController used after being disposed', which
    // cascades into _dependents.isEmpty and dirty-widget-in-wrong-build-scope.
    // The controller is a local variable; once the dialog fully unmounts and
    // removes all listeners, it becomes unreachable and is garbage-collected.
  }

  // Opens a prefilled edit dialog for an existing catch-up topic.
  // Reuses the same layout as the add dialog with current values pre-populated.
  Future<void> _showEditTopicDialog(CatchUpTopic topic) async {
    final textController = TextEditingController(text: topic.text);

    // Pre-parse existing contextLabel (format: "Month Year", e.g. "July 2026").
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    int? selectedMonth;
    int? selectedYear;
    if (topic.contextLabel != null) {
      final parts = topic.contextLabel!.split(' ');
      if (parts.length == 2) {
        final mIdx = monthNames.indexOf(parts[0]);
        final y = int.tryParse(parts[1]);
        if (mIdx >= 0) selectedMonth = mIdx + 1;
        if (y != null) selectedYear = y;
      }
    }

    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - 1 + i);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Edit topic'),
            // SizedBox(width: maxFinite) prevents IntrinsicWidth from
            // expanding the dialog as the user types in the TextField.
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Topic'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  Text('When? (optional)',
                      style: Theme.of(ctx).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          hint: const Text('Month'),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                                value: i + 1, child: Text(monthNames[i])),
                          ),
                          onChanged: (v) =>
                              setDialogState(() => selectedMonth = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          hint: const Text('Year'),
                          items: years
                              .map((y) =>
                                  DropdownMenuItem(value: y, child: Text('$y')))
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => selectedYear = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: textController,
                builder: (_, value, __) => TextButton(
                  onPressed: value.text.trim().isEmpty
                      ? null
                      : () {
                          final text = value.text.trim();
                          String? label;
                          if (selectedMonth != null && selectedYear != null) {
                            label =
                                '${monthNames[selectedMonth! - 1]} $selectedYear';
                          }
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(ctx).pop();
                          if (!mounted) return;
                          _editTopic(topic.id, text, label);
                        },
                  child: const Text('Save'),
                ),
              ),
            ],
          );
        },
      ),
    );
    // Do NOT dispose textController here — see comment in _showAddTopicDialog.
  }

  // Opens the token input dialog and handles linking result.
  // Method lives on State so context is always alive (not from a closure).
  Future<void> _showLinkDialog(PersonDetailProvider provider) async {
    final tokenController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter sharing token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ask your friend to generate a token in Friendsheet and enter it below.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenController,
              decoration:
                  const InputDecoration(labelText: 'Token (6 characters)'),
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [_UpperCaseTextFormatter()],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Link'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await provider.linkFriendAccount(tokenController.text);
    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account linked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final message = switch (result.error!) {
        TokenValidationError.notFound =>
          'Invalid token. Check the code and try again.',
        TokenValidationError.expired =>
          'This token has expired. Ask your friend to generate a new one.',
        TokenValidationError.alreadyUsed => 'This token has already been used.',
        TokenValidationError.serverError =>
          'Something went wrong. Check your connection and try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}

// Formats "MM-dd" string as "d MMM" (e.g. "03-15" -> "15 Mar").
// Returns "Not set" when value is null.
String _formatBirthDayMonth(String? value) {
  if (value == null) return 'Not set';
  final parts = value.split('-');
  final month = int.parse(parts[0]);
  final day = int.parse(parts[1]);
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '$day ${months[month]}';
}

class _PersonDetailBody extends StatelessWidget {
  final PersonDetailProvider provider;
  final List<CatchUpTopic> topics;
  final bool topicsLoading;
  final Person person;
  final VoidCallback onLinkTap;
  final VoidCallback onSendTap;
  final VoidCallback onMeetingsTap;
  final VoidCallback onBirthdayTap;
  final VoidCallback onAddTopicTap;
  final Future<void> Function(String topicId) onDeleteTopic;
  final void Function(CatchUpTopic topic) onEditTopic;
  final Future<void> Function(String topicId) onArchiveTopic;
  final List<CatchUpTopic> archivedTopics;
  final bool archivedLoading;
  final VoidCallback onLoadArchived;
  final Future<void> Function(String topicId) onDeleteArchivedTopic;
  final Person? partnerPerson;
  final VoidCallback onCoupleLinkTap;

  const _PersonDetailBody({
    required this.provider,
    required this.topics,
    required this.topicsLoading,
    required this.person,
    required this.onLinkTap,
    required this.onSendTap,
    required this.onMeetingsTap,
    required this.onBirthdayTap,
    required this.onAddTopicTap,
    required this.onDeleteTopic,
    required this.onEditTopic,
    required this.onArchiveTopic,
    required this.archivedTopics,
    required this.archivedLoading,
    required this.onLoadArchived,
    required this.onDeleteArchivedTopic,
    required this.partnerPerson,
    required this.onCoupleLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    return ListView(
      children: [
        if (provider.score != null)
          RelationshipStrengthWidget(score: provider.score!),
        ListTile(
          title: const Text('First Name'),
          subtitle: Text(person.firstName),
        ),
        if (person.lastName != null && person.lastName!.isNotEmpty)
          ListTile(
            title: const Text('Last Name'),
            subtitle: Text(person.lastName!),
          ),
        ListTile(
          leading: const Icon(Icons.cake_outlined),
          title: const Text('Birthday'),
          subtitle: Text(_formatBirthDayMonth(person.birthDayMonth)),
          trailing: const Icon(Icons.edit_outlined),
          onTap: onBirthdayTap,
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Meetings together'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${provider.meetingCount}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'View meetings',
                onPressed: onMeetingsTap,
              ),
            ],
          ),
        ),
        CatchUpListSection(
          topics: topics,
          isLoading: topicsLoading,
          personId: person.id,
          onAddTap: onAddTopicTap,
          onDelete: onDeleteTopic,
          onEdit: onEditTopic,
          onArchive: onArchiveTopic,
        ),
        HistorySection(
          archivedTopics: archivedTopics,
          archivedLoading: archivedLoading,
          onLoadArchived: onLoadArchived,
          onDeleteArchivedTopic: onDeleteArchivedTopic,
        ),
        CoupleLinkSection(
          person: person,
          partnerPerson: partnerPerson,
          onLinkTap: onCoupleLinkTap,
        ),
        NicknamesSection(provider: provider, person: person),
        _GroupsSection(person: person),
        _SharingSection(
          provider: provider,
          person: person,
          onLinkTap: onLinkTap,
          onSendTap: onSendTap,
        ),
      ],
    );
  }
}

// Groups section — shows all friend groups with a checkbox for this person.
// FriendGroupsProvider is injected at the call-site (PersonsListScreen._openPerson).
class _GroupsSection extends StatelessWidget {
  final Person person;

  const _GroupsSection({required this.person});

  @override
  Widget build(BuildContext context) {
    final groupsProvider = context.watch<FriendGroupsProvider>();
    final groups = groupsProvider.groups;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Groups', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (groups.isEmpty)
            Text(
              'No groups yet',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            )
          else
            ...groups.map(
              (group) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: ActivityIcon(
                  identifier: group.iconIdentifier,
                  size: 20,
                ),
                title: Text(group.name),
                value: group.personIds.contains(person.id),
                onChanged: (checked) {
                  if (checked == true) {
                    groupsProvider.addPersonToGroup(group.id, person.id);
                  } else {
                    groupsProvider.removePersonFromGroup(group.id, person.id);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Sharing section — "Share meetings with friend" when unlinked, "Send meetings" when linked.
// Callbacks come from _PersonDetailScreenState to avoid stale context.
class _SharingSection extends StatelessWidget {
  final PersonDetailProvider provider;
  final Person person;
  final VoidCallback onLinkTap;
  final VoidCallback onSendTap;

  const _SharingSection({
    required this.provider,
    required this.person,
    required this.onLinkTap,
    required this.onSendTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLinked = person.linkedUserId != null;

    return ListTile(
      leading: Icon(isLinked ? Icons.send : Icons.share),
      title: Text(isLinked ? 'Send meetings' : 'Share meetings with friend'),
      subtitle: isLinked ? const Text('Account linked') : null,
      enabled: isLinked ? true : !provider.isLinking,
      onTap: isLinked ? onSendTap : onLinkTap,
    );
  }
}

// Forces all typed characters to uppercase for the token input field.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
