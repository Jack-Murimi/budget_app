import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../../accounts/widgets/account_brand_badge.dart';

/// Single source of truth for which accounts are selected:
/// - nothing picked yet -> [defaultId]
/// - picked account no longer exists -> `null` (force re-pick, never save stale id)
/// - [to] only counts for transfers and cannot equal [from].
({int? from, int? to}) resolveSelectedAccounts({
  required String type,
  required int? selectedAccountId,
  required int? selectedToAccountId,
  required List<int> availableIds,
  required int? defaultId,
}) {
  final from = selectedAccountId == null
      ? defaultId
      : (availableIds.contains(selectedAccountId) ? selectedAccountId : null);
  final to = (type == 'transfer' &&
          selectedToAccountId != from &&
          availableIds.contains(selectedToAccountId))
      ? selectedToAccountId
      : null;
  return (from: from, to: to);
}

/// Account / Wallet selector (or From / To pair for transfers).
class TransactionAccountSection extends ConsumerWidget {
  final String type;
  final int? selectedAccountId;
  final int? selectedToAccountId;
  final ValueChanged<int?> onFromChanged;
  final ValueChanged<int?> onToChanged;
  final InputDecoration Function(String label, IconData? icon)
      decorationBuilder;

  const TransactionAccountSection({
    super.key,
    required this.type,
    required this.selectedAccountId,
    required this.selectedToAccountId,
    required this.onFromChanged,
    required this.onToChanged,
    required this.decorationBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final async = ref.watch(accountsWithBalanceProvider);
    final accounts = async.value;

    if (accounts == null) {
      return async.hasError
          ? Text(
              l10n.couldNotLoadAccounts,
              style: TextStyle(color: theme.colorScheme.error),
            )
          : const SizedBox(
              height: 56,
              child: Center(child: LinearProgressIndicator()),
            );
    }
    if (accounts.isEmpty) {
      return Text(
        l10n.noAccountsAvailable,
        style: TextStyle(color: theme.colorScheme.error),
      );
    }

    final defaultId =
        (accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull)
            ?.id;
    final res = resolveSelectedAccounts(
      type: type,
      selectedAccountId: selectedAccountId,
      selectedToAccountId: selectedToAccountId,
      availableIds: [for (final a in accounts) a.id],
      defaultId: defaultId,
    );

    if (accounts.length == 1 &&
        type != 'transfer' &&
        res.from == accounts.first.id) {
      return InputDecorator(
        decoration: decorationBuilder(
          l10n.account,
          Icons.account_balance_wallet_outlined,
        ),
        child: Row(
          children: [
            AccountBrandBadge.fromAccount(accounts.first, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(accounts.first.name, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    List<DropdownMenuItem<int>> items({int? except}) => [
          for (final a in accounts)
            if (a.id != except)
              DropdownMenuItem<int>(
                value: a.id,
                child: Row(
                  children: [
                    AccountBrandBadge.fromAccount(a, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${a.name} (${CurrencyFormatter.format(a.balance)})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
        ];

    if (type != 'transfer') {
      return DropdownButtonFormField<int>(
        key: ValueKey('acct_${res.from}'),
        isExpanded: true,
        decoration: decorationBuilder(
          l10n.accountWalletRequired,
          Icons.account_balance_wallet_outlined,
        ),
        initialValue: res.from,
        hint: Text(l10n.selectAccount),
        items: items(),
        onChanged: onFromChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          key: ValueKey('from_acct_${res.from}'),
          isExpanded: true,
          decoration:
              decorationBuilder(l10n.fromAccountRequired, Icons.arrow_left),
          initialValue: res.from,
          hint: Text(l10n.selectSourceAccount),
          items: items(),
          onChanged: onFromChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey('to_acct_${res.from}_${res.to}'),
          isExpanded: true,
          decoration:
              decorationBuilder(l10n.toAccountRequired, Icons.arrow_right),
          initialValue: res.to,
          hint: Text(l10n.selectDestAccount),
          items: items(except: res.from),
          onChanged: onToChanged,
        ),
      ],
    );
  }
}
