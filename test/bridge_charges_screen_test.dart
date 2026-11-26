import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/repositories/debt_repository.dart';
import 'package:budget_app/features/debts/screens/bridge_charges_screen.dart';
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

  Widget buildTestApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: BridgeChargesScreen()),
    );
  }

  testWidgets('renders empty state when no Bridge loans exist', (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Bridge Loan Charges'), findsOneWidget);
    expect(find.text('No Bridge loans recorded yet'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Last month'), findsOneWidget);
    expect(find.text('All time'), findsOneWidget);
  });

  testWidgets('displays total charges and loan breakdown for Bridge loans',
      (tester) async {
    final accountId = await db
        .into(db.accounts)
        .insert(AccountsCompanion.insert(name: 'M-Pesa'));

    final debtId = await repo.create(
      direction: 'borrowed',
      counterparty: 'Bridge',
      principal: 600,
      interest: 0,
      product: 'bridge',
      disbursementShortfall: 30,
      accountId: accountId,
    );

    final debt = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();

    await repo.repay(
      debt: debt,
      amount: 603.68,
      accountId: accountId,
      paymentDate: DateTime.now(),
    );

    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Bridge Loan Charges'), findsOneWidget);
    expect(find.text('Total Bridge charges'), findsOneWidget);
    // Total charges = 30 + 3.68 = 33.68
    expect(find.text('KES 33.68'), findsWidgets);
    expect(find.text('Settled'), findsOneWidget);
  });

  testWidgets('partially repaid active Bridge loan shows Last payment instead of Settled',
      (tester) async {
    final accountId = await db
        .into(db.accounts)
        .insert(AccountsCompanion.insert(name: 'M-Pesa'));

    final debtId = await repo.create(
      direction: 'borrowed',
      counterparty: 'Bridge',
      principal: 1000,
      interest: 0,
      product: 'bridge',
      disbursementShortfall: 50,
      accountId: accountId,
    );
    final debt = await (db.select(db.debts)
          ..where((row) => row.id.equals(debtId)))
        .getSingle();

    await repo.repay(
      debt: debt,
      amount: 400,
      accountId: accountId,
      paymentDate: DateTime.now(),
    );

    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.textContaining('Last payment:'), findsOneWidget);
    expect(find.textContaining('Settled:'), findsNothing);
  });
}
