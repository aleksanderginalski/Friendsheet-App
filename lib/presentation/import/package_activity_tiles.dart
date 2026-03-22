part of 'package_activities_screen.dart';

// Card for an activity whose name exactly matches an existing category (conflict).
// User MUST choose an option — blocks Continue until resolved.
class _ActivityConflictTile extends StatefulWidget {
  final String packageId;
  final String lowerName;
  final String originalName;
  final ActivityCategory existingCategory;
  final SharedPackageInboxProvider provider;

  const _ActivityConflictTile({
    required this.packageId,
    required this.lowerName,
    required this.originalName,
    required this.existingCategory,
    required this.provider,
  });

  @override
  State<_ActivityConflictTile> createState() => _ActivityConflictTileState();
}

class _ActivityConflictTileState extends State<_ActivityConflictTile> {
  final _controller = TextEditingController();
  bool _showRenameField = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitRename() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.provider.resolveActivityConflict(
        widget.packageId, widget.lowerName, ActivityResolution.rename(name));
    setState(() => _showRenameField = false);
  }

  Future<void> _pickExisting(BuildContext context) async {
    final result = await Navigator.push<ActivityCategory?>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityPickerScreen(
          categories: widget.provider.existingCategories,
        ),
      ),
    );
    if (result != null) {
      widget.provider.resolveActivityConflict(widget.packageId,
          widget.lowerName, ActivityResolution.link(result.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.provider
        .activityResolutionFor(widget.packageId, widget.lowerName);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.orange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ Conflict: "${widget.originalName}" matches existing '
              '"${widget.existingCategory.name}"',
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: [
              _btn('Create as New',
                  selected: res != null &&
                      res.isRename &&
                      res.renamedName == widget.originalName, onPressed: () {
                widget.provider.resolveActivityConflict(
                    widget.packageId,
                    widget.lowerName,
                    ActivityResolution.rename(widget.originalName));
                setState(() => _showRenameField = false);
              }),
              _btn('Rename',
                  selected: res != null &&
                      res.isRename &&
                      res.renamedName != widget.originalName,
                  onPressed: () => setState(() => _showRenameField = true)),
              _btn('Link to: ${widget.existingCategory.name}',
                  selected: res?.isLink == true &&
                      res?.linkedCategoryId == widget.existingCategory.id,
                  onPressed: () {
                widget.provider.resolveActivityConflict(
                    widget.packageId,
                    widget.lowerName,
                    ActivityResolution.link(widget.existingCategory.id));
                setState(() => _showRenameField = false);
              }),
              _btn('Link with Existing',
                  selected: res?.isLink == true &&
                      res?.linkedCategoryId != widget.existingCategory.id,
                  onPressed: () => _pickExisting(context)),
              _btn('Skip', selected: res?.isSkip ?? false, onPressed: () {
                widget.provider.resolveActivityConflict(widget.packageId,
                    widget.lowerName, const ActivityResolution.skip());
                setState(() => _showRenameField = false);
              }),
            ]),
            if (_showRenameField) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'New activity name', isDense: true),
                    onSubmitted: (_) => _submitRename(),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.check), onPressed: _submitRename),
              ]),
            ],
            if (res != null) ...[
              const SizedBox(height: 4),
              Text(_statusText(res),
                  style: const TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }

  String _statusText(ActivityResolution res) {
    if (res.isSkip) return '→ Skipped';
    if (res.isLink) {
      final linkedId = res.linkedCategoryId!;
      final name = linkedId == widget.existingCategory.id
          ? widget.existingCategory.name
          : widget.provider.existingCategories
                  .where((c) => c.id == linkedId)
                  .firstOrNull
                  ?.name ??
              linkedId;
      return '→ Linked to: $name';
    }
    return '→ Will be created as: ${res.renamedName}';
  }

  Widget _btn(String label,
      {required bool selected, required VoidCallback onPressed}) {
    if (selected) return FilledButton(onPressed: onPressed, child: Text(label));
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}

// Card for an activity with a fuzzy (similar but not exact) match to an existing
// category. Does not block the Continue button.
class _ActivityFuzzyTile extends StatefulWidget {
  final String packageId;
  final String lowerName;
  final String originalName;
  final ActivityCategory suggestedCategory;
  final SharedPackageInboxProvider provider;

  const _ActivityFuzzyTile({
    required this.packageId,
    required this.lowerName,
    required this.originalName,
    required this.suggestedCategory,
    required this.provider,
  });

  @override
  State<_ActivityFuzzyTile> createState() => _ActivityFuzzyTileState();
}

class _ActivityFuzzyTileState extends State<_ActivityFuzzyTile> {
  final _controller = TextEditingController();
  bool _showRenameField = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitRename() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.provider.resolveActivityConflict(
        widget.packageId, widget.lowerName, ActivityResolution.rename(name));
    setState(() => _showRenameField = false);
  }

  Future<void> _pickExisting(BuildContext context) async {
    final result = await Navigator.push<ActivityCategory?>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityPickerScreen(
          categories: widget.provider.existingCategories,
        ),
      ),
    );
    if (result != null) {
      widget.provider.resolveActivityConflict(widget.packageId,
          widget.lowerName, ActivityResolution.link(result.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.provider
        .activityResolutionFor(widget.packageId, widget.lowerName);
    final isDefault = res == null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue.shade300, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Similar: "${widget.originalName}" \u2248 '
              '"${widget.suggestedCategory.name}"',
              style: TextStyle(
                  color: Colors.blue.shade700, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: [
              _btn('Create as New',
                  selected: isDefault || (res.isRename && !_showRenameField),
                  onPressed: () {
                widget.provider.clearActivityResolution(
                    widget.packageId, widget.lowerName);
                setState(() => _showRenameField = false);
              }),
              _btn('Rename',
                  selected: _showRenameField,
                  onPressed: () => setState(() => _showRenameField = true)),
              _btn('Link with similar: ${widget.suggestedCategory.name}',
                  selected: res?.isLink == true &&
                      res?.linkedCategoryId == widget.suggestedCategory.id,
                  onPressed: () {
                widget.provider.resolveActivityConflict(
                    widget.packageId,
                    widget.lowerName,
                    ActivityResolution.link(widget.suggestedCategory.id));
                setState(() => _showRenameField = false);
              }),
              _btn('Link with Existing',
                  selected: res?.isLink == true &&
                      res?.linkedCategoryId != widget.suggestedCategory.id,
                  onPressed: () => _pickExisting(context)),
              _btn('Skip', selected: res?.isSkip ?? false, onPressed: () {
                widget.provider.resolveActivityConflict(widget.packageId,
                    widget.lowerName, const ActivityResolution.skip());
                setState(() => _showRenameField = false);
              }),
            ]),
            if (_showRenameField) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'New activity name', isDense: true),
                    onSubmitted: (_) => _submitRename(),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.check), onPressed: _submitRename),
              ]),
            ],
            if (res != null) ...[
              const SizedBox(height: 4),
              Text(_statusText(res),
                  style: const TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }

  String _statusText(ActivityResolution res) {
    if (res.isSkip) return '→ Skipped';
    if (res.isLink) {
      final linkedId = res.linkedCategoryId!;
      final name = linkedId == widget.suggestedCategory.id
          ? widget.suggestedCategory.name
          : widget.provider.existingCategories
                  .where((c) => c.id == linkedId)
                  .firstOrNull
                  ?.name ??
              linkedId;
      return '→ Linked to: $name';
    }
    return '→ Will be created as: ${res.renamedName}';
  }

  Widget _btn(String label,
      {required bool selected, required VoidCallback onPressed}) {
    if (selected) return FilledButton(onPressed: onPressed, child: Text(label));
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}

// Tile for an activity with no name conflict.
// Default action is to add as new; user may link to existing or skip.
class _ActivityOptInTile extends StatelessWidget {
  final String packageId;
  final String lowerName;
  final String displayName;
  final SharedPackageInboxProvider provider;

  const _ActivityOptInTile({
    required this.packageId,
    required this.lowerName,
    required this.displayName,
    required this.provider,
  });

  Future<void> _pickExisting(BuildContext context) async {
    final result = await Navigator.push<ActivityCategory?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ActivityPickerScreen(categories: provider.existingCategories),
      ),
    );
    if (result != null) {
      provider.resolveActivityConflict(
          packageId, lowerName, ActivityResolution.link(result.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = provider.activityResolutionFor(packageId, lowerName);
    final isOptedOut = provider.isActivityOptedOut(packageId, lowerName);
    final isDefault = res == null && !isOptedOut;
    return ListTile(
      title: Text(displayName),
      subtitle: Wrap(spacing: 8, runSpacing: 4, children: [
        _btn('Add new',
            selected: isDefault,
            onPressed: () =>
                provider.clearActivityResolution(packageId, lowerName)),
        _btn('Link with Existing',
            selected: res?.isLink ?? false,
            onPressed: () => _pickExisting(context)),
        _btn('Skip',
            selected: res?.isSkip ?? isOptedOut,
            onPressed: () => provider.resolveActivityConflict(
                packageId, lowerName, const ActivityResolution.skip())),
      ]),
    );
  }

  Widget _btn(String label,
      {required bool selected, required VoidCallback onPressed}) {
    if (selected) {
      return FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 12)),
          child: Text(label));
    }
    return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(fontSize: 12)),
        child: Text(label));
  }
}
