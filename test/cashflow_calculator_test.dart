import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/transactions/models/transaction_model.dart';
import 'package:budget_app/features/transactions/providers/transaction_providers.dart';
import 'package:budget_app/main.dart';
import 'package:budget_app/shared/utils/cashflow_calculator.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  TransactionModel txn({
    required String type,
    required double amount,
    double cost = 0,
    double fulizaFee = 0,
  }) {
    final now = DateTime(2026, 11, 15);
    return TransactionModel(
      id: 1,
      header: type,
      amount: amount,
      transactionCost: cost,
      fulizaFee: fulizaFee,
      type: type,
      transactionDate: now,
      createdAt: now,
    );
  }

  test('expenseTotal includes amount, transactionCost, and fulizaFee with exact cents', () {
    final t = txn(type: 'expense', amount: 100.10, cost: 12.20, fulizaFee: 1.05);
    expect(CashflowCalculator.expenseTotalCents(t), 11335);
    expect(CashflowCalculator.expenseTotal(t), 113.35);
  });

  test('summarize excludes transfers and includes expense fees', () {
    final summary = CashflowCalculator.summarize([
      txn(type: 'income', amount: 5000.00),
      txn(type: 'expense', amount: 1000.00, cost: 27.00, fulizaFee: 5.00),
      txn(type: 'transfer', amount: 2500.00, cost: 15.00),
    ]);

    expect(summary.income, 5000.00);
    expect(summary.expenses, 1032.00);
    expect(summary.net, 3968.00);
  });

  test('monthSummaryProvider excludes transfers and includes transaction/fuliza fees', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final now = DateTime.now();
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Salary',
            amount: 10000.0,
            type: const Value('income'),
            transactionDate: now,
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Groceries',
            amount: 1500.0,
            transactionCost: const Value(27.0),
            fulizaFee: const Value(10.50),
            type: const Value('expense'),
            transactionDate: now,
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Goal contribution: Emergency',
            amount: 3000.0,
            type: const Value('transfer'),
            transactionDate: now,
          ),
        );

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    final summary = await container.read(monthSummaryProvider.future);
    expect(summary.totalIncome, 10000.0);
    expect(summary.totalExpenses, 1537.50);
    expect(summary.net, 8462.50);
  });
}
