import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/friend_group.dart';
import '../../data/models/person.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/sharing_token_repository.dart';
import '../../data/services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../persons/add_edit_group_dialog.dart';
import '../persons/assign_persons_bottom_sheet.dart';
import '../persons/friend_groups_provider.dart';
import '../persons/group_section_widgets.dart';
import '../persons/person_detail_provider.dart';
import '../persons/person_detail_screen.dart';
import '../persons/person_list_tile.dart';
import '../persons/persons_list_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/person_autocomplete.dart';
import '../widgets/shared_search_bar.dart';

/// Displays persons grouped by friend groups with an Ungrouped fallback section.
/// PersonsListProvider and FriendGroupsProvider are provided by MainScreen.
class PersonsListScreen extends StatelessWidget {
  const PersonsListScreen({super.key});

  @override
  Widget build(BuildContext context) => const _PersonsListView();
}

class _PersonsListView extends StatefulWidget {
  const _PersonsListView();

  @override
  State<_PersonsListView> createState() => _PersonsListViewState();
}

class _PersonsListViewState extends State<_PersonsListView> {
  final _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        context.read<PersonsListProvider>().setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personsListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.personsListAdd,
            onPressed: () => _showAddBottomSheet(context),
          ),
          IconButton(
            icon: Icon(_isSearchActive ? Icons.search_off : Icons.search),
            tooltip: _isSearchActive
                ? l10n.personsListSearchClose
                : l10n.personsListSearch,
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchActive)
            SharedSearchBar(
              controller: _searchController,
              hintText: l10n.personsListSearchHint,
              onChanged: (value) =>
                  context.read<PersonsListProvider>().setSearchQuery(value),
            ),
          const Expanded(child: _PersonsListBody()),
        ],
      ),
    );
  }

  // Bottom sheet for choosing between adding a person or a group.
  void _showAddBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(l10n.personsListAddPerson),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showAddPersonDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: Text(l10n.personsListAddGroup),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showAddGroupDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPersonDialog(BuildContext context) async {
    final provider = context.read<PersonsListProvider>();
    bool personAdded = false;

    // AddPersonDialog calls onSave internally and pops exactly once.
    // Creation happens before the pop, so personAdded is set before showDialog
    // resolves, letting us correctly show the snackbar only on success.
    await showDialog<void>(
      context: context,
      builder: (_) => AddPersonDialog(
        initialFirstName: '',
        personNameExists: provider.personNameExists,
        onSave: (
            {required firstName, String? lastName, String? nickname}) async {
          final userId = AuthService().currentUserId!;
          final person = Person(
            id: '',
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            nicknames: nickname != null ? [nickname] : [],
            createdAt: DateTime.now(),
          );
          await PersonRepository().addPerson(person);
          personAdded = true;
        },
      ),
    );

    if (!context.mounted) return;
    if (personAdded) {
      provider.initialize();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.personsListPersonAdded),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddGroupDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AddEditGroupDialog(
        onSave: (name, icon) => context.read<FriendGroupsProvider>().addGroup(
              name: name,
              iconIdentifier: icon,
            ),
      ),
    );
  }
}

class _PersonsListBody extends StatelessWidget {
  const _PersonsListBody();

