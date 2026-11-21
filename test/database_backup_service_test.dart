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
          .any((row) => row.header == 'Backup test' && row.amount == 42.0),
      isTrue,
    );
  });

  test('restores legacy v1 REAL-money snapshots into integer cents', () async {
    final destination = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(destination.close);

    final legacyV1Snapshot = {
      'version': 1,
      'tables': {
        'accounts': [
          {
            'id': 1,
            'name': 'M-Pesa',
            'type': 'mpesa',
            'initial_balance': 250.75,
            'currency': 'KES',
            'color_hex': '#1B5E20',
            'icon': 'phone_android',
            'is_default': 1,
            'is_archived': 0,
            'created_at': 1730419200,
          },
        ],
        'transactions': [
          {
            'id': 1,
            'header': 'Legacy Coffee',
            'description': '',
            'amount': 123.45,
            'transaction_cost': 5.50,
            'fuliza_amount': 0.0,
            'fuliza_fee': 0.0,
            'type': 'expense',
            'account_id': 1,
            'transaction_date': 1730419200,
            'is_parsed': 0,
            'exclude_from_budget': 0,
            'is_recurring': 0,
            'created_at': 1730419200,
          },
        ],
      },
    };

    await DatabaseBackupService(destination).restore(legacyV1Snapshot);

    final account = await destination.select(destination.accounts).getSingle();
    expect(account.initialBalance, 250.75);

    final txn = await destination.select(destination.transactions).getSingle();
    expect(txn.amount, 123.45);
    expect(txn.transactionCost, 5.50);
  });
}
