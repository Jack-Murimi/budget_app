import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/app_localizations_en.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../categories/providers/category_providers.dart';
import '../models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../utils/budget_period_helper.dart';
import 'budgets_screen.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final BudgetWithProgress budgetWithProgress;

  const BudgetDetailScreen({
    super.key,
    required this.budgetWithProgress,
  });

  static final AppLocalizations _fallbackL10n = AppLocalizationsEn();

  static String formatPeriodInfo(
    BudgetWithProgress bp, {
    DateTime? now,
    AppLocalizations? l10n,
  }) {
    final strings = l10n ?? _fallbackL10n;
    if (bp.remaining <= 0) {
      return strings.noRemainingBudget;
    }

    final current = now ?? DateTime.now();
    final (_, end) = BudgetPeriodHelper.getPeriodWindow(bp.budget, current);
    if (!current.isBefore(end)) {
      return strings.periodEnded;
    }

    final remainingDays = BudgetPeriodHelper.daysRemaining(
      bp.budget,
      now: current,
    ).clamp(1, 999999);
    final recommendedDaily = bp.remaining / remainingDays;
    final daily = CurrencyFormatter.formatCompact(recommendedDaily);

    return strings.recommendedDaily(daily, remainingDays);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
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
                      nextArchived ? l10n.budgetArchived : l10n.budgetUnarchived,
                    ),
                  ),
                );
              }
            },
            tooltip: liveBudget.isArchived
                ? l10n.unarchiveBudgetTooltip
                : l10n.archiveBudgetTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref, liveBudget),
            tooltip: l10n.editBudgetTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, ref, liveBudget),
            tooltip: l10n.deleteBudgetTooltip,
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
                      l10n.rolloverIncludes(
                        CurrencyFormatter.format(liveBudget.rolloverAmount),
                      ),
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
                        ? l10n.overBudgetBy(
                            CurrencyFormatter.format(
                              liveBudget.spent - liveBudget.amount,
                            ),
                          )
                        : l10n.amountRemaining(
                            CurrencyFormatter.format(liveBudget.remaining),
                          ),
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
                    formatPeriodInfo(liveBudget, l10n: l10n),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.contributingTransactions,
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
                      l10n.noExpensesInPeriodYet,
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
              child: Center(child: Text(l10n.errorLabel('$e'))),
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
      SnackBar(content: Text(context.l10n.budgetUpdated)),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetWithProgress current,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBudgetTitle),
        content: Text(l10n.deleteBudgetConfirm(current.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(budgetRepositoryProvider).deleteBudget(current.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.budgetDeleted)),
      );
    }
  }
}
