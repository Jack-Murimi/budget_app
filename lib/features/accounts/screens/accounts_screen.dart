import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../providers/account_providers.dart';
import '../models/account_model.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  final _newBalanceCtrl = TextEditingController();

  @override
  void dispose() {
    _newBalanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAdjustBalanceDialog(AccountWithBalance account) async {
    _newBalanceCtrl.text = account.balance.toStringAsFixed(2);

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newBalanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'New Balance',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newBal = double.tryParse(_newBalanceCtrl.text.replaceAll('KES ', '').replaceAll(',', ''));
              if (newBal != null) {
                await ref.read(accountRepositoryProvider).correctBalance(
                  accountId: account.id,
                  currentBalance: account.balance,
                  targetBalance: newBal,
                );
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTransferDialog() async {
    final amountCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final accounts = await ref.read(accountRepositoryProvider).getAll();
    if (!mounted) return;
    final accountOptions = accounts.where((a) => !a.isArchived).toList();

    int? fromId = accountOptions.isNotEmpty ? accountOptions.first.id : null;
    int? toId = accountOptions.length > 1 ? accountOptions[1].id : null;

    return showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Transfer Between Accounts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'From Account', border: OutlineInputBorder()),
                  initialValue: fromId,
                  items: accountOptions.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v) => setDialogState(() => fromId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'To Account', border: OutlineInputBorder()),
                  initialValue: toId,
                  items: accountOptions.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v) => setDialogState(() => toId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (KES)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Transaction Fee (KES)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                final fee = double.tryParse(feeCtrl.text) ?? 0.0;
                final note = noteCtrl.text.trim();

                if (fromId != null && toId != null && amount != null) {
                  await ref.read(accountRepositoryProvider).createTransfer(
                    fromAccountId: fromId!,
                    toAccountId: toId!,
                    amount: amount,
                    transactionCost: fee,
                    note: note,
                  );
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddAccountDialog() async {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    final colorCtrl = TextEditingController(text: '#4CAF50');
    String selectedType = 'mpesa';

    return showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Account'),
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
                  initialValue: selectedType,
                  items: const ['mpesa', 'cash', 'bank', 'airtel', 'other']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedType = v);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: balanceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Initial Balance', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: colorCtrl,
                  decoration: const InputDecoration(labelText: 'Color (hex)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await ref.read(accountRepositoryProvider).insertAccount(
                  AccountsCompanion.insert(
                    name: nameCtrl.text.trim(),
                    type: Value(selectedType),
                    initialBalance: Value(double.tryParse(balanceCtrl.text) ?? 0.0),
                    colorHex: Value(colorCtrl.text.trim()),
                  ),
                );
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netWorthAsync = ref.watch(totalNetWorthProvider);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts & Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _showTransferDialog,
            tooltip: 'Transfer',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAccountDialog,
            tooltip: 'Add Account',
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) => accounts.isEmpty
            ? const Center(child: Text('No accounts'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  netWorthAsync.when(
                    data: (total) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Balance'),
                            Text(CurrencyFormatter.format(total)),
                          ],
                        ),
                      ),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  ...accounts.map((a) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(int.parse(a.colorHex.replaceFirst('#', '0xFF'))),
                        child: Text(a.name[0], style: const TextStyle(color: Colors.white)),
                      ),
                      title: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(a.name),
                          if (a.isDefault)
                            Chip(
                              label: const Text('Default'),
                              backgroundColor: theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(a.type.toUpperCase()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(CurrencyFormatter.format(a.balance)),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'adjust') {
                                await _showAdjustBalanceDialog(a);
                              } else if (value == 'archive') {
                                await ref.read(accountRepositoryProvider).archiveAccount(a.id, archive: true);
                              } else if (value == 'unarchive') {
                                await ref.read(accountRepositoryProvider).archiveAccount(a.id, archive: false);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'adjust', child: Text('Adjust Balance')),
                              if (a.isArchived)
                                const PopupMenuItem(value: 'unarchive', child: Text('Unarchive'))
                              else
                                const PopupMenuItem(value: 'archive', child: Text('Archive')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading accounts')),
      ),
    );
  }
}
