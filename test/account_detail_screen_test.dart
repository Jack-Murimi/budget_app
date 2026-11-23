import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/repositories/account_repository.dart';
import 'package:budget_app/features/accounts/screens/account_detail_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  late AppDatabase db;
  late AccountRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> unmountTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets('AccountDetailScreen displays incoming/outgoing transfers, adjusts balance, edits, sets default, and handles delete guard',
      (tester) async {
    final accounts = await db.select(db.accounts).get();
    final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');
    final bank = accounts.firstWhere((a) => a.name == 'Bank');

    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Top up from Bank',
            type: const Value('transfer'),
            amount: 1200.0,
            accountId: Value(bank.id),
            toAccountId: Value(mpesa.id),
            transactionDate: DateTime.now(),
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Move to Bank',
            type: const Value('transfer'),
            amount: 200.0,
            accountId: Value(mpesa.id),
            toAccountId: Value(bank.id),
            transactionDate: DateTime.now(),
          ),
        );

    final mpesaWithBal = (await repo.watchAccountsWithBalance().first)
        .firstWhere((a) => a.id == mpesa.id);
    final bankWithBal = (await repo.watchAccountsWithBalance().first)
        .firstWhere((a) => a.id == bank.id);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    // 1. Open M-Pesa detail (default account)
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: AccountDetailScreen(account: mpesaWithBal)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+KES 1,200.00'), findsOneWidget);
    expect(find.text('-KES 200.00'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    // Adjust balance validation & submission
    await tester.tap(find.text('Adjust Balance'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New Balance'),
      'bad',
    );
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid balance'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'New Balance'),
      '2500',
    );
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(find.text('KES 2,500.00'), findsOneWidget);
    expect(find.text('Balance Adjustment'), findsOneWidget);

    // Edit account name
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Safaricom M-Pesa',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Safaricom M-Pesa'), findsWidgets);

    // Deleting default account surfaces StateError message cleanly
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cannot delete the default account'), findsOneWidget);

    await unmountTree(tester);

    // 2. Open non-default Bank account, test Set as Default and Archive
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute<void>(
                      builder: (_) => AccountDetailScreen(account: bankWithBal),
                    ),
                  ),
                  child: const Text('Open Bank'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Bank'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set as Default'));
    await tester.pumpAndSettle();
    expect(find.text('Bank set as default'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(AccountDetailScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountDetailScreen), findsNothing);
    expect(find.text('Bank archived'), findsOneWidget);

    await unmountTree(tester);
  });
}
