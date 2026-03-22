import 'package:flutter/material.dart';

import '../../data/models/person.dart';

/// Full-screen search picker that returns the selected [Person] via
/// [Navigator.pop]. Returns null if the user navigates back without picking.
class PersonPickerScreen extends StatefulWidget {
  final List<Person> persons;

  const PersonPickerScreen({super.key, required this.persons});

  @override
  State<PersonPickerScreen> createState() => _PersonPickerScreenState();
}

class _PersonPickerScreenState extends State<PersonPickerScreen> {
  final _controller = TextEditingController();
  late List<Person> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.persons;
    _controller.addListener(_onSearch);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _controller.text.toLowerCase();
    setState(() {
      _filtered = widget.persons
          .where((p) => p.fullName.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Person')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search persons...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_filtered[i].fullName),
                onTap: () => Navigator.pop(context, _filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
