import 'package:budget_app/features/insights/providers/insights_providers.dart';
import 'package:budget_app/features/transactions/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('summarizes current and previous period cashflow', () {
    TransactionModel item(String type, double amount, DateTime date) =>
        TransactionModel(
          id: amount.toInt(),
          header: type,
          amount: amount,
          type: type,
          transactionDate: date,
          createdAt: date,
        );
    final summary = buildInsightsSummary([
      item('income', 1000, DateTime(2026, 11, 4)),
      item('expense', 250, DateTime(2026, 11, 4)),
      item('expense', 100, DateTime(2026, 10, 28)),
      item('transfer', 500, DateTime(2026, 11, 5)),
    ], DateRange(DateTime(2026, 11), DateTime(2026, 12)));

    expect(summary.income, 1000);
    expect(summary.expenses, 250);
    expect(summary.previousExpenses, 100);
    expect(summary.net, 750);
  });
}
