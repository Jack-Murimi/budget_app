import 'dart:ffi';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/models/account_model.dart';
import 'package:budget_app/features/accounts/screens/account_detail_screen.dart';
import 'package:budget_app/features/accounts/screens/accounts_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AccountsScreen()),
    );
  }

  Future<void> pumpAccountsScreen(WidgetTester tester, ProviderContainer container) async {
    await tester.pumpWidget(buildTestApp(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  testWidgets('renders accounts list and total balance', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpAccountsScreen(tester, container);

    expect(find.text('Accounts & Wallets'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('M-Pesa'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Bank'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
  });

  testWidgets('opens and cancels Add Account dialog', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpAccountsScreen(tester, container);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Account'), findsOneWidget);
    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Opening Balance'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Add Account'), findsNothing);
  });

  testWidgets('adds new account successfully', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpAccountsScreen(tester, container);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    // 0: Name, 1: Initial Balance, 2: Color
    await tester.enterText(textFields.at(0), 'Crypto Wallet');
    await tester.enterText(textFields.at(1), '5000');
    await tester.tap(find.text('Add'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Crypto Wallet'), findsOneWidget);
  });

  testWidgets('opens and submits Transfer dialog', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpAccountsScreen(tester, container);

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Transfer Between Accounts'), findsOneWidget);
    expect(find.text('Amount (KES)'), findsOneWidget);

    final amountField = find.widgetWithText(TextField, 'Amount (KES)');
    await tester.enterText(amountField, '500');

    await tester.tap(find.text('Transfer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Transfer Between Accounts'), findsNothing);
  });

  testWidgets('opens and submits Adjust Balance dialog', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpAccountsScreen(tester, container);

    await tester.tap(find.text('M-Pesa'));
    await tester.pumpAndSettle();

    expect(find.text('Adjust Balance'), findsOneWidget);
    await tester.tap(find.text('Adjust Balance'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AlertDialog, 'Adjust Balance'), findsOneWidget);
    final balanceField = find.widgetWithText(TextField, 'New Balance');
    await tester.enterText(balanceField, '1000');

    await tester.tap(find.text('Update'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AlertDialog, 'Adjust Balance'), findsNothing);
  });

  testWidgets('AccountsScreen displays archived accounts, validates transfers, and shows incoming + on AccountDetailScreen',
      (tester) async {
    await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        name: 'Old Mattress',
        isArchived: const Value(true),
      ),
    );

    final accounts = await db.select(db.accounts).get();
    final mpesa = accounts.firstWhere((a) => a.name == 'M-Pesa');
    final cash = accounts.firstWhere((a) => a.name == 'Cash');

    // Transfer M-Pesa -> Cash
    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        header: 'ATM Withdrawal',
        type: const Value('transfer'),
        amount: 500.0,
        accountId: Value(mpesa.id),
        toAccountId: Value(cash.id),
        transactionDate: DateTime.now(),
      ),
    );

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpAccountsScreen(tester, container);

    // Archived account visible and can be unarchived
    expect(find.text('Archived'), findsWidgets);
    expect(find.byTooltip('Unarchive'), findsOneWidget);
    expect(find.text('Old Mattress'), findsOneWidget);

    // Transfer validation rejects empty/invalid amount
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a positive amount'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify AccountDetailScreen on Cash shows incoming transfer as +KES 500.00
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: AccountDetailScreen(
            account: AccountWithBalance(account: cash, balance: 500),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+KES 500.00'), findsOneWidget);
  });
}
