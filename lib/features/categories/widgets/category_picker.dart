import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../providers/category_providers.dart';

/// Shows a category picker bottom sheet with transaction type tabs and sub-category drilling.
/// Returns the selected [Category] (can be parent or sub-category).
Future<Category?> showCategoryPicker(BuildContext context, {String? initialType}) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _CategoryPickerSheet(initialType: initialType),
  );
}

class _CategoryPickerSheet extends ConsumerStatefulWidget {
  final String? initialType;
  const _CategoryPickerSheet({this.initialType});

  @override
  ConsumerState<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<_CategoryPickerSheet> {
  late String _activeType;
  Category? _selectedParent; // null = top-level view

  @override
  void initState() {
    super.initState();
    _activeType = widget.initialType ?? 'expense';
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
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

          // Header with back button / title
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
            child: Row(
              children: [
                if (_selectedParent != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _selectedParent = null),
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    _selectedParent != null
                        ? _selectedParent!.name
                        : 'Select Category',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (_selectedParent != null)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_selectedParent),
                    child: const Text('Use this'),
                  ),
              ],
            ),
          ),

          // Transaction type filter tabs (only on top-level)
          if (_selectedParent == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 'transfer',
                    label: Text('Transfer'),
                    icon: Icon(Icons.swap_horiz_rounded, size: 16),
                  ),
                ],
                selected: {_activeType},
                onSelectionChanged: (s) => setState(() {
                  _activeType = s.first;
                  _selectedParent = null;
                }),
              ),
            ),

          const Divider(height: 1),

          Expanded(
            child: categoriesAsync.when(
              data: (allCats) {
                // Filter for current type & hierarchy level
                final typeFiltered = allCats.where((c) => c.transactionType == _activeType).toList();

                final toShow = _selectedParent == null
                    ? typeFiltered.where((c) => c.parentId == null).toList()
                    : allCats.where((c) => c.parentId == _selectedParent!.id).toList();

                bool hasChildren(Category cat) =>
                    allCats.any((c) => c.parentId == cat.id);

                if (toShow.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${_activeType.toUpperCase()} categories found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: toShow.length,
                  itemBuilder: (_, i) {
                    final cat = toShow[i];
                    final color = _hexColor(cat.colorHex);
                    final children = hasChildren(cat);
                    final icon = CategoryIconHelper.getIcon(cat.icon, type: cat.transactionType);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(cat.name),
                      trailing: children
                          ? const Icon(Icons.chevron_right)
                          : null,
                      onTap: () {
                        if (children) {
                          setState(() => _selectedParent = cat);
                        } else {
                          Navigator.of(context).pop(cat);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }
}
