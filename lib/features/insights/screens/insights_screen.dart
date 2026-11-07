import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../providers/insights_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final range = ref.read(insightsRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
          start: range.start, end: range.end.subtract(const Duration(days: 1))),
    );
    if (picked == null) return;
    ref.read(insightsCustomRangeProvider.notifier).state =
        DateRange(picked.start, picked.end.add(const Duration(days: 1)));
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
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final value in InsightsPeriod.values)
                  ChoiceChip(
                    label: Text(value == InsightsPeriod.custom
                        ? 'Custom'
                        : _periodLabel(value)),
                    selected: period == value,
                    onSelected: (_) => value == InsightsPeriod.custom
                        ? _pickRange(context, ref)
                        : ref.read(insightsPeriodProvider.notifier).state =
                            value,
                  ),
              ]),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              summary.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Unable to load insights: $error'),
                data: (data) => Column(children: [
                  _SummaryCard(summary: data),
                  const SizedBox(height: 16),
                  _CashflowChart(summary: data),
                ]),
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
                  data: (all) => _CategoryChart(items: items, categoryNames: {
                    for (final category in all) category.id: category.name
                  }),
                ),
              ),
            ]),
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
  const _SummaryCard({required this.summary});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = summary.expenseDelta;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cashflow summary', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _Metric(
                        label: 'Income',
                        value: summary.income,
                        color: Colors.green)),
                Expanded(
                    child: _Metric(
                        label: 'Spent',
                        value: summary.expenses,
                        color: theme.colorScheme.error)),
                Expanded(
                    child: _Metric(
                        label: 'Net',
                        value: summary.net,
                        color: summary.net < 0
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary)),
              ]),
              if (summary.previousExpenses > 0)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${delta >= 0 ? 'Up' : 'Down'} ${delta.abs().toStringAsFixed(0)}% from previous period',
                      style: theme.textTheme.bodySmall,
                    )),
            ])));
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _Metric(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(CurrencyFormatter.format(value),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ]);
}

class _CashflowChart extends StatelessWidget {
  final InsightsSummary summary;
  const _CashflowChart({required this.summary});
  @override
  Widget build(BuildContext context) {
    final entries = summary.byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return const _EmptyCard(message: 'No cashflow in this period');
    }
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Daily cashflow',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                  height: 200,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final index = value.toInt();
                                  return index >= 0 && index < entries.length
                                      ? Text(
                                          DateFormat.d()
                                              .format(entries[index].key),
                                          style: const TextStyle(fontSize: 10))
                                      : const SizedBox.shrink();
                                }))),
                    barGroups: [
                      for (var i = 0; i < entries.length; i++)
                        BarChartGroupData(x: i, barsSpace: 3, barRods: [
                          BarChartRodData(
                              toY: entries[i].value.income,
                              color: Colors.green,
                              width: 7),
                          BarChartRodData(
                              toY: entries[i].value.expenses,
                              color: Theme.of(context).colorScheme.error,
                              width: 7),
                        ])
                    ],
                  ))),
            ])));
  }
}

class _CategoryChart extends StatelessWidget {
  final List<dynamic> items;
  final Map<int, String> categoryNames;
  const _CategoryChart({required this.items, required this.categoryNames});
  @override
  Widget build(BuildContext context) {
    final grouped = <String, double>{};
    for (final item in items.where((item) => item.type == 'expense')) {
      final name = item.categoryId == null
          ? 'Uncategorized'
          : (categoryNames[item.categoryId] ?? 'Uncategorized');
      grouped[name] = (grouped[name] ?? 0) + item.amount;
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) {
      return const _EmptyCard(message: 'No expenses in this period');
    }
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF00897B),
      Color(0xFFF57C00),
      Color(0xFFC62828),
      Color(0xFF7B1FA2)
    ];
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Spending by category',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                  height: 180,
                  child: PieChart(PieChartData(
                      centerSpaceRadius: 38,
                      sectionsSpace: 2,
                      sections: [
                        for (var i = 0; i < entries.take(5).length; i++)
                          PieChartSectionData(
                              value: entries[i].value,
                              color: colors[i],
                              radius: 55,
                              showTitle: false)
                      ]))),
              for (var i = 0; i < entries.take(5).length; i++)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Container(width: 10, height: 10, color: colors[i]),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(entries[i].key,
                              overflow: TextOverflow.ellipsis)),
                      Text(
                          '${(entries[i].value / total * 100).toStringAsFixed(0)}%')
                    ])),
            ])));
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
        FlSpot(i.toDouble(), entries[i].value)
    ];
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Net worth trend',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(CurrencyFormatter.format(entries.last.value),
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              SizedBox(
                  height: 180,
                  child: LineChart(LineChartData(
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false))),
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
                                  .withValues(alpha: 0.12)))
                    ],
                  ))),
            ])));
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(message))));
}
