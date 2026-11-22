import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../categories/widgets/category_picker.dart';
import '../models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../repositories/budget_repository.dart';
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
    final budgetsAsync = ref.watch(allBudgetsWithProgressProvider);

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
            onRefresh: () async => ref.invalidate(allBudgetsWithProgressProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
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

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      var normalized = hex.replaceFirst('#', '');
      if (normalized.length == 6) normalized = 'FF$normalized';
      return Color(int.parse(normalized, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  String _periodLabel(String period) => switch (period) {
        'monthly' => 'Monthly',
        'weekly' => 'Weekly',
        _ => 'Custom',
      };

  Widget _buildBudgetCard(BudgetWithProgress b) {
    final theme = Theme.of(context);
    final isOver = b.isOverBudget;
    final progressColor = isOver
        ? theme.colorScheme.error
        : b.progress >= 0.75
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;

    if (b.isOverall) {
      final daysLeft = _daysRemaining(b.budget);
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
              if (b.rolloverAmount > 0)
                Text(
                  '+${CurrencyFormatter.format(b.rolloverAmount)} rollover',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
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
                  color: isOver
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          trailing: _showArchived
              ? IconButton(
                  icon: const Icon(Icons.unarchive_outlined),
                  tooltip: 'Unarchive',
                  onPressed: () => ref
                      .read(budgetRepositoryProvider)
                      .archiveBudget(b.id, archive: false),
                )
              : Text(
                  daysLeft == 1 ? '1 day' : '$daysLeft days',
                  style: theme.textTheme.bodySmall,
                ),
          onTap: () => _openDetail(b),
        ),
      );
    } else {
      final categoryColor = _parseColor(
        b.categoryColorHex,
        theme.colorScheme.primary,
      );

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: categoryColor.withValues(alpha: 0.15),
            child: Icon(
              CategoryIconHelper.getIcon(b.categoryIcon),
              color: categoryColor,
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
              if (b.rolloverAmount > 0)
                Text(
                  '+${CurrencyFormatter.format(b.rolloverAmount)} rollover',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
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
                    : (b.categoryName ?? ''),
                style: TextStyle(
                  color: isOver
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          trailing: _showArchived
              ? IconButton(
                  icon: const Icon(Icons.unarchive_outlined),
                  tooltip: 'Unarchive',
                  onPressed: () => ref
                      .read(budgetRepositoryProvider)
                      .archiveBudget(b.id, archive: false),
                )
              : Chip(
                  label: Text(
                    _periodLabel(b.budget.period),
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
    final today = DateTime(now.year, now.month, now.day);
    final (_, end) = BudgetRepository.getPeriodWindow(budget, now);
    final endDay = DateTime(end.year, end.month, end.day);
    return endDay.difference(today).inDays.clamp(0, 999999);
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
    final result = await showDialog<BudgetsCompanion>(
      context: context,
      builder: (_) => const BudgetFormDialog(),
    );
    if (result == null) return;
    await ref.read(budgetRepositoryProvider).insertBudget(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget created')),
    );
  }
}

/// Shared create/edit budget dialog that owns and disposes its controllers.
class BudgetFormDialog extends StatefulWidget {
  final BudgetWithProgress? existing;
  final Category? initialCategory;

  const BudgetFormDialog({
    super.key,
    this.existing,
    this.initialCategory,
  });

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.existing != null
        ? widget.existing!.baseAmount.toString()
        : '',
  );

  late String _period = widget.existing?.period ?? 'monthly';
  late Category? _selectedCategory = widget.initialCategory;
  late bool _rollover = widget.existing?.budget.rollover ?? false;
  late DateTime _customStart =
      widget.existing?.budget.startDate ?? DateTime.now();
  late DateTime _customEnd = widget.existing?.budget.endDate ??
      DateTime.now().add(const Duration(days: 30));

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _customStart = picked;
        if (_customEnd.isBefore(_customStart)) {
          _customEnd = _customStart;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEnd.isBefore(_customStart) ? _customStart : _customEnd,
      firstDate: _customStart,
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _customEnd = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Budget' : 'Create Budget'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (KES) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _period,
              decoration: const InputDecoration(
                labelText: 'Period',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _period = v);
              },
            ),
            if (_period == 'custom') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickStartDate,
                      icon: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text('Start: ${fmt.format(_customStart)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndDate,
                      icon: const Icon(Icons.event_outlined, size: 16),
                      label: Text('End: ${fmt.format(_customEnd)}'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Category'),
              subtitle: Text(
                _selectedCategory == null
                    ? 'Overall Budget (All Expenses)'
                    : _selectedCategory!.name,
              ),
              trailing: _selectedCategory != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Use Overall Budget',
                      onPressed: () =>
                          setState(() => _selectedCategory = null),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () async {
                final cat = await showCategoryPicker(context);
                if (cat != null && mounted) {
                  setState(() => _selectedCategory = cat);
                }
              },
            ),
            if (_period != 'custom') ...[
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Rollover remaining budget'),
                subtitle: _isEdit
                    ? const Text('Carry over unused amount to next period')
                    : null,
                value: _rollover,
                onChanged: (v) => setState(() => _rollover = v),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final amount =
                double.tryParse(_amountCtrl.text.replaceAll(',', '').trim());
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Name is required')),
              );
              return;
            }
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid amount')),
              );
              return;
            }
            final startDate = _period == 'custom'
                ? _customStart
                : (widget.existing?.budget.startDate ?? DateTime.now());
            final endDate = _period == 'custom' ? _customEnd : null;
            final rolloverFlag = _period == 'custom' ? false : _rollover;

            if (_isEdit) {
              Navigator.pop(
                context,
                BudgetsCompanion(
                  id: Value(widget.existing!.id),
                  name: Value(name),
                  amount: Value(amount),
                  period: Value(_period),
                  categoryId: Value(_selectedCategory?.id),
                  startDate: Value(startDate),
                  endDate: Value(endDate),
                  rollover: Value(rolloverFlag),
                ),
              );
            } else {
              Navigator.pop(
                context,
                BudgetsCompanion.insert(
                  name: name,
                  amount: amount,
                  period: Value(_period),
                  categoryId: Value(_selectedCategory?.id),
                  startDate: startDate,
                  endDate: Value(endDate),
                  rollover: Value(rolloverFlag),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
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
