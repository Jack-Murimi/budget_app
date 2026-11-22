import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/repositories/debt_repository.dart';
import 'package:budget_app/features/goals/repositories/goal_repository.dart';
import 'package:budget_app/features/transactions/repositories/transaction_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDatabase db;
  late TransactionRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TransactionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insertOrIgnoreDuplicate rejects duplicate non-empty mpesaRef and allows multiple nulls', () async {
    final first = await repo.insertOrIgnoreDuplicate(
      TransactionsCompanion.insert(
        header: 'Test 1',
        amount: 100.0,
        transactionDate: DateTime.now(),
        mpesaRef: const Value('REF123'),
      ),
    );
    expect(first, isNotNull);

    // Duplicate ref
    final duplicate = await repo.insertOrIgnoreDuplicate(
      TransactionsCompanion.insert(
        header: 'Test 2',
        amount: 200.0,
        transactionDate: DateTime.now(),
        mpesaRef: const Value('REF123'),
      ),
    );
    expect(duplicate, isNull);

    // Null ref (manual entry) 1
    final manual1 = await repo.insertOrIgnoreDuplicate(
      TransactionsCompanion.insert(
        header: 'Manual 1',
        amount: 50.0,
        transactionDate: DateTime.now(),
      ),
    );
    expect(manual1, isNotNull);

    // Null ref (manual entry) 2
    final manual2 = await repo.insertOrIgnoreDuplicate(
      TransactionsCompanion.insert(
        header: 'Manual 2',
        amount: 60.0,
        transactionDate: DateTime.now(),
      ),
    );
    expect(manual2, isNotNull);

    // Verify DB UNIQUE constraint throws on raw insert with same ref
    expect(
      () => repo.insert(
        TransactionsCompanion.insert(
          header: 'Direct dup',
          amount: 300.0,
          transactionDate: DateTime.now(),
          mpesaRef: const Value('REF123'),
        ),
      ),
      throwsException,
    );
  });

  test('updateFulizaFields updates existing transaction and returns false when ref not found', () async {
    final updatedMissing = await repo.updateFulizaFields(
      mpesaRef: 'NONEXISTENT',
      fulizaAmount: 50.0,
      fulizaFee: 0.50,
    );
    expect(updatedMissing, isFalse);

    await repo.insert(
      TransactionsCompanion.insert(
        header: 'Test Send',
        amount: 200.0,
        transactionDate: DateTime.now(),
        mpesaRef: const Value('REF999'),
      ),
    );

    final updated = await repo.updateFulizaFields(
      mpesaRef: 'REF999',
      fulizaAmount: 150.0,
      fulizaFee: 1.50,
    );
    expect(updated, isTrue);

    final record = await repo.getByRef('REF999');
    expect(record, isNotNull);
    expect(record!.fulizaAmount, 150.0);
    expect(record.fulizaFee, 1.50);
  });

  test('watchRecent returns transactions ordered by date descending', () async {
    final now = DateTime.now();
    await repo.insert(TransactionsCompanion.insert(
      header: 'Old',
      amount: 100.0,
      transactionDate: now.subtract(const Duration(days: 10)),
    ));
    await repo.insert(TransactionsCompanion.insert(
      header: 'Recent',
      amount: 200.0,
      transactionDate: now,
    ));
    await repo.insert(TransactionsCompanion.insert(
      header: 'Middle',
      amount: 150.0,
      transactionDate: now.subtract(const Duration(days: 5)),
    ));

    final stream = repo.watchRecent(limit: 10);
    final transactions = await stream.first;

    expect(transactions.length, 3);
    expect(transactions[0].header, 'Recent');
    expect(transactions[1].header, 'Middle');
    expect(transactions[2].header, 'Old');
  });

  test('watchMonthSummary returns only transactions in specified month', () async {
    await repo.insert(TransactionsCompanion.insert(
      header: 'Nov 2026',
      amount: 100.0,
      transactionDate: DateTime(2026, 11, 15),
    ));
    await repo.insert(TransactionsCompanion.insert(
      header: 'Oct 2026',
      amount: 200.0,
      transactionDate: DateTime(2026, 10, 20),
    ));
    await repo.insert(TransactionsCompanion.insert(
      header: 'Nov 2026 Again',
      amount: 150.0,
      transactionDate: DateTime(2026, 11, 25),
    ));

    final stream = repo.watchMonthSummary(year: 2026, month: 11);
    final transactions = await stream.first;

    expect(transactions.length, 2);
    expect(transactions.every((t) => t.transactionDate.month == 11), true);
    expect(transactions.every((t) => t.transactionDate.year == 2026), true);
  });

  test('getByRef returns transaction with matching mpesaRef', () async {
    await repo.insert(TransactionsCompanion.insert(
      header: 'Test',
      amount: 100.0,
      transactionDate: DateTime.now(),
      mpesaRef: const Value('TESTREF123'),
    ));

    final result = await repo.getByRef('TESTREF123');
    expect(result, isNotNull);
    expect(result!.mpesaRef, 'TESTREF123');
    expect(result.header, 'Test');
  });

  test('getByRef returns null when ref not found', () async {
    final result = await repo.getByRef('NONEXISTENT');
    expect(result, isNull);
  });

  test('delete removes transaction by id', () async {
    final id = await repo.insert(TransactionsCompanion.insert(
      header: 'To Delete',
      amount: 100.0,
      transactionDate: DateTime.now(),
      mpesaRef: const Value('DELREF'),
    ));

    final beforeDelete = await repo.getByRef('DELREF');
    expect(beforeDelete, isNotNull);

    await repo.delete(id);

    final afterDelete = await repo.getByRef('DELREF');
    expect(afterDelete, isNull);
  });

  test('watchAll returns all transactions ordered by date descending', () async {
    final now = DateTime.now();
    await repo.insert(TransactionsCompanion.insert(
      header: 'Old',
      amount: 100.0,
      transactionDate: now.subtract(const Duration(days: 10)),
    ));
    await repo.insert(TransactionsCompanion.insert(
      header: 'Recent',
      amount: 200.0,
      transactionDate: now,
    ));
    await repo.insert(TransactionsCompanion.insert(
      header: 'Middle',
      amount: 150.0,
      transactionDate: now.subtract(const Duration(days: 5)),
    ));

    final stream = repo.watchAll();
    final transactions = await stream.first;

    expect(transactions.length, 3);
    expect(transactions[0].header, 'Recent');
    expect(transactions[1].header, 'Middle');
    expect(transactions[2].header, 'Old');
  });

  test('updateTransaction updates existing transaction and returns false when id not found', () async {
    final updatedMissing = await repo.updateTransaction(
      TransactionsCompanion(
        id: const Value(999),
        header: const Value('Updated'),
        amount: const Value(500.0),
        transactionDate: Value(DateTime.now()),
      ),
    );
    expect(updatedMissing, isFalse);

    final insertResult = await repo.insert(
      TransactionsCompanion.insert(
        header: 'To Update',
        amount: 100.0,
        transactionDate: DateTime.now(),
        mpesaRef: const Value('UPDREF'),
      ),
    );
    expect(insertResult, isNotNull);

    final updated = await repo.updateTransaction(
      TransactionsCompanion(
        id: Value(insertResult),
        header: const Value('Updated'),
        amount: const Value(300.0),
        transactionDate: Value(DateTime.now()),
      ),
    );
    expect(updated, isTrue);

    final record = await repo.getByRef('UPDREF');
    expect(record, isNotNull);
    expect(record!.header, 'Updated');
    expect(record.amount, 300.0);
  });

  group('getHeaderSuggestions', () {
    test('returns empty list for empty/whitespace query', () async {
      final res = await repo.getHeaderSuggestions('   ');
      expect(res, isEmpty);
    });

    test('returns max 3 items and supports same header with different categories', () async {
      // Create parent category (Food & Drinks) and sub-category (Groceries)
      final foodId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Food & Drinks',
          icon: const Value('fastfood'),
          colorHex: const Value('#FF0000'),
        ),
      );
      final groceriesId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Groceries',
          parentId: Value(foodId),
          icon: const Value('local_grocery_store'),
          colorHex: const Value('#FF0000'),
        ),
      );
      // Create Shopping category and Electronics sub-category
      final shopId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Shopping',
          icon: const Value('shopping_bag'),
          colorHex: const Value('#0000FF'),
        ),
      );
      final elecId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Electronics',
          parentId: Value(shopId),
          icon: const Value('devices'),
          colorHex: const Value('#0000FF'),
        ),
      );

      // Insert transactions:
      // 1. Naivas with Groceries (sub of Food & Drinks)
      await repo.insert(
        TransactionsCompanion.insert(
          header: 'Naivas',
          amount: 1500.0,
          transactionDate: DateTime(2026, 1, 2),
          categoryId: Value(groceriesId),
        ),
      );
      // 2. Naivas with Electronics (sub of Shopping)
      await repo.insert(
        TransactionsCompanion.insert(
          header: 'Naivas',
          amount: 5000.0,
          transactionDate: DateTime(2026, 1, 3),
          categoryId: Value(elecId),
        ),
      );
      // 3. Nairobi Java House with Food & Drinks (top-level)
      await repo.insert(
        TransactionsCompanion.insert(
          header: 'Nairobi Java House',
          amount: 800.0,
          transactionDate: DateTime(2026, 1, 4),
          categoryId: Value(foodId),
        ),
      );
      // 4. Naivas Supermarket (4th item matching 'Nai', older date)
      await repo.insert(
        TransactionsCompanion.insert(
          header: 'Naivas Supermarket',
          amount: 300.0,
          transactionDate: DateTime(2026, 1, 1),
        ),
      );

      final suggestions = await repo.getHeaderSuggestions('Nai');
      // Max 3 items
      expect(suggestions.length, 3);

      // Verify that same header 'Naivas' appears with both different categories
      final headers = suggestions.map((s) => s.header).toList();
      expect(headers, contains('Naivas'));

      // Find Naivas suggestions
      final naivasItems = suggestions.where((s) => s.header == 'Naivas').toList();
      expect(naivasItems.length, 2);

      final elecSuggestion = naivasItems.firstWhere((s) => s.categoryId == elecId);
      expect(elecSuggestion.categoryDisplay, 'Shopping > Electronics');
      expect(elecSuggestion.categoryName, 'Electronics');
      expect(elecSuggestion.parentCategoryName, 'Shopping');

      final grocSuggestion = naivasItems.firstWhere((s) => s.categoryId == groceriesId);
      expect(grocSuggestion.categoryDisplay, 'Food & Drinks > Groceries');
      expect(grocSuggestion.categoryName, 'Groceries');
      expect(grocSuggestion.parentCategoryName, 'Food & Drinks');
    });

    test('deduplicates same header + category and picks latest casing/date', () async {
      final catId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Utilities',
          icon: const Value('bolt'),
          colorHex: const Value('#FFFF00'),
        ),
      );

      await repo.insert(
        TransactionsCompanion.insert(
          header: 'kplc tokens',
          amount: 500.0,
          transactionDate: DateTime(2026, 1, 1),
          categoryId: Value(catId),
        ),
      );
      await repo.insert(
        TransactionsCompanion.insert(
          header: 'KPLC Tokens',
          amount: 1000.0,
          transactionDate: DateTime(2026, 1, 5),
          categoryId: Value(catId),
        ),
      );

      final suggestions = await repo.getHeaderSuggestions('kplc');
      expect(suggestions.length, 1);
      expect(suggestions.first.header, 'KPLC Tokens');
      expect(suggestions.first.categoryDisplay, 'Utilities');
      expect(suggestions.first.categoryId, catId);
    });
  });

  group('Phase 2 normalization & linked record reconciliation', () {
    test('insertOrIgnoreDuplicate normalizes blank mpesaRef to null', () async {
      final id1 = await repo.insertOrIgnoreDuplicate(
        TransactionsCompanion.insert(
          header: 'Blank 1',
          amount: 100.0,
          transactionDate: DateTime(2026, 11, 1),
          mpesaRef: const Value(''),
        ),
      );
      final id2 = await repo.insertOrIgnoreDuplicate(
        TransactionsCompanion.insert(
          header: 'Blank 2',
          amount: 200.0,
          transactionDate: DateTime(2026, 11, 2),
          mpesaRef: const Value('   '),
        ),
      );
      expect(id1, isNotNull);
      expect(id2, isNotNull);

      final rows = await db.select(db.transactions).get();
      expect(rows.every((t) => t.mpesaRef == null), isTrue);
    });

    test('deleting or editing a goal contribution transaction reconciles goal currentAmount',
        () async {
      final accountId = (await db.select(db.accounts).get()).first.id;
      final goalRepo = GoalRepository(db);
      final goalId = await goalRepo.create(name: 'Laptop', targetAmount: 50000);
      await goalRepo.contribute(
        goalId: goalId,
        amount: 3000,
        accountId: accountId,
      );

      final contrib = await db.select(db.goalContributions).getSingle();
      final txId = contrib.transactionId!;

      await repo.updateTransaction(
        TransactionsCompanion(
          id: Value(txId),
          amount: const Value(4500),
        ),
      );
      var goal = await (db.select(db.savingsGoals)
            ..where((g) => g.id.equals(goalId)))
          .getSingle();
      expect(goal.currentAmount, 4500.0);

      await repo.delete(txId);
      goal = await (db.select(db.savingsGoals)
            ..where((g) => g.id.equals(goalId)))
          .getSingle();
      expect(goal.currentAmount, 0.0);
      expect(await db.select(db.goalContributions).get(), isEmpty);
    });

    test('deleting or editing a debt repayment or disbursement reconciles debt balances',
        () async {
      final accountId = (await db.select(db.accounts).get()).first.id;
      final debtRepo = DebtRepository(db);
      final disbTxId = await debtRepo.recordLoanGiven(
        counterparty: 'Sam',
        transaction: TransactionsCompanion.insert(
          header: 'Loan to Sam',
          amount: 1000,
          accountId: Value(accountId),
          transactionDate: DateTime(2026, 11, 1),
        ),
      );
      expect(disbTxId, isNotNull);
      var debt = await db.select(db.debts).getSingle();

      final repayTxId = await debtRepo.recordRepaymentWithTransaction(
        debtId: debt.id,
        transaction: TransactionsCompanion.insert(
          header: 'Sam repays',
          amount: 400,
          type: const Value('income'),
          accountId: Value(accountId),
          transactionDate: DateTime(2026, 11, 5),
        ),
      );
      expect(repayTxId, isNotNull);

      // Editing repayment from 400 -> 600 lowers outstanding from 600 -> 400.
      await repo.updateTransaction(
        TransactionsCompanion(id: Value(repayTxId!), amount: const Value(600)),
      );
      debt = await db.select(db.debts).getSingle();
      expect(debt.outstanding, 400.0);

      // Deleting repayment restores outstanding back to 1000.
      await repo.delete(repayTxId);
      debt = await db.select(db.debts).getSingle();
      expect(debt.outstanding, 1000.0);
      expect(await db.select(db.debtRepayments).get(), isEmpty);

      // Deleting sole disbursement removes the debt record cleanly.
      await repo.delete(disbTxId!);
      expect(await db.select(db.debts).get(), isEmpty);
    });
  });
}
