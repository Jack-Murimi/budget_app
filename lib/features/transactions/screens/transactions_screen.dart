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

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(transactionSearchQueryProvider);
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
        content: Text('Are you sure you want to delete "$txn.header"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
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
        SnackBar(
          content: Text('Deleted "${txn.header}"'),
          duration: const Duration(seconds: 2),
        ),
      );
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

    String categoryLabel = 'All Categories';
    if (selectedCategoryId != null) {
      final cats = categoriesAsync.asData?.value;
      if (cats != null) {
        final match = cats.where((c) => c.id == selectedCategoryId).firstOrNull;
        if (match != null) categoryLabel = match.name;
      }
    }

    String accountLabel = 'All Accounts';
    if (selectedAccountId != null) {
      final accs = accountsAsync.asData?.value;
      if (accs != null) {
        final match = accs.where((a) => a.id == selectedAccountId).firstOrNull;
        if (match != null) accountLabel = match.name;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        automaticallyImplyLeading: !widget.isEmbedded,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search payee, header, ref...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(transactionSearchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                ref.read(transactionSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'expense', label: Text('Expense')),
                    ButtonSegment(value: 'income', label: Text('Income')),
                    ButtonSegment(value: 'transfer', label: Text('Transfer')),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (set) {
                    ref.read(transactionTypeFilterProvider.notifier).state = set.first;
                  },
                ),
                const SizedBox(width: 8),

                FilterChip(
                  label: Text(categoryLabel),
                  selected: selectedCategoryId != null,
                  avatar: const Icon(Icons.category_outlined, size: 16),
                  onSelected: (selected) async {
                    if (selectedCategoryId != null) {
                      ref.read(transactionCategoryFilterProvider.notifier).state = null;
                    } else {
                      final picked = await showCategoryPicker(context);
                      if (picked != null) {
                        ref.read(transactionCategoryFilterProvider.notifier).state = picked.id;
                      }
                    }
                  },
                ),
                const SizedBox(width: 8),

                FilterChip(
                  label: const Text('This Month'),
                  selected: selectedDateRange == 'this_month',
                  onSelected: (selected) {
                    ref.read(transactionDateRangeFilterProvider.notifier).state =
                        selected ? 'this_month' : 'all';
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: const Text('Today'),
                  selected: selectedDateRange == 'today',
                  onSelected: (selected) {
                    ref.read(transactionDateRangeFilterProvider.notifier).state =
                        selected ? 'today' : 'all';
                  },
                ),
                const SizedBox(width: 8),

                FilterChip(
                  label: Text(accountLabel),
                  selected: selectedAccountId != null,
                  avatar: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                  onSelected: (selected) async {
                    if (selectedAccountId != null) {
                      ref.read(transactionAccountFilterProvider.notifier).state = null;
                    } else {
                      final accounts = accountsAsync.asData?.value ?? [];
                      if (accounts.isNotEmpty) {
                        final picked = await showDialog<int>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Select Account'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView(
                                shrinkWrap: true,
                                children: accounts.map((a) => ListTile(
                                  title: Text(a.name),
                                  subtitle: Text(CurrencyFormatter.format(a.balance)),
                                  onTap: () => Navigator.of(ctx).pop(a.id),
                                )).toList(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                        if (picked != null) {
                          ref.read(transactionAccountFilterProvider.notifier).state = picked;
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

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
                      ],
                    ),
                  );
                }

                double total = 0;
                for (final t in txns) {
                  if (t.type == 'income') {
                    total += t.amount;
                  } else {
                    total -= (t.amount + t.transactionCost + t.fulizaFee);
                  }
                }

                final Map<String, List<TransactionModel>> grouped = {};
                for (final t in txns) {
                  final key = _formatGroupDate(t.transactionDate);
                  grouped.putIfAbsent(key, () => []).add(t);
                }

                return ListView(
                  padding: EdgeInsets.only(bottom: widget.isEmbedded ? 120 : 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      child: Row(
                        children: [
                          Text(
                            '${txns.length} transaction${txns.length == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            'Net: ${total >= 0 ? '+' : ''}${CurrencyFormatter.format(total)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: total >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),

                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          entry.key,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                          confirmDismiss: (dir) async {
                            await _confirmDelete(context, txn);
                            return false;
                          },
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddTransactionScreen(transactionToEdit: txn),
                                ),
                              );
                            },
                            title: Text(
                              txn.header,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              txn.description.isNotEmpty
                                  ? txn.description
                                  : (txn.mpesaRef ?? ''),
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
}