import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../fuliza/screens/fuliza_screen.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/floating_action_buttons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final summaryAsync = ref.watch(monthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget KE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_problem_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FulizaScreen()),
            ),
            tooltip: 'Fuliza',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {}, // ponytail: stats screen; add when analytics feature added
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(recentTransactionsProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            summaryAsync.when(
              data: (summary) => SpendingSummaryCard(
                totalSpent: summary.totalExpenses,
                totalIncome: summary.totalIncome,
                month: summary.month,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            transactionsAsync.when(
              data: (txns) => CategoryPieChartSection(transactions: txns),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            transactionsAsync.when(
              data: (txns) => txns.isEmpty
                  ? const _EmptyState()
                  : Column(
                      children: txns
                          .map((t) => TransactionListItem(transaction: t))
                          .toList(),
                    ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
      floatingActionButton: const HomeFloatingActionButtons(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Paste an M-Pesa SMS or add manually',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
