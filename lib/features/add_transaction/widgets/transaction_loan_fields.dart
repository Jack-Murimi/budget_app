import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../debts/providers/debt_providers.dart';

/// Dropdown picking which outstanding lent debt is being repaid.
class BorrowerDropdownField extends ConsumerWidget {
  final int? selectedDebtId;
  final ValueChanged<int?> onChanged;

  const BorrowerDropdownField({
    super.key,
    required this.selectedDebtId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lentAsync = ref.watch(lentDebtsProvider);

    return lentAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (e, _) => Text(
        l10n.couldNotLoadBorrowers,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (lentDebts) {
        if (lentDebts.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.borrower,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.noOutstandingLoans),
          );
        }
        final validValue = lentDebts.any((d) => d.debt.id == selectedDebtId)
            ? selectedDebtId
            : null;
        return DropdownButtonFormField<int>(
          key: ValueKey('borrower_$validValue'),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.borrowerRequired,
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          initialValue: validValue,
          hint: Text(l10n.selectWhoRepaying),
          items: lentDebts
              .map(
                (d) => DropdownMenuItem<int>(
                  value: d.debt.id,
                  child: Text(
                    '${d.debt.counterparty} (${CurrencyFormatter.format(d.debt.outstanding)})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}

/// Optional field capturing net cash credited when receiving a deducted loan.
class LoanReceivedCreditedField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController principalCtrl;
  final double? Function(String?) parseMoney;

  const LoanReceivedCreditedField({
    super.key,
    required this.controller,
    required this.principalCtrl,
    required this.parseMoney,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: l10n.actualCreditedOptional,
        hintText: l10n.actualCreditedHint,
        helperText: l10n.actualCreditedHelper,
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        final credited = parseMoney(v);
        if (credited == null || !credited.isFinite || credited <= 0) {
          return l10n.errorValidPositiveAmount;
        }
        final principal = parseMoney(principalCtrl.text);
        if (principal != null && principal > 0 && credited > principal) {
          return l10n.cannotExceedBorrowed;
        }
        return null;
      },
    );
  }
}

/// Dropdown picking which outstanding borrowed loan is being repaid.
class LenderRepayDropdownField extends ConsumerWidget {
  final int? selectedDebtId;
  final ValueChanged<int?> onChanged;

  const LenderRepayDropdownField({
    super.key,
    required this.selectedDebtId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final borrowedAsync = ref.watch(borrowedDebtsProvider);

    return borrowedAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (e, _) => Text(
        l10n.couldNotLoadLenders,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (borrowedDebts) {
        if (borrowedDebts.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.lender,
              prefixIcon: const Icon(Icons.account_balance_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.noOpenBorrowedLoans),
          );
        }
        final validValue = borrowedDebts.any((d) => d.debt.id == selectedDebtId)
            ? selectedDebtId
            : null;
        return DropdownButtonFormField<int>(
          key: ValueKey('lender_$validValue'),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.lenderRepaidRequired,
            prefixIcon: const Icon(Icons.account_balance_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          initialValue: validValue,
          hint: Text(l10n.selectLoanToRepay),
          items: borrowedDebts
              .map(
                (d) => DropdownMenuItem<int>(
                  value: d.debt.id,
                  child: Text(
                    '${d.debt.counterparty} (${CurrencyFormatter.format(d.debt.outstanding)})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
