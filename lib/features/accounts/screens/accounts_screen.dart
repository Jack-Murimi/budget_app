import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../providers/account_providers.dart';
import '../models/account_model.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  static const _typeOptions = ['mpesa', 'cash', 'bank', 'airtel', 'other'];
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

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    String selectedType = 'mpesa';
    String selectedColor = '#4CAF50';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  value: selectedType,
                  items: _typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
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
                const SizedBox(height: 12),
                TextField(
                  controller: balanceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Opening Balance', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await ref.read(accountRepositoryProvider).insertAccount(
                  AccountsCompanion.insert(
                    name: nameCtrl.text.trim(),
                    type: Value(selectedType),
                    initialBalance: Value(double.tryParse(balanceCtrl.text) ?? 0.0),
                    colorHex: Value(selectedColor),
                  ),
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTransferDialog() async {
    final amountCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final accounts = await ref.read(accountRepositoryProvider).getAll();
    if (!mounted) return;
    final opts = accounts.where((a) => !a.isArchived).toList();
    int? fromId = opts.isNotEmpty ? opts.first.id : null;
    int? toId = opts.length > 1 ? opts[1].id : null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Transfer Between Accounts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'From Account', border: OutlineInputBorder()),
                  value: fromId,
                  items: opts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v) => setS(() => fromId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'To Account', border: OutlineInputBorder()),
                  value: toId,
                  items: opts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v) => setS(() => toId = v),
                ),
                const SizedBox(height: 12),
                TextField(controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount (KES)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: feeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Fee (KES)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                if (fromId != null && toId != null && amount != null) {
                  await ref.read(accountRepositoryProvider).createTransfer(
                    fromAccountId: fromId!,
                    toAccountId: toId!,
                    amount: amount,
                    transactionCost: double.tryParse(feeCtrl.text) ?? 0.0,
                    note: noteCtrl.text.trim(),
                  );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Transfer'),
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
          IconButton(icon: const Icon(Icons.swap_horiz), onPressed: _showTransferDialog, tooltip: 'Transfer'),
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog, tooltip: 'Add Account'),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading accounts')),
        data: (accounts) {
          final active = accounts.where((a) => !a.isArchived).toList();
          final archived = accounts.where((a) => a.isArchived).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Net worth card
              netWorthAsync.when(
                data: (total) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Balance', style: theme.textTheme.bodyMedium),
                        Text(CurrencyFormatter.format(total),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              if (active.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No accounts yet. Tap + to add one.'),
                ))
              else
                ...active.map((a) => _AccountCard(account: a)),

              if (archived.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Archived', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                ),
                ...archived.map((a) => _AccountCard(account: a, dimmed: true)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  final AccountWithBalance account;
  final bool dimmed;

  const _AccountCard({required this.account, this.dimmed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = Color(int.parse(account.colorHex.replaceFirst('#', '0xFF')));

    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AccountDetailScreen(account: account)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(account.name,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if (account.isDefault) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Default',
                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(account.type.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.format(account.balance),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
