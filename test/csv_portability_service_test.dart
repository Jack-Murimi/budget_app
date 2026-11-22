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

    final all = await db.select(db.transactions).get();
    expect(all.length, 3);
    final importedSalary = all.firstWhere((t) => t.mpesaRef == 'REF100');
    final defaultAcc = (await db.select(db.accounts).get())
        .firstWhere((a) => a.isDefault);
    expect(importedSalary.accountId, defaultAcc.id);
  });

  test('round-trips extended columns and deduplicates by mpesa_ref', () async {
    final src = AppDatabase.forTesting(NativeDatabase.memory());
    final dst = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(src.close);
    addTearDown(dst.close);

    final srcAccounts = await src.select(src.accounts).get();
    final mpesa = srcAccounts.firstWhere((a) => a.name == 'M-Pesa');
    final bank = srcAccounts.firstWhere((a) => a.name == 'Bank');
    final food = (await src.select(src.categories).get())
        .firstWhere((c) => c.name == 'Food & Groceries');

    await src.into(src.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Transfer to Bank',
            amount: 2500.0,
            transactionCost: const Value(33.0),
            fulizaAmount: const Value(500.0),
            fulizaFee: const Value(5.50),
            type: const Value('transfer'),
            categoryId: Value(food.id),
            accountId: Value(mpesa.id),
            toAccountId: Value(bank.id),
            excludeFromBudget: const Value(true),
            mpesaRef: const Value('ABC123XYZ'),
            transactionDate: DateTime.utc(2026, 11, 15, 12),
          ),
        );

    final csv = await CsvPortabilityService(src).exportTransactionsCsv();
    final firstImport =
        await CsvPortabilityService(dst).importTransactionsCsv(csv);
    expect(firstImport.imported, 1);
    expect(firstImport.skippedDuplicates, 0);

    final restored = await dst.select(dst.transactions).getSingle();
    final dstAccounts = await dst.select(dst.accounts).get();
    final dstMpesa = dstAccounts.firstWhere((a) => a.name == 'M-Pesa');
    final dstBank = dstAccounts.firstWhere((a) => a.name == 'Bank');
    final dstFood = (await dst.select(dst.categories).get())
        .firstWhere((c) => c.name == 'Food & Groceries');

    expect(restored.transactionCost, 33.0);
    expect(restored.fulizaAmount, 500.0);
    expect(restored.fulizaFee, 5.50);
    expect(restored.accountId, dstMpesa.id);
    expect(restored.toAccountId, dstBank.id);
    expect(restored.categoryId, dstFood.id);
    expect(restored.excludeFromBudget, isTrue);

    // Same mpesa_ref with different date/payee must still be skipped.
    final dupRefResult =
        await CsvPortabilityService(dst).importTransactionsCsv('''
header,amount,type,transaction_date,mpesa_ref
Different Header,999,expense,2026-11-16T08:00:00.000Z,ABC123XYZ
''');
    expect(dupRefResult.imported, 0);
    expect(dupRefResult.skippedDuplicates, 1);
  });

  test('sanitizes formula-injection prefixes in CSV exports without corrupting negative numbers',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            name: '@evilAccount',
            initialBalance: const Value(-50.0),
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: '=CMD()',
            description: const Value('+1+1'),
            counterpartyName: const Value('-HYPERLINK("http://x")'),
            amount: 100.0,
            transactionDate: DateTime.utc(2026, 11, 10),
          ),
        );

    final service = CsvPortabilityService(db);
    final txCsv = await service.exportTransactionsCsv();
    final accCsv = await service.exportAccountsCsv();

    expect(txCsv, contains('"\'=CMD()"'));
    expect(txCsv, contains('"\'+1+1"'));
    expect(txCsv, contains('"\'-HYPERLINK(""http://x"")"'));
    expect(accCsv, contains('"\'@evilAccount"'));
    expect(accCsv, contains('"-50.0"'));
  });
}
