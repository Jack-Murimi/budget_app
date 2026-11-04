import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class CategoryPieChartSection extends StatelessWidget {
  final List<Transaction> transactions;

  const CategoryPieChartSection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group by type only (category wiring comes when category picker is done)
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    if (expenses.isEmpty) return const SizedBox.shrink();

    // Group by header for now (ponytail: group by category when category FK wired)
    final Map<String, double> grouped = {};
    for (final t in expenses) {
      grouped[t.header] = (grouped[t.header] ?? 0) + t.amount;
    }

    final sorted = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
    ];

    final total = top.fold<double>(0, (sum, e) => sum + e.value);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Breakdown',
                style: Theme.of(context).textTheme.titleSmall),
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
                            color: colors[i % colors.length],
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colors[i % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  top[i].key,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
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
  }
}
