import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/cashflow_calculator.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';
import '../../home/widgets/floating_action_buttons.dart';
import '../../home/widgets/transaction_list_item.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_providers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const TransactionsScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(transactionSearchQueryProvider);
    _searchExpanded = _searchCtrl.text.isNotEmpty;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatGroupDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txnDate = DateTime(dt.year, dt.month, dt.day);
    if (txnDate == today) return l10n.today;
    if (txnDate == today.subtract(const Duration(days: 1))) {
      return l10n.yesterday;
    }
    return DateFormat('EEE, d MMM yyyy').format(dt);
  }

  Future<void> _confirmDelete(BuildContext context, TransactionModel txn) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTransactionTitle),
        content: Text(l10n.deleteItemQuestion(txn.header)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(transactionRepositoryProvider).delete(txn.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deletedItemToast(txn.header)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearAllFilters() {
    ref.read(transactionTypeFilterProvider.notifier).state = 'all';
    ref.read(transactionCategoryFilterProvider.notifier).state = null;
    ref.read(transactionDateRangeFilterProvider.notifier).state = 'all';
    ref.read(transactionAccountFilterProvider.notifier).state = null;
    _searchCtrl.clear();
    ref.read(transactionSearchQueryProvider.notifier).state = '';
    setState(() => _searchExpanded = false);
  }

  Future<void> _pickAccount(BuildContext context) async {
    final l10n = context.l10n;
    final accounts = ref.read(accountsWithBalanceProvider).asData?.value ?? [];
    if (accounts.isEmpty) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l10n.filterByAccount, style: Theme.of(ctx).textTheme.titleSmall),
            ),
            ...accounts.map((a) => ListTile(
              leading: CircleAvatar(
                backgroundColor: parseHexColor(a.colorHex),
                radius: 14,
                child: Text(a.name.isNotEmpty ? a.name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              title: Text(a.name),
              subtitle: Text(CurrencyFormatter.format(a.balance)),
              onTap: () => Navigator.pop(ctx, a.id),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) {
      ref.read(transactionAccountFilterProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final selectedType = ref.watch(transactionTypeFilterProvider);
    final selectedCategoryId = ref.watch(transactionCategoryFilterProvider);
    final selectedDateRange = ref.watch(transactionDateRangeFilterProvider);
    final selectedAccountId = ref.watch(transactionAccountFilterProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);

    final activeFilterCount = [
      selectedType != 'all',
      selectedCategoryId != null,
      selectedDateRange != 'all',
      selectedAccountId != null,
    ].where((b) => b).length;

    final categoryName = selectedCategoryId != null
        ? (categoriesById[selectedCategoryId]?.name ?? l10n.category)
        : l10n.category;

    String accountName = l10n.account;
    if (selectedAccountId != null) {
      final match = accountsAsync.asData?.value.where((a) => a.id == selectedAccountId).firstOrNull;
      if (match != null) accountName = match.name;
    }

    String typeLabel(String t) => switch (t) {
          'income' => l10n.income,
          'expense' => l10n.expense,
          'transfer' => l10n.transfer,
          _ => l10n.all,
        };

    final reduced = Motion.reduced(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEmbedded,
        title: AnimatedSwitcher(
          duration: reduced ? Duration.zero : Motion.fast,
          switchInCurve: Motion.emphasizedDecelerate,
          switchOutCurve: Motion.emphasized,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.centerLeft,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: _searchExpanded
              ? TextField(
                  key: const ValueKey('search'),
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchTransactionsHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5)),
                  ),
                  style: theme.textTheme.bodyLarge,
                  onChanged: (val) {
                    ref.read(transactionSearchQueryProvider.notifier).state =
                        val;
                    setState(() {});
                  },
                )
              : Text(
                  l10n.transactionsTitle,
                  key: const ValueKey('title'),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            tooltip: l10n.batchPasteTitle,
            onPressed: () {
              HapticFeedback.selectionClick();
              HomeFloatingActionButtons.openBatchPaste(context, ref);
            },
          ),
          // Search toggle
          IconButton(
            icon: AnimatedSwitcher(
              duration: reduced ? Duration.zero : Motion.fast,
              child: Icon(
                _searchExpanded ? Icons.close : Icons.search,
                key: ValueKey(_searchExpanded),
              ),
            ),
            tooltip: _searchExpanded ? l10n.closeSearch : l10n.search,
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _searchExpanded = !_searchExpanded);
              if (!_searchExpanded) {
                _searchCtrl.clear();
                ref.read(transactionSearchQueryProvider.notifier).state = '';
              }
            },
          ),
          // Filter icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: l10n.filters,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _showFilterSheet(context);
                },
              ),
              if (activeFilterCount > 0)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$activeFilterCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          if (activeFilterCount > 0)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: l10n.clearFilters,
              onPressed: _clearAllFilters,
            ),
        ],
      ),

      body: Column(
        children: [
          // Active filter chips — smooth animated reveal
          AnimatedSize(
            duration: reduced ? Duration.zero : Motion.fast,
            curve: Motion.emphasized,
            child: activeFilterCount > 0
                ? SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      children: [
                        if (selectedType != 'all')
                          _ActiveChip(
                            label: typeLabel(selectedType),
                            onRemove: () => ref
                                .read(transactionTypeFilterProvider.notifier)
                                .state = 'all',
                          ),
                        if (selectedCategoryId != null)
                          _ActiveChip(
                            label: categoryName,
                            onRemove: () => ref
                                .read(
                                    transactionCategoryFilterProvider.notifier)
                                .state = null,
                          ),
                        if (selectedDateRange != 'all')
                          _ActiveChip(
                            label: switch (selectedDateRange) {
                              'today' => l10n.today,
                              'this_week' => l10n.thisWeekTitle,
                              _ => l10n.thisMonth,
                            },
                            onRemove: () => ref
                                .read(
                                    transactionDateRangeFilterProvider.notifier)
                                .state = 'all',
                          ),
                        if (selectedAccountId != null)
                          _ActiveChip(
                            label: accountName,
                            onRemove: () => ref
                                .read(transactionAccountFilterProvider.notifier)
                                .state = null,
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorLabel('$e'))),
              data: (txns) {
                if (txns.isEmpty) {
                  return FadeSlideIn(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 34,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noTransactionsFound,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (activeFilterCount > 0) ...[
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                onPressed: _clearAllFilters,
                                child: Text(l10n.clearFilters),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final summary = CashflowCalculator.summarize(txns);
                final income = summary.income;
                final expense = summary.expenses;
                final net = summary.net;

                final Map<String, List<TransactionModel>> grouped = {};
                for (final t in txns) {
                  grouped.putIfAbsent(_formatGroupDate(t.transactionDate, l10n), () => []).add(t);
                }

                final listItems = <_TransactionsListItem>[
                  _SummaryBarItem(
                    count: txns.length,
                    income: income,
                    expense: expense,
                    net: net,
                  ),
                  for (final entry in grouped.entries) ...[
                    _DateHeaderItem(
                      title: entry.key,
                      net: CashflowCalculator.summarize(entry.value).net,
                    ),
                    for (final txn in entry.value) _TransactionRowItem(txn),
                  ],
                ];

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: widget.isEmbedded ? 120 : 32),
                  itemCount: listItems.length,
                  itemBuilder: (context, index) => switch (listItems[index]) {
                    _SummaryBarItem(:final count, :final income, :final expense, :final net) =>
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              Text(
                                l10n.transactionCount(count),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _SummaryPill(label: '▲', amount: expense, color: theme.colorScheme.error),
                                  _SummaryPill(label: '▼', amount: income, color: theme.colorScheme.primary),
                                  AnimatedAmount(
                                    value: net,
                                    format: (v) =>
                                        '${v >= 0 ? '+' : ''}${CurrencyFormatter.format(v)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: net >= 0
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    _DateHeaderItem(:final title, :final net) => Builder(
                        builder: (context) {
                          final isPositive = net > 0;
                          final isNegative = net < 0;
                          final netColor = isPositive
                              ? theme.colorScheme.primary
                              : (isNegative ? theme.colorScheme.error : theme.colorScheme.outline);
                          final netSign = isPositive ? '+' : (isNegative ? '-' : '');
                          final netFormatted = '$netSign${CurrencyFormatter.format(net.abs())}';

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: netColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    netFormatted,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: netColor,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    _TransactionRowItem(:final transaction) => Dismissible(
                        key: ValueKey(transaction.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: theme.colorScheme.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _confirmDelete(context, transaction);
                          return false;
                        },
                        child: TransactionListItem(
                          transaction: transaction,
                          onDelete: () => _confirmDelete(context, transaction),
                        ),
                      ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final l10n = context.l10n;
    String localType = ref.read(transactionTypeFilterProvider);
    String localDate = ref.read(transactionDateRangeFilterProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.filters, style: Theme.of(ctx).textTheme.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearAllFilters();
                      },
                      child: Text(l10n.clearAll),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(l10n.type, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['all', 'income', 'expense', 'transfer'].map((t) {
                    final label = switch (t) {
                      'income' => l10n.income,
                      'expense' => l10n.expense,
                      'transfer' => l10n.transfer,
                      _ => l10n.all,
                    };
                    final selected = localType == t;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setS(() => localType = t),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text(l10n.date, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: {
                    'all': l10n.allTime,
                    'today': l10n.today,
                    'this_week': l10n.thisWeek,
                    'this_month': l10n.thisMonth,
                  }.entries.map((e) {
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: localDate == e.key,
                      onSelected: (_) => setS(() => localDate = e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text(l10n.category, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.category_outlined, size: 16),
                  label: Text(ref.read(transactionCategoryFilterProvider) != null
                      ? (ref.read(categoriesByIdProvider)[ref.read(transactionCategoryFilterProvider)!]?.name ?? l10n.category)
                      : l10n.pickCategory),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final picked = await showCategoryPicker(context);
                    if (picked != null) {
                      ref.read(transactionCategoryFilterProvider.notifier).state = picked.id;
                    }
                  },
                ),
                const SizedBox(height: 16),

                Text(l10n.account, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                  label: Text(ref.read(transactionAccountFilterProvider) != null
                      ? (ref.read(accountsWithBalanceProvider).asData?.value
                              .where((a) => a.id == ref.read(transactionAccountFilterProvider))
                              .firstOrNull
                              ?.name ?? l10n.account)
                      : l10n.pickAccount),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _pickAccount(context);
                  },
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(transactionTypeFilterProvider.notifier).state = localType;
                      ref.read(transactionDateRangeFilterProvider.notifier).state = localDate;
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.apply),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: theme.colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryPill({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedAmount(
      value: amount,
      format: (v) => '$label ${CurrencyFormatter.format(v)}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

sealed class _TransactionsListItem {
  const _TransactionsListItem();
}

class _SummaryBarItem extends _TransactionsListItem {
  final int count;
  final double income;
  final double expense;
  final double net;

  const _SummaryBarItem({
    required this.count,
    required this.income,
    required this.expense,
    required this.net,
  });
}

class _DateHeaderItem extends _TransactionsListItem {
  final String title;
  final double net;

  const _DateHeaderItem({required this.title, required this.net});
}

class _TransactionRowItem extends _TransactionsListItem {
  final TransactionModel transaction;

  const _TransactionRowItem(this.transaction);
}
