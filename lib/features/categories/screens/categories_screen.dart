import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/widgets/motion.dart';
import '../providers/category_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _showArchived = false;
  String _selectedType = 'expense';
  List<Category> _topLevel = [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(
      categoriesByFilterProvider((
        includeArchived: _showArchived,
        transactionType: _selectedType,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle),
        actions: [
          TextButton.icon(
            icon: Icon(_showArchived ? Icons.unarchive_rounded : Icons.archive_outlined),
            label: Text(_showArchived ? l10n.active : l10n.archived),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _showArchived = !_showArchived);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: 'expense',
                  label: Text(l10n.expense),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text(l10n.income),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                ),
                ButtonSegment(
                  value: 'transfer',
                  label: Text(l10n.transfer),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (s) {
                HapticFeedback.selectionClick();
                setState(() => _selectedType = s.first);
              },
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.errorLabel('$error'))),
              data: (all) {
                _topLevel = all.where((c) => c.parentId == null).toList();

                if (_topLevel.isEmpty) {
                  return Center(
                    child: Text(
                      _showArchived ? l10n.noArchivedCategories : l10n.noCategories,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: _topLevel.length,
                  onReorderItem: _reorder,
                  itemBuilder: (_, i) {
                    final cat = _topLevel[i];
                    final subs = all.where((c) => c.parentId == cat.id).toList();
                    return _CategoryTile(
                      key: ValueKey(cat.id),
                      index: i,
                      category: cat,
                      subcategories: subs,
                      onEdit: () => _editCategory(cat),
                      onArchive: () => _toggleArchive(cat),
                      onAddSub: () => _addSubcategory(cat),
                      onEditSub: (sub) => _editSubcategory(cat, sub),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _reorder(int oldIdx, int newIdx) {
    final moved = _topLevel.removeAt(oldIdx);
    _topLevel.insert(newIdx, moved);
    ref
        .read(categoryRepositoryProvider)
        .reorderCategories(_topLevel.map((c) => c.id).toList());
    setState(() {});
  }

  Future<void> _toggleArchive(Category cat) async {
    await ref
        .read(categoryRepositoryProvider)
        .archiveCategory(cat.id, archive: !cat.isArchived);
  }

  Future<void> _addCategory() async {
    await showCategoryEditDialog(context, null, initialType: _selectedType);
  }

  Future<void> _addSubcategory(Category parent) async {
    await showCategoryEditDialog(context, parent);
  }

  Future<void> _editCategory(Category cat) async {
    await showCategoryEditDialog(context, null, category: cat);
  }

  Future<void> _editSubcategory(Category parent, Category sub) async {
    await showCategoryEditDialog(context, parent, category: sub);
  }
}

class _CategoryTile extends StatelessWidget {
  final int index;
  final Category category;
  final List<Category> subcategories;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onAddSub;
  final ValueChanged<Category> onEditSub;

  const _CategoryTile({
    required super.key,
    required this.index,
    required this.category,
    required this.subcategories,
    required this.onEdit,
    required this.onArchive,
    required this.onAddSub,
    required this.onEditSub,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = parseHexColor(category.colorHex);
    final icon = CategoryIconHelper.resolveCategoryIcon(
      iconName: category.icon,
      categoryName: category.name,
      type: category.transactionType,
    );

    return ExpansionTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
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
            tooltip: category.isArchived ? l10n.unarchive : l10n.archive,
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
            tooltip: l10n.edit,
          ),
        ],
      ),
      children: [
        ...subcategories.map((sub) {
          final subColor = parseHexColor(sub.colorHex);
          return ListTile(
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            leading: CircleAvatar(
              backgroundColor: subColor.withValues(alpha: 0.15),
              radius: 16,
              child: Icon(
                CategoryIconHelper.resolveCategoryIcon(
                  iconName: sub.icon,
                  categoryName: sub.name,
                  type: sub.transactionType,
                ),
                color: subColor,
                size: 16,
              ),
            ),
            title: Text(sub.name),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => onEditSub(sub),
            ),
          );
        }),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 72, right: 16),
          leading: const Icon(Icons.add_circle_outline),
          title: Text(l10n.addSubcategory),
          onTap: onAddSub,
        ),
      ],
    );
  }
}

Future<bool?> showCategoryEditDialog(
  BuildContext context,
  Category? parentCategory, {
  Category? category,
  String? initialType,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _CategoryEditDialog(
      parentCategory: parentCategory,
      category: category,
      initialType: initialType,
    ),
  );
}

class _CategoryEditDialog extends ConsumerStatefulWidget {
  final Category? parentCategory;
  final Category? category;
  final String? initialType;

  const _CategoryEditDialog({
    this.parentCategory,
    this.category,
    this.initialType,
  });

  @override
  ConsumerState<_CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends ConsumerState<_CategoryEditDialog> {
  late final TextEditingController _nameCtrl;
  int? _selectedParentId;
  late String _transactionType;
  String _selectedColor = '#E53935';
  String _selectedIcon = 'restaurant';

  static const _colors = [
    '#E53935', '#1E88E5', '#8E24AA', '#F4511E', '#43A047',
    '#E91E63', '#00897B', '#FFB300', '#546E7A', '#3949AB',
    '#00ACC1', '#7CB342', '#5D4037', '#D81B60', '#78909C',
    '#C62828', '#757575', '#2E7D32', '#388E3C', '#1B5E20',
    '#66BB6A', '#81C784', '#0277BD', '#455A64', '#00838F',
  ];

  static const _icons = [
    'restaurant', 'local_grocery_store', 'shopping_cart', 'store',
    'directions_car', 'directions_bus', 'local_taxi', 'local_gas_station',
    'shopping_bag', 'checkroom', 'receipt_long', 'water_drop',
    'bolt', 'wifi', 'phone_android', 'tv', 'home', 'chair',
    'movie', 'videogame_asset', 'favorite', 'local_hospital',
    'medication', 'security', 'fitness_center', 'school', 'menu_book',
    'laptop', 'savings', 'work', 'attach_money', 'trending_up',
    'account_balance', 'payments', 'credit_card', 'handshake',
    'groups', 'send', 'card_giftcard', 'repeat', 'sync', 'build',
    'flight', 'widgets', 'more_horiz',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _selectedParentId = widget.category?.parentId ?? widget.parentCategory?.id;
    _transactionType = widget.category?.transactionType ??
        widget.parentCategory?.transactionType ??
        widget.initialType ??
        'expense';
    _selectedColor = widget.category?.colorHex ??
        widget.parentCategory?.colorHex ??
        '#E53935';
    _selectedIcon = widget.category?.icon ?? 'restaurant';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = ref.watch(categoryRepositoryProvider);
    final colors = _colors.contains(_selectedColor)
        ? _colors
        : [_selectedColor, ..._colors];
    final icons = _icons.contains(_selectedIcon)
        ? _icons
        : [_selectedIcon, ..._icons];

    return AlertDialog(
      title: Text(widget.category == null ? l10n.newCategory : l10n.editCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.name),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _transactionType,
              decoration: InputDecoration(labelText: l10n.type),
              items: [
                DropdownMenuItem(value: 'expense', child: Text(l10n.expense)),
                DropdownMenuItem(value: 'income', child: Text(l10n.income)),
                DropdownMenuItem(value: 'transfer', child: Text(l10n.transfer)),
              ],
              onChanged: (v) {
                if (v == null || v == _transactionType) return;
                setState(() {
                  _transactionType = v;
                  _selectedParentId = null;
                });
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Category>>(
              future: repo.getTopLevel(transactionType: _transactionType),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox();
                final parents = snap.data!
                    .where((p) => p.id != widget.category?.id)
                    .toList();
                final validParentId = parents.any((p) => p.id == _selectedParentId)
                    ? _selectedParentId
                    : null;
                return DropdownButtonFormField<int?>(
                  key: ValueKey('parent_$_transactionType'),
                  isExpanded: true,
                  initialValue: validParentId,
                  decoration: InputDecoration(labelText: l10n.parentCategory),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        l10n.noneTopLevel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...parents.map(
                      (p) => DropdownMenuItem<int?>(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedParentId = v),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.colorLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors.map((hex) {
                final color = parseHexColor(
                  hex,
                  fallback: const Color(0xFFE53935),
                );
                final selected = _selectedColor == hex;
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedColor = hex);
                  },
                  child: AnimatedScale(
                    scale: selected ? 1.12 : 1.0,
                    duration: Motion.reduced(context)
                        ? Duration.zero
                        : Motion.fast,
                    curve: Motion.emphasized,
                    child: AnimatedContainer(
                      duration: Motion.reduced(context)
                          ? Duration.zero
                          : Motion.fast,
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(width: 3, color: Colors.white)
                            : null,
                        boxShadow: selected
                            ? [BoxShadow(color: color, blurRadius: 8)]
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.iconLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: icons.map((name) {
                final icon = CategoryIconHelper.getIcon(
                  name,
                  type: _transactionType,
                );
                final selected = _selectedIcon == name;
                final color = parseHexColor(
                  _selectedColor,
                  fallback: const Color(0xFFE53935),
                );
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedIcon = name);
                  },
                  child: AnimatedScale(
                    scale: selected ? 1.1 : 1.0,
                    duration: Motion.reduced(context)
                        ? Duration.zero
                        : Motion.fast,
                    curve: Motion.emphasized,
                    child: AnimatedContainer(
                      duration: Motion.reduced(context)
                          ? Duration.zero
                          : Motion.fast,
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(width: 2, color: color)
                            : null,
                      ),
                      child: Icon(icon,
                          size: 20, color: selected ? color : Colors.grey),
                    ),
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(categoryRepositoryProvider);
    if (widget.category == null) {
      await repo.insertCategory(
        CategoriesCompanion.insert(
          name: name,
          icon: Value(_selectedIcon),
          colorHex: Value(_selectedColor),
          parentId: Value(_selectedParentId),
          transactionType: Value(_transactionType),
        ),
      );
    } else {
      await repo.updateCategory(
        CategoriesCompanion(
          id: Value(widget.category!.id),
          name: Value(name),
          icon: Value(_selectedIcon),
          colorHex: Value(_selectedColor),
          parentId: Value(_selectedParentId),
          transactionType: Value(_transactionType),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }
}
