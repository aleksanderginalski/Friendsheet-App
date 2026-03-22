import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_category.dart';
import '../../data/services/auth_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/shared_search_bar.dart';
import 'activities_list_provider.dart';
import 'activity_icons.dart';
import 'add_edit_activity_dialog.dart';
import 'merge_category_picker_screen.dart';

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

  Future<void> _openMergePicker(
      BuildContext context, ActivityCategory source) async {
    final provider = context.read<ActivitiesListProvider>();
    final candidates = provider.mergeCandidates(source.id);

    final target = await Navigator.push<ActivityCategory>(
      context,
      MaterialPageRoute(
        builder: (_) => MergeCategoryPickerScreen(
          source: source,
          candidates: candidates,
        ),
      ),
    );

    if (target == null || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Merge categories?'),
        content: Text(
          'Merge "${source.name}" into "${target.name}"?\n\n'
          'All meetings will be updated. "${source.name}" will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('MERGE'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final userId = AuthService().currentUserId!;
    try {
      await context
          .read<ActivitiesListProvider>()
          .mergeCategory(userId, source.id, target.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merged "${source.name}" into "${target.name}"'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merge failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                SharedSearchBar(
                  controller: _searchController,
                  hintText: 'Search activities...',
                  onChanged: provider.setSearchQuery,
                ),
              Expanded(
                child: _ActivitiesBody(
                  provider: provider,
                  onAddRoot: () => _openAddRootDialog(context),
                  onAddChild: (parentId) =>
                      _openAddChildDialog(context, parentId),
                  onEdit: (cat) => _openEditDialog(context, cat),
                  onDelete: (cat) => _confirmDelete(context, cat),
                  onMerge: (cat) => _openMergePicker(context, cat),
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
  final ValueChanged<ActivityCategory> onMerge;

  const _ActivitiesBody({
    required this.provider,
    required this.onAddRoot,
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
    required this.onMerge,
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
      return const EmptyStateWidget(
        imagePath: 'assets/images/empty_state_activities.png',
        message: 'No activities yet — tap + to create your first category!',
      );
    }

    // Search is active but no child categories match — show empty state.
    if (provider.searchQuery.isNotEmpty && !provider.hasSearchResults) {
      return const EmptyStateWidget(
        imagePath: 'assets/images/empty_state_activities.png',
        message: 'No activities found',
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
          onMerge: onMerge,
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
  final ValueChanged<ActivityCategory> onMerge;

  const _RootCategoryTile({
    required this.category,
    required this.provider,
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
    required this.onMerge,
  });

  Future<void> _showOptions(BuildContext context) async {
    final hasNoChildren = provider.childrenOf(category.id).isEmpty;
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
            if (hasNoChildren)
              ListTile(
                leading: const Icon(Icons.merge_type),
                title: const Text('Merge into\u2026'),
                onTap: () {
                  Navigator.of(context).pop();
                  onMerge(category);
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
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: category.isGlobal ? null : () => _showOptions(context),
      child: ExpansionTile(
        key: ValueKey('${category.id}_$isExpanded'),
        initiallyExpanded: isExpanded,
        leading: ActivityIcon(identifier: category.iconIdentifier),
        title: Text(category.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge showing direct child count — hidden for leaf categories.
            if (children.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${children.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
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
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return _ActivityLeafTile(
            category: entry.value,
            isLast: isLast,
            onEdit: onEdit,
            onDelete: onDelete,
            onMerge: onMerge,
          );
        }).toList(),
      ),
    );
  }
}

// Tile for a level-2 (leaf) activity category.
// Long-press opens a bottom sheet with Edit and Delete options.
// [isLast] controls whether the tree line is L-shaped (last child) or T-shaped.
class _ActivityLeafTile extends StatelessWidget {
  final ActivityCategory category;
  final bool isLast;
  final ValueChanged<ActivityCategory> onEdit;
  final ValueChanged<ActivityCategory> onDelete;
  final ValueChanged<ActivityCategory> onMerge;

  const _ActivityLeafTile({
    required this.category,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    required this.onMerge,
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
            ListTile(
              leading: const Icon(Icons.merge_type),
              title: const Text('Merge into\u2026'),
              onTap: () {
                Navigator.of(context).pop();
                onMerge(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.outlineVariant;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: CustomPaint(
              painter: _TreeLinePainter(isLast: isLast, color: lineColor),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 8, right: 16),
              leading: ActivityIcon(identifier: category.iconIdentifier),
              title: Text(category.name),
              onLongPress: () => _showOptions(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Draws a vertical + horizontal tree connector line.
// T-shape (non-last child): vertical line runs full height, horizontal at mid.
// L-shape (last child): vertical line runs to mid-height only, horizontal at mid.
class _TreeLinePainter extends CustomPainter {
  final bool isLast;
  final Color color;

  const _TreeLinePainter({required this.isLast, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final midX = size.width / 2;
    final midY = size.height / 2;

    // Vertical line: full height for T-shape, half height for L-shape.
    canvas.drawLine(
      Offset(midX, 0),
      Offset(midX, isLast ? midY : size.height),
      paint,
    );

    // Horizontal line at mid-height connecting to tile content.
    canvas.drawLine(Offset(midX, midY), Offset(size.width, midY), paint);
  }

  @override
  bool shouldRepaint(_TreeLinePainter old) =>
      old.isLast != isLast || old.color != color;
}
