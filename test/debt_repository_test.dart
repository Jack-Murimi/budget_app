import 'dart:ffi';
import 'dart:io';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/repositories/debt_repository.dart';
import 'package:drift/drift.dart' show Value;
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

  test('watchLent returns only open lent debts', () async {
    final lentOpenId = await repo.create(
      direction: 'lent',
      counterparty: 'Bob',
      principal: 200,
      interest: 0,
      product: 'personal',
    );
    final lentSettledId = await repo.create(
      direction: 'lent',
      counterparty: 'Charlie',
      principal: 100,
      interest: 0,
      product: 'personal',
    );
    final settledDebt = await (db.select(db.debts)
          ..where((row) => row.id.equals(lentSettledId)))
        .getSingle();
    await repo.repay(debt: settledDebt, amount: 100);

    await repo.create(
      direction: 'borrowed',
      counterparty: 'Bank',
      principal: 500,
      interest: 0,
      product: 'personal',
    );

    final lentDebts = await repo.watchLent().first;
    expect(lentDebts.length, 1);
    expect(lentDebts.single.debt.id, lentOpenId);
    expect(lentDebts.single.debt.counterparty, 'Bob');
  });

  test('repay with transactionId links existing transaction without creating duplicate', () async {
    final accountId = await db
        .into(db.accounts)
        .insert(AccountsCompanion.insert(name: 'Cash'));
    final debtId = await repo.create(
      direction: 'lent',
      counterparty: 'David',
      principal: 500,
      interest: 0,
      product: 'personal',
    );
    final debt = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();

    final customTxId = await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Repayment from David',
            amount: 200,
            type: const Value('income'),
            accountId: Value(accountId),
            transactionDate: DateTime(2026, 11, 8),
          ),
        );

    final txCountBefore = (await db.select(db.transactions).get()).length;

    await repo.repay(
      debt: debt,
      amount: 200,
      accountId: accountId,
      paymentDate: DateTime(2026, 11, 8),
      transactionId: customTxId,
    );

    final txCountAfter = (await db.select(db.transactions).get()).length;
    expect(txCountAfter, txCountBefore, reason: 'Must not create duplicate transaction');

    final repayments = await (db.select(db.debtRepayments)
          ..where((row) => row.debtId.equals(debtId)))
        .get();
    expect(repayments.single.transactionId, customTxId);
    expect(repayments.single.accountId, accountId);
    expect(repayments.single.amount, 200);

    final updated = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();
    expect(updated.outstanding, 300);
  });

  test('recordLoanReceived records debt with shortfall and transaction with actual amount', () async {
    final accountId = await db
        .into(db.accounts)
        .insert(AccountsCompanion.insert(name: 'M-Pesa'));

    final tx = TransactionsCompanion.insert(
      header: 'Bridge loan received',
      amount: 600,
      type: const Value('income'),
      accountId: Value(accountId),
      transactionDate: DateTime(2026, 11, 11),
    );

    final txId = await repo.recordLoanReceived(
      transaction: tx,
      counterparty: 'Bridge',
      actualReceived: 570,
      product: 'bridge',
    );
    expect(txId, isNotNull);

    // Verify transaction amount is 570 (actual credited into account)
    final savedTx = await (db.select(db.transactions)
          ..where((row) => row.id.equals(txId!)))
        .getSingle();
    expect(savedTx.amount, 570);
    expect(savedTx.debtId, isNotNull);

    // Verify debt has principal 600, shortfall 30, outstanding 600
    final savedDebt = await (db.select(db.debts)
          ..where((row) => row.id.equals(savedTx.debtId!)))
        .getSingle();
    expect(savedDebt.direction, 'borrowed');
    expect(savedDebt.counterparty, 'Bridge');
    expect(savedDebt.principal, 600);
    expect(savedDebt.outstanding, 600);
    expect(savedDebt.disbursementShortfall, 30);
    expect(savedDebt.interest, 0);
  });

  test('repay borrowed loan with extra amount records extra as interest and settles debt', () async {
    final accountId = await db
        .into(db.accounts)
        .insert(AccountsCompanion.insert(name: 'M-Pesa'));

    final debtId = await repo.create(
      direction: 'borrowed',
      counterparty: 'Bridge',
      principal: 600,
      interest: 0,
      product: 'bridge',
      disbursementShortfall: 30,
      accountId: accountId,
    );

    final debt = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();

    // Repay 603.68 (600 principal + 3.68 interest)
    await repo.repay(
      debt: debt,
      amount: 603.68,
      accountId: accountId,
      paymentDate: DateTime(2026, 11, 12),
    );

    final updated = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();
    expect(updated.outstanding, 0.0);
    expect(updated.interest, closeTo(3.68, 0.001));

    // Watch bridge debts returns the settled loan with correct total charges
    final bridgeDebts = await repo.watchBridgeDebts().first;
    expect(bridgeDebts.length, 1);
    final bridgeLoan = bridgeDebts.first;
    expect(bridgeLoan.isSettled, true);
    expect(bridgeLoan.debt.disbursementShortfall, 30);
    expect(bridgeLoan.debt.interest, closeTo(3.68, 0.001));
    // Total charges = 30 + 3.68 = 33.68
    expect(bridgeLoan.debt.disbursementShortfall + bridgeLoan.debt.interest,
        closeTo(33.68, 0.001));
  });
}
