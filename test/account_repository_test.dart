import 'dart:ffi';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/repositories/account_repository.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDatabase db;
  late AccountRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AccountRepository(db);
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  group('AccountRepository', () {
    test('default accounts seeded on DB creation', () async {
      final accounts = await repo.getAll();
      expect(accounts.length, 3);
      expect(accounts.any((a) => a.name == 'M-Pesa' && a.isDefault), true);
      expect(accounts.any((a) => a.name == 'Cash'), true);
      expect(accounts.any((a) => a.name == 'Bank'), true);
    });

    test('getDefaultAccount returns M-Pesa', () async {
      final defaultAccount = await repo.getDefaultAccount();
      expect(defaultAccount, isNotNull);
      expect(defaultAccount!.name, 'M-Pesa');
      expect(defaultAccount.isDefault, true);
    });

    test('balance calculation with income, expense, and transfer', () async {
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');
      final cash = accounts.firstWhere((a) => a.name == 'Cash');

      // Add income to M-Pesa
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          type: const Value('income'),
          header: 'Salary',
          amount: 50000,
          accountId: Value(mpesa.id),
          transactionDate: DateTime.now(),
        ),
      );

      // Add expense from M-Pesa
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          type: const Value('expense'),
          header: 'Groceries',
          amount: 5000,
          transactionCost: const Value(50),
          accountId: Value(mpesa.id),
          transactionDate: DateTime.now(),
        ),
      );

      // Transfer from M-Pesa to Cash
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          type: const Value('transfer'),
          header: 'Transfer',
          amount: 10000,
          transactionCost: const Value(100),
          accountId: Value(mpesa.id),
          toAccountId: Value(cash.id),
          transactionDate: DateTime.now(),
        ),
      );

      final accountsWithBalance = await repo.watchAccountsWithBalance().first;
      final mpesaWithBalance = accountsWithBalance.firstWhere((a) => a.name == 'M-Pesa');
      final cashWithBalance = accountsWithBalance.firstWhere((a) => a.name == 'Cash');

      // M-Pesa: 0 + 50000 - (5000 + 50) - (10000 + 100) = 34850
      expect(mpesaWithBalance.balance, 34850);
      
      // Cash: 0 + 10000 = 10000
      expect(cashWithBalance.balance, 10000);
    });

    test('correctBalance creates adjustment transaction', () async {
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');

      // Add income
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          type: const Value('income'),
          header: 'Salary',
          amount: 50000,
          accountId: Value(mpesa.id),
          transactionDate: DateTime.now(),
        ),
      );

      final accountsWithBalance = await repo.watchAccountsWithBalance().first;
      final mpesaWithBalance = accountsWithBalance.firstWhere((a) => a.name == 'M-Pesa');
      expect(mpesaWithBalance.balance, 50000);

      // Correct balance to 55000
      final adjustmentId = await repo.correctBalance(
        accountId: mpesa.id,
        currentBalance: 50000,
        targetBalance: 55000,
      );
      expect(adjustmentId, isNotNull);

      final updatedAccounts = await repo.watchAccountsWithBalance().first;
      final updatedMpesa = updatedAccounts.firstWhere((a) => a.name == 'M-Pesa');
      expect(updatedMpesa.balance, 55000);

      // Correct balance down to 50000
      final adjustmentId2 = await repo.correctBalance(
        accountId: mpesa.id,
        currentBalance: 55000,
        targetBalance: 50000,
      );
      expect(adjustmentId2, isNotNull);

      final finalAccounts = await repo.watchAccountsWithBalance().first;
      final finalMpesa = finalAccounts.firstWhere((a) => a.name == 'M-Pesa');
      expect(finalMpesa.balance, 50000);
    });

    test('correctBalance returns null when difference < 0.001', () async {
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');

      final adjustmentId = await repo.correctBalance(
        accountId: mpesa.id,
        currentBalance: 50000.0,
        targetBalance: 50000.0005,
      );
      expect(adjustmentId, isNull);
    });

    test('createTransfer creates transfer transaction', () async {
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');
      final bank = accounts.firstWhere((a) => a.name == 'Bank');

      // Add initial balance to M-Pesa
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          type: const Value('income'),
          header: 'Initial',
          amount: 100000,
          accountId: Value(mpesa.id),
          transactionDate: DateTime.now(),
        ),
      );

      final transferId = await repo.createTransfer(
        fromAccountId: mpesa.id,
        toAccountId: bank.id,
        amount: 20000,
        transactionCost: 50,
        note: 'Bank deposit',
      );
      expect(transferId, isNotNull);

      final transaction = await (db.select(db.transactions)
        ..where((t) => t.id.equals(transferId)))
        .getSingle();
      expect(transaction.type, 'transfer');
      expect(transaction.amount, 20000);
      expect(transaction.transactionCost, 50);
      expect(transaction.accountId, mpesa.id);
      expect(transaction.toAccountId, bank.id);

      final accountsWithBalance = await repo.watchAccountsWithBalance().first;
      final mpesaWithBalance = accountsWithBalance.firstWhere((a) => a.name == 'M-Pesa');
      final bankWithBalance = accountsWithBalance.firstWhere((a) => a.name == 'Bank');

      // M-Pesa: 100000 - (20000 + 50) = 79950
      expect(mpesaWithBalance.balance, 79950);
      // Bank: 0 + 20000 = 20000
      expect(bankWithBalance.balance, 20000);
    });

    test('archiveAccount sets isArchived flag', () async {
      final accounts = await repo.getAll();
      final cash = accounts.firstWhere((a) => a.name == 'Cash');

      await repo.archiveAccount(cash.id);

      final allAccounts = await repo.getAll(includeArchived: true);
      final archivedCash = allAccounts.firstWhere((a) => a.name == 'Cash');
      expect(archivedCash.isArchived, true);

      final activeAccounts = await repo.getAll();
      expect(activeAccounts.any((a) => a.name == 'Cash'), false);
    });

    test('watchAccountsWithBalance sorts default first then by name', () async {
      final accountsWithBalance = await repo.watchAccountsWithBalance().first;
      
      expect(accountsWithBalance.first.name, 'M-Pesa');
      expect(accountsWithBalance.first.isDefault, true);
      
      // Next should be alphabetically sorted: Bank, Cash
      expect(accountsWithBalance[1].name, 'Bank');
      expect(accountsWithBalance[2].name, 'Cash');
    });
  });
}
