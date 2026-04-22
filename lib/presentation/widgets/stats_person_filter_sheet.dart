import 'package:flutter/material.dart';

import '../../data/models/friend_group.dart';
import '../../l10n/app_localizations.dart';
import '../activities/activity_icons.dart';

typedef PersonEntry = ({String personId, String name});

enum _GroupCheckState { all, partial, none }

/// Content widget for the person-filter bottom sheet.
/// Caller is responsible for wrapping this in showModalBottomSheet +
/// DraggableScrollableSheet. Do NOT call showModalBottomSheet here.
class StatsPersonFilterSheet extends StatefulWidget {
  final List<PersonEntry> allEntries;
  final Set<String> selectedPersonIds;
  final List<FriendGroup> groups;
  final void Function(String personId) onTogglePerson;
  final void Function(Set<String> newIds) onReplaceSelection;
  final VoidCallback onAutoSelectTop10;

  const StatsPersonFilterSheet({
    super.key,
    required this.allEntries,
    required this.selectedPersonIds,
    required this.groups,
    required this.onTogglePerson,
    required this.onReplaceSelection,
    required this.onAutoSelectTop10,
  });

  @override
  State<StatsPersonFilterSheet> createState() => _StatsPersonFilterSheetState();
}

class _StatsPersonFilterSheetState extends State<StatsPersonFilterSheet> {
  late Set<String> _selected;
  String _searchQuery = '';
  final Set<String> _expandedGroups = {};

  // Do NOT dispose — local controller is GC'd when sheet fully unmounts.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedPersonIds);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  Set<String> get _assignedPersonIds =>
      widget.groups.expand((g) => g.personIds).toSet();

  _GroupCheckState _groupState(FriendGroup group) {
    final members = widget.allEntries
        .where((e) => group.personIds.contains(e.personId))
        .map((e) => e.personId)
        .toSet();
    if (members.isEmpty) return _GroupCheckState.none;
    final selectedCount = members.where(_selected.contains).length;
    if (selectedCount == members.length) return _GroupCheckState.all;
    if (selectedCount == 0) return _GroupCheckState.none;
    return _GroupCheckState.partial;
  }

  void _toggleGroup(FriendGroup group) {
    final members = widget.allEntries
        .where((e) => group.personIds.contains(e.personId))
        .map((e) => e.personId)
        .toSet();
    final state = _groupState(group);
    setState(() {
      if (state == _GroupCheckState.all) {
        _selected.removeAll(members);
      } else {
        _selected.addAll(members);
      }
    });
    widget.onReplaceSelection(Set.from(_selected));
  }

  void _togglePerson(String personId) {
    setState(() {
      if (_selected.contains(personId)) {
        _selected.remove(personId);
      } else {
        _selected.add(personId);
      }
    });
    widget.onTogglePerson(personId);
  }

  void _applyTop10() {
    widget.onAutoSelectTop10();
    if (mounted) Navigator.pop(context);
  }

  void _applySelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selected = widget.allEntries.map((e) => e.personId).toSet();
      } else {
        _selected = {};
      }
    });
    widget.onReplaceSelection(Set.from(_selected));
  }

  List<PersonEntry> get _filteredEntries {
    if (_searchQuery.isEmpty) return widget.allEntries;
    final q = _searchQuery.toLowerCase();
    return widget.allEntries
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
  }

  Widget _buildGroupCheckbox(_GroupCheckState state) {
    switch (state) {
      case _GroupCheckState.all:
        return const Icon(Icons.check_box, size: 20);
      case _GroupCheckState.partial:
        return const Icon(Icons.indeterminate_check_box, size: 20);
      case _GroupCheckState.none:
        return const Icon(Icons.check_box_outline_blank, size: 20);
    }
  }

  Widget _buildPersonTile(PersonEntry entry) {
    final isSelected = _selected.contains(entry.personId);
    return CheckboxListTile(
      dense: true,
      value: isSelected,
      title: Text(entry.name, style: const TextStyle(fontSize: 13)),
      onChanged: (_) => _togglePerson(entry.personId),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  List<Widget> _buildGroupedList(AppLocalizations l10n) {
    final assigned = _assignedPersonIds;
    final items = <Widget>[];

    for (final group in widget.groups) {
      final members = widget.allEntries
          .where((e) => group.personIds.contains(e.personId))
          .toList();
      if (members.isEmpty) continue;

      final state = _groupState(group);
      final isExpanded = _expandedGroups.contains(group.id);

      items.add(_GroupRow(
        group: group,
        state: state,
        isExpanded: isExpanded,
        groupCheckbox: _buildGroupCheckbox(state),
        onToggleGroup: () => _toggleGroup(group),
        onToggleExpand: () => setState(() {
          if (isExpanded) {
            _expandedGroups.remove(group.id);
          } else {
            _expandedGroups.add(group.id);
          }
        }),
      ));

      if (isExpanded) {
        for (final entry in members) {
          items.add(_buildPersonTile(entry));
        }
      }
    }

    final ungrouped =
        widget.allEntries.where((e) => !assigned.contains(e.personId)).toList();
    if (ungrouped.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          l10n.statsFilterNoGroup,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ));
      for (final entry in ungrouped) {
        items.add(_buildPersonTile(entry));
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allSelected = _selected.length == widget.allEntries.length;
    final hiddenCount =
        widget.allEntries.where((e) => !_selected.contains(e.personId)).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.statsFilterSheetTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.statsFilterSearch,
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: _applyTop10,
              child: Text(l10n.statsFilterAutoSelectTop10),
            ),
            TextButton(
              onPressed: () => _applySelectAll(!allSelected),
              child: Text(
                allSelected
                    ? l10n.statsFilterDeselectAll
                    : l10n.statsFilterSelectAll,
              ),
            ),
          ],
        ),
        if (hiddenCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.statsFilterHiddenHint(hiddenCount),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: _searchQuery.isNotEmpty
              ? ListView(
                  children: _filteredEntries.map(_buildPersonTile).toList(),
                )
              : ListView(
                  children: _buildGroupedList(l10n),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.statsFilterClose),
          ),
        ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  final FriendGroup group;
  final _GroupCheckState state;
  final bool isExpanded;
  final Widget groupCheckbox;
  final VoidCallback onToggleGroup;
  final VoidCallback onToggleExpand;

  const _GroupRow({
    required this.group,
    required this.state,
    required this.isExpanded,
    required this.groupCheckbox,
    required this.onToggleGroup,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggleGroup,
            child: groupCheckbox,
          ),
          const SizedBox(width: 4),
          group.iconIdentifier != null
              ? ActivityIcon(identifier: group.iconIdentifier, size: 20)
              : const Icon(Icons.group, size: 20),
        ],
      ),
      title: Text(
        group.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      trailing: IconButton(
        icon: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          size: 20,
        ),
        onPressed: onToggleExpand,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      onTap: onToggleExpand,
    );
  }
}
