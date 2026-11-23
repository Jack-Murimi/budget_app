import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'calculator_amount_field.dart';

/// Transaction type selector (`expense` / `income` / `transfer`).
class TransactionTypeToggle extends StatelessWidget {
  final String type;
  final Color accent;
  final ValueChanged<String> onChanged;
  final String expenseLabel;
  final String incomeLabel;
  final String transferLabel;

  const TransactionTypeToggle({
    super.key,
    required this.type,
    required this.accent,
    required this.onChanged,
    this.expenseLabel = 'Expense',
    this.incomeLabel = 'Income',
    this.transferLabel = 'Transfer',
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      showSelectedIcon: false, // keeps 3 labelled segments readable at 360dp
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: accent.withValues(alpha: 0.14),
        selectedForegroundColor: accent,
      ),
      segments: [
        ButtonSegment(
          value: 'expense',
          label: Text(expenseLabel),
          icon: const Icon(Icons.arrow_upward_rounded),
        ),
        ButtonSegment(
          value: 'income',
          label: Text(incomeLabel),
          icon: const Icon(Icons.arrow_downward_rounded),
        ),
        ButtonSegment(
          value: 'transfer',
          label: Text(transferLabel),
          icon: const Icon(Icons.swap_horiz),
        ),
      ],
      selected: {type},
      onSelectionChanged: (s) {
        HapticFeedback.selectionClick();
        onChanged(s.first);
      },
    );
  }
}

/// Tinted hero card for the primary amount input and optional fee field.
class TransactionAmountHero extends StatelessWidget {
  final String type;
  final Color accent;
  final TextEditingController amountCtrl;
  final TextEditingController costCtrl;
  final bool showFee;
  final VoidCallback onShowFee;
  final String? Function(String?) validateAmount;
  final String? Function(String?) validateCost;
  final double? Function(String?) parseMoney;
  final InputDecoration Function(String label, IconData? icon, {String? helper})
      decorationBuilder;
  final String amountLabel;
  final String addFeeLabel;
  final String feeLabel;
  final String feeHelper;
  final String Function(String formattedTotal) amountPlusFeeBuilder;

  const TransactionAmountHero({
    super.key,
    required this.type,
    required this.accent,
    required this.amountCtrl,
    required this.costCtrl,
    required this.showFee,
    required this.onShowFee,
    required this.validateAmount,
    required this.validateCost,
    required this.parseMoney,
    required this.decorationBuilder,
    this.amountLabel = 'Amount',
    this.addFeeLabel = 'Add transaction fee',
    this.feeLabel = 'Transaction fee (KES)',
    this.feeHelper = 'M-Pesa or bank charge',
    this.amountPlusFeeBuilder = _defaultAmountPlusFee,
  });

  static String _defaultAmountPlusFee(String total) => 'Amount + fee: $total';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.headlineMedium
        ?.copyWith(fontWeight: FontWeight.w700, color: accent);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.copyWith(bodyLarge: amountStyle),
            ),
            child: CalculatorAmountField(
              controller: amountCtrl,
              decoration: InputDecoration(
                labelText: amountLabel,
                hintText: '0.00',
                prefixText: 'KES ',
                prefixStyle: amountStyle,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              validator: validateAmount,
            ),
          ),
          if (type != 'income') _buildFee(theme),
        ],
      ),
    );
  }

  Widget _buildFee(ThemeData theme) {
    if (!showFee) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onShowFee,
          icon: const Icon(Icons.add, size: 18),
          label: Text(addFeeLabel),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        TextFormField(
          controller: costCtrl,
          decoration: decorationBuilder(feeLabel, null, helper: feeHelper)
              .copyWith(filled: true, fillColor: theme.colorScheme.surface),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: validateCost,
        ),
        ListenableBuilder(
          listenable: Listenable.merge([amountCtrl, costCtrl]),
          builder: (context, _) {
            final amount = parseMoney(amountCtrl.text) ?? 0;
            final fee = parseMoney(costCtrl.text) ?? 0;
            if (amount <= 0 || fee <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                amountPlusFeeBuilder(CurrencyFormatter.format(amount + fee)),
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.end,
              ),
            );
          },
        ),
      ],
    );
  }
}
