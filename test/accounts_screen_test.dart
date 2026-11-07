import 'dart:ffi';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/screens/accounts_screen.dart';
import 'package:budget_app/main.dart';
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
}
