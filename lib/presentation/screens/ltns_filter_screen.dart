import 'package:flutter/material.dart';

import '../../core/utils/person_search_helper.dart';
import '../../data/models/person.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/services/ltns_exclusion_service.dart';

/// Screen for managing which persons appear in the Long Time No See feature.
///
/// Each person can be toggled on/off. Excluded persons are hidden from the
/// LTNS widget and chat mode. Changes are persisted immediately via
/// [LtnsExclusionService].
class LtnsFilterScreen extends StatefulWidget {
  const LtnsFilterScreen({super.key, required this.userId});

  final String userId;

  @override
  State<LtnsFilterScreen> createState() => _LtnsFilterScreenState();
}

class _LtnsFilterScreenState extends State<LtnsFilterScreen> {
  final _exclusionService = LtnsExclusionService();
  final _personRepository = PersonRepository();
  final _searchController = TextEditingController();

  List<Person> _allPersons = [];
  Set<String> _excludedIds = {};
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final persons = await _personRepository.getPersonsByUser(widget.userId);
    final excluded = await _exclusionService.getExcludedIds();
    persons.sort(
        (a, b) => _normalize(a.fullName).compareTo(_normalize(b.fullName)));
    if (!mounted) return;
    setState(() {
      _allPersons = persons;
      _excludedIds = excluded;
      _isLoading = false;
    });
  }

  Future<void> _onToggle(String personId, bool included) async {
    // included = true → switch is ON → person is NOT excluded.
    await _exclusionService.setExcluded(personId, excluded: !included);
    if (!mounted) return;
    setState(() {
      if (included) {
        _excludedIds.remove(personId);
      } else {
        _excludedIds.add(personId);
      }
    });
  }

  /// Normalizes a string for locale-aware sorting.
  /// Maps Polish diacritics to their ASCII equivalents so that names
  /// starting with Ł, Ą, etc. sort in their expected alphabetical position.
  static String _normalize(String s) {
    const polish = 'ąćęłńóśźżĄĆĘŁŃÓŚŹŻ';
    const ascii = 'acelnoszzACELNOSZZ';
    var result = s.toLowerCase();
    for (var i = 0; i < polish.length; i++) {
      result = result.replaceAll(polish[i], ascii[i]);
    }
    return result;
  }

  List<Person> get _filtered {
    if (_query.isEmpty) return _allPersons;
    return _allPersons
        .where((p) => PersonSearchHelper.matches(p, _query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LTNS Filters',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Toggle off friends you don\'t want to see in '
                    'Long Time No See reminders.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or nickname…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final person = _filtered[index];
                      final included = !_excludedIds.contains(person.id);
                      return SwitchListTile(
                        title: Text(person.fullName),
                        value: included,
                        onChanged: (value) => _onToggle(person.id, value),
                        activeThumbColor: const Color(0xFF4CAF50),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
