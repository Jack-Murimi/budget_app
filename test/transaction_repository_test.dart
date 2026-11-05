import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
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
}
