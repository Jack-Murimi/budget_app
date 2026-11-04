import 'package:flutter/material.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import 'add_transaction_screen.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';

class ParsePreviewScreen extends StatelessWidget {
  final MpesaParseResult parseResult;

  const ParsePreviewScreen({super.key, required this.parseResult});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('M-Pesa Parsed')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Auto-filled fields', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 12),
                  _Row('Ref', parseResult.mpesaRef),
                  _Row('Amount', CurrencyFormatter.format(parseResult.amount)),
                  if (parseResult.transactionCost > 0)
                    _Row('Transaction Cost', CurrencyFormatter.format(parseResult.transactionCost)),
                  _Row('Date', DateFormatter.formatDate(parseResult.transactionDate)),
                  _Row('Time', DateFormatter.formatTime(parseResult.transactionDate)),
                  _Row('Type', parseResult.type.defaultDescription),
                  if (parseResult.counterpartyName.isNotEmpty)
                    _Row('Description', parseResult.counterpartyName),
                  if (parseResult.counterpartyAccount.isNotEmpty)
                    _Row('Account', parseResult.counterpartyAccount),
                  if (parseResult.newBalance > 0)
                    _Row('New Balance', CurrencyFormatter.format(parseResult.newBalance)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You need to fill in', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.tertiary)),
                  const SizedBox(height: 8),
                  const Text('• Header (title for this transaction)'),
                  const Text('• Category'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // Navigate to full form pre-filled with parse data
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(parseResult: parseResult),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue & Add Header / Category'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
