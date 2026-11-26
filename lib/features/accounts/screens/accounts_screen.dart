import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
import '../models/account_model.dart';
import '../models/payment_provider.dart';
import '../providers/account_providers.dart';
import '../widgets/account_brand_badge.dart';
import '../widgets/add_account_dialog.dart';
import '../widgets/provider_picker_sheet.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  Future<void> _showAddDialog({PaymentProvider? initialProvider}) async {
    await showAddAccountDialog(context, initialProvider: initialProvider);
  }

  Future<void> _pickAndAddBank() async {
    final picked = await showProviderPickerSheet(
      context,
      initialGroup: PaymentProviderGroup.bank,
    );
    if (!mounted || picked == null) return;
    switch (picked) {
      case PickedProvider(:final provider):
        await _showAddDialog(initialProvider: provider);
      case PickedCustom():
        await _showAddDialog();
    }
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
            onPressed: () => _showAddDialog(),
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
          final hasBankAccount = active.any((a) => a.type == 'bank');

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

              if (!hasBankAccount) ...[
                const SizedBox(height: 6),
                FadeSlideIn(
                  index: active.length + 1,
                  child: _AddYourBankCard(
                    onPickBank: (provider) =>
                        _showAddDialog(initialProvider: provider),
                    onMoreBanks: _pickAndAddBank,
                  ),
                ),
              ],

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
                    index: active.length + i + 2,
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

class _AddYourBankCard extends StatelessWidget {
  final ValueChanged<PaymentProvider> onPickBank;
  final VoidCallback onMoreBanks;

  const _AddYourBankCard({
    required this.onPickBank,
    required this.onMoreBanks,
  });

  static const _featuredBanks = [
    PaymentProviders.equity,
    PaymentProviders.kcb,
    PaymentProviders.coop,
    PaymentProviders.ncba,
    PaymentProviders.absa,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.addYourBank,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.addYourBankSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final bank in _featuredBanks)
                  ActionChip(
                    avatar: AccountBrandBadge.fromProvider(bank, size: 22),
                    label: Text(bank.name),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onPickBank(bank);
                    },
                  ),
                ActionChip(
                  avatar: const Icon(Icons.grid_view_rounded, size: 16),
                  label: Text(l10n.moreBanks),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onMoreBanks();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    final gradientColors = accountCardGradientColors(account);
    final provider = PaymentProviders.resolve(
      icon: account.icon,
      name: account.name,
      type: account.type,
    );
    final subtitle = provider?.subtitle ?? account.type.toUpperCase();

    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Pressable(
          haptic: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountDetailScreen(account: account),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    top: -22,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: AccountBrandBadge.fromAccount(
                            account,
                            size: 46,
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
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (account.isDefault) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.22),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        l10n.defaultLabel,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (account.isArchived) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.25),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        l10n.archived,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (account.isArchived)
                          IconButton(
                            icon: const Icon(
                              Icons.unarchive_outlined,
                              color: Colors.white,
                            ),
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ],
                          ),
                      ],
                    ),
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
