import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/models/transaction_model.dart';
import '../widgets/transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  final MpesaParseResult? parseResult;
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.parseResult, this.transactionToEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          transactionToEdit != null
              ? l10n.editTransaction
              : (parseResult != null
                  ? l10n.completeTransaction
                  : l10n.addTransaction),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransactionForm(parseResult: parseResult, transactionToEdit: transactionToEdit),
      ),
    );
  }
}
