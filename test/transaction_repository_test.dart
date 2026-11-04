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
}
