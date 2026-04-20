import 'package:flutter/material.dart';

import '../../data/models/meeting.dart';

const _monthNames = [
  '',
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

class MeetingPickerSheet extends StatefulWidget {
  final List<Meeting> meetings;
  final void Function(Meeting) onSelected;

  const MeetingPickerSheet({
    super.key,
    required this.meetings,
    required this.onSelected,
  });

  @override
  State<MeetingPickerSheet> createState() => _MeetingPickerSheetState();
}

class _MeetingPickerSheetState extends State<MeetingPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  late final Set<int> _expandedYears;
  late final Set<String> _expandedMonths;

  @override
  void initState() {
    super.initState();
    // Expand all years and months by default so meetings are immediately visible.
    _expandedYears = widget.meetings.map((m) => m.date.year).toSet();
    _expandedMonths = widget.meetings
        .map((m) => _monthKey(m.date.year, m.date.month))
        .toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _monthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  List<Meeting> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.meetings;
    return widget.meetings.where((m) {
      if (m.name.toLowerCase().contains(q)) return true;
      final dateStr =
          '${m.date.day.toString().padLeft(2, '0')}/${m.date.month.toString().padLeft(2, '0')}/${m.date.year}';
      return dateStr.contains(q);
    }).toList();
  }

  // Groups [meetings] by year → month, both sorted descending.
  // Within each month meetings are sorted by date descending.
  Map<int, Map<int, List<Meeting>>> _group(List<Meeting> meetings) {
    final sorted = [...meetings]..sort((a, b) => b.date.compareTo(a.date));
    final map = <int, Map<int, List<Meeting>>>{};
    for (final m in sorted) {
      map
          .putIfAbsent(m.date.year, () => {})
          .putIfAbsent(m.date.month, () => [])
          .add(m);
    }
    final years = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {
      for (final y in years)
        y: {
          for (final mo
              in (map[y]!.keys.toList()..sort((a, b) => b.compareTo(a))))
            mo: map[y]![mo]!,
        },
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final isSearching = _query.trim().isNotEmpty;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or date (dd/mm/yyyy)…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: isSearching
                ? _buildFlatList(filtered, scrollController)
                : _buildGroupedList(_group(filtered), scrollController),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatList(List<Meeting> meetings, ScrollController controller) {
    if (meetings.isEmpty) {
      return const Center(
        child: Text('No meetings found.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      controller: controller,
      itemCount: meetings.length,
      itemBuilder: (_, i) => _meetingTile(meetings[i]),
    );
  }

  Widget _buildGroupedList(
      Map<int, Map<int, List<Meeting>>> grouped, ScrollController controller) {
    return ListView(
      controller: controller,
      children: [
        for (final yearEntry in grouped.entries) ...[
          ListTile(
            tileColor: const Color(0xFFE8F5E9),
            title: Text(
              yearEntry.key.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Icon(_expandedYears.contains(yearEntry.key)
                ? Icons.expand_less
                : Icons.expand_more),
            onTap: () => setState(() {
              if (_expandedYears.contains(yearEntry.key)) {
                _expandedYears.remove(yearEntry.key);
              } else {
                _expandedYears.add(yearEntry.key);
              }
            }),
          ),
          if (_expandedYears.contains(yearEntry.key))
            for (final monthEntry in yearEntry.value.entries) ...[
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  _monthNames[monthEntry.key],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                trailing: Icon(
                  _expandedMonths
                          .contains(_monthKey(yearEntry.key, monthEntry.key))
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 18,
                  color: Colors.grey,
                ),
                onTap: () => setState(() {
                  final key = _monthKey(yearEntry.key, monthEntry.key);
                  if (_expandedMonths.contains(key)) {
                    _expandedMonths.remove(key);
                  } else {
                    _expandedMonths.add(key);
                  }
                }),
              ),
              if (_expandedMonths
                  .contains(_monthKey(yearEntry.key, monthEntry.key)))
                for (final m in monthEntry.value) _meetingTile(m, indent: true),
            ],
        ],
      ],
    );
  }

  Widget _meetingTile(Meeting m, {bool indent = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: indent ? 40 : 16),
      title: Text(m.name),
      subtitle: Text(
        '${m.date.day.toString().padLeft(2, '0')}/'
        '${m.date.month.toString().padLeft(2, '0')}/'
        '${m.date.year}',
      ),
      onTap: () {
        Navigator.of(context).pop();
        widget.onSelected(m);
      },
    );
  }
}
