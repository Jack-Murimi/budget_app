import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/repositories/account_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  Future<void> expectMoneyColumnsAreInteger(AppDatabase db) async {
    const moneyColumns = <String, List<String>>{
      'accounts': ['initial_balance'],
      'budgets': ['amount'],
      'fuliza_records': ['fuliza_amount', 'access_fee', 'outstanding_total'],
      'recurring_transactions': ['amount'],
      'debts': ['principal', 'outstanding', 'interest', 'disbursement_shortfall'],
      'debt_repayments': ['amount'],
      'savings_goals': ['target_amount', 'current_amount'],
      'goal_contributions': ['amount'],
      'sms_inbox_items': ['parsed_amount'],
      'transactions': ['amount', 'transaction_cost', 'fuliza_amount', 'fuliza_fee'],
    };

    for (final entry in moneyColumns.entries) {
      final info = await db.customSelect('PRAGMA table_info("${entry.key}")').get();
      final typesByName = {
        for (final row in info)
          row.read<String>('name'): row.read<String>('type').toUpperCase(),
      };
      for (final col in entry.value) {
        expect(
          typesByName[col],
          equals('INTEGER'),
          reason: '${entry.key}.$col should have INTEGER affinity after v17',
        );
      }
    }
  }

  test('migrates schema v1 -> v17 cleanly and converts REAL money to integer cents',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('budget_v1_to_v17_');
    final dbFile = File('${tempDir.path}/test.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Seed an authentic v1 database with REAL monetary columns.
    final raw = sql.sqlite3.open(dbFile.path);
    try {
      raw.execute('PRAGMA user_version = 1;');
      raw.execute('''
        CREATE TABLE categories (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT NOT NULL DEFAULT 'category',
          color_hex TEXT NOT NULL DEFAULT '#6750A4',
          parent_id INTEGER REFERENCES categories(id),
          is_default INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
      ''');
      raw.execute('''
        CREATE TABLE transactions (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          header TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          amount REAL NOT NULL,
          transaction_cost REAL NOT NULL DEFAULT 0.0,
          type TEXT NOT NULL DEFAULT 'expense',
          category_id INTEGER REFERENCES categories(id),
          transaction_date INTEGER NOT NULL,
          mpesa_ref TEXT,
          counterparty_name TEXT NOT NULL DEFAULT '',
          counterparty_account TEXT NOT NULL DEFAULT '',
          is_parsed INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
      ''');
      raw.execute('''
        INSERT INTO categories (id, name, icon, color_hex, is_default)
        VALUES (1, 'Food & Dining', 'restaurant', '#E53935', 1);
      ''');
      // Include a classic binary floating-point drift pair (0.10 + 0.20) and fractional KES.
      raw.execute('''
        INSERT INTO transactions (header, amount, transaction_cost, type, category_id, transaction_date, mpesa_ref)
        VALUES
          ('Naivas', 150.55, 12.50, 'expense', 1, 1730419200, 'REF001'),
          ('Micro A', 0.10, 0.0, 'income', 1, 1730419260, 'REF002'),
          ('Micro B', 0.20, 0.0, 'income', 1, 1730419320, 'REF003');
      ''');
    } finally {
      raw.dispose();
    }

    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    // Trigger migration & beforeOpen.
    final txns = await db.select(db.transactions).get();
    expect(txns, hasLength(3));

    final versionRow = await db.customSelect('PRAGMA user_version').getSingle();
    expect(versionRow.read<int>('user_version'), 17);

    await expectMoneyColumnsAreInteger(db);

    // Raw SQLite values must be exact integer cents.
    final rawNaivas = await db.customSelect(
      "SELECT amount, transaction_cost FROM transactions WHERE header = 'Naivas'",
    ).getSingle();
    expect(rawNaivas.read<int>('amount'), 15055);
    expect(rawNaivas.read<int>('transaction_cost'), 1250);

    // Drift decodes back to exact KES doubles.
    final naivas = txns.firstWhere((t) => t.header == 'Naivas');
    expect(naivas.amount, 150.55);
    expect(naivas.transactionCost, 12.50);

    // Account balance math must have zero floating-point drift:
    // 0.10 + 0.20 - (150.55 + 12.50) = -162.75 exactly.
    final accounts = await AccountRepository(db).watchAccountsWithBalance().first;
    final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');
    expect(mpesa.balance, equals(-162.75));
  });

  test('migrates schema v16 -> v17 preserving values across all monetary tables',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('budget_v16_to_v17_');
    final dbFile = File('${tempDir.path}/test_v16.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final raw = sql.sqlite3.open(dbFile.path);
    try {
      raw.execute('PRAGMA user_version = 16;');
      raw.execute('''
        CREATE TABLE categories (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT NOT NULL DEFAULT 'category',
          color_hex TEXT NOT NULL DEFAULT '#6750A4',
          parent_id INTEGER REFERENCES categories(id),
          transaction_type TEXT NOT NULL DEFAULT 'expense',
          is_default INTEGER NOT NULL DEFAULT 0,
          is_archived INTEGER NOT NULL DEFAULT 0,
          sort_order INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE accounts (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL DEFAULT 'mpesa',
          initial_balance REAL NOT NULL DEFAULT 0.0,
          currency TEXT NOT NULL DEFAULT 'KES',
          color_hex TEXT NOT NULL DEFAULT '#1B5E20',
          icon TEXT NOT NULL DEFAULT 'account_balance_wallet',
          is_default INTEGER NOT NULL DEFAULT 0,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE budgets (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          period TEXT NOT NULL DEFAULT 'monthly',
          category_id INTEGER REFERENCES categories(id),
          start_date INTEGER NOT NULL,
          end_date INTEGER,
          rollover INTEGER NOT NULL DEFAULT 0,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE fuliza_records (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          mpesa_ref TEXT NOT NULL UNIQUE,
          fuliza_amount REAL NOT NULL,
          access_fee REAL NOT NULL DEFAULT 0.0,
          outstanding_total REAL NOT NULL DEFAULT 0.0,
          due_date INTEGER,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE recurring_transactions (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER REFERENCES accounts(id),
          category_id INTEGER REFERENCES categories(id),
          amount REAL NOT NULL,
          type TEXT NOT NULL DEFAULT 'expense',
          payee TEXT NOT NULL DEFAULT '',
          notes TEXT NOT NULL DEFAULT '',
          frequency TEXT NOT NULL DEFAULT 'monthly',
          interval_count INTEGER NOT NULL DEFAULT 1,
          start_date INTEGER NOT NULL,
          end_date INTEGER,
          next_due_date INTEGER NOT NULL,
          auto_record INTEGER NOT NULL DEFAULT 0,
          notify INTEGER NOT NULL DEFAULT 1,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
          updated_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE debts (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          direction TEXT NOT NULL,
          counterparty TEXT NOT NULL,
          product TEXT NOT NULL DEFAULT 'personal',
          principal REAL NOT NULL,
          outstanding REAL NOT NULL,
          interest REAL NOT NULL DEFAULT 0.0,
          disbursement_shortfall REAL NOT NULL DEFAULT 0.0,
          due_date INTEGER,
          account_id INTEGER REFERENCES accounts(id),
          notes TEXT NOT NULL DEFAULT '',
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE debt_repayments (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          debt_id INTEGER NOT NULL REFERENCES debts(id),
          amount REAL NOT NULL,
          account_id INTEGER REFERENCES accounts(id),
          payment_date INTEGER NOT NULL,
          transaction_id INTEGER,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE savings_goals (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          target_amount REAL NOT NULL,
          current_amount REAL NOT NULL DEFAULT 0.0,
          target_date INTEGER,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
        CREATE TABLE goal_contributions (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL REFERENCES savings_goals(id),
          amount REAL NOT NULL,
          account_id INTEGER REFERENCES accounts(id),
          transaction_id INTEGER,
          contribution_date INTEGER NOT NULL
        );
        CREATE TABLE payee_category_rules (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          payee_key TEXT NOT NULL UNIQUE,
          display_name TEXT NOT NULL,
          category_id INTEGER NOT NULL REFERENCES categories(id),
          usage_count INTEGER NOT NULL DEFAULT 1,
          updated_at INTEGER NOT NULL
        );
        CREATE TABLE sms_inbox_items (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          raw_body TEXT NOT NULL,
          parsed_type TEXT,
          parsed_amount REAL,
          parsed_payee TEXT,
          parsed_ref TEXT,
          parsed_date INTEGER,
          status TEXT NOT NULL DEFAULT 'pending',
          parse_note TEXT,
          created_at INTEGER NOT NULL
        );
        CREATE TABLE transactions (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          header TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          amount REAL NOT NULL,
          transaction_cost REAL NOT NULL DEFAULT 0.0,
          fuliza_amount REAL NOT NULL DEFAULT 0.0,
          fuliza_fee REAL NOT NULL DEFAULT 0.0,
          type TEXT NOT NULL DEFAULT 'expense',
          category_id INTEGER REFERENCES categories(id),
          transaction_date INTEGER NOT NULL,
          mpesa_ref TEXT UNIQUE,
          counterparty_name TEXT NOT NULL DEFAULT '',
          counterparty_account TEXT NOT NULL DEFAULT '',
          account_id INTEGER REFERENCES accounts(id),
          to_account_id INTEGER REFERENCES accounts(id),
          is_parsed INTEGER NOT NULL DEFAULT 0,
          exclude_from_budget INTEGER NOT NULL DEFAULT 0,
          recurrence_id INTEGER REFERENCES recurring_transactions(id),
          is_recurring INTEGER NOT NULL DEFAULT 0,
          debt_id INTEGER REFERENCES debts(id),
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
        );
      ''');

      raw.execute('''
        INSERT INTO categories (id, name, transaction_type, is_default)
        VALUES (1, 'Food & Groceries', 'expense', 1);
        INSERT INTO accounts (id, name, initial_balance, is_default)
        VALUES (1, 'M-Pesa', 1234.56, 1);
        INSERT INTO budgets (id, name, amount, category_id, start_date)
        VALUES (1, 'Groceries', 15000.50, 1, 1730419200);
        INSERT INTO fuliza_records (id, mpesa_ref, fuliza_amount, access_fee, outstanding_total)
        VALUES (1, 'FUL001', 500.25, 5.15, 505.40);
        INSERT INTO recurring_transactions (id, account_id, category_id, amount, payee, start_date, next_due_date)
        VALUES (1, 1, 1, 2999.99, 'WiFi', 1730419200, 1733011200);
        INSERT INTO debts (id, direction, counterparty, principal, outstanding, interest, disbursement_shortfall, account_id)
        VALUES (1, 'borrowed', 'Bridge', 600.00, 650.75, 50.75, 30.25, 1);
        INSERT INTO debt_repayments (id, debt_id, amount, account_id, payment_date)
        VALUES (1, 1, 100.50, 1, 1730419200);
        INSERT INTO savings_goals (id, name, target_amount, current_amount)
        VALUES (1, 'Emergency', 100000.00, 2500.75);
        INSERT INTO goal_contributions (id, goal_id, amount, account_id, contribution_date)
        VALUES (1, 1, 500.25, 1, 1730419200);
        INSERT INTO sms_inbox_items (id, raw_body, parsed_amount, created_at)
        VALUES
          (1, 'Paid Ksh 42.50', 42.50, 1730419200),
          (2, 'Unparseable SMS', NULL, 1730419200);
        INSERT INTO transactions (id, header, amount, transaction_cost, fuliza_amount, fuliza_fee, account_id, category_id, transaction_date, mpesa_ref)
        VALUES (1, 'Java House', 850.75, 13.00, 200.50, 2.05, 1, 1, 1730419200, 'TXN001');
      ''');
    } finally {
      raw.dispose();
    }

    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    await db.select(db.accounts).get();
    await expectMoneyColumnsAreInteger(db);

    final acc = await db.select(db.accounts).getSingle();
    expect(acc.initialBalance, 1234.56);

    final budget = await db.select(db.budgets).getSingle();
    expect(budget.amount, 15000.50);

    final fuliza = await db.select(db.fulizaRecords).getSingle();
    expect(fuliza.fulizaAmount, 500.25);
    expect(fuliza.accessFee, 5.15);
    expect(fuliza.outstandingTotal, 505.40);

    final rec = await db.select(db.recurringTransactions).getSingle();
    expect(rec.amount, 2999.99);

    final debt = await db.select(db.debts).getSingle();
    expect(debt.principal, 600.00);
    expect(debt.outstanding, 650.75);
    expect(debt.interest, 50.75);
    expect(debt.disbursementShortfall, 30.25);

    final repay = await db.select(db.debtRepayments).getSingle();
    expect(repay.amount, 100.50);

    final goal = await db.select(db.savingsGoals).getSingle();
    expect(goal.targetAmount, 100000.00);
    expect(goal.currentAmount, 2500.75);

    final contrib = await db.select(db.goalContributions).getSingle();
    expect(contrib.amount, 500.25);

    final sms = await db.select(db.smsInboxItems).get();
    expect(sms.firstWhere((s) => s.id == 1).parsedAmount, 42.50);
    expect(sms.firstWhere((s) => s.id == 2).parsedAmount, isNull);

    final txn = await db.select(db.transactions).getSingle();
    expect(txn.amount, 850.75);
    expect(txn.transactionCost, 13.00);
    expect(txn.fulizaAmount, 200.50);
    expect(txn.fulizaFee, 2.05);

    // Verify critical indexes were recreated after table rebuild.
    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name IS NOT NULL",
        )
        .get();
    final indexNames = indexes.map((r) => r.read<String>('name')).toSet();
    expect(indexNames, contains('idx_transactions_mpesa_ref'));
    expect(indexNames, contains('idx_transactions_header'));
    expect(indexNames, contains('idx_transactions_header_cat'));
    expect(indexNames, contains('idx_fuliza_records_mpesa_ref'));
  });
}
