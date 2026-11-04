import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../providers/category_providers.dart';

/// Shows a 2-level category picker bottom sheet.
/// Returns the selected [Category] (can be parent or sub-category).
Future<Category?> showCategoryPicker(BuildContext context) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _CategoryPickerSheet(),
  );
}

class _CategoryPickerSheet extends ConsumerStatefulWidget {
  const _CategoryPickerSheet();

  @override
  ConsumerState<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<_CategoryPickerSheet> {
  Category? _selectedParent; // null = top-level view

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header with optional back button
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                // Allow selecting the parent category itself
                if (_selectedParent != null)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_selectedParent),
                    child: const Text('Use this'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (allCats) {
                // Filter for current level
                final toShow = _selectedParent == null
                    ? allCats.where((c) => c.parentId == null).toList()
                    : allCats.where((c) => c.parentId == _selectedParent!.id).toList();

                // Check if category has children
                bool hasChildren(Category cat) =>
                    allCats.any((c) => c.parentId == cat.id);

                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: toShow.length,
                  itemBuilder: (_, i) {
                    final cat = toShow[i];
                    final color = _hexColor(cat.colorHex);
                    final children = hasChildren(cat);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(
                          _iconData(cat.icon),
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
                          // Drill into sub-categories
                          setState(() => _selectedParent = cat);
                        } else {
                          // Leaf — select it
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

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData _iconData(String name) {
    // Map common icon names to real MaterialIcons
    return switch (name) {
      'restaurant' => Icons.restaurant,
      'directions_car' => Icons.directions_car,
      'shopping_bag' => Icons.shopping_bag,
      'receipt_long' => Icons.receipt_long,
      'movie' => Icons.movie,
      'favorite' => Icons.favorite,
      'school' => Icons.school,
      'savings' => Icons.savings,
      'attach_money' => Icons.attach_money,
      'more_horiz' => Icons.more_horiz,
      'swap_horiz' => Icons.swap_horiz,
      'water_drop' => Icons.water_drop,
      'bolt' => Icons.bolt,
      'wifi' => Icons.wifi,
      'home' => Icons.home,
      'tv' => Icons.tv,
      'phone_android' => Icons.phone_android,
      'security' => Icons.security,
      'medication' => Icons.medication,
      'local_hospital' => Icons.local_hospital,
      'fitness_center' => Icons.fitness_center,
      'work' => Icons.work,
      'store' => Icons.store,
      'trending_up' => Icons.trending_up,
      'groups' => Icons.groups,
      'send' => Icons.send,
      'sync' => Icons.sync,
      _ => Icons.category,
    };
  }
}
