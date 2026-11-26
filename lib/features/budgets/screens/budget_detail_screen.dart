import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/app_localizations_en.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
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
    final isPinned = ref.watch(pinnedBudgetIdsProvider).contains(liveBudget.id);
    final canPin = !liveBudget.isOverall && !liveBudget.isArchived;

    final progressColor = liveBudget.isOverBudget
        ? theme.colorScheme.error
        : liveBudget.progress >= 0.75
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(liveBudget.name),
        actions: [
          if (canPin)
            IconButton(
              icon: Icon(
                isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              ),
              tooltip: isPinned ? l10n.unpinFromHome : l10n.pinToHome,
              onPressed: () {
                final ok = ref
                    .read(pinnedBudgetIdsProvider.notifier)
                    .toggle(liveBudget.id);
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
              if (nextArchived) {
                ref.read(pinnedBudgetIdsProvider.notifier).unpin(liveBudget.id);
              }
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
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          FadeSlideIn(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${CurrencyFormatter.format(liveBudget.spent)} / ${CurrencyFormatter.format(liveBudget.amount)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${liveBudget.percentage.toStringAsFixed(0)}%',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: progressColor,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (liveBudget.rolloverAmount > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.rolloverIncludes(
                          CurrencyFormatter.format(liveBudget.rolloverAmount),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    AnimatedProgressBar(
                      value: liveBudget.progress,
                      color: progressColor,
                      minHeight: 10,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: liveBudget.isOverBudget
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatPeriodInfo(liveBudget, l10n: l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!liveBudget.isOverall &&
                        liveBudget.categories.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final cat in liveBudget.categories)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              avatar: Icon(
                                CategoryIconHelper.resolveCategoryIcon(
                                  iconName: cat.icon,
                                  categoryName: cat.name,
                                  type: cat.transactionType,
                                ),
                                size: 16,
                                color: parseHexColor(
                                  cat.colorHex,
                                  fallback: theme.colorScheme.primary,
                                ),
                              ),
                              label: Text(cat.name),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (liveBudget.isMultiCategory &&
              liveBudget.categoryBreakdown.isNotEmpty)
            FadeSlideIn(
              index: 1,
              child: _CategoryBreakdownCard(budget: liveBudget),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.contributingTransactions,
              style: theme.textTheme.titleMedium,
            ),
          ),
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n.noExpensesInPeriodYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  for (final (i, t) in transactions.indexed)
                    FadeSlideIn(
                      index: i > 8 ? 8 : i,
                      dy: 10,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (t.type == 'income'
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            t.type == 'income'
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: 18,
                            color: t.type == 'income'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                        title: Text(
                          t.header,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${t.transactionDate.day}/${t.transactionDate.month}/${t.transactionDate.year}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(
                            t.amount + t.transactionCost + t.fulizaFee,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: t.type == 'income'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                ],
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
    var selectedCategories = List<Category>.of(current.categories);
    if (selectedCategories.isEmpty && current.categoryId != null) {
      final cat = await ref
          .read(categoryRepositoryProvider)
          .getCategoryById(current.categoryId!);
      if (cat != null) selectedCategories = [cat];
    }
    if (!context.mounted) return;

    final result = await showDialog<BudgetFormResult>(
      context: context,
      builder: (_) => BudgetFormDialog(
        existing: current,
        initialCategories: selectedCategories,
      ),
    );
    if (result == null) return;

    await ref
        .read(budgetRepositoryProvider)
        .updateBudget(result.companion, categoryIds: result.categoryIds);
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
      ref.read(pinnedBudgetIdsProvider.notifier).unpin(current.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.budgetDeleted)),
      );
    }
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  final BudgetWithProgress budget;

  const _CategoryBreakdownCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final slices = budget.categoryBreakdown;
    final totalSpent = budget.spent;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryBreakdownTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (totalSpent > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      for (final slice in slices)
                        if (slice.spent > 0)
                          Expanded(
                            flex: (slice.spent * 100).round().clamp(1, 1 << 30),
                            child: Container(
                              color: parseHexColor(
                                slice.category.colorHex,
                                fallback: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            for (final (i, slice) in slices.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              _BreakdownRow(
                slice: slice,
                budgetLimit: budget.amount,
                totalSpent: totalSpent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final BudgetCategoryBreakdown slice;
  final double budgetLimit;
  final double totalSpent;

  const _BreakdownRow({
    required this.slice,
    required this.budgetLimit,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final catColor = parseHexColor(
      slice.category.colorHex,
      fallback: theme.colorScheme.primary,
    );
    final sharePercent =
        totalSpent > 0 ? (slice.spent / totalSpent * 100).round() : 0;
    final barValue =
        budgetLimit > 0 ? (slice.spent / budgetLimit).clamp(0.0, 1.0) : 0.0;

    final subtitleParts = <String>[
      l10n.categoryTxnCount(slice.transactionCount),
      if (totalSpent > 0) l10n.categoryBreakdownShare(sharePercent),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CategoryIconHelper.resolveCategoryIcon(
                  iconName: slice.category.icon,
                  categoryName: slice.category.name,
                  type: slice.category.transactionType,
                ),
                size: 16,
                color: catColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slice.category.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitleParts.join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              CurrencyFormatter.format(slice.spent),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedProgressBar(
          value: barValue,
          color: catColor,
          minHeight: 5,
        ),
      ],
    );
  }
}
