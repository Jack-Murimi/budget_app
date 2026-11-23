import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/account_model.dart';
import '../providers/account_providers.dart';

class AccountDetailScreen extends ConsumerWidget {
  final AccountWithBalance account;

  const AccountDetailScreen({super.key, required this.account});

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

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(dt.year, dt.month, dt.day);
    if (txDate == today) return l10n.today;
    if (txDate == today.subtract(const Duration(days: 1))) {
      return l10n.yesterday;
    }
    return DateFormat('EEE, d MMM yyyy').format(dt);
  }

  Widget _buildLeadingIcon(ThemeData theme, String type) {
    final (IconData icon, Color bg, Color fg) = switch (type) {
      'income' => (
          Icons.arrow_downward_rounded,
          theme.colorScheme.primaryContainer,
          theme.colorScheme.primary
        ),
      'transfer' => (
          Icons.swap_horiz_rounded,
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.tertiary
        ),
      _ => (
          Icons.arrow_upward_rounded,
          theme.colorScheme.errorContainer,
          theme.colorScheme.error
        ),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    AccountWithBalance currentAccount,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => _EditAccountDialog(
        account: currentAccount,
        colorOptions: _colorOptions,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AccountWithBalance currentAccount,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountConfirm(currentAccount.name)),
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
      try {
        await ref.read(accountRepositoryProvider).deleteAccount(currentAccount.id);
        if (!context.mounted) return;
        Navigator.of(context).pop();
      } on StateError catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _adjustBalance(
    BuildContext context,
    AccountWithBalance currentAccount,
    double currentBalance,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => _AdjustBalanceDialog(
        accountId: currentAccount.id,
        currentBalance: currentBalance,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final allAccounts =
        ref.watch(allAccountsWithBalanceProvider).asData?.value ?? const [];
    final currentAccount =
        allAccounts.where((a) => a.id == account.id).firstOrNull ?? account;
    final txnsAsync = ref.watch(accountTransactionsProvider(currentAccount.id));
    final accountColor = parseHexColor(
      currentAccount.colorHex,
      fallback: theme.colorScheme.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentAccount.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'edit':
                  await _showEditDialog(context, currentAccount);
                case 'default':
                  await ref
                      .read(accountRepositoryProvider)
                      .setDefault(currentAccount.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.accountSetAsDefault(currentAccount.name),
                      ),
                    ),
                  );
                case 'archive':
                  final nextArchived = !currentAccount.isArchived;
                  await ref
                      .read(accountRepositoryProvider)
                      .archiveAccount(currentAccount.id, archive: nextArchived);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        nextArchived
                            ? l10n.accountArchived(currentAccount.name)
                            : l10n.accountUnarchived(currentAccount.name),
                      ),
                    ),
                  );
                  if (nextArchived) {
                    Navigator.pop(context);
                  }
                case 'delete':
                  await _confirmDelete(context, ref, currentAccount);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.edit),
                  dense: true,
                ),
              ),
              if (!currentAccount.isDefault)
                PopupMenuItem(
                  value: 'default',
                  child: ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: Text(l10n.setAsDefault),
                    dense: true,
                  ),
                ),
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(
                    currentAccount.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                  ),
                  title: Text(
                    currentAccount.isArchived ? l10n.unarchive : l10n.archive,
                  ),
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    l10n.delete,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorLabel('$e'))),
        data: (rawTxns) {
          final balance = currentAccount.balance;
          final txns = rawTxns.map((t) => t.toModel()).toList();

          final Map<String, List<TransactionModel>> grouped = {};
          for (final t in txns) {
            grouped.putIfAbsent(_formatDate(t.transactionDate, l10n), () => []).add(t);
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
                          child: Text(
                            currentAccount.name.isNotEmpty
                                ? currentAccount.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentAccount.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              currentAccount.type.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (currentAccount.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.defaultLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.balanceLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            _adjustBalance(context, currentAccount, balance),
                        icon: const Icon(Icons.tune, size: 16),
                        label: Text(l10n.adjustBalance),
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
                    Text(l10n.transactionsTitle, style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      l10n.totalCount(txns.length),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),

              if (txns.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noTransactionsYet,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      entry.key,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final txn in entry.value)
                    Builder(
                      builder: (context) {
                        final isIncoming = txn.type == 'income' ||
                            (txn.type == 'transfer' &&
                                txn.toAccountId == currentAccount.id);
                        return ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(transactionToEdit: txn),
                            ),
                          ),
                          leading: _buildLeadingIcon(theme, txn.type),
                          title: Text(
                            txn.header,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            txn.description.isNotEmpty
                                ? txn.description
                                : (txn.mpesaRef ?? ''),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            '${isIncoming ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isIncoming
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                          ),
                        );
                      },
                    ),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _EditAccountDialog extends ConsumerStatefulWidget {
  final AccountWithBalance account;
  final Map<String, String> colorOptions;

  const _EditAccountDialog({
    required this.account,
    required this.colorOptions,
  });

  @override
  ConsumerState<_EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends ConsumerState<_EditAccountDialog> {
  static const _validTypes = ['mpesa', 'cash', 'bank', 'airtel', 'other'];

  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.account.name);
  late String _selectedType =
      _validTypes.contains(widget.account.type.toLowerCase())
          ? widget.account.type.toLowerCase()
          : 'other';
  late String _selectedColor =
      widget.colorOptions.containsKey(widget.account.colorHex)
          ? widget.account.colorHex
          : widget.colorOptions.keys.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editAccount),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.name,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.type,
                border: const OutlineInputBorder(),
              ),
              initialValue: _selectedType,
              items: _validTypes
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
              decoration: InputDecoration(
                labelText: l10n.colorLabel,
                border: const OutlineInputBorder(),
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
                              color: parseHexColor(e.key),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    await ref.read(accountRepositoryProvider).updateAccount(
          AccountsCompanion(
            id: Value(widget.account.id),
            name: Value(_nameCtrl.text.trim()),
            type: Value(_selectedType),
            colorHex: Value(_selectedColor),
          ),
        );
    if (mounted) Navigator.pop(context, true);
  }
}

class _AdjustBalanceDialog extends ConsumerStatefulWidget {
  final int accountId;
  final double currentBalance;

  const _AdjustBalanceDialog({
    required this.accountId,
    required this.currentBalance,
  });

  @override
  ConsumerState<_AdjustBalanceDialog> createState() =>
      _AdjustBalanceDialogState();
}

class _AdjustBalanceDialogState extends ConsumerState<_AdjustBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.currentBalance.toStringAsFixed(2),
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.adjustBalance),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.newBalance,
            border: const OutlineInputBorder(),
          ),
          validator: (v) {
            final parsed =
                double.tryParse((v ?? '').replaceAll(',', '').trim());
            if (parsed == null || !parsed.isFinite) {
              return l10n.errorValidNumberShort;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.update),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final newBal = double.parse(_ctrl.text.replaceAll(',', '').trim());
    setState(() => _isSaving = true);
    await ref.read(accountRepositoryProvider).correctBalance(
          accountId: widget.accountId,
          currentBalance: widget.currentBalance,
          targetBalance: newBal,
        );
    if (mounted) Navigator.pop(context, true);
  }
}
