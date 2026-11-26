import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../../../shared/utils/color_utils.dart';
import '../providers/category_providers.dart';

/// Shows a multi-select expandable category & subcategory picker bottom sheet.
/// Returns the selected [Category] list on Apply (empty list = Overall Budget),
/// or `null` if dismissed without applying.
Future<List<Category>?> showMultiCategoryPicker(
  BuildContext context, {
  Set<int> initialSelectedIds = const {},
  String transactionType = 'expense',
}) {
  return showModalBottomSheet<List<Category>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _MultiCategoryPickerSheet(
      initialSelectedIds: initialSelectedIds,
      transactionType: transactionType,
    ),
  );
}

class _MultiCategoryPickerSheet extends ConsumerStatefulWidget {
  final Set<int> initialSelectedIds;
  final String transactionType;

  const _MultiCategoryPickerSheet({
    required this.initialSelectedIds,
    required this.transactionType,
  });

  @override
  ConsumerState<_MultiCategoryPickerSheet> createState() =>
      _MultiCategoryPickerSheetState();
}

class _MultiCategoryPickerSheetState
    extends ConsumerState<_MultiCategoryPickerSheet> {
  late final Set<int> _selectedIds = Set<int>.from(widget.initialSelectedIds);
  final Set<int> _expandedParentIds = <int>{};
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _initializedExpansion = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _initExpansionOnce(
    List<Category> parents,
    Map<int, List<Category>> childrenByParent,
  ) {
    if (_initializedExpansion) return;
    _initializedExpansion = true;
    for (final parent in parents) {
      final children = childrenByParent[parent.id] ?? const <Category>[];
      if (!_selectedIds.contains(parent.id) &&
          children.any((c) => _selectedIds.contains(c.id))) {
        _expandedParentIds.add(parent.id);
      }
    }
  }

  bool? _parentCheckState(Category parent, List<Category> children) {
    if (_selectedIds.contains(parent.id)) return true;
    if (children.isEmpty) return false;
    final selectedCount =
        children.where((c) => _selectedIds.contains(c.id)).length;
    if (selectedCount == 0) return false;
    if (selectedCount == children.length) return true;
    return null;
  }

  void _toggleParent(Category parent, List<Category> children) {
    setState(() {
      final state = _parentCheckState(parent, children);
      if (state == true || state == null) {
        _selectedIds.remove(parent.id);
        for (final c in children) {
          _selectedIds.remove(c.id);
        }
      } else {
        _selectedIds.add(parent.id);
        for (final c in children) {
          _selectedIds.remove(c.id);
        }
      }
    });
  }

  void _toggleChild(
    Category parent,
    Category child,
    List<Category> children,
  ) {
    setState(() {
      final isParentSelected = _selectedIds.contains(parent.id);
      if (isParentSelected) {
        _selectedIds.remove(parent.id);
        for (final sibling in children) {
          if (sibling.id != child.id) {
            _selectedIds.add(sibling.id);
          }
        }
        return;
      }

      if (_selectedIds.contains(child.id)) {
        _selectedIds.remove(child.id);
      } else {
        _selectedIds.add(child.id);
        if (children.length >= 2 &&
            children.every((c) => _selectedIds.contains(c.id))) {
          for (final c in children) {
            _selectedIds.remove(c.id);
          }
          _selectedIds.add(parent.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      expand: false,
      builder: (ctx, scrollCtrl) {
        final allCats = categoriesAsync.valueOrNull ?? const <Category>[];
        final typeCats = allCats
            .where((c) => c.transactionType == widget.transactionType)
            .toList();
        final parents = typeCats.where((c) => c.parentId == null).toList();
        final childrenByParent = <int, List<Category>>{};
        for (final c in typeCats) {
          if (c.parentId != null) {
            childrenByParent.putIfAbsent(c.parentId!, () => []).add(c);
          }
        }
        if (categoriesAsync.hasValue) {
          _initExpansionOnce(parents, childrenByParent);
        }

        final q = _searchQuery.trim().toLowerCase();
        final visibleEntries = <({
          Category parent,
          List<Category> children,
          bool expanded,
        })>[];

        for (final parent in parents) {
          final allChildren = childrenByParent[parent.id] ?? const <Category>[];
          if (q.isEmpty) {
            visibleEntries.add((
              parent: parent,
              children: allChildren,
              expanded: _expandedParentIds.contains(parent.id),
            ));
          } else {
            final parentMatches = parent.name.toLowerCase().contains(q);
            final matchingChildren = allChildren
                .where((c) => c.name.toLowerCase().contains(q))
                .toList();
            if (parentMatches || matchingChildren.isNotEmpty) {
              final shownChildren =
                  matchingChildren.isNotEmpty ? matchingChildren : allChildren;
              visibleEntries.add((
                parent: parent,
                children: shownChildren,
                expanded: matchingChildren.isNotEmpty ||
                    _expandedParentIds.contains(parent.id),
              ));
            }
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectCategories,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_selectedIds.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(_selectedIds.clear),
                      child: Text(l10n.clearSelection),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: l10n.searchCategoriesHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: categoriesAsync.when(
                data: (_) {
                  if (visibleEntries.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noTypeCategoriesFound(
                          widget.transactionType.toUpperCase(),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    controller: scrollCtrl,
                    children: [
                      for (final entry in visibleEntries) ...[
                        _buildParentTile(
                          theme,
                          l10n,
                          entry.parent,
                          childrenByParent[entry.parent.id] ??
                              const <Category>[],
                          entry.expanded,
                          hasChildrenToShow: entry.children.isNotEmpty,
                        ),
                        if (entry.expanded)
                          for (final child in entry.children)
                            _buildChildTile(
                              theme,
                              entry.parent,
                              child,
                              childrenByParent[entry.parent.id] ??
                                  const <Category>[],
                            ),
                      ],
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.categoriesSelectedCount(_selectedIds.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        final selected = [
                          for (final cat in typeCats)
                            if (_selectedIds.contains(cat.id)) cat,
                        ];
                        Navigator.of(context).pop(selected);
                      },
                      child: Text(l10n.apply),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParentTile(
    ThemeData theme,
    AppLocalizations l10n,
    Category parent,
    List<Category> allChildren,
    bool isExpanded, {
    required bool hasChildrenToShow,
  }) {
    final color = parseHexColor(parent.colorHex);
    final checkState = _parentCheckState(parent, allChildren);
    final icon = CategoryIconHelper.resolveCategoryIcon(
      iconName: parent.icon,
      categoryName: parent.name,
      type: parent.transactionType,
    );

    String? subtitle;
    if (allChildren.isNotEmpty) {
      if (_selectedIds.contains(parent.id)) {
        subtitle = l10n.allSubcategoriesCount(allChildren.length);
      } else {
        final selectedCount =
            allChildren.where((c) => _selectedIds.contains(c.id)).length;
        subtitle = selectedCount > 0
            ? l10n.selectedOfTotalSubcategories(
                selectedCount,
                allChildren.length,
              )
            : l10n.subcategoriesCount(allChildren.length);
      }
    }

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            tristate: true,
            value: checkState,
            onChanged: (_) => _toggleParent(parent, allChildren),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 18),
          ),
        ],
      ),
      title: Text(parent.name),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: hasChildrenToShow
          ? Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            )
          : null,
      onTap: () {
        if (hasChildrenToShow) {
          setState(() {
            if (_expandedParentIds.contains(parent.id)) {
              _expandedParentIds.remove(parent.id);
            } else {
              _expandedParentIds.add(parent.id);
            }
          });
        } else {
          _toggleParent(parent, allChildren);
        }
      },
    );
  }

  Widget _buildChildTile(
    ThemeData theme,
    Category parent,
    Category child,
    List<Category> allChildren,
  ) {
    final color = parseHexColor(child.colorHex);
    final isChecked =
        _selectedIds.contains(parent.id) || _selectedIds.contains(child.id);
    final icon = CategoryIconHelper.resolveCategoryIcon(
      iconName: child.icon,
      categoryName: child.name,
      type: child.transactionType,
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 44, right: 16),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (_) => _toggleChild(parent, child, allChildren),
          ),
          CircleAvatar(
            radius: 15,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color, size: 16),
          ),
        ],
      ),
      title: Text(
        child.name,
        style: theme.textTheme.bodyMedium,
      ),
      onTap: () => _toggleChild(parent, child, allChildren),
    );
  }
}
