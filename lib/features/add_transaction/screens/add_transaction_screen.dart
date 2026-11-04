import 'package:flutter/material.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../widgets/transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  final MpesaParseResult? parseResult;

  const AddTransactionScreen({super.key, this.parseResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parseResult != null ? 'Complete Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransactionForm(parseResult: parseResult),
      ),
    );
  }
}
