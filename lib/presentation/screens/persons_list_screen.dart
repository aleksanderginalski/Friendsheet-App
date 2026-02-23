import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/meeting_repository.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/auth_service.dart';
import '../persons/person_detail_provider.dart';
import '../persons/person_detail_screen.dart';
import '../persons/person_list_tile.dart';
import '../persons/persons_list_provider.dart';

/// Displays the list of all persons for the current user with search support.
class PersonsListScreen extends StatelessWidget {
  const PersonsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PersonsListProvider(
        personRepository: PersonRepository(),
        authService: AuthService(),
      )..initialize(),
      child: const _PersonsListView(),
    );
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No people yet!\nAdd participants when creating a meeting.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (persons.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results for "${provider.searchQuery}"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
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
