import 'package:flutter/material.dart';

import '../../data/models/activity_category.dart';

/// Full-screen search picker that returns the selected [ActivityCategory] via
/// [Navigator.pop]. Returns null if the user navigates back without picking.
class ActivityPickerScreen extends StatefulWidget {
  final List<ActivityCategory> categories;

  const ActivityPickerScreen({super.key, required this.categories});

  @override
  State<ActivityPickerScreen> createState() => _ActivityPickerScreenState();
}

class _ActivityPickerScreenState extends State<ActivityPickerScreen> {
  final _controller = TextEditingController();
  late List<ActivityCategory> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.categories;
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
      _filtered = widget.categories
          .where((c) => c.name.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Activity')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_filtered[i].name),
                onTap: () => Navigator.pop(context, _filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
