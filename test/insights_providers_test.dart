import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/providers/account_providers.dart';
import 'package:budget_app/features/insights/providers/insights_providers.dart';
import 'package:budget_app/features/insights/screens/insights_screen.dart';
import 'package:budget_app/features/transactions/models/transaction_model.dart';
import 'package:budget_app/features/transactions/providers/transaction_providers.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  TransactionModel item(
    String type,
    double amount,
    DateTime date, {
    double cost = 0,
    double fulizaFee = 0,
  }) =>
      TransactionModel(
        id: amount.toInt(),
        header: type,
        amount: amount,
        transactionCost: cost,
        fulizaFee: fulizaFee,
        type: type,
        transactionDate: date,
        createdAt: date,
      );

  test('summarizes current and previous period cashflow including fees', () {
    final summary = buildInsightsSummary([
      item('income', 1000, DateTime(2026, 11, 4)),
      item('expense', 250, DateTime(2026, 11, 4), cost: 13, fulizaFee: 2),
      item('expense', 100, DateTime(2026, 10, 28), cost: 5),
      item('transfer', 500, DateTime(2026, 11, 5)),
    ], DateRange(DateTime(2026, 11), DateTime(2026, 12)));

    expect(summary.income, 1000);
    expect(summary.expenses, 265);
    expect(summary.previousExpenses, 105);
    expect(summary.net, 735);
  });

  test('uses calendar month boundary for previous period comparison', () {
    final summary = buildInsightsSummary([
      item('expense', 300, DateTime(2026, 3, 10)),
      item('expense', 200, DateTime(2026, 2, 14)),
      // Jan 30 must NOT be included when comparing March against February
      item('expense', 999, DateTime(2026, 1, 30)),
    ], DateRange(DateTime(2026, 3, 1), DateTime(2026, 4, 1)));

    expect(summary.expenses, 300);
    expect(summary.previousExpenses, 200);
    expect(summary.expenseDelta, closeTo(0.5, 1e-9));
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

  test('netWorthTrendProvider includes archived account opening balances', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final archivedAccId = await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            name: 'Old Bank',
            initialBalance: const Value(500.0),
            isArchived: const Value(true),
          ),
        );
    final now = DateTime.now();
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Deposit',
            amount: 200.0,
            type: const Value('income'),
            accountId: Value(archivedAccId),
            transactionDate: DateTime(now.year, now.month, now.day),
          ),
        );

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    // Wait for streams to emit
    final sub = container.listen(netWorthTrendProvider, (_, __) {});
    addTearDown(sub.close);
    await container.read(allAccountsWithBalanceProvider.future);
    await container.read(allTransactionsProvider.future);

    final trend = container.read(netWorthTrendProvider).value!;
    final today = DateTime(now.year, now.month, now.day);
    expect(trend[today], 700.0);
  });

  testWidgets('InsightsScreen displays 50% delta and opens Custom picker without crashing',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final now = DateTime.now();
    final thisMonthDay = DateTime(now.year, now.month, 1);
    final lastMonthDay = DateTime(now.year, now.month - 1, 10);

    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Prev expense',
            amount: 100.0,
            type: const Value('expense'),
            transactionDate: lastMonthDay,
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Curr expense',
            amount: 150.0,
            type: const Value('expense'),
            transactionDate: thisMonthDay,
          ),
        );

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: InsightsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Up 50% from previous period'), findsOneWidget);

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
  });
}
