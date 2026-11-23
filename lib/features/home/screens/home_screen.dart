import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/widget_update_service.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
import '../../accounts/providers/account_providers.dart';
import '../../accounts/screens/account_detail_screen.dart';
import '../../budgets/providers/budget_providers.dart';
import '../../budgets/screens/budgets_screen.dart';
import '../../recurring/providers/recurring_providers.dart';
import '../../recurring/screens/recurring_screen.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../providers/navigation_providers.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/transaction_list_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double? _lastSyncedSpend;
  double? _lastSyncedBalance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncWidgetIfReady();
    });
  }

  void _syncWidgetIfReady() {
    final spend = ref.read(monthSummaryProvider).valueOrNull?.totalExpenses;
    final balance = ref.read(totalNetWorthProvider).valueOrNull;
    if (spend == null || balance == null) return;
    if (spend == _lastSyncedSpend && balance == _lastSyncedBalance) return;
    _lastSyncedSpend = spend;
    _lastSyncedBalance = balance;
    WidgetUpdateService.update(monthSpend: spend, totalBalance: balance);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final monthTxnsAsync = ref.watch(currentMonthTransactionsProvider);
    final summaryAsync = ref.watch(monthSummaryProvider);

    ref.listen<AsyncValue<MonthSummary>>(
      monthSummaryProvider,
      (_, __) => _syncWidgetIfReady(),
    );
    ref.listen<AsyncValue<double>>(
      totalNetWorthProvider,
      (_, __) => _syncWidgetIfReady(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              isDark ? 'assets/logo_dark.svg' : 'assets/logo.svg',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 10),
            Text(l10n.appTitle),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(currentMonthTransactionsProvider);
          ref.invalidate(monthSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            summaryAsync.when(
              data: (summary) => FadeSlideIn(
                child: SpendingSummaryCard(
                  totalSpent: summary.totalExpenses,
                  totalIncome: summary.totalIncome,
                  month: summary.month,
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Consumer(
              builder: (context, ref, _) {
                final dueAsync = ref.watch(dueOrOverdueRecurringProvider);
                return dueAsync.when(
                  data: (items) {
                    if (items.isEmpty) return const SizedBox.shrink();
                    final theme = Theme.of(context);
                    final overdueCount = items.where((i) => i.isOverdue).length;
                    final isAlert = overdueCount > 0;

                    return FadeSlideIn(
                      index: 1,
                      dy: 12,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Pressable(
                          haptic: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RecurringScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isAlert
                                  ? theme.colorScheme.errorContainer
                                      .withValues(alpha: 0.7)
                                  : theme.colorScheme.tertiaryContainer
                                      .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (isAlert
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.tertiary)
                                    .withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: (isAlert
                                            ? theme.colorScheme.error
                                            : theme.colorScheme.tertiary)
                                        .withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isAlert
                                        ? Icons.warning_amber_rounded
                                        : Icons.schedule_rounded,
                                    color: isAlert
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onTertiaryContainer,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isAlert
                                        ? l10n.billsOverdueCount(overdueCount)
                                        : l10n.billsDueSoonCount(items.length),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isAlert
                                          ? theme.colorScheme.onErrorContainer
                                          : theme.colorScheme
                                              .onTertiaryContainer,
                                    ),
                                  ),
                                ),
                                Text(
                                  l10n.view,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isAlert
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: isAlert
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onTertiaryContainer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final theme = Theme.of(context);
                final budgetAsync = ref.watch(overallBudgetProvider);
                return budgetAsync.when(
                  data: (budget) {
                    if (budget == null) return const SizedBox.shrink();
                    final statusColor = budget.isOverBudget
                        ? theme.colorScheme.error
                        : budget.progress >= 0.75
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.primary;
                    return FadeSlideIn(
                      index: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                        child: Pressable(
                          haptic: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BudgetsScreen()),
                          ),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                              alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet_rounded,
                                          size: 17,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          l10n.overallBudget,
                                          style: theme.textTheme.titleSmall,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    l10n.budgetProgressSummary(
                                      budget.spent.toStringAsFixed(0),
                                      budget.amount.toStringAsFixed(0),
                                      budget.percentage.toStringAsFixed(0),
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedProgressBar(
                                    value: budget.progress,
                                    color: statusColor,
                                    minHeight: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final theme = Theme.of(context);
                final accountsAsync = ref.watch(accountsWithBalanceProvider);
                return accountsAsync.when(
                  data: (accounts) => accounts.isEmpty
                      ? const SizedBox.shrink()
                      : FadeSlideIn(
                          index: 2,
                          dy: 10,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: accounts.map((a) {
                                  final isDefault = a.isDefault;
                                  final accountColor = parseHexColor(
                                    a.colorHex,
                                    fallback: theme.colorScheme.primary,
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Pressable(
                                      haptic: true,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AccountDetailScreen(account: a),
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 11),
                                        decoration: BoxDecoration(
                                          color: isDefault
                                              ? accountColor.withValues(
                                                  alpha: 0.16)
                                              : theme.colorScheme
                                                  .surfaceContainerLow,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDefault
                                                ? accountColor.withValues(
                                                    alpha: 0.65)
                                                : theme
                                                    .colorScheme.outlineVariant
                                                    .withValues(alpha: 0.7),
                                            width: isDefault ? 1.25 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: accountColor,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  a.name,
                                                  style: theme
                                                      .textTheme.labelMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  CurrencyFormatter.format(
                                                      a.balance),
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontFeatures: const [
                                                      FontFeature
                                                          .tabularFigures()
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            monthTxnsAsync.when(
              data: (txns) => FadeSlideIn(
                index: 3,
                child: CategoryPieChartSection(transactions: txns),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Text(
                    l10n.recentTransactions,
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        ref.read(selectedTabProvider.notifier).state = 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.seeAll),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            transactionsAsync.when(
              data: (txns) => txns.isEmpty
                  ? const _EmptyState()
                  : Column(
                      children: [
                        for (final (i, t) in txns.indexed)
                          FadeSlideIn(
                            key: ValueKey(t.id),
                            index: 4 + (i > 6 ? 6 : i),
                            dy: 12,
                            child: TransactionListItem(transaction: t),
                          ),
                      ],
                    ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.couldNotLoadTransactions,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        ref.invalidate(recentTransactionsProvider);
                        ref.invalidate(monthSummaryProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return FadeSlideIn(
      index: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.noTransactionsYet,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.pasteOrAddHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
