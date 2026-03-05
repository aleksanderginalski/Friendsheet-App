import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/person.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';
import '../persons/person_detail_provider.dart';
import '../persons/person_detail_screen.dart';
import '../persons/person_list_tile.dart';
import '../persons/persons_list_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/person_autocomplete.dart';

/// Displays the list of all persons for the current user with search support.
/// PersonsListProvider is provided by MainScreen via ChangeNotifierProvider.value.
class PersonsListScreen extends StatelessWidget {
  const PersonsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PersonsListView();
  }
}

class _PersonsListView extends StatelessWidget {
  const _PersonsListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonsListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PEOPLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add person',
            onPressed: () => _showAddPersonDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => context
                            .read<PersonsListProvider>()
                            .setSearchQuery(''),
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) =>
                  context.read<PersonsListProvider>().setSearchQuery(value),
            ),
          ),
          Expanded(
            child: _PersonsListBody(provider: provider),
          ),
        ],
      ),
    );
  }

  // Shows the AddPersonDialog and saves the new person to Firestore on confirm.
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
  final PersonsListProvider provider;

  const _PersonsListBody({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    final persons = provider.persons;

    if (persons.isEmpty && provider.searchQuery.isEmpty) {
      return const EmptyStateWidget(
        imagePath: 'assets/images/empty_state_friends.png',
        message: 'No friends added yet — tap + to get started!',
      );
    }

    if (persons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No results for "${provider.searchQuery}"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: persons.length,
      itemBuilder: (context, index) {
        final person = persons[index];
        return PersonListTile(
          person: person,
          onTap: () async {
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
            // Refresh after returning — person may have been edited or deleted.
            if (context.mounted) {
              context.read<PersonsListProvider>().initialize();
            }
          },
        );
      },
    );
  }
}
