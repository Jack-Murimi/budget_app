import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
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
    final l10n = context.l10n;
    final accounts = await ref.read(accountRepositoryProvider).getAll();
    if (!mounted) return;
    final opts = accounts.where((a) => !a.isArchived).toList();
    if (opts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.needTwoAccountsToTransfer),
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
        SnackBar(content: Text(l10n.transferRecorded)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final netWorthAsync = ref.watch(totalNetWorthProvider);
    final accountsAsync = ref.watch(allAccountsWithBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _showTransferDialog,
            tooltip: l10n.transfer,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
            tooltip: l10n.addAccount,
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorLoadingAccounts)),
        data: (accounts) {
          final active = accounts.where((a) => !a.isArchived).toList();
          final archived = accounts.where((a) => a.isArchived).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Net worth hero card
              netWorthAsync.when(
                data: (total) => FadeSlideIn(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primaryContainer,
                            Color.lerp(
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.tertiaryContainer,
                              0.45,
                            )!,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -24,
                            top: -28,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.totalBalance,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedAmount(
                                    value: total,
                                    format: CurrencyFormatter.format,
                                    style:
                                        theme.textTheme.headlineLarge?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              if (active.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l10n.noAccountsYet),
                  ),
                )
              else
                for (final (i, a) in active.indexed)
                  FadeSlideIn(
                    index: i + 1,
                    child: _AccountCard(account: a),
                  ),

              if (archived.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.archived.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                for (final (i, a) in archived.indexed)
                  FadeSlideIn(
                    index: active.length + i + 1,
                    child: _AccountCard(account: a, dimmed: true),
                  ),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.addAccount),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.nameRequired,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.enterAccountName
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.type,
                  border: const OutlineInputBorder(),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _balanceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.openingBalance,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.add),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.transferBetweenAccounts),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: l10n.fromAccount,
                  border: const OutlineInputBorder(),
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
                decoration: InputDecoration(
                  labelText: l10n.toAccount,
                  border: const OutlineInputBorder(),
                ),
                initialValue: _toId,
                items: widget.accounts
                    .map(
                      (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                    )
                    .toList(),
                validator: (v) {
                  if (v == null) return l10n.selectDestAccount;
                  if (v == _fromId) return l10n.accountsMustDiffer;
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
                decoration: InputDecoration(
                  labelText: l10n.amountKES,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return l10n.errorPositiveAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.feeKes,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final parsed = double.tryParse(v.replaceAll(',', '').trim());
                  if (parsed == null || parsed < 0) {
                    return l10n.feeCannotBeNegative;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.transfer),
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
    final l10n = context.l10n;
    final color = parseHexColor(
      account.colorHex,
      fallback: theme.colorScheme.primary,
    );

    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Pressable(
          haptic: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountDetailScreen(account: account),
            ),
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        account.name.isNotEmpty
                            ? account.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
                            Flexible(
                              child: Text(
                                account.name,
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (account.isDefault) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  l10n.defaultLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            if (account.isArchived) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  l10n.archived,
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
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (account.isArchived)
                    IconButton(
                      icon: const Icon(Icons.unarchive_outlined),
                      tooltip: l10n.unarchive,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(accountRepositoryProvider)
                            .archiveAccount(account.id, archive: false);
                      },
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(account.balance),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
