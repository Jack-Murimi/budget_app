import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/repositories/debt_repository.dart';
import 'package:budget_app/features/debts/screens/loan_detail_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  late AppDatabase db;
  late DebtRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = DebtRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('LoanDetailScreen records repayment, deletes repayment, edits debt, and deletes debt',
      (tester) async {
    final accountId = await db
        .into(db.accounts)
        .insert(AccountsCompanion.insert(name: 'M-Pesa'));
    final debtId = await repo.create(
      direction: 'borrowed',
      counterparty: 'KCB M-Pesa',
      principal: 5000,
      interest: 400,
      product: 'personal',
      accountId: accountId,
      dueDate: DateTime(2026, 12, 31),
    );
    final initialItem =
        (await repo.watchAll().first).firstWhere((d) => d.debt.id == debtId);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

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
                      builder: (_) => LoanDetailScreen(item: initialItem),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('KCB M-Pesa'), findsOneWidget);
    expect(find.text('Total borrowed'), findsOneWidget);
    expect(find.text('Loan received'), findsOneWidget);
    expect(find.text('KES 5,400.00'), findsOneWidget);
    expect(find.textContaining('Interest/Fees: KES 400.00'), findsOneWidget);
    expect(find.textContaining('Due:'), findsOneWidget);

    // Record repayment of 1400 -> outstanding becomes 4000
    await tester.tap(find.text('Record repayment'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '1400');
    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();

    expect(find.text('Repayment'), findsOneWidget);
    expect(find.text('KES 4,000.00'), findsOneWidget);
    expect(find.text('KES 1,400.00'), findsOneWidget);

    // Delete repayment -> outstanding restores to 5400
    await tester.tap(find.byTooltip('Delete repayment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Repayment deleted'), findsOneWidget);
    expect(find.text('KES 5,400.00'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(LoanDetailScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    // Edit debt counterparty
    await tester.tap(find.byTooltip('Edit debt'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Person or lender'),
      'KCB Bank',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Debt updated'), findsOneWidget);
    expect(find.text('KCB Bank'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(LoanDetailScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    // Delete debt -> pops LoanDetailScreen and removes DB row
    await tester.tap(find.byTooltip('Delete debt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(LoanDetailScreen), findsNothing);
    expect(await db.select(db.debts).get(), isEmpty);
  });

  testWidgets('LoanDetailScreen shows lent labels when direction is lent',
      (tester) async {
    final debtId = await repo.create(
      direction: 'lent',
      counterparty: 'Wanjiku',
      principal: 3000,
      interest: 0,
      product: 'personal',
    );
    final item =
        (await repo.watchAll().first).firstWhere((d) => d.debt.id == debtId);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: LoanDetailScreen(item: item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total lent'), findsOneWidget);
    expect(find.text('Loan disbursed'), findsOneWidget);
    expect(find.text('KES 3,000.00'), findsNWidgets(2));
  });
}
