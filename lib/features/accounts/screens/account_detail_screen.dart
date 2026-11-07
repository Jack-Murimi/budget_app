import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/account_model.dart';
import '../providers/account_providers.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final AccountWithBalance account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  late AccountWithBalance _account;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(dt.year, dt.month, dt.day);
    if (txDate == today) return 'Today';
    if (txDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, d MMM yyyy').format(dt);
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

  static const _colorOptions = {
    '#1B5E20': 'Dark Green',
    '#4CAF50': 'Green',
    '#2196F3': 'Blue',
    '#F44336': 'Red',
    '#FF9800': 'Orange',
    '#9C27B0': 'Purple',
    '#009688': 'Teal',
    '#795548': 'Brown',
    '#607D8B': 'Grey',
  };

  Future<void> _showEditDialog() async {
    final nameCtrl = TextEditingController(text: _account.name);
    const validTypes = ['mpesa', 'cash', 'bank', 'airtel', 'other'];
    String selectedType = validTypes.contains(_account.type.toLowerCase())
        ? _account.type.toLowerCase()
        : 'other';
    // fall back to first option if stored hex not in list
    String selectedColor = _colorOptions.containsKey(_account.colorHex)
        ? _account.colorHex
        : _colorOptions.keys.first;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  value: selectedType,
                  items: const ['mpesa', 'cash', 'bank', 'airtel', 'other']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (v) { if (v != null) setS(() => selectedType = v); },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Color', border: OutlineInputBorder()),
                  value: selectedColor,
                  items: _colorOptions.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(children: [
                      Container(width: 16, height: 16, margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(color: Color(int.parse(e.key.replaceFirst('#', '0xFF'))), shape: BoxShape.circle)),
                      Text(e.value),
                    ]),
                  )).toList(),
                  onChanged: (v) { if (v != null) setS(() => selectedColor = v); },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await ref.read(accountRepositoryProvider).updateAccount(
                  AccountsCompanion(
                    id: Value(_account.id),
                    name: Value(nameCtrl.text.trim()),
                    type: Value(selectedType),
                    colorHex: Value(selectedColor),
                  ),
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      // Refresh account data from provider
      final updated = await ref.read(accountRepositoryProvider).getAll(includeArchived: true);
      final match = updated.where((a) => a.id == _account.id).firstOrNull;
      if (match != null && mounted) {
        setState(() => _account = AccountWithBalance(account: match, balance: _account.balance));
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Delete "${_account.name}"? All linked transactions will lose their account reference.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(accountRepositoryProvider).deleteAccount(_account.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<void> _adjustBalance(double currentBalance) async {
    final ctrl = TextEditingController(text: currentBalance.toStringAsFixed(2));
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Balance'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'New Balance', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final newBal = double.tryParse(ctrl.text.replaceAll(',', ''));
              if (newBal != null) {
                await ref.read(accountRepositoryProvider).correctBalance(
                  accountId: _account.id,
                  currentBalance: currentBalance,
                  targetBalance: newBal,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txnsAsync = ref.watch(accountTransactionsProvider(_account.id));
    final accountColor = Color(int.parse(_account.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      appBar: AppBar(
        title: Text(_account.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'edit': await _showEditDialog();
                case 'default':
                  await ref.read(accountRepositoryProvider).setDefault(_account.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_account.name} set as default')),
                  );
                case 'archive':
                  await ref.read(accountRepositoryProvider).archiveAccount(_account.id, archive: !_account.isArchived);
                  if (!mounted) return;
                  Navigator.pop(context);
                case 'delete': await _confirmDelete();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'), dense: true)),
              if (!_account.isDefault)
                const PopupMenuItem(value: 'default', child: ListTile(leading: Icon(Icons.star_outline), title: Text('Set as Default'), dense: true)),
              PopupMenuItem(value: 'archive', child: ListTile(
                leading: Icon(_account.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                title: Text(_account.isArchived ? 'Unarchive' : 'Archive'),
                dense: true,
              )),
              PopupMenuItem(value: 'delete', child: ListTile(
                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                dense: true,
              )),
            ],
          ),
        ],
      ),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rawTxns) {
          // Compute balance from account data in provider (stays reactive)
          final accountsAsync = ref.watch(accountsWithBalanceProvider);
          final liveAccount = accountsAsync.asData?.value.where((a) => a.id == _account.id).firstOrNull;
          final balance = liveAccount?.balance ?? _account.balance;

          // Convert to TransactionModel for display
          final txns = rawTxns.map((t) => t.toModel()).toList();

          // Group by date
          final Map<String, List<TransactionModel>> grouped = {};
          for (final t in txns) {
            grouped.putIfAbsent(_formatDate(t.transactionDate), () => []).add(t);
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // Header card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accountColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(_account.name.isNotEmpty ? _account.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_account.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(_account.type.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        if (_account.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Balance', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                    Text(CurrencyFormatter.format(balance),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: () => _adjustBalance(balance),
                        icon: const Icon(Icons.tune, size: 16),
                        label: const Text('Adjust Balance'),
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text('Transactions', style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Text('${txns.length} total',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),

              if (txns.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 8),
                      Text('No transactions yet', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )
              else
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(entry.key,
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline, fontWeight: FontWeight.w600)),
                  ),
                  for (final txn in entry.value)
                    ListTile(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: txn))),
                      leading: _buildLeadingIcon(theme, txn.type),
                      title: Text(txn.header,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        txn.description.isNotEmpty ? txn.description : (txn.mpesaRef ?? ''),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '${txn.type == 'income' ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: txn.type == 'income' ? theme.colorScheme.primary : theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
            ],
          );
        },
      ),
    );
  }
}
