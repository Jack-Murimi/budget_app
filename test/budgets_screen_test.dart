import 'dart:ffi';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/main.dart';
import 'package:sqlite3/open.dart';
import 'package:budget_app/features/budgets/screens/budgets_screen.dart';
import 'package:budget_app/shared/theme/app_theme.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  }

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const BudgetsScreen(),
      ),
    );
  }

  Future<void> pumpBudgetsScreen(WidgetTester tester, ProviderContainer container) async {
    await tester.pumpWidget(buildTestApp(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  testWidgets('BudgetsScreen renders with no budgets', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpBudgetsScreen(tester, container);

    expect(find.text('No budgets set yet'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Amount (KES) *'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('BudgetsScreen shows overall budget card', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    // Insert a budget
    final now = DateTime(2026, 11, 1);
    await db.into(db.budgets).insert(
      BudgetsCompanion.insert(
        name: 'Monthly Budget',
        amount: 50000.0,
        period: const Value('monthly'),
        startDate: now,
      ),
    );

    await pumpBudgetsScreen(tester, container);

    expect(find.text('Overall Budget'), findsOneWidget);
    expect(find.text('Create Budget'), findsNothing);
  });

  testWidgets('BudgetsScreen shows over-budget indicator when spent > amount', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    // Insert a category
    final foodId = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'Food',
        icon: const Value('restaurant'),
        colorHex: const Value('#FF0000'),
      ),
    );

    // Insert a budget with low limit
    final now = DateTime(2026, 11, 1);
    await db.into(db.budgets).insert(
      BudgetsCompanion.insert(
        name: 'Food Budget',
        amount: 1000.0,
        categoryId: Value(foodId),
        period: const Value('monthly'),
        startDate: now,
      ),
    );

    // Insert an expense that exceeds the budget
    final accountId = await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        name: 'M-Pesa',
        colorHex: const Value('#1B5E20'),
      ),
    );

    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        header: 'Big Shopping',
        amount: 2000.0,
        type: const Value('expense'),
        categoryId: Value(foodId),
        transactionDate: DateTime(2026, 11, 10),
        accountId: Value(accountId),
      ),
    );

    await pumpBudgetsScreen(tester, container);

    expect(find.text('Over budget'), findsNothing);
    expect(find.textContaining('Over budget by'), findsOneWidget);
  });

  testWidgets('BudgetsScreen creates budget via FAB', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await pumpBudgetsScreen(tester, container);

    // Tap FAB to open dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify dialog contents
    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Amount (KES) *'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);

    // Fill in form
    await tester.enterText(find.widgetWithText(TextField, 'Name *'), 'Test Budget');
    await tester.enterText(find.widgetWithText(TextField, 'Amount (KES) *'), '10000');

    // Select monthly period
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monthly').last);
    await tester.pumpAndSettle();

    // Save budget
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify budget was created
    final budgets = await db.select(db.budgets).get();
    expect(budgets.length, 1);
    expect(budgets[0].name, 'Test Budget');
    expect(budgets[0].amount, 10000.0);
  });
}
