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

  test('builds net worth trend from account transactions', () {
    final date = DateTime(2026, 11, 1);
    final trend = buildNetWorthTrend([
      TransactionModel(
          id: 1,
          header: 'Pay',
          amount: 200,
          type: 'income',
          accountId: 1,
          transactionDate: date,
          createdAt: date),
      TransactionModel(
          id: 2,
          header: 'Food',
          amount: 50,
          type: 'expense',
          accountId: 1,
          transactionDate: date.add(const Duration(days: 1)),
          createdAt: date),
    ], DateRange(date, date.add(const Duration(days: 3))), 100);

    expect(trend[date], 300);
    expect(trend[date.add(const Duration(days: 1))], 250);
    expect(trend[date.add(const Duration(days: 2))], 250);
  });
}
