import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../categories/providers/category_providers.dart';
import '../models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../repositories/budget_repository.dart';
import 'budgets_screen.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final BudgetWithProgress budgetWithProgress;

  const BudgetDetailScreen({
    super.key,
    required this.budgetWithProgress,
  });

  static String formatPeriodInfo(BudgetWithProgress bp, {DateTime? now}) {
    if (bp.remaining <= 0) {
      return 'No remaining budget';
    }

    final current = now ?? DateTime.now();
    final (_, end) = BudgetRepository.getPeriodWindow(bp.budget, current);
    if (!current.isBefore(end)) {
      return 'Period ended';
    }

    final today = DateTime(current.year, current.month, current.day);
    final endDay = DateTime(end.year, end.month, end.day);
    final daysLeft = endDay.difference(today).inDays;
    final remainingDays = daysLeft < 1 ? 1 : daysLeft;
    final recommendedDaily = bp.remaining / remainingDays;
    final daily = CurrencyFormatter.formatCompact(recommendedDaily);

    return '$daily / day for the remaining $remainingDays '
        '${remainingDays == 1 ? 'day' : 'days'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allBudgets = ref.watch(allBudgetsWithProgressProvider).valueOrNull;
    final liveBudget = allBudgets
            ?.where((b) => b.id == budgetWithProgress.id)
            .firstOrNull ??
        budgetWithProgress;
    final transactionsAsync =
        ref.watch(budgetTransactionsAsyncProvider(liveBudget.budget));

    final progressColor = liveBudget.isOverBudget
        ? theme.colorScheme.error
        : liveBudget.progress >= 0.75
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(liveBudget.name),
        actions: [
          IconButton(
            icon: Icon(
              liveBudget.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
            onPressed: () async {
              final nextArchived = !liveBudget.isArchived;
              await ref
                  .read(budgetRepositoryProvider)
                  .archiveBudget(liveBudget.id, archive: nextArchived);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      nextArchived ? 'Budget archived' : 'Budget unarchived',
                    ),
                  ),
                );
              }
            },
            tooltip: liveBudget.isArchived ? 'Unarchive budget' : 'Archive budget',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref, liveBudget),
            tooltip: 'Edit budget',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, ref, liveBudget),
            tooltip: 'Delete budget',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${CurrencyFormatter.format(liveBudget.spent)} / ${CurrencyFormatter.format(liveBudget.amount)}',
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (liveBudget.rolloverAmount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Includes ${CurrencyFormatter.format(liveBudget.rolloverAmount)} rollover from previous period',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: liveBudget.progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    liveBudget.isOverBudget
                        ? 'Over budget by ${CurrencyFormatter.format(liveBudget.spent - liveBudget.amount)}'
                        : '${CurrencyFormatter.format(liveBudget.remaining)} remaining',
                    style: TextStyle(
                      color: liveBudget.isOverBudget
                          ? theme.colorScheme.error
                          : null,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPeriodInfo(liveBudget),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Contributing Transactions',
              style: theme.textTheme.titleSmall,
            ),
          ),
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No expenses in this period yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: transactions
                    .map(
                      (t) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            t.type == 'income'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(t.header),
                        subtitle: Text(
                          '${t.transactionDate.day}/${t.transactionDate.month}/${t.transactionDate.year}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(
                            t.amount + t.transactionCost + t.fulizaFee,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: t.type == 'income'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetWithProgress current,
  ) async {
    Category? selectedCategory;
    if (current.categoryId != null) {
      selectedCategory = await ref
          .read(categoryRepositoryProvider)
          .getCategoryById(current.categoryId!);
    }
    if (!context.mounted) return;

    final result = await showDialog<BudgetsCompanion>(
      context: context,
      builder: (_) => BudgetFormDialog(
        existing: current,
        initialCategory: selectedCategory,
      ),
    );
    if (result == null) return;

    await ref.read(budgetRepositoryProvider).updateBudget(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget updated')),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetWithProgress current,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${current.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(budgetRepositoryProvider).deleteBudget(current.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget deleted')),
      );
    }
  }
}