  // Navigates to PersonDetailScreen, injecting FriendGroupsProvider at call-site.
  Future<void> _openPerson(BuildContext context, Person person) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => PersonDetailProvider(
                personRepository: PersonRepository(),
                meetingRepository: MeetingRepository(),
                authService: AuthService(),
                sharingTokenRepository: SharingTokenRepository(),
              ),
            ),
            ChangeNotifierProvider.value(
              value: context.read<FriendGroupsProvider>(),
            ),
          ],
          child: PersonDetailScreen(
            person: person,
            personNameExists:
                context.read<PersonsListProvider>().personNameExists,
          ),
        ),
      ),
    );
    if (context.mounted) context.read<PersonsListProvider>().initialize();
  }

  // Resolves Person objects for a group from the full list.
  // Stale IDs (person deleted but still in a group) are silently skipped.
  List<Person> _resolvePersons(FriendGroup group, List<Person> allPersons) {
    final index = {for (final p in allPersons) p.id: p};
    return group.personIds.map((id) => index[id]).whereType<Person>().toList();
  }

  // Shows bottom sheet with Edit / Delete options for a group.
  // Uses parent [context] after sheet closes — Stale Context Rule.
  void _showGroupOptions(BuildContext context, FriendGroup group) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) {
        final errorColor = Theme.of(sheetCtx).colorScheme.error;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.personsListEditGroup),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showEditGroupDialog(context, group);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: errorColor),
                title: Text(
                  AppLocalizations.of(context)!.personsListDeleteGroup,
                  style: TextStyle(color: errorColor),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showDeleteGroupConfirmation(context, group);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditGroupDialog(BuildContext context, FriendGroup group) {
    showDialog<void>(
      context: context,
      builder: (_) => AddEditGroupDialog(
        initialGroup: group,
        onSave: (name, icon) =>
            context.read<FriendGroupsProvider>().updateGroup(
                  group.copyWith(name: name, iconIdentifier: icon),
                ),
      ),
    );
  }

  Future<void> _showDeleteGroupConfirmation(
      BuildContext context, FriendGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.personsListDeleteGroupTitle),
        content: Text(l10n.personsListDeleteGroupContent(group.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.personsListDeleteGroupConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<FriendGroupsProvider>().deleteGroup(group.id);
  }

  // Shows assign-persons sheet, or snackbar if all persons already assigned.
  void _showAssignPersonsSheet(
      BuildContext context, FriendGroup group, List<Person> allPersons) {
    final available =
        allPersons.where((p) => !group.personIds.contains(p.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.personsListAlreadyInGroup,
          ),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => AssignPersonsBottomSheet(
          group: group,
          available: available,
          groupsProvider: context.read<FriendGroupsProvider>(),
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PersonsListProvider, FriendGroupsProvider>(
      builder: (context, personsProvider, groupsProvider, _) {
        if (personsProvider.isLoading || groupsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (personsProvider.errorMessage != null) {
          return Center(child: Text(personsProvider.errorMessage!));
        }
        final allPersons = personsProvider.persons;
        final l10n = AppLocalizations.of(context)!;
        if (allPersons.isEmpty && personsProvider.searchQuery.isEmpty) {
          return EmptyStateWidget(
            imagePath: 'assets/images/empty_state_friends.png',
            message: l10n.personsListEmpty,
          );
        }
        // Search active: flat filtered results across all sections.
        if (personsProvider.searchQuery.isNotEmpty) {
          if (allPersons.isEmpty) {
            return EmptyStateWidget(
              imagePath: 'assets/images/empty_state_friends.png',
              message: l10n.personsListNoResults(personsProvider.searchQuery),
            );
          }
          return ListView.builder(
            itemCount: allPersons.length,
            itemBuilder: (context, i) => PersonListTile(
              person: allPersons[i],
              displayName: personsProvider.displayNameFor(allPersons[i]),
              onTap: () => _openPerson(context, allPersons[i]),
            ),
          );
        }
        // Grouped view: one ExpansionTile per group, then Ungrouped section.
        final groups = groupsProvider.groups;
        final assignedIds = groups.expand((g) => g.personIds).toSet();
        final ungrouped =
            allPersons.where((p) => !assignedIds.contains(p.id)).toList();
        return ListView(
          children: [
            for (final group in groups)
              GroupSection(
                group: group,
                persons: _resolvePersons(group, allPersons),
                onPersonTap: (p) => _openPerson(context, p),
                onGroupLongPress: () => _showGroupOptions(context, group),
                onAssignPersonTap: () =>
                    _showAssignPersonsSheet(context, group, allPersons),
                displayNameOf: personsProvider.displayNameFor,
              ),
            if (ungrouped.isNotEmpty)
              UngroupedSection(
                persons: ungrouped,
                onPersonTap: (p) => _openPerson(context, p),
                displayNameOf: personsProvider.displayNameFor,
              ),
          ],
        );
      },
    );
  }
}
