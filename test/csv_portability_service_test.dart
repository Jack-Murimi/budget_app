import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/portability/services/csv_portability_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  test(
      'exports date-filtered transactions and skips timestamp amount payee duplicates',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final service = CsvPortabilityService(db);
    final date = DateTime.utc(2026, 11, 8, 10);
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Naivas',
            amount: 500,
            type: const Value('expense'),
            transactionDate: date,
            counterpartyName: const Value('Naivas'),
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Old payment',
            amount: 100,
            transactionDate: DateTime.utc(2026, 10, 1),
          ),
        );

    final csv = await service.exportTransactionsCsv(
      start: DateTime.utc(2026, 11, 1),
      end: DateTime.utc(2026, 12, 1),
    );
    final result = await service.importTransactionsCsv('''
header,description,amount,type,transaction_date,mpesa_ref,counterparty_name,counterparty_account
Naivas,,500,expense,2026-11-08T10:00:00.000Z,,Naivas,
Salary,,1000,income,2026-11-09T09:00:00.000Z,REF100,Employer,
''');

    expect(csv, contains('Naivas'));
    expect(csv, isNot(contains('Old payment')));
    expect(result.imported, 1);
    expect(result.skippedDuplicates, 1);
    expect((await db.select(db.transactions).get()).length, 3);
  });
}
