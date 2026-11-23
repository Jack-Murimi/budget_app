import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/widget_update_service.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
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
            Consumer(
              builder: (context, ref, _) {
                final dueAsync = ref.watch(dueOrOverdueRecurringProvider);
                return dueAsync.when(
                  data: (items) {
                    if (items.isEmpty) return const SizedBox.shrink();
                    final theme = Theme.of(context);
                    final overdueCount = items.where((i) => i.isOverdue).length;
                    final isAlert = overdueCount > 0;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RecurringScreen()),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isAlert
                                ? theme.colorScheme.errorContainer
                                    .withValues(alpha: 0.6)
                                : theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAlert
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.tertiary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isAlert
                                    ? Icons.warning_amber_rounded
                                    : Icons.schedule,
                                color: isAlert
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onTertiaryContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isAlert
                                      ? l10n.billsOverdueCount(overdueCount)
                                      : l10n.billsDueSoonCount(items.length),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isAlert
                                        ? theme.colorScheme.onErrorContainer
                                        : theme.colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                              Text(
                                l10n.view,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isAlert
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: isAlert
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onTertiaryContainer,
                              ),
                            ],
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
                  data: (budget) => budget == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Card(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const BudgetsScreen()),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.account_balance_wallet,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(l10n.overallBudget),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.budgetProgressSummary(
                                        budget.spent.toStringAsFixed(0),
                                        budget.amount.toStringAsFixed(0),
                                        budget.percentage.toStringAsFixed(0),
                                      ),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: budget.progress,
                                        backgroundColor: theme.colorScheme
                                            .surfaceContainerHighest,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          budget.isOverBudget
                                              ? theme.colorScheme.error
                                              : budget.progress >= 0.75
                                                  ? theme.colorScheme.tertiary
                                                  : theme.colorScheme.primary,
                                        ),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: accounts.map((a) {
                                final isDefault = a.isDefault;
                                final accountColor = parseHexColor(
                                  a.colorHex,
                                  fallback: theme.colorScheme.primary,
                                );
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AccountDetailScreen(account: a),
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: accountColor.withValues(
                                          alpha: isDefault ? 0.24 : 0.14),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: accountColor.withValues(
                                            alpha: isDefault ? 0.9 : 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: accountColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              a.name,
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              CurrencyFormatter.format(
                                                  a.balance),
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            monthTxnsAsync.when(
              data: (txns) => CategoryPieChartSection(transactions: txns),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    l10n.recentTransactions,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        ref.read(selectedTabProvider.notifier).state = 1,
                    child: Text(l10n.seeAll),
                  ),
                ],
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
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.noTransactionsYet,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pasteOrAddHint,
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
