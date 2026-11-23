import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../categories/widgets/category_picker.dart';
import '../models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../utils/budget_period_helper.dart';
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
    final l10n = context.l10n;
    final budgetsAsync = ref.watch(allBudgetsWithProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetsTitle),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.unarchive : Icons.archive_outlined),
            onPressed: () => setState(() => _showArchived = !_showArchived),
            tooltip: _showArchived ? l10n.showActive : l10n.showArchived,
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
                      l10n.noArchivedBudgets,
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
        error: (e, _) => Center(child: Text(l10n.errorLabel('$e'))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _periodLabel(String period, AppLocalizations l10n) => switch (period) {
        'monthly' => l10n.monthly,
        'weekly' => l10n.weekly,
        _ => l10n.custom,
      };

  Widget _buildBudgetCard(BudgetWithProgress b) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isOver = b.isOverBudget;
    final progressColor = isOver
        ? theme.colorScheme.error
        : b.progress >= 0.75
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;

    if (b.isOverall) {
      final daysLeft = BudgetPeriodHelper.daysRemaining(b.budget);
      return Card(
        margin: const EdgeInsets.all(16),
        child: ListTile(
          leading: Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          title: Text(l10n.overallBudget),
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
                  l10n.rolloverPlusBadge(
                    CurrencyFormatter.format(b.rolloverAmount),
                  ),
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
                    ? l10n.overBudgetBy(
                        CurrencyFormatter.format(b.spent - b.amount),
                      )
                    : l10n.amountLeft(CurrencyFormatter.format(b.remaining)),
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
                  tooltip: l10n.unarchive,
                  onPressed: () => ref
                      .read(budgetRepositoryProvider)
                      .archiveBudget(b.id, archive: false),
                )
              : Text(
                  l10n.daysCount(daysLeft),
                  style: theme.textTheme.bodySmall,
                ),
          onTap: () => _openDetail(b),
        ),
      );
    } else {
      final categoryColor = parseHexColor(
        b.categoryColorHex,
        fallback: theme.colorScheme.primary,
      );

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: categoryColor.withValues(alpha: 0.15),
            child: Icon(
              CategoryIconHelper.resolveCategoryIcon(
                iconName: b.categoryIcon,
                categoryName: b.categoryName,
              ),
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
                  l10n.rolloverPlusBadge(
                    CurrencyFormatter.format(b.rolloverAmount),
                  ),
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
                    ? l10n.overBudgetBy(
                        CurrencyFormatter.format(b.spent - b.amount),
                      )
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
                  tooltip: l10n.unarchive,
                  onPressed: () => ref
                      .read(budgetRepositoryProvider)
                      .archiveBudget(b.id, archive: false),
                )
              : Chip(
                  label: Text(
                    _periodLabel(b.budget.period, l10n),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
          onTap: () => _openDetail(b),
        ),
      );
    }
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
      SnackBar(content: Text(context.l10n.budgetCreated)),
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
    final l10n = context.l10n;
    final fmt = DateFormat('d MMM yyyy');
    return AlertDialog(
      title: Text(_isEdit ? l10n.editBudget : l10n.createBudget),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.nameRequired,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.budgetAmountRequired,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _period,
              decoration: InputDecoration(
                labelText: l10n.period,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'monthly', child: Text(l10n.monthly)),
                DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                DropdownMenuItem(value: 'custom', child: Text(l10n.custom)),
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
                      label: Text(l10n.startWithDate(fmt.format(_customStart))),
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
                      label: Text(l10n.endWithDate(fmt.format(_customEnd))),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.category),
              subtitle: Text(
                _selectedCategory == null
                    ? l10n.overallBudgetAllExpenses
                    : _selectedCategory!.name,
              ),
              trailing: _selectedCategory != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.useOverallBudget,
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
                title: Text(l10n.rolloverRemainingBudget),
                subtitle: _isEdit ? Text(l10n.rolloverSubtitle) : null,
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final amount =
                double.tryParse(_amountCtrl.text.replaceAll(',', '').trim());
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.budgetNameRequiredError)),
              );
              return;
            }
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.errorValidAmount)),
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
          child: Text(l10n.save),
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
    final l10n = context.l10n;
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
            l10n.noBudgetsSetYet,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onCreateBudget,
            child: Text(l10n.createBudget),
          ),
        ],
      ),
    );
  }
}
