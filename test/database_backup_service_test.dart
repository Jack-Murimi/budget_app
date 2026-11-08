import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/portability/services/database_backup_service.dart';
import 'package:drift/drift.dart' show Value;
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

  test('snapshot restores transactions, accounts, and categories', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final destination = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(destination.close);
    final accountId = await source.into(source.accounts).insert(
          AccountsCompanion.insert(name: 'M-Pesa'),
        );
    await source.into(source.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Backup test',
            amount: 42,
            accountId: Value(accountId),
            transactionDate: DateTime.utc(2026, 11, 8),
          ),
        );

    final snapshot = await DatabaseBackupService(source).snapshot();
    await DatabaseBackupService(destination).restore(snapshot);

    expect(
      (await destination.select(destination.accounts).get())
          .any((row) => row.name == 'M-Pesa'),
      isTrue,
    );
    expect(
      (await destination.select(destination.transactions).get())
          .any((row) => row.header == 'Backup test'),
      isTrue,
    );
  });
}
