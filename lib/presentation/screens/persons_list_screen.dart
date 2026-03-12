import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/friend_group.dart';
import '../../data/models/person.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';
import '../activities/activity_icons.dart';
import '../persons/friend_groups_provider.dart';
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
  Widget build(BuildContext context) {
    return const _PersonsListView();
  }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PEOPLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add person',
            onPressed: () => _showAddPersonDialog(context),
          ),
          IconButton(
            icon: Icon(_isSearchActive ? Icons.search_off : Icons.search),
            tooltip: _isSearchActive ? 'Close search' : 'Search',
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchActive)
            SharedSearchBar(
              controller: _searchController,
              hintText: 'Search friends...',
              onChanged: (value) =>
                  context.read<PersonsListProvider>().setSearchQuery(value),
            ),
          const Expanded(child: _PersonsListBody()),
        ],
      ),
    );
  }

  Future<void> _showAddPersonDialog(BuildContext context) async {
    final result = await showDialog<({String firstName, String lastName})>(
      context: context,
      builder: (_) => const AddPersonDialog(initialFirstName: ''),
    );

    if (result == null || !context.mounted) return;

    try {
      final userId = AuthService().currentUserId!;
      final person = Person(
        id: '',
        userId: userId,
        firstName: result.firstName,
        lastName: result.lastName.isEmpty ? null : result.lastName,
        createdAt: DateTime.now(),
      );
      await PersonRepository().addPerson(person);

      if (context.mounted) {
        context.read<PersonsListProvider>().initialize();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Person added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _PersonsListBody extends StatelessWidget {
  const _PersonsListBody();

  // Navigates to PersonDetailScreen and refreshes persons list on return.
  Future<void> _openPerson(BuildContext context, Person person) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PersonDetailProvider(
            personRepository: PersonRepository(),
            meetingRepository: MeetingRepository(),
            authService: AuthService(),
          ),
          child: PersonDetailScreen(person: person),
        ),
      ),
    );
    if (context.mounted) {
      context.read<PersonsListProvider>().initialize();
    }
  }

  // Resolves Person objects for a group from the full persons list.
  // Stale IDs (person deleted but still referenced in a group) are skipped.
  List<Person> _resolvePersons(FriendGroup group, List<Person> allPersons) {
    final index = {for (final p in allPersons) p.id: p};
    return group.personIds.map((id) => index[id]).whereType<Person>().toList();
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

        if (allPersons.isEmpty && personsProvider.searchQuery.isEmpty) {
          return const EmptyStateWidget(
            imagePath: 'assets/images/empty_state_friends.png',
            message: 'No friends added yet — tap + to get started!',
          );
        }

        // Search active: show flat filtered results across all sections.
        if (personsProvider.searchQuery.isNotEmpty) {
          if (allPersons.isEmpty) {
            return EmptyStateWidget(
              imagePath: 'assets/images/empty_state_friends.png',
              message: 'No results for "${personsProvider.searchQuery}"',
            );
          }
          return ListView.builder(
            itemCount: allPersons.length,
            itemBuilder: (context, index) => PersonListTile(
              person: allPersons[index],
              onTap: () => _openPerson(context, allPersons[index]),
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
              _GroupSection(
                group: group,
                persons: _resolvePersons(group, allPersons),
                onPersonTap: (p) => _openPerson(context, p),
              ),
            if (ungrouped.isNotEmpty)
              _UngroupedSection(
                persons: ungrouped,
                onPersonTap: (p) => _openPerson(context, p),
              ),
          ],
        );
      },
    );
  }
}

// Collapsible ExpansionTile for a single friend group.
class _GroupSection extends StatelessWidget {
  final FriendGroup group;
  final List<Person> persons;
  final ValueChanged<Person> onPersonTap;

  const _GroupSection({
    required this.group,
    required this.persons,
    required this.onPersonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      leading: group.iconIdentifier != null
          ? ActivityIcon(identifier: group.iconIdentifier)
          : const Icon(Icons.group),
      title: Text(group.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (persons.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${persons.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          // Spacer to avoid overlap with the ExpansionTile expand arrow.
          const SizedBox(width: 24),
        ],
      ),
      children: persons
          .map((p) => PersonListTile(person: p, onTap: () => onPersonTap(p)))
          .toList(),
    );
  }
}

// Non-collapsible section for persons not assigned to any group.
class _UngroupedSection extends StatelessWidget {
  final List<Person> persons;
  final ValueChanged<Person> onPersonTap;

  const _UngroupedSection({
    required this.persons,
    required this.onPersonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Ungrouped',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        ...persons.map(
          (p) => PersonListTile(person: p, onTap: () => onPersonTap(p)),
        ),
      ],
    );
  }
}
