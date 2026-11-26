import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/repositories/debt_repository.dart';
import 'package:budget_app/features/debts/screens/debts_screen.dart';
import 'package:budget_app/features/debts/screens/loan_detail_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

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
      child: const MaterialApp(home: DebtsScreen()),
    );
  }

  testWidgets('renders horizontal pills and switches tabs and FAB labels',
      (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Loans & Debts'), findsOneWidget);
    expect(find.text('They owe me'), findsOneWidget);
    expect(find.text('I owe them'), findsOneWidget);
    expect(find.text('Lend money'), findsOneWidget);
    expect(find.text('No loans given'), findsOneWidget);

    // Switch to "I owe them"
    await tester.tap(find.text('I owe them'));
    await tester.pumpAndSettle();

    expect(find.text('Add debt'), findsOneWidget);
    expect(find.text('No debts owed'), findsOneWidget);

    // Switch back to "They owe me"
    await tester.tap(find.text('They owe me'));
    await tester.pumpAndSettle();

    expect(find.text('Lend money'), findsOneWidget);
  });

  testWidgets('shows lent loan and navigates to LoanDetailScreen',
      (tester) async {
    final repo = DebtRepository(db);
    final debtId = await repo.create(
      direction: 'lent',
      counterparty: 'Alice Smith',
      principal: 5000,
      interest: 0,
      product: 'personal',
    );

    final debt =
        await (db.select(db.debts)..where((row) => row.id.equals(debtId)))
            .getSingle();

    await repo.repay(debt: debt, amount: 2000);

    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    // Person card should be visible
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('1 repayment'), findsOneWidget);

    // Tap to open LoanDetailScreen
    await tester.tap(find.text('Alice Smith'));
    await tester.pumpAndSettle();

    expect(find.byType(LoanDetailScreen), findsOneWidget);
    expect(find.text('Total lent'), findsOneWidget);
    expect(find.text('Repaid'), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
    expect(find.text('Record repayment'), findsOneWidget);
    expect(find.text('Loan disbursed'), findsOneWidget);
    expect(find.text('Repayment'), findsOneWidget);

    // Tap record repayment and verify dialog opens
    await tester.tap(find.text('Record repayment'));
    await tester.pumpAndSettle();
    expect(find.text('Repay Alice Smith'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('shows settled loan with badge and separated section',
      (tester) async {
    final repo = DebtRepository(db);
    final debtId = await repo.create(
      direction: 'lent',
      counterparty: 'Bob Builder',
      principal: 1000,
      interest: 0,
      product: 'personal',
    );
    final debt =
        await (db.select(db.debts)..where((row) => row.id.equals(debtId)))
            .getSingle();
    await repo.repay(debt: debt, amount: 1000);

    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Bob Builder'), findsOneWidget);
    expect(find.text('Settled'), findsWidgets);
  });

  testWidgets('shows borrowed debt on borrowed tab', (tester) async {
    final repo = DebtRepository(db);
    await repo.create(
      direction: 'borrowed',
      counterparty: 'Bank Loan',
      principal: 15000,
      interest: 500,
      product: 'mshwari',
    );

    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    // Default tab is "They owe me" - should not show Bank Loan
    expect(find.text('Bank Loan'), findsNothing);

    // Switch to "I owe them"
    await tester.tap(find.text('I owe them'));
    await tester.pumpAndSettle();

    expect(find.text('Bank Loan'), findsOneWidget);
    expect(find.text('Repay'), findsOneWidget);

    // Tapping a borrowed debt opens LoanDetailScreen with Total borrowed
    await tester.tap(find.text('Bank Loan'));
    await tester.pumpAndSettle();

    expect(find.byType(LoanDetailScreen), findsOneWidget);
    expect(find.text('Total borrowed'), findsOneWidget);
  });

  testWidgets('creating debt with explicit account picker and editing/deleting via LoanDetailScreen',
      (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lend money'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Person (borrower)'),
      'Grace',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Principal (KES)'),
      '2000',
    );
    // Account picker is visible and selectable
    expect(find.text('Account'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Grace'), findsOneWidget);

    // Open LoanDetailScreen and edit
    await tester.tap(find.text('Grace'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit debt'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Person or lender').evaluate().isNotEmpty
          ? find.widgetWithText(TextFormField, 'Person or lender')
          : find.widgetWithText(TextFormField, 'Person (borrower)'),
      'Grace Updated',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Grace Updated'), findsOneWidget);

    // Delete debt cleanly
    await tester.tap(find.byTooltip('Delete debt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(LoanDetailScreen), findsNothing);
    expect(await db.select(db.debts).get(), isEmpty);
  });
}
