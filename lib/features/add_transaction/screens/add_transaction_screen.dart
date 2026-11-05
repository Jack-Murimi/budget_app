import 'package:flutter/material.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/models/transaction_model.dart';
import '../widgets/transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  final MpesaParseResult? parseResult;
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.parseResult, this.transactionToEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transactionToEdit != null ? 'Edit Transaction' : (parseResult != null ? 'Complete Transaction' : 'Add Transaction')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransactionForm(parseResult: parseResult, transactionToEdit: transactionToEdit),
      ),
    );
  }
}
