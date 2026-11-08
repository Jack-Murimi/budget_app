import 'dart:ffi';
import 'dart:io';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/repositories/debt_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
        OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  }

  late AppDatabase db;
  late DebtRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = DebtRepository(db);
  });

  tearDown(() => db.close());

  test(
      'records repayment, updates outstanding balance, and creates ledger transaction',
      () async {
    final accountId = await db
        .into(db.accounts)
        .insert(AccountsCompanion.insert(name: 'M-Pesa'));
    final debtId = await repo.create(
      direction: 'borrowed',
      counterparty: 'M-Shwari',
      principal: 1000,
      interest: 50,
      product: 'mshwari',
      accountId: accountId,
    );
    final debt = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();

    await repo.repay(
        debt: debt,
        amount: 400,
        accountId: accountId,
        paymentDate: DateTime(2026, 11, 7));

    final updated = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();
    final repayments = await (db.select(db.debtRepayments)
          ..where((row) => row.debtId.equals(debtId)))
        .get();
    final transactions = await db.select(db.transactions).get();
    expect(updated.outstanding, 650);
    expect(repayments.single.amount, 400);
    expect(repayments.single.transactionId, isNotNull);
    expect(transactions.map((row) => row.type),
        containsAll(['income', 'expense']));
  });

  test('rejects repayments above outstanding balance', () async {
    final debtId = await repo.create(
        direction: 'lent',
        counterparty: 'Amina',
        principal: 500,
        interest: 0,
        product: 'personal');
    final debt = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();
    expect(() => repo.repay(debt: debt, amount: 501), throwsArgumentError);
  });
}
