import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/models/transaction_model.dart';

class CategoryPieChartSection extends ConsumerStatefulWidget {
  final List<TransactionModel> transactions;

  const CategoryPieChartSection({super.key, required this.transactions});

  @override
  ConsumerState<CategoryPieChartSection> createState() => _CategoryPieChartSectionState();
}

class _CategoryPieChartSectionState extends ConsumerState<CategoryPieChartSection> {
  bool _showSubcategories = false;

  static const List<Color> _palette = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
    Color(0xFF795548),
    Color(0xFF009688),
    Color(0xFFFF5722),
    Color(0xFF673AB7),
  ];

  Map<int, Category> _buildCategoryMap(List<Category> categories) {
    return {for (final c in categories) c.id: c};
  }

  String _getCategoryName(Category category, bool showSubcategories, List<Category> categories) {
    if (showSubcategories) {
      return category.name;
    }
    if (category.parentId != null) {
      try {
        final parent = categories.firstWhere((c) => c.id == category.parentId);
        return parent.name;
      } catch (e) {
        return category.name;
      }
    }
    return category.name;
  }

  final Map<String, Color> categoryColors = {};

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) {
        final categoryMap = _buildCategoryMap(categories);
        categoryColors.clear();

        final grouped = <String, double>{};
        for (final t in widget.transactions.where((t) => t.type == 'expense')) {
          String displayName;
          Color color;

          final category = t.categoryId != null ? categoryMap[t.categoryId!] : null;
          if (category == null) {
            displayName = 'Uncategorized';
            color = const Color(0xFF9E9E9E);
          } else {
            displayName = _getCategoryName(category, _showSubcategories, categories);
            final colorHex = category.colorHex;
            color = colorHex.isNotEmpty
                ? _parseColor(colorHex)
                : _palette[grouped.length % _palette.length];
          }

          grouped[displayName] = (grouped[displayName] ?? 0) + t.amount;
          if (!categoryColors.containsKey(displayName)) {
            categoryColors[displayName] = color;
          }
        }

        final sorted = grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final top = sorted.take(5).toList();

        final total = top.fold<double>(0, (sum, e) => sum + e.value);

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Spending Breakdown', style: Theme.of(context).textTheme.titleSmall),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, size: 18),
                      onSelected: (value) {
                        setState(() {
                          _showSubcategories = value == 'subcategory';
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'category', child: Text('Category')),
                        const PopupMenuItem(value: 'subcategory', child: Text('Subcategory')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: List.generate(top.length, (i) {
                              final pct = top[i].value / total * 100;
                              return PieChartSectionData(
                                value: top[i].value,
                                color: categoryColors[top[i].key] ?? _palette[i % _palette.length],
                                title: '${pct.toStringAsFixed(0)}%',
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }),
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(top.length, (i) {
                            final pct = top[i].value / total * 100;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: categoryColors[top[i].key] ?? _palette[i % _palette.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          top[i].key,
                                          style: Theme.of(context).textTheme.bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Ksh${top[i].value.toStringAsFixed(0)} (${pct.toStringAsFixed(1)}%)',
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

Color _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) {
    return const Color(0xFF6750A4);
  }
  try {
    String hexValue = hex.replaceFirst('#', '');
    if (hexValue.length == 6) {
      hexValue = 'FF$hexValue';
    }
    return Color(int.parse(hexValue, radix: 16));
  } catch (e) {
    return const Color(0xFF6750A4);
  }
}
