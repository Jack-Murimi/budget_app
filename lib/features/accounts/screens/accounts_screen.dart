import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../models/account_model.dart';
import '../providers/account_providers.dart';
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
    await showDialog<bool>(
      context: context,
      builder: (_) => const _AddAccountDialog(
        typeOptions: _typeOptions,
        colorOptions: _colorOptions,
      ),
    );
  }

  Future<void> _showTransferDialog() async {
    final accounts = await ref.read(accountRepositoryProvider).getAll();
    if (!mounted) return;
    final opts = accounts.where((a) => !a.isArchived).toList();
    if (opts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least 2 active accounts to transfer'),
        ),
      );
      return;
    }

    final transferred = await showDialog<bool>(
      context: context,
      builder: (_) => _TransferAccountDialog(accounts: opts),
    );
    if (transferred == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer recorded')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netWorthAsync = ref.watch(totalNetWorthProvider);
    final accountsAsync = ref.watch(allAccountsWithBalanceProvider);

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
            onPressed: _showAddDialog,
            tooltip: 'Add Account',
          ),
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
                        Text(
                          CurrencyFormatter.format(total),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              if (active.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No accounts yet. Tap + to add one.'),
                  ),
                )
              else
                ...active.map((a) => _AccountCard(account: a)),

              if (archived.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Archived',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
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

class _AddAccountDialog extends ConsumerStatefulWidget {
  final List<String> typeOptions;
  final Map<String, String> colorOptions;

  const _AddAccountDialog({
    required this.typeOptions,
    required this.colorOptions,
  });

  @override
  ConsumerState<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<_AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  String _selectedType = 'mpesa';
  String _selectedColor = '#4CAF50';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Account'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter account name'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedType,
                items: widget.typeOptions
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedColor,
                items: widget.colorOptions.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(e.key.replaceFirst('#', '0xFF')),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(e.value),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedColor = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _balanceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Opening Balance',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await ref.read(accountRepositoryProvider).insertAccount(
          AccountsCompanion.insert(
            name: _nameCtrl.text.trim(),
            type: Value(_selectedType),
            initialBalance: Value(
              double.tryParse(_balanceCtrl.text.replaceAll(',', '').trim()) ??
                  0.0,
            ),
            colorHex: Value(_selectedColor),
          ),
        );
    if (mounted) Navigator.pop(context, true);
  }
}

class _TransferAccountDialog extends ConsumerStatefulWidget {
  final List<Account> accounts;

  const _TransferAccountDialog({required this.accounts});

  @override
  ConsumerState<_TransferAccountDialog> createState() =>
      _TransferAccountDialogState();
}

class _TransferAccountDialogState
    extends ConsumerState<_TransferAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late int _fromId = widget.accounts.first.id;
  late int _toId = widget.accounts.length > 1
      ? widget.accounts[1].id
      : widget.accounts.first.id;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _feeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transfer Between Accounts'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'From Account',
                  border: OutlineInputBorder(),
                ),
                initialValue: _fromId,
                items: widget.accounts
                    .map(
                      (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _fromId = v);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'To Account',
                  border: OutlineInputBorder(),
                ),
                initialValue: _toId,
                items: widget.accounts
                    .map(
                      (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                    )
                    .toList(),
                validator: (v) {
                  if (v == null) return 'Select destination account';
                  if (v == _fromId) return 'Accounts must be different';
                  return null;
                },
                onChanged: (v) {
                  if (v != null) setState(() => _toId = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (KES)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Fee (KES)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final parsed = double.tryParse(v.replaceAll(',', '').trim());
                  if (parsed == null || parsed < 0) {
                    return 'Fee cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: const Text('Transfer'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.parse(_amountCtrl.text.replaceAll(',', '').trim());
    final feeText = _feeCtrl.text.replaceAll(',', '').trim();
    final fee = feeText.isEmpty ? 0.0 : double.parse(feeText);

    setState(() => _isSaving = true);
    await ref.read(accountRepositoryProvider).createTransfer(
          fromAccountId: _fromId,
          toAccountId: _toId,
          amount: amount,
          transactionCost: fee,
          note: _noteCtrl.text.trim(),
        );
    if (mounted) Navigator.pop(context, true);
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
            MaterialPageRoute(
              builder: (_) => AccountDetailScreen(account: account),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      account.name.isNotEmpty
                          ? account.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            account.name,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (account.isDefault) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Default',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                          if (account.isArchived) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Archived',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.type.toUpperCase(),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                if (account.isArchived)
                  IconButton(
                    icon: const Icon(Icons.unarchive_outlined),
                    tooltip: 'Unarchive',
                    onPressed: () => ref
                        .read(accountRepositoryProvider)
                        .archiveAccount(account.id, archive: false),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(account.balance),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
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
