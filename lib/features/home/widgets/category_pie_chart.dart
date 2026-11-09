import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/models/transaction_model.dart';

class _Slice {
  final String label;
  final double value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

class CategoryPieChartSection extends ConsumerStatefulWidget {
  final List<TransactionModel> transactions;

  const CategoryPieChartSection({super.key, required this.transactions});

  @override
  ConsumerState<CategoryPieChartSection> createState() =>
      _CategoryPieChartSectionState();
}

class _CategoryPieChartSectionState
    extends ConsumerState<CategoryPieChartSection> {
  bool _showSubcategories = false;
  int? _touchedIndex;

  static const int _maxSlices = 5; // top N, rest rolled into "Other"
  static const Color _uncategorizedColor = Color(0xFF9E9E9E);
  static const Color _otherColor = Color(0xFF78909C);

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

  static final NumberFormat _money = NumberFormat.decimalPattern();

  // Stable fallback: same category always gets the same color.
  Color _colorFor(Category c) =>
      _tryParseColor(c.colorHex) ?? _palette[c.id % _palette.length];

  /// Pure aggregation: no state mutation during build.
  List<_Slice> _buildSlices(List<Category> categories) {
    final byId = {for (final c in categories) c.id: c};
    final totals = <int?, double>{};
    final cats = <int?, Category?>{};

    for (final t in widget.transactions) {
      if (t.type != 'expense') continue;

      var cat = t.categoryId != null ? byId[t.categoryId!] : null;
      // Category mode: roll up to the parent AND use the parent's color,
      // so the color doesn't depend on which child transaction came first.
      if (cat != null && !_showSubcategories && cat.parentId != null) {
        cat = byId[cat.parentId!] ?? cat;
      }

      final key = cat?.id;
      totals[key] = (totals[key] ?? 0) + t.amount;
      cats[key] = cat;
    }

    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final slices = <_Slice>[
      for (final e in entries.take(_maxSlices))
        _Slice(
          cats[e.key]?.name ?? 'Uncategorized',
          e.value,
          cats[e.key] == null ? _uncategorizedColor : _colorFor(cats[e.key]!),
        ),
    ];

    final rest =
        entries.skip(_maxSlices).fold<double>(0, (s, e) => s + e.value);
    if (rest > 0) slices.add(_Slice('Other', rest, _otherColor));
    return slices;
  }

  void _select(int index) {
    HapticFeedback.selectionClick();
    setState(() => _touchedIndex = _touchedIndex == index ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      skipLoadingOnReload: true, // no flicker when the stream re-emits
      data: (categories) => _buildCard(context, _buildSlices(categories)),
      loading: () =>
          const SizedBox(height: 220), // reserve space, no layout jump
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, List<_Slice> slices) {
    final theme = Theme.of(context);
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    final selected = (_touchedIndex != null && _touchedIndex! < slices.length)
        ? _touchedIndex
        : null;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Breakdown', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: false, label: Text('Category')),
                ButtonSegment(value: true, label: Text('Subcategory')),
              ],
              selected: {_showSubcategories},
              onSelectionChanged: (s) => setState(() {
                _showSubcategories = s.first;
                _touchedIndex = null;
              }),
            ),
            const SizedBox(height: 16),
            if (total <= 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No expenses in this period',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final chartSize =
                      math.min(160.0, constraints.maxWidth * 0.46);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildChart(theme, slices, total, selected, chartSize),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildLegend(theme, slices, total, selected)),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme, List<_Slice> slices, double total,
      int? selected, double size) {
    final scale = size / 160;
    final centerLabel = selected != null ? slices[selected].label : 'Total';
    final centerValue = selected != null ? slices[selected].value : total;

    return Semantics(
      label:
          'Spending breakdown: ${slices.map((s) => '${s.label} Ksh ${_money.format(s.value)}').join(', ')}',
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 38 * scale,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final i = response?.touchedSection?.touchedSectionIndex;
                    if (i == null || i < 0) {
                      if (_touchedIndex != null) {
                        setState(() => _touchedIndex = null);
                      }
                    } else {
                      _select(i);
                    }
                  },
                ),
                sections: List.generate(slices.length, (i) {
                  final s = slices[i];
                  final pct = s.value / total * 100;
                  final isSelected = i == selected;
                  final dimmed = selected != null && !isSelected;
                  final color =
                      dimmed ? s.color.withValues(alpha: 0.45) : s.color;
                  final onColor =
                      ThemeData.estimateBrightnessForColor(s.color) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black87;

                  return PieChartSectionData(
                    value: s.value,
                    color: color,
                    radius: (isSelected ? 40 : 34) * scale,
                    // tiny slices can't fit a label
                    title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
                    titleStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: onColor),
                  );
                }),
              ),
            ),
            IgnorePointer(
              child: SizedBox(
                width: 66 * scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _money.format(centerValue),
                        style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(
      ThemeData theme, List<_Slice> slices, double total, int? selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(slices.length, (i) {
        final s = slices[i];
        final pct = s.value / total * 100;
        final dimmed = selected != null && selected != i;

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _select(i),
          child: Opacity(
            opacity: dimmed ? 0.5 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: s.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.label,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ksh ${_money.format(s.value)} (${pct.toStringAsFixed(1)}%)',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

Color? _tryParseColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    var v = hex.replaceFirst('#', '');
    if (v.length == 6) v = 'FF$v';
    return Color(int.parse(v, radix: 16));
  } catch (_) {
    return null;
  }
}
