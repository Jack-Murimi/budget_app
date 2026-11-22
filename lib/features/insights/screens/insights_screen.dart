import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../shared/utils/cashflow_calculator.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/models/transaction_model.dart';
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
  DateRange range,
) {
  final sortedDays = byDay.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final totalDays = math.max(1, range.end.difference(range.start).inDays);

  if (totalDays <= 31) {
    return CashflowAggregation(
      title: 'Daily cashflow',
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
    title: useMonthly ? 'Monthly cashflow' : 'Weekly cashflow',
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
    final period = ref.watch(insightsPeriodProvider);
    final range = ref.watch(insightsRangeProvider);
    final summary = ref.watch(insightsSummaryProvider);
    final transactions = ref.watch(insightsTransactionsProvider);
    final categories = ref.watch(categoriesStreamProvider);
    final netWorthTrend = ref.watch(netWorthTrendProvider);
    final title =
        '${DateFormat.MMMd().format(range.start)} - ${DateFormat.MMMd().format(range.end.subtract(const Duration(days: 1)))}';
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
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
                          ? 'Custom'
                          : _periodLabel(value),
                    ),
                    selected: period == value,
                    onSelected: (_) => value == InsightsPeriod.custom
                        ? _pickRange(context, ref)
                        : ref.read(insightsPeriodProvider.notifier).state =
                            value,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            summary.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Unable to load insights: $error'),
              data: (data) => Column(
                children: [
                  _SummaryCard(summary: data, range: range),
                  const SizedBox(height: 16),
                  _CashflowChart(summary: data, range: range),
                ],
              ),
            ),
            const SizedBox(height: 16),
            netWorthTrend.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (trend) => _NetWorthChart(trend: trend),
            ),
            const SizedBox(height: 16),
            transactions.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => categories.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (all) => _CategoryChart(
                  items: items,
                  categoryNames: {
                    for (final category in all) category.id: category.name,
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _periodLabel(InsightsPeriod value) => switch (value) {
      InsightsPeriod.week => 'This week',
      InsightsPeriod.month => 'This month',
      InsightsPeriod.lastMonth => 'Last month',
      InsightsPeriod.year => 'This year',
      InsightsPeriod.custom => 'Custom',
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
    final delta = summary.expenseDelta;
    final days = _burnDays(DateTime.now());
    final burnRate = summary.expenses / days;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cashflow summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Income',
                    value: summary.income,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Spent',
                    value: summary.expenses,
                    color: theme.colorScheme.error,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Net',
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
              'Avg daily spend: ${CurrencyFormatter.format(burnRate)}/day',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (summary.previousExpenses > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${delta >= 0 ? 'Up' : 'Down'} ${(delta.abs() * 100).toStringAsFixed(0)}% from previous period',
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
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(value),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
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
    final aggregation = aggregateCashflowBuckets(summary.byDay, range);
    final buckets = aggregation.buckets;
    if (buckets.isEmpty) {
      return const _EmptyCard(message: 'No cashflow in this period');
    }

    final theme = Theme.of(context);
    final labelStep = buckets.length > 15 ? (buckets.length / 6).ceil() : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                            style: const TextStyle(fontSize: 10),
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
                          ),
                          BarChartRodData(
                            toY: buckets[i].expenses,
                            color: theme.colorScheme.error,
                            width: 7,
                          ),
                        ],
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
}

class _CategoryChart extends StatelessWidget {
  final List<TransactionModel> items;
  final Map<int, String> categoryNames;

  const _CategoryChart({required this.items, required this.categoryNames});

  @override
  Widget build(BuildContext context) {
    final groupedCents = <String, int>{};
    for (final item in items.where((item) => item.type == 'expense')) {
      final name = item.categoryId == null
          ? 'Uncategorized'
          : (categoryNames[item.categoryId] ?? 'Uncategorized');
      groupedCents[name] =
          (groupedCents[name] ?? 0) + CashflowCalculator.expenseTotalCents(item);
    }
    final sortedCents = groupedCents.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sortedCents.isEmpty) {
      return const _EmptyCard(message: 'No expenses in this period');
    }

    final entries = <MapEntry<String, double>>[
      for (final e in sortedCents.take(5))
        MapEntry(e.key, CentsConverter.fromCents(e.value)),
    ];
    final otherCents =
        sortedCents.skip(5).fold<int>(0, (sum, e) => sum + e.value);
    if (otherCents > 0) {
      entries.add(MapEntry('Other', CentsConverter.fromCents(otherCents)));
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 38,
                  sectionsSpace: 2,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: colors[i],
                        radius: 55,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < entries.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, color: colors[i]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entries[i].key,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${CurrencyFormatter.format(entries[i].value)} (${total > 0 ? (entries[i].value / total * 100).toStringAsFixed(0) : 0}%)',
                      style: Theme.of(context).textTheme.bodySmall,
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
    final entries = trend.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return const SizedBox.shrink();
    final spots = [
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].value),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net worth trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(entries.last.value),
              style: Theme.of(context).textTheme.titleSmall,
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
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
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
