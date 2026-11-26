import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/repositories/account_repository.dart';

void main() {

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
      expect(accounts.length, 2);
      expect(
        accounts.any(
          (a) => a.name == 'M-Pesa' && a.isDefault && a.icon == 'brand_mpesa',
        ),
        true,
      );
      expect(
        accounts.any((a) => a.name == 'Cash' && a.icon == 'brand_cash'),
        true,
      );
      expect(accounts.any((a) => a.type == 'bank'), false);
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
      final bankId = await repo.insertAccount(
        AccountsCompanion.insert(
          name: 'KCB Bank',
          type: const Value('bank'),
          colorHex: const Value('#003D4C'),
          icon: const Value('brand_kcb'),
        ),
      );
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');
      final bank = accounts.firstWhere((a) => a.id == bankId);

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
      final bankWithBalance = accountsWithBalance.firstWhere((a) => a.name == 'KCB Bank');

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
      await repo.insertAccount(
        AccountsCompanion.insert(
          name: 'Equity Bank',
          type: const Value('bank'),
          colorHex: const Value('#A32A29'),
          icon: const Value('brand_equity'),
        ),
      );
      final accountsWithBalance = await repo.watchAccountsWithBalance().first;
      
      expect(accountsWithBalance.first.name, 'M-Pesa');
      expect(accountsWithBalance.first.isDefault, true);
      
      // Next should be alphabetically sorted: Cash, Equity Bank
      expect(accountsWithBalance[1].name, 'Cash');
      expect(accountsWithBalance[2].name, 'Equity Bank');
    });

    test('correctBalance marks adjustment transactions excludeFromBudget', () async {
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');

      final adjId = await repo.correctBalance(
        accountId: mpesa.id,
        currentBalance: 0,
        targetBalance: 1200,
      );
      expect(adjId, isNotNull);
      final txn = await (db.select(db.transactions)
            ..where((t) => t.id.equals(adjId!)))
          .getSingle();
      expect(txn.excludeFromBudget, isTrue);
    });

    test('deleteAccount guards default, linked, and last accounts; deletes unused non-default',
        () async {
      final bankId = await repo.insertAccount(
        AccountsCompanion.insert(
          name: 'KCB Bank',
          type: const Value('bank'),
          colorHex: const Value('#003D4C'),
          icon: const Value('brand_kcb'),
        ),
      );
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.isDefault);
      final cash = accounts.firstWhere((a) => a.name == 'Cash');
      final bank = accounts.firstWhere((a) => a.id == bankId);

      // Cannot delete default account.
      await expectLater(repo.deleteAccount(mpesa.id), throwsStateError);

      // Cannot delete account with linked transaction.
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              header: 'Cash lunch',
              amount: 200,
              accountId: Value(cash.id),
              transactionDate: DateTime(2026, 11, 10),
            ),
          );
      await expectLater(repo.deleteAccount(cash.id), throwsStateError);

      // Unused non-default account deletes cleanly.
      await repo.deleteAccount(bank.id);
      expect(
        (await repo.getAll(includeArchived: true)).any((a) => a.id == bank.id),
        isFalse,
      );
    });

    test('Fuliza-covered expenses do not double-deduct from M-Pesa wallet balance',
        () async {
      final accounts = await repo.getAll();
      final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');

      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              type: const Value('income'),
              header: 'Deposit',
              amount: 100.0,
              accountId: Value(mpesa.id),
              transactionDate: DateTime(2026, 11, 10),
            ),
          );

      // Spent 170 total, where 70 was covered by Fuliza with 0.70 Fuliza fee.
      // Only 100 came out of M-Pesa wallet cash; Fuliza portion/fee is Fuliza debt.
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              type: const Value('expense'),
              header: 'Paybill with Fuliza',
              amount: 170.0,
              transactionCost: const Value(0.0),
              fulizaAmount: const Value(70.0),
              fulizaFee: const Value(0.70),
              accountId: Value(mpesa.id),
              transactionDate: DateTime(2026, 11, 10),
            ),
          );

      final updated = await repo.watchAccountsWithBalance().first;
      final mpesaBalance =
          updated.firstWhere((a) => a.id == mpesa.id).balance;
      expect(mpesaBalance, 0.0);
    });
  });
}
