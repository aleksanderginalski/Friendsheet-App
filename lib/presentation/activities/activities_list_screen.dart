import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../../data/services/auth_service.dart';
import 'activities_list_provider.dart';
import 'activity_icons.dart';
import 'add_edit_activity_dialog.dart';

/// Displays all activity categories in a two-level tree.
/// Level-1 categories are collapsible sections; level-2 categories are leaf tiles.
/// ActivitiesListProvider is provided by MainScreen via ChangeNotifierProvider.value.
class ActivitiesListScreen extends StatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  State<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends State<ActivitiesListScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Defer initialize so the provider is available in context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = AuthService().currentUserId;
      if (userId != null && mounted) {
        context.read<ActivitiesListProvider>().initialize(userId);
      }
    });
  }

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
        context.read<ActivitiesListProvider>().setSearchQuery('');
      }
    });
  }

  void _openAddRootDialog(BuildContext context) {
    final provider = context.read<ActivitiesListProvider>();
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const AddEditActivityDialog(
          availableParents: [],
        ),
      ),
    );
  }

  void _openAddChildDialog(BuildContext context, String parentId) {
    final provider = context.read<ActivitiesListProvider>();
    final roots = provider.rootCategories;
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: AddEditActivityDialog(
          availableParents: roots,
          preselectedParentId: parentId,
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context, ActivityCategory category) {
    final provider = context.read<ActivitiesListProvider>();
    // Exclude the category itself from available parents to avoid self-reference.
    final roots =
        provider.rootCategories.where((c) => c.id != category.id).toList();
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: AddEditActivityDialog(
          initialCategory: category,
          availableParents: roots,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ActivityCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text('Delete "${category.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final userId = AuthService().currentUserId!;
    try {
      await context
          .read<ActivitiesListProvider>()
          .deleteCategory(userId, category.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesListProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Activities'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add activity category',
                onPressed: () => _openAddRootDialog(context),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search activities...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: provider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: provider.setSearchQuery,
                  ),
                ),
              Expanded(
                child: _ActivitiesBody(
                  provider: provider,
                  onAddRoot: () => _openAddRootDialog(context),
                  onAddChild: (parentId) =>
                      _openAddChildDialog(context, parentId),
                  onEdit: (cat) => _openEditDialog(context, cat),
                  onDelete: (cat) => _confirmDelete(context, cat),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivitiesBody extends StatelessWidget {
  final ActivitiesListProvider provider;
  final VoidCallback onAddRoot;
  final ValueChanged<String> onAddChild;
  final ValueChanged<ActivityCategory> onEdit;
  final ValueChanged<ActivityCategory> onDelete;

  const _ActivitiesBody({
    required this.provider,
    required this.onAddRoot,
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final userId = AuthService().currentUserId;
                if (userId != null) provider.initialize(userId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final roots = provider.rootCategories;

    if (roots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_tennis, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No activities yet',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddRoot,
              icon: const Icon(Icons.add),
              label: const Text('Add activity'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: roots.length,
      itemBuilder: (context, index) {
        final root = roots[index];
        return _RootCategoryTile(
          category: root,
          provider: provider,
          onAddChild: onAddChild,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

// ExpansionTile for a level-1 category. Uses a ValueKey derived from the
// expansion state so that programmatic expansion changes (e.g. from search)
// are reflected by recreating the tile with the updated initiallyExpanded value.
class _RootCategoryTile extends StatelessWidget {
  final ActivityCategory category;
  final ActivitiesListProvider provider;
  final ValueChanged<String> onAddChild;
  final ValueChanged<ActivityCategory> onEdit;
  final ValueChanged<ActivityCategory> onDelete;

  const _RootCategoryTile({
    required this.category,
    required this.provider,
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _showOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                onEdit(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                onDelete(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = provider.isExpanded(category.id);
    final children = provider.childrenOf(category.id);
    return GestureDetector(
      onLongPress: category.isGlobal ? null : () => _showOptions(context),
      child: ExpansionTile(
        key: ValueKey('${category.id}_$isExpanded'),
        initiallyExpanded: isExpanded,
        leading: Icon(resolveActivityIcon(category.iconIdentifier)),
        title: Text(category.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add child activity',
              onPressed: () => onAddChild(category.id),
            ),
            // ExpansionTile renders its own arrow after trailing, so we use
            // a small spacer to avoid overlap with the default expand icon.
            const SizedBox(width: 24),
          ],
        ),
        onExpansionChanged: (_) => provider.toggleExpanded(category.id),
        children: children
            .map(
              (child) => _ActivityLeafTile(
                category: child,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            )
            .toList(),
      ),
    );
  }
}

// Tile for a level-2 (leaf) activity category.
// Long-press opens a bottom sheet with Edit and Delete options.
class _ActivityLeafTile extends StatelessWidget {
  final ActivityCategory category;
  final ValueChanged<ActivityCategory> onEdit;
  final ValueChanged<ActivityCategory> onDelete;

  const _ActivityLeafTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _showOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                onEdit(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                onDelete(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(resolveActivityIcon(category.iconIdentifier)),
      title: Text(category.name),
      onLongPress: () => _showOptions(context),
    );
  }
}
