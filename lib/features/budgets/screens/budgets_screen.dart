import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../../categories/widgets/category_picker.dart';
import 'budget_detail_screen.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetsWithProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.unarchive : Icons.archive_outlined),
            onPressed: () => setState(() => _showArchived = !_showArchived),
            tooltip: _showArchived ? 'Show active' : 'Show archived',
          ),
        ],
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          final filteredBudgets = _showArchived
              ? budgets.where((b) => b.isArchived).toList()
              : budgets.where((b) => !b.isArchived).toList();

          if (filteredBudgets.isEmpty && !_showArchived) {
            return _EmptyState(onCreateBudget: _showCreateDialog);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(budgetsWithProgressProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                ...filteredBudgets.map((b) => _buildBudgetCard(b)),
                if (_showArchived && filteredBudgets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No archived budgets',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetCard(BudgetWithProgress b) {
    final theme = Theme.of(context);

    if (b.isOverall) {
      final isOver = b.isOverBudget;
      final progressColor = isOver
          ? Colors.red
          : b.progress >= 0.75
              ? Colors.amber
              : Colors.green;

      return Card(
        margin: const EdgeInsets.all(16),
        child: ListTile(
          leading: Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Overall Budget'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.format(b.spent)} / ${CurrencyFormatter.format(b.amount)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: b.progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOver
                    ? 'Over budget by ${CurrencyFormatter.format(b.spent - b.amount)}'
                    : '${CurrencyFormatter.format(b.remaining)} left',
                style: TextStyle(
                  color: isOver ? Colors.red : theme.colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          trailing: Text(
            '${_daysRemaining(b.budget)} days',
            style: theme.textTheme.bodySmall,
          ),
          onTap: () => _openDetail(b),
        ),
      );
    } else {
      final progressColor = b.isOverBudget
          ? Colors.red
          : b.progress >= 0.75
              ? Colors.amber
              : Colors.green;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: b.categoryColorHex != null
                ? Color(int.parse(b.categoryColorHex!.replaceFirst('#', '0xFF')))
                : Colors.grey,
            child: Icon(
              _getCategoryIcon(b.categoryIcon),
              color: b.categoryColorHex != null
                  ? Color(int.parse(b.categoryColorHex!.replaceFirst('#', '0xFF')))
                  : Colors.white,
            ),
          ),
          title: Text(b.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.format(b.spent)} / ${CurrencyFormatter.format(b.amount)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: b.progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                b.isOverBudget
                    ? 'Over budget by ${CurrencyFormatter.format(b.spent - b.amount)}'
                    : (b.categoryName ?? ''),
                style: TextStyle(
                  color: b.isOverBudget ? Colors.red : theme.colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(
              b.budget.period == 'monthly' ? 'Monthly' : 'Weekly',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          onTap: () => _openDetail(b),
        ),
      );
    }
  }

  int _daysRemaining(Budget budget) {
    final now = DateTime.now();
    final (start, end) = _getPeriodWindow(budget.period, now);
    return end.difference(now).inDays;
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

  IconData _getCategoryIcon(String? icon) {
    if (icon == null) return Icons.category;
    return switch (icon) {
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

  void _openDetail(BudgetWithProgress b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetDetailScreen(budgetWithProgress: b),
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String period = 'monthly';
    Category? selectedCategory;
    bool rollover = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Budget'),
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
                  title: const Text('Category'),
                  subtitle: Text(
                    selectedCategory == null
                        ? 'Overall Budget (All Expenses)'
                        : selectedCategory!.name,
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
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Name is required')),
                        );
                        return;
                      }
                      final amount = double.tryParse(amountCtrl.text);
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Enter a valid amount')),
                        );
                        return;
                      }

                      final repo = ref.read(budgetRepositoryProvider);
                      final companion = BudgetsCompanion.insert(
                        name: nameCtrl.text.trim(),
                        amount: amount,
                        period: Value(period),
                        categoryId: Value(selectedCategory?.id),
                        startDate: DateTime.now(),
                      );
                      await repo.insertBudget(companion);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget created')),
                      );
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateBudget});

  final VoidCallback onCreateBudget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets set yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onCreateBudget,
            child: const Text('Create Budget'),
          ),
        ],
      ),
    );
  }
}
