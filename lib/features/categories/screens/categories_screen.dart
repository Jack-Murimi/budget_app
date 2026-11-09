import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/database/app_database.dart';
import '../providers/category_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _showArchived = false;
  List<Category> _topLevel = [];

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(categoryRepositoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          TextButton.icon(
            icon: Icon(_showArchived ? Icons.unarchive : Icons.archive),
            label: Text(_showArchived ? 'Active' : 'Archived'),
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: repo.getAll(includeArchived: _showArchived),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final all = snap.data!;
          _topLevel = all.where((c) => c.parentId == null).toList();
          
          if (_topLevel.isEmpty) {
            return Center(
              child: Text(
                _showArchived ? 'No archived categories' : 'No categories',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          
          return ReorderableListView.builder(
            itemCount: _topLevel.length,
            // ignore: deprecated_member_use
            onReorder: _reorder,
            itemBuilder: (_, i) {
              final cat = _topLevel[i];
              final subs = all.where((c) => c.parentId == cat.id).toList();
              return _CategoryTile(
                key: ValueKey(cat.id),
                category: cat,
                subcategories: subs,
                onEdit: () => _editCategory(cat),
                onArchive: () => _toggleArchive(cat),
                onAddSub: () => _addSubcategory(cat),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _reorder(int oldIdx, int newIdx) {
    if (oldIdx < newIdx) newIdx--;
    final moved = _topLevel.removeAt(oldIdx);
    _topLevel.insert(newIdx, moved);
    ref.read(categoryRepositoryProvider).reorderCategories(_topLevel.map((c) => c.id).toList());
    setState(() {});
  }

  Future<void> _toggleArchive(Category cat) async {
    await ref.read(categoryRepositoryProvider).archiveCategory(cat.id, archive: !cat.isArchived);
    setState(() {});
  }

  Future<void> _addCategory() async {
    final result = await showCategoryEditDialog(context, null);
    if (result != null) setState(() {});
  }

  Future<void> _addSubcategory(Category parent) async {
    final result = await showCategoryEditDialog(context, parent);
    if (result != null) setState(() {});
  }

  Future<void> _editCategory(Category cat) async {
    final result = await showCategoryEditDialog(context, null, category: cat);
    if (result != null) setState(() {});
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final List<Category> subcategories;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onAddSub;

  const _CategoryTile({
    required super.key,
    required this.category,
    required this.subcategories,
    required this.onEdit,
    required this.onArchive,
    required this.onAddSub,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(category.colorHex);
    final icon = _parseIcon(category.icon);

    return ExpansionTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ReorderableDragStartListener(
            index: 0,
            child: Icon(Icons.drag_handle),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(category.isArchived ? Icons.unarchive : Icons.archive, size: 20),
            onPressed: onArchive,
            tooltip: category.isArchived ? 'Unarchive' : 'Archive',
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
        ],
      ),
      children: [
        ...subcategories.map((sub) => ListTile(
          contentPadding: const EdgeInsets.only(left: 72, right: 16),
          leading: CircleAvatar(
            backgroundColor: _parseColor(sub.colorHex).withValues(alpha: 0.15),
            radius: 16,
            child: Icon(_parseIcon(sub.icon), color: _parseColor(sub.colorHex), size: 16),
          ),
          title: Text(sub.name),
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => showCategoryEditDialog(context, null, category: sub),
          ),
        )),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 72, right: 16),
          leading: const Icon(Icons.add_circle_outline),
          title: const Text('Add subcategory'),
          onTap: onAddSub,
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData _parseIcon(String name) => _iconMap[name] ?? Icons.category;
}

const _iconMap = {
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'shopping_bag': Icons.shopping_bag,
  'receipt_long': Icons.receipt_long,
  'movie': Icons.movie,
  'favorite': Icons.favorite,
  'school': Icons.school,
  'savings': Icons.savings,
  'work': Icons.work,
  'home': Icons.home,
  'phone_android': Icons.phone_android,
  'fitness_center': Icons.fitness_center,
  'fastfood': Icons.fastfood,
  'local_gas_station': Icons.local_gas_station,
  'bolt': Icons.bolt,
  'wifi': Icons.wifi,
  'medication': Icons.medication,
  'build': Icons.build,
  'more_horiz': Icons.more_horiz,
};

Future<bool?> showCategoryEditDialog(
  BuildContext context,
  Category? parentCategory, {
  Category? category,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _CategoryEditDialog(
      parentCategory: parentCategory,
      category: category,
    ),
  );
}

class _CategoryEditDialog extends ConsumerStatefulWidget {
  final Category? parentCategory;
  final Category? category;

  const _CategoryEditDialog({
    this.parentCategory,
    this.category,
  });

  @override
  ConsumerState<_CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends ConsumerState<_CategoryEditDialog> {
  late final TextEditingController _nameCtrl;
  Category? _selectedParent;
  String _selectedColor = '#E53935';
  String _selectedIcon = 'restaurant';

  static const _colors = [
    '#E53935', '#1E88E5', '#8E24AA', '#F4511E', '#43A047',
    '#E91E63', '#00897B', '#FFB300', '#546E7A', '#3949AB',
    '#00ACC1', '#7CB342',
  ];

  static const _icons = [
    'restaurant', 'directions_car', 'shopping_bag', 'receipt_long',
    'movie', 'favorite', 'school', 'savings', 'work', 'home',
    'phone_android', 'fitness_center', 'fastfood', 'local_gas_station',
    'bolt', 'wifi', 'medication', 'build', 'more_horiz',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _selectedParent = widget.parentCategory;
    _selectedColor = widget.category?.colorHex ?? '#E53935';
    _selectedIcon = widget.category?.icon ?? 'restaurant';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(categoryRepositoryProvider);

    return AlertDialog(
      title: Text(widget.category == null ? 'New Category' : 'Edit Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Category>>(
              future: repo.getTopLevel(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox();
                final parents = snap.data!;
                return DropdownButtonFormField<Category?>(
                  isExpanded: true,
                  initialValue: _selectedParent,
                  decoration: const InputDecoration(labelText: 'Parent Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None (Top-level)', overflow: TextOverflow.ellipsis)),
                    ...parents.map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _selectedParent = v),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final selected = _selectedColor == hex;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(width: 3, color: Colors.white) : null,
                      boxShadow: selected ? [BoxShadow(color: color, blurRadius: 8)] : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Icon', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((name) {
                final icon = _iconMap[name] ?? Icons.category;
                final selected = _selectedIcon == name;
                final color = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = name),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: selected ? Border.all(width: 2, color: color) : null,
                    ),
                    child: Icon(icon, size: 20, color: selected ? color : Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(categoryRepositoryProvider);
    final companion = CategoriesCompanion(
      id: widget.category != null ? Value(widget.category!.id) : const Value.absent(),
      name: Value(name),
      icon: Value(_selectedIcon),
      colorHex: Value(_selectedColor),
      parentId: Value(_selectedParent?.id),
      transactionType: Value(_selectedParent?.transactionType ?? widget.category?.transactionType ?? 'expense'),
    );

    if (widget.category == null) {
      await repo.insertCategory(companion);
    } else {
      await repo.updateCategory(companion);
    }

    if (mounted) Navigator.of(context).pop(true);
  }
}
