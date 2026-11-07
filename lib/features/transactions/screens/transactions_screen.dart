import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';
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

  String _formatGroupDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txnDate = DateTime(dt.year, dt.month, dt.day);
    if (txnDate == today) return 'Today';
    if (txnDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, d MMM yyyy').format(dt);
  }

  Future<void> _confirmDelete(BuildContext context, TransactionModel txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${txn.header}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(transactionRepositoryProvider).delete(txn.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${txn.header}"'), duration: const Duration(seconds: 2)),
      );
    }
  }

  Widget _buildLeadingIcon(ThemeData theme, String type) {
    final (IconData icon, Color bg, Color fg) = switch (type) {
      'income' => (Icons.arrow_downward_rounded, theme.colorScheme.primaryContainer, theme.colorScheme.primary),
      'transfer' => (Icons.swap_horiz_rounded, theme.colorScheme.tertiaryContainer, theme.colorScheme.tertiary),
      _ => (Icons.arrow_upward_rounded, theme.colorScheme.errorContainer, theme.colorScheme.error),
    };
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: fg, size: 20),
    );
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
              child: Text('Filter by Account', style: Theme.of(ctx).textTheme.titleSmall),
            ),
            ...accounts.map((a) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(int.parse(a.colorHex.replaceFirst('#', '0xFF'))),
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
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final selectedType = ref.watch(transactionTypeFilterProvider);
    final selectedCategoryId = ref.watch(transactionCategoryFilterProvider);
    final selectedDateRange = ref.watch(transactionDateRangeFilterProvider);
    final selectedAccountId = ref.watch(transactionAccountFilterProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);

    final activeFilterCount = [
      selectedType != 'all',
      selectedCategoryId != null,
      selectedDateRange != 'all',
      selectedAccountId != null,
    ].where((b) => b).length;

    String categoryName = 'Category';
    if (selectedCategoryId != null) {
      final match = categoriesAsync.asData?.value.where((c) => c.id == selectedCategoryId).firstOrNull;
      if (match != null) categoryName = match.name;
    }

    String accountName = 'Account';
    if (selectedAccountId != null) {
      final match = accountsAsync.asData?.value.where((a) => a.id == selectedAccountId).firstOrNull;
      if (match != null) accountName = match.name;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEmbedded,
        title: _searchExpanded
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                style: theme.textTheme.bodyLarge,
                onChanged: (val) {
                  ref.read(transactionSearchQueryProvider.notifier).state = val;
                  setState(() {});
                },
              )
            : const Text('Transactions'),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(_searchExpanded ? Icons.close : Icons.search),
            tooltip: _searchExpanded ? 'Close search' : 'Search',
            onPressed: () {
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
                tooltip: 'Filters',
                onPressed: () => _showFilterSheet(context),
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
              tooltip: 'Clear filters',
              onPressed: _clearAllFilters,
            ),
        ],
      ),

      body: Column(
        children: [
          // Active filter chips — compact horizontal scroll, only shown when active
          if (activeFilterCount > 0)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: [
                  if (selectedType != 'all')
                    _ActiveChip(
                      label: selectedType[0].toUpperCase() + selectedType.substring(1),
                      onRemove: () => ref.read(transactionTypeFilterProvider.notifier).state = 'all',
                    ),
                  if (selectedCategoryId != null)
                    _ActiveChip(
                      label: categoryName,
                      onRemove: () => ref.read(transactionCategoryFilterProvider.notifier).state = null,
                    ),
                  if (selectedDateRange != 'all')
                    _ActiveChip(
                      label: selectedDateRange == 'today' ? 'Today' : 'This Month',
                      onRemove: () => ref.read(transactionDateRangeFilterProvider.notifier).state = 'all',
                    ),
                  if (selectedAccountId != null)
                    _ActiveChip(
                      label: accountName,
                      onRemove: () => ref.read(transactionAccountFilterProvider.notifier).state = null,
                    ),
                ],
              ),
            ),

          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (txns) {
                if (txns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 8),
                        Text('No transactions found', style: theme.textTheme.bodyMedium),
                        if (activeFilterCount > 0) ...[
                          const SizedBox(height: 8),
                          TextButton(onPressed: _clearAllFilters, child: const Text('Clear filters')),
                        ],
                      ],
                    ),
                  );
                }

                double income = 0, expense = 0;
                for (final t in txns) {
                  if (t.type == 'income') income += t.amount;
                  else expense += t.amount + t.transactionCost + t.fulizaFee;
                }
                final net = income - expense;

                final Map<String, List<TransactionModel>> grouped = {};
                for (final t in txns) {
                  grouped.putIfAbsent(_formatGroupDate(t.transactionDate), () => []).add(t);
                }

                return ListView(
                  padding: EdgeInsets.only(bottom: widget.isEmbedded ? 120 : 32),
                  children: [
                    // Summary bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      child: Row(
                        children: [
                          Text('${txns.length} transaction${txns.length == 1 ? '' : 's'}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                          const Spacer(),
                          _SummaryPill(label: '▲', amount: expense, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          _SummaryPill(label: '▼', amount: income, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '${net >= 0 ? '+' : ''}${CurrencyFormatter.format(net)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: net >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),

                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(entry.key,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.outline, fontWeight: FontWeight.w600)),
                      ),
                      for (final txn in entry.value)
                        Dismissible(
                          key: ValueKey(txn.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.error,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            await _confirmDelete(context, txn);
                            return false;
                          },
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: txn)),
                            ),
                            leading: _buildLeadingIcon(theme, txn.type),
                            title: Text(txn.header,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              txn.description.isNotEmpty ? txn.description : (txn.mpesaRef ?? ''),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${txn.type == 'income' ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: txn.type == 'income'
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  onPressed: () => _confirmDelete(context, txn),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
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
                    Text('Filters', style: Theme.of(ctx).textTheme.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearAllFilters();
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text('Type', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['all', 'income', 'expense', 'transfer'].map((t) {
                    final label = t == 'all' ? 'All' : t[0].toUpperCase() + t.substring(1);
                    final selected = localType == t;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setS(() => localType = t),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text('Date', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: {
                    'all': 'All time',
                    'today': 'Today',
                    'this_week': 'This week',
                    'this_month': 'This month',
                  }.entries.map((e) {
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: localDate == e.key,
                      onSelected: (_) => setS(() => localDate = e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text('Category', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.category_outlined, size: 16),
                  label: Text(ref.read(transactionCategoryFilterProvider) != null
                      ? (ref.read(categoriesStreamProvider).asData?.value
                              .where((c) => c.id == ref.read(transactionCategoryFilterProvider))
                              .firstOrNull
                              ?.name ?? 'Category')
                      : 'Pick category'),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final picked = await showCategoryPicker(context);
                    if (picked != null) {
                      ref.read(transactionCategoryFilterProvider.notifier).state = picked.id;
                    }
                  },
                ),
                const SizedBox(height: 16),

                Text('Account', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: Theme.of(ctx).colorScheme.primary)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                  label: Text(ref.read(transactionAccountFilterProvider) != null
                      ? (ref.read(accountsWithBalanceProvider).asData?.value
                              .where((a) => a.id == ref.read(transactionAccountFilterProvider))
                              .firstOrNull
                              ?.name ?? 'Account')
                      : 'Pick account'),
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
                    child: const Text('Apply'),
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
    return Text(
      '$label ${CurrencyFormatter.format(amount)}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}
