import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
import '../../categories/widgets/multi_category_picker.dart';
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
    final pinnedIds = ref.watch(pinnedBudgetIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetsTitle),
        actions: [
          IconButton(
            icon: Icon(
              _showArchived
                  ? Icons.unarchive_rounded
                  : Icons.archive_outlined,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _showArchived = !_showArchived);
            },
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
            onRefresh: () async =>
                ref.invalidate(allBudgetsWithProgressProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96, top: 4),
              children: [
                for (final (i, b) in filteredBudgets.indexed)
                  FadeSlideIn(
                    key: ValueKey('${b.id}-$_showArchived'),
                    index: i,
                    child: _buildBudgetCard(
                      b,
                      isPinned: pinnedIds.contains(b.id),
                    ),
                  ),
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
        onPressed: () {
          HapticFeedback.lightImpact();
          _showCreateDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _periodLabel(String period, AppLocalizations l10n) => switch (period) {
        'monthly' => l10n.monthly,
        'weekly' => l10n.weekly,
        _ => l10n.custom,
      };

  Widget _buildBudgetCard(BudgetWithProgress b, {bool isPinned = false}) {
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
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDetail(b),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: progressColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 22,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.overallBudget,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${CurrencyFormatter.format(b.spent)} / ${CurrencyFormatter.format(b.amount)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showArchived)
                      IconButton(
                        icon: const Icon(Icons.unarchive_outlined),
                        tooltip: l10n.unarchive,
                        onPressed: () => ref
                            .read(budgetRepositoryProvider)
                            .archiveBudget(b.id, archive: false),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.daysCount(daysLeft),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (b.rolloverAmount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.rolloverPlusBadge(
                      CurrencyFormatter.format(b.rolloverAmount),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                AnimatedProgressBar(
                  value: b.progress,
                  color: progressColor,
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  isOver
                      ? l10n.overBudgetBy(
                          CurrencyFormatter.format(b.spent - b.amount),
                        )
                      : l10n.amountLeft(CurrencyFormatter.format(b.remaining)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOver
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final categoryColor = parseHexColor(
        b.categoryColorHex,
        fallback: theme.colorScheme.primary,
      );

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: categoryColor.withValues(alpha: 0.15),
            child: Icon(
              b.isMultiCategory
                  ? Icons.layers_outlined
                  : CategoryIconHelper.resolveCategoryIcon(
                      iconName: b.categoryIcon,
                      categoryName: b.categoryName,
                    ),
              color: categoryColor,
            ),
          ),
          title: Text(
            b.name,
            style: theme.textTheme.titleSmall,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.format(b.spent)} / ${CurrencyFormatter.format(b.amount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
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
              const SizedBox(height: 6),
              AnimatedProgressBar(
                value: b.progress,
                color: progressColor,
                minHeight: 7,
              ),
              const SizedBox(height: 6),
              Text(
                isOver
                    ? l10n.overBudgetBy(
                        CurrencyFormatter.format(b.spent - b.amount),
                      )
                    : b.categorySummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOver
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isOver ? FontWeight.w600 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          trailing: _showArchived
              ? IconButton(
                  icon: const Icon(Icons.unarchive_outlined),
                  tooltip: l10n.unarchive,
                  onPressed: () {
                    ref.read(pinnedBudgetIdsProvider.notifier).unpin(b.id);
                    ref
                        .read(budgetRepositoryProvider)
                        .archiveBudget(b.id, archive: false);
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 20,
                        color: isPinned
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: isPinned ? l10n.unpinFromHome : l10n.pinToHome,
                      onPressed: () {
                        final ok = ref
                            .read(pinnedBudgetIdsProvider.notifier)
                            .toggle(b.id);
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                !ok
                                    ? l10n.maxPinnedBudgetsReached(
                                        PinnedBudgetsNotifier.maxPinned,
                                      )
                                    : (isPinned
                                        ? l10n.budgetUnpinnedFromHome
                                        : l10n.budgetPinnedToHome),
                              ),
                            ),
                          );
                      },
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        _periodLabel(b.budget.period, l10n),
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
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
    final result = await showDialog<BudgetFormResult>(
      context: context,
      builder: (_) => const BudgetFormDialog(),
    );
    if (result == null) return;
    await ref
        .read(budgetRepositoryProvider)
        .insertBudget(result.companion, categoryIds: result.categoryIds);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.budgetCreated)),
    );
  }
}

/// Shared create/edit budget dialog that owns and disposes its controllers.
class BudgetFormDialog extends StatefulWidget {
  final BudgetWithProgress? existing;
  final List<Category> initialCategories;

  const BudgetFormDialog({
    super.key,
    this.existing,
    this.initialCategories = const [],
  });

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.existing != null ? widget.existing!.baseAmount.toString() : '',
  );

  late String _period = widget.existing?.period ?? 'monthly';
  late List<Category> _selectedCategories = List.of(widget.initialCategories);
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
      initialDate:
          _customEnd.isBefore(_customStart) ? _customStart : _customEnd,
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
              title: Text(l10n.categories),
              subtitle: Text(
                l10n.categoriesSelectedCount(_selectedCategories.length),
              ),
              trailing: _selectedCategories.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.useOverallBudget,
                      onPressed: () =>
                          setState(() => _selectedCategories = []),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showMultiCategoryPicker(
                  context,
                  initialSelectedIds:
                      _selectedCategories.map((c) => c.id).toSet(),
                );
                if (picked != null && mounted) {
                  setState(() => _selectedCategories = picked);
                }
              },
            ),
            if (_selectedCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final cat in _selectedCategories)
                    InputChip(
                      avatar: Icon(
                        CategoryIconHelper.resolveCategoryIcon(
                          iconName: cat.icon,
                          categoryName: cat.name,
                          type: cat.transactionType,
                        ),
                        size: 16,
                        color: parseHexColor(cat.colorHex),
                      ),
                      label: Text(cat.name),
                      onDeleted: () => setState(() {
                        _selectedCategories.removeWhere((c) => c.id == cat.id);
                      }),
                    ),
                ],
              ),
            ],
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
            final categoryIds = _selectedCategories.map((c) => c.id).toList();
            final primaryCategoryId =
                categoryIds.isEmpty ? null : categoryIds.first;

            if (_isEdit) {
              Navigator.pop(
                context,
                BudgetFormResult(
                  companion: BudgetsCompanion(
                    id: Value(widget.existing!.id),
                    name: Value(name),
                    amount: Value(amount),
                    period: Value(_period),
                    categoryId: Value(primaryCategoryId),
                    startDate: Value(startDate),
                    endDate: Value(endDate),
                    rollover: Value(rolloverFlag),
                  ),
                  categoryIds: categoryIds,
                ),
              );
            } else {
              Navigator.pop(
                context,
                BudgetFormResult(
                  companion: BudgetsCompanion.insert(
                    name: name,
                    amount: amount,
                    period: Value(_period),
                    categoryId: Value(primaryCategoryId),
                    startDate: startDate,
                    endDate: Value(endDate),
                    rollover: Value(rolloverFlag),
                  ),
                  categoryIds: categoryIds,
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
    final theme = Theme.of(context);
    return FadeSlideIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 38,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.noBudgetsSetYet,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onCreateBudget,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.createBudget),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
