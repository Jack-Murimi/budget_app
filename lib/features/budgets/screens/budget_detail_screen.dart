import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final BudgetWithProgress budgetWithProgress;

  const BudgetDetailScreen({
    super.key,
    required this.budgetWithProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(budgetTransactionsAsyncProvider(budgetWithProgress.budget));

    return Scaffold(
      appBar: AppBar(
        title: Text(budgetWithProgress.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref),
            tooltip: 'Edit budget',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, ref),
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
                    '${CurrencyFormatter.format(budgetWithProgress.spent)} / ${CurrencyFormatter.format(budgetWithProgress.amount)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: budgetWithProgress.progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budgetWithProgress.isOverBudget
                            ? Colors.red
                            : budgetWithProgress.progress >= 0.75
                                ? Colors.amber
                                : Colors.green,
                      ),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    budgetWithProgress.isOverBudget
                        ? 'Over budget by ${CurrencyFormatter.format(budgetWithProgress.spent - budgetWithProgress.amount)}'
                        : '${CurrencyFormatter.format(budgetWithProgress.remaining)} remaining',
                    style: TextStyle(
                      color: budgetWithProgress.isOverBudget ? Colors.red : null,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPeriodInfo(budgetWithProgress),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Contributing Transactions',
              style: Theme.of(context).textTheme.titleSmall,
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
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
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(t.header),
                    subtitle: Text(
                      '${t.transactionDate.day}/${t.transactionDate.month}/${t.transactionDate.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Text(
                      CurrencyFormatter.format(t.amount + t.transactionCost + t.fulizaFee),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: t.type == 'income'
                            ? Colors.green
                            : Colors.red,
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

  String _getPeriodInfo(BudgetWithProgress bp) {
    if (bp.remaining <= 0) {
      return 'No remaining budget';
    }

    final now = DateTime.now();
    final (start, end) = _getPeriodWindow(bp.period, now);
    final daysLeft = end.difference(now).inDays;

    if (daysLeft <= 0) {
      return 'Period ended';
    }

    final remainingDays = daysLeft == 0 ? 1 : daysLeft;
    final recommendedDaily = bp.remaining / remainingDays;
    final formattedDaily = CurrencyFormatter.formatCompact(recommendedDaily);
    final daily = formattedDaily.contains('KES') ? formattedDaily : 'KES $formattedDaily';

    return '$daily / day for the remaining $remainingDays days';
  }

  (DateTime, DateTime) _getPeriodWindow(String period, DateTime now) {
    switch (period) {
      case 'monthly':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start, end);
      case 'weekly':
        final weekday = now.weekday;
        final start = DateTime(now.year, now.month, now.day - (weekday - 1));
        final end = start.add(const Duration(days: 7));
        return (start, end);
      default:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start, end);
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController(text: budgetWithProgress.name);
    final amountCtrl = TextEditingController(text: budgetWithProgress.amount.toString());
    String period = budgetWithProgress.period;
    Category? selectedCategory;
    if (budgetWithProgress.categoryId != null) {
      final cat = await ref.read(categoryRepositoryProvider).getCategoryById(budgetWithProgress.categoryId!);
      if (cat != null) selectedCategory = cat;
    }
    if (!context.mounted) return;
    bool rollover = budgetWithProgress.budget.rollover;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Budget'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (KES) *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: period,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  ],
                  onChanged: (v) => setDialogState(() => period = v!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    selectedCategory == null
                        ? 'Overall Budget (All Expenses)'
                        : 'Category: ${selectedCategory!.name}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final cat = await showCategoryPicker(ctx);
                    setDialogState(() => selectedCategory = cat);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Rollover remaining budget'),
                  subtitle: const Text('Carry over unused amount to next period'),
                  value: rollover,
                  onChanged: (v) => setDialogState(() => rollover = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text);

                if (name.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }

                final repo = ref.read(budgetRepositoryProvider);
                final companion = BudgetsCompanion(
                  id: Value(budgetWithProgress.id),
                  name: Value(name),
                  amount: Value(amount),
                  period: Value(period),
                  categoryId: Value(selectedCategory?.id),
                  startDate: Value(budgetWithProgress.budget.startDate),
                  rollover: Value(rollover),
                );
                await repo.updateBudget(companion);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ref.invalidate(budgetsWithProgressProvider);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${budgetWithProgress.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.deleteBudget(budgetWithProgress.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget deleted')),
      );
    }
  }
}
