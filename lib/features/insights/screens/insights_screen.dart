import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/models/transaction_split_allocator.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../providers/insights_providers.dart';

class CashflowBucket {
  final String label;
  final double income;
  final double expenses;

  const CashflowBucket({
    required this.label,
    required this.income,
    required this.expenses,
  });
}

class CashflowAggregation {
  final String title;
  final List<CashflowBucket> buckets;

  const CashflowAggregation({
    required this.title,
    required this.buckets,
  });
}

@visibleForTesting
CashflowAggregation aggregateCashflowBuckets(
  Map<DateTime, Cashflow> byDay,
  DateRange range, {
  AppLocalizations? l10n,
}) {
  final sortedDays = byDay.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final totalDays = math.max(1, range.end.difference(range.start).inDays);

  if (totalDays <= 31) {
    return CashflowAggregation(
      title: l10n?.dailyCashflow ?? 'Daily cashflow',
      buckets: [
        for (final entry in sortedDays)
          CashflowBucket(
            label: DateFormat.d().format(entry.key),
            income: entry.value.income,
            expenses: entry.value.expenses,
          ),
      ],
    );
  }

  final useMonthly = totalDays > 120;
  final grouped = <DateTime, List<int>>{};
  for (final entry in sortedDays) {
    final dt = entry.key;
    final key = useMonthly
        ? DateTime(dt.year, dt.month, 1)
        : DateTime(dt.year, dt.month, dt.day - (dt.weekday - 1));
    final acc = grouped.putIfAbsent(key, () => [0, 0]);
    acc[0] += CentsConverter.toCents(entry.value.income);
    acc[1] += CentsConverter.toCents(entry.value.expenses);
  }

  final sortedBuckets = grouped.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return CashflowAggregation(
    title: useMonthly
        ? (l10n?.monthlyCashflow ?? 'Monthly cashflow')
        : (l10n?.weeklyCashflow ?? 'Weekly cashflow'),
    buckets: [
      for (final entry in sortedBuckets)
        CashflowBucket(
          label: useMonthly
              ? DateFormat.MMM().format(entry.key)
              : DateFormat('d/M').format(entry.key),
          income: CentsConverter.fromCents(entry.value[0]),
          expenses: CentsConverter.fromCents(entry.value[1]),
        ),
    ],
  );
}

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final range = ref.read(insightsRangeProvider);
    final rawEnd = range.end.subtract(const Duration(days: 1));
    final safeEnd = rawEnd.isAfter(today) ? today : rawEnd;
    final safeStart = range.start.isAfter(safeEnd) ? safeEnd : range.start;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: DateTimeRange(start: safeStart, end: safeEnd),
    );
    if (picked == null) return;
    ref.read(insightsCustomRangeProvider.notifier).state = DateRange(
      picked.start,
      DateTime(picked.end.year, picked.end.month, picked.end.day + 1),
    );
    ref.read(insightsPeriodProvider.notifier).state = InsightsPeriod.custom;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final period = ref.watch(insightsPeriodProvider);
    final range = ref.watch(insightsRangeProvider);
    final summary = ref.watch(insightsSummaryProvider);
    final transactions = ref.watch(insightsTransactionsProvider);
    final categories = ref.watch(categoriesStreamProvider);
    final netWorthTrend = ref.watch(netWorthTrendProvider);
    final title =
        '${DateFormat.MMMd().format(range.start)} - ${DateFormat.MMMd().format(range.end.subtract(const Duration(days: 1)))}';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allTransactionsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in InsightsPeriod.values)
                  ChoiceChip(
                    label: Text(
                      value == InsightsPeriod.custom
                          ? l10n.custom
                          : _periodLabel(l10n, value),
                    ),
                    selected: period == value,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      if (value == InsightsPeriod.custom) {
                        _pickRange(context, ref);
                      } else {
                        ref.read(insightsPeriodProvider.notifier).state = value;
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.9,
                  ),
            ),
            const SizedBox(height: 12),
            summary.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(l10n.unableToLoadInsights('$error')),
              data: (data) => Column(
                children: [
                  FadeSlideIn(child: _SummaryCard(summary: data, range: range)),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    index: 1,
                    child: _CashflowChart(summary: data, range: range),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            netWorthTrend.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (trend) => FadeSlideIn(
                index: 2,
                child: _NetWorthChart(trend: trend),
              ),
            ),
            const SizedBox(height: 16),
            transactions.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => categories.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (all) => FadeSlideIn(
                  index: 3,
                  child: _CategoryChart(
                    items: items,
                    categoryNames: {
                      for (final category in all) category.id: category.name,
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _periodLabel(AppLocalizations l10n, InsightsPeriod value) => switch (value) {
      InsightsPeriod.week => l10n.thisWeek,
      InsightsPeriod.month => l10n.thisMonth,
      InsightsPeriod.lastMonth => l10n.lastMonth,
      InsightsPeriod.year => l10n.thisYear,
      InsightsPeriod.custom => l10n.custom,
    };

class _SummaryCard extends StatelessWidget {
  final InsightsSummary summary;
  final DateRange range;

  const _SummaryCard({required this.summary, required this.range});

  int _burnDays(DateTime now) {
    final totalDays = math.max(1, range.end.difference(range.start).inDays);
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    if (!today.isBefore(startDay) && today.isBefore(range.end)) {
      return (today.difference(startDay).inDays + 1).clamp(1, totalDays);
    }
    return totalDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final delta = summary.expenseDelta;
    final days = _burnDays(DateTime.now());
    final burnRate = summary.expenses / days;
    final pct = (delta.abs() * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.cashflowSummary, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: l10n.income,
                    value: summary.income,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: l10n.spent,
                    value: summary.expenses,
                    color: theme.colorScheme.error,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: l10n.net,
                    value: summary.net,
                    color: summary.net < 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.avgDailySpend(CurrencyFormatter.format(burnRate)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (summary.previousExpenses > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  delta >= 0
                      ? l10n.upPercentFromPrevious(pct)
                      : l10n.downPercentFromPrevious(pct),
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              value: value,
              format: CurrencyFormatter.format,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
}

class _CashflowChart extends StatelessWidget {
  final InsightsSummary summary;
  final DateRange range;

  const _CashflowChart({required this.summary, required this.range});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduced = Motion.reduced(context);
    final aggregation =
        aggregateCashflowBuckets(summary.byDay, range, l10n: l10n);
    final buckets = aggregation.buckets;
    if (buckets.isEmpty) {
      return _EmptyCard(message: l10n.noCashflowInPeriod);
    }

    final theme = Theme.of(context);
    final labelStep = buckets.length > 15 ? (buckets.length / 6).ceil() : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aggregation.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 ||
                              index >= buckets.length ||
                              index % labelStep != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            buckets[index].label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < buckets.length; i++)
                      BarChartGroupData(
                        x: i,
                        barsSpace: 3,
                        barRods: [
                          BarChartRodData(
                            toY: buckets[i].income,
                            color: theme.colorScheme.primary,
                            width: 7,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: buckets[i].expenses,
                            color: theme.colorScheme.error,
                            width: 7,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                swapAnimationDuration: reduced ? Duration.zero : Motion.medium,
                swapAnimationCurve: Motion.emphasized,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final List<TransactionModel> items;
  final Map<int, String> categoryNames;

  const _CategoryChart({required this.items, required this.categoryNames});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduced = Motion.reduced(context);
    final groupedCents = <String, int>{};
    for (final item in items.where((item) => item.type == 'expense')) {
      for (final alloc
          in TransactionSplitAllocator.allocateForTransaction(item)) {
        final name = alloc.categoryId == null
            ? l10n.uncategorized
            : (categoryNames[alloc.categoryId] ?? l10n.uncategorized);
        groupedCents[name] = (groupedCents[name] ?? 0) + alloc.cents;
      }
    }
    final sortedCents = groupedCents.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sortedCents.isEmpty) {
      return _EmptyCard(message: l10n.noExpensesInPeriod);
    }

    final entries = <MapEntry<String, double>>[
      for (final e in sortedCents.take(5))
        MapEntry(e.key, CentsConverter.fromCents(e.value)),
    ];
    final otherCents =
        sortedCents.skip(5).fold<int>(0, (sum, e) => sum + e.value);
    if (otherCents > 0) {
      entries.add(MapEntry(l10n.otherLabel, CentsConverter.fromCents(otherCents)));
    }

    const colors = [
      Color(0xFF1565C0),
      Color(0xFF00897B),
      Color(0xFFF57C00),
      Color(0xFFC62828),
      Color(0xFF7B1FA2),
      Color(0xFF78909C),
    ];
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.spendingByCategory,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sectionsSpace: 2.5,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: colors[i],
                        radius: 52,
                        showTitle: false,
                      ),
                  ],
                ),
                swapAnimationDuration: reduced ? Duration.zero : Motion.medium,
                swapAnimationCurve: Motion.emphasized,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < entries.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entries[i].key,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${CurrencyFormatter.format(entries[i].value)} (${total > 0 ? (entries[i].value / total * 100).toStringAsFixed(0) : 0}%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthChart extends StatelessWidget {
  final Map<DateTime, double> trend;

  const _NetWorthChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    final entries = trend.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return const SizedBox.shrink();
    final spots = [
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].value),
    ];
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.netWorthTrend,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            AnimatedAmount(
              value: entries.last.value,
              format: CurrencyFormatter.format,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primary.withValues(alpha: 0.22),
                            primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                duration: reduced ? Duration.zero : Motion.medium,
                curve: Motion.emphasized,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(message)),
        ),
      );
}
