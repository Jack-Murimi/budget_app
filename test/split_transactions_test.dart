import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/add_transaction/screens/add_transaction_screen.dart';
import 'package:budget_app/features/budgets/repositories/budget_repository.dart';
import 'package:budget_app/features/transactions/models/transaction_model.dart';
import 'package:budget_app/features/transactions/models/transaction_split_allocator.dart';
import 'package:budget_app/features/transactions/repositories/transaction_repository.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group('TransactionSplitAllocator', () {
    test('distributes uneven fees across splits with exact integer cent conservation',
        () {
      // KES 4,500 split into 3,000 + 1,000 + 500 with KES 23 fee (2300 cents)
      final allocs = TransactionSplitAllocator.allocateExpenseCents(
        fallbackCategoryId: 1,
        amountCents: 450000,
        feeCents: 2300,
        splits: const [
          (categoryId: 10, amountCents: 300000),
          (categoryId: 20, amountCents: 100000),
          (categoryId: 30, amountCents: 50000),
        ],
      );

      expect(allocs, hasLength(3));
      final totalAllocated = allocs.fold<int>(0, (s, e) => s + e.cents);
      expect(totalAllocated, 452300);
      expect(allocs[0].categoryId, 10);
      expect(allocs[0].cents, 301533);
      expect(allocs[1].categoryId, 20);
      expect(allocs[1].cents, 100511);
      expect(allocs[2].categoryId, 30);
      expect(allocs[2].cents, 50256);
    });

    test('falls back to transaction category when splits are empty', () {
      final allocs = TransactionSplitAllocator.allocateExpenseCents(
        fallbackCategoryId: 7,
        amountCents: 100000,
        feeCents: 1500,
        splits: const [],
      );

      expect(allocs, hasLength(1));
      expect(allocs.single.categoryId, 7);
      expect(allocs.single.cents, 101500);
    });
  });

  group('Split Transactions persistence & budgets', () {
    late AppDatabase db;
    late TransactionRepository txnRepo;
    late BudgetRepository budgetRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      txnRepo = TransactionRepository(db);
      budgetRepo = BudgetRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertWithSplits, updateWithSplits, watchAll hydration & cascade delete',
        () async {
      final cats = await db.select(db.categories).get();
      final expenseCats =
          cats.where((c) => c.transactionType == 'expense').toList();
      final catA = expenseCats[0];
      final catB = expenseCats[1];
      final account = await db.select(db.accounts).get();

      final id = await txnRepo.insertWithSplits(
        TransactionsCompanion.insert(
          header: 'Naivas Receipt',
          amount: 4500.0,
          transactionCost: const Value(23.0),
          type: const Value('expense'),
          transactionDate: DateTime(2026, 11, 20),
          accountId: Value(account.first.id),
        ),
        [
          TransactionSplitModel(
            categoryId: catA.id,
            amount: 3000.0,
            note: 'Groceries',
          ),
          TransactionSplitModel(
            categoryId: catB.id,
            amount: 1500.0,
            note: 'Cleaning',
          ),
        ],
      );
      expect(id, isNotNull);

      final hydrated = (await txnRepo.watchAll().first).single;
      expect(hydrated.isSplit, isTrue);
      expect(hydrated.categoryId, catA.id);
      expect(hydrated.splits, hasLength(2));
      expect(hydrated.splits[0].amount, 3000.0);
      expect(hydrated.splits[1].amount, 1500.0);

      // Update splits (and verify replacement)
      await txnRepo.updateWithSplits(
        TransactionsCompanion(
          id: Value(id!),
          amount: const Value(4500.0),
        ),
        [
          TransactionSplitModel(categoryId: catA.id, amount: 2500.0),
          TransactionSplitModel(categoryId: catB.id, amount: 2000.0),
        ],
      );
      final updatedSplits = await txnRepo.getSplitsForTransaction(id);
      expect(updatedSplits.map((s) => s.amount), equals([2500.0, 2000.0]));

      // Deleting transaction cascades transaction_splits
      await txnRepo.delete(id);
      expect(await db.select(db.transactionSplits).get(), isEmpty);
    });

    test('BudgetRepository attributes split slices accurately without double-counting',
        () async {
      final now = DateTime(2026, 11, 15);
      final monthStart = DateTime(2026, 11, 1);
      final foodId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: 'Food Split Test',
              colorHex: const Value('#4CAF50'),
            ),
          );
      final houseId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: 'Household Split Test',
              colorHex: const Value('#2196F3'),
            ),
          );
      final accounts = await db.select(db.accounts).get();

      final overallId = await budgetRepo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Overall',
          amount: 10000.0,
          startDate: monthStart,
        ),
      );
      final foodBudgetId = await budgetRepo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food Limit',
          amount: 5000.0,
          startDate: monthStart,
        ),
        categoryIds: [foodId],
      );
      final houseBudgetId = await budgetRepo.insertBudget(
        BudgetsCompanion.insert(
          name: 'House Limit',
          amount: 5000.0,
          startDate: monthStart,
        ),
        categoryIds: [houseId],
      );
      final combinedId = await budgetRepo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food + House',
          amount: 8000.0,
          startDate: monthStart,
        ),
        categoryIds: [foodId, houseId],
      );

      // KES 4,500 + KES 30 fee split 3,000 Food / 1,500 House => fee splits 20 / 10
      await txnRepo.insertWithSplits(
        TransactionsCompanion.insert(
          header: 'Naivas Split',
          amount: 4500.0,
          transactionCost: const Value(30.0),
          type: const Value('expense'),
          transactionDate: now,
          accountId: Value(accounts.first.id),
        ),
        [
          TransactionSplitModel(categoryId: foodId, amount: 3000.0),
          TransactionSplitModel(categoryId: houseId, amount: 1500.0),
        ],
      );

      final budgets = await budgetRepo.watchBudgetsWithProgress(asOf: now).first;
      final overall = budgets.firstWhere((b) => b.id == overallId);
      final foodB = budgets.firstWhere((b) => b.id == foodBudgetId);
      final houseB = budgets.firstWhere((b) => b.id == houseBudgetId);
      final combinedB = budgets.firstWhere((b) => b.id == combinedId);

      expect(overall.spent, 4530.0);
      expect(foodB.spent, 3020.0);
      expect(houseB.spent, 1510.0);
      expect(combinedB.spent, 4530.0);
      expect(combinedB.categoryBreakdown, hasLength(2));
      expect(combinedB.categoryBreakdown[0].category.id, foodId);
      expect(combinedB.categoryBreakdown[0].spent, 3020.0);
      expect(combinedB.categoryBreakdown[0].transactionCount, 1);
      expect(combinedB.categoryBreakdown[1].category.id, houseId);
      expect(combinedB.categoryBreakdown[1].spent, 1510.0);
      expect(combinedB.categoryBreakdown[1].transactionCount, 1);
    });
  });

  testWidgets('TransactionForm validates split balance, fills remaining, and saves splits',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    addTearDown(db.close);

    final cat1Id = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Split Food Leaf',
            transactionType: const Value('expense'),
            sortOrder: const Value(-10),
          ),
        );
    final cat2Id = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Split House Leaf',
            transactionType: const Value('expense'),
            sortOrder: const Value(-9),
          ),
        );
    final cats = await db.select(db.categories).get();
    final cat1 = cats.firstWhere((c) => c.id == cat1Id);
    final cat2 = cats.firstWhere((c) => c.id == cat2Id);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AddTransactionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Enter amount (4500) and title ('Naivas Split')
    await tester.enterText(
      find.byType(TextFormField).first,
      '4500',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title *'),
      'Naivas Split',
    );

    // Enable Split across categories
    final splitSwitch = find.widgetWithText(
      SwitchListTile,
      'Split across categories',
    );
    await tester.ensureVisible(splitSwitch);
    await tester.tap(splitSwitch);
    await tester.pumpAndSettle();

    expect(find.text('KES 4,500.00 left to assign'), findsOneWidget);

    // Pick category for row 0 and row 1
    final chooseCatFinder = find.text('Choose a category');
    await tester.ensureVisible(chooseCatFinder.first);
    await tester.tap(chooseCatFinder.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(cat1.name).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(chooseCatFinder.first);
    await tester.tap(chooseCatFinder.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(cat2.name).first);
    await tester.pumpAndSettle();

    // Enter unbalanced amount in row 0 -> verify save blocks with validation toast
    await tester.enterText(
      find.byKey(const ValueKey('split_amount_0')),
      '3000',
    );
    await tester.pumpAndSettle();
    expect(find.text('KES 1,500.00 left to assign'), findsOneWidget);

    final saveBtn = find.widgetWithText(FilledButton, 'Save Transaction');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();
    expect(
      find.text('Split amounts must equal the transaction total'),
      findsOneWidget,
    );
    expect(await db.select(db.transactions).get(), isEmpty);
    ScaffoldMessenger.of(tester.element(find.byType(AddTransactionScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    // Use Fill remaining -> balances to 4,500.00 and saves splits cleanly
    final fillChip = find.widgetWithText(ActionChip, 'Fill remaining');
    await tester.ensureVisible(fillChip);
    await tester.tap(fillChip);
    await tester.pumpAndSettle();
    expect(find.text('Split balanced (KES 4,500.00)'), findsOneWidget);

    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    final savedTxns = await db.select(db.transactions).get();
    expect(savedTxns, hasLength(1));
    final savedSplits = await db.select(db.transactionSplits).get();
    expect(savedSplits, hasLength(2));
    expect(savedSplits[0].categoryId, cat1.id);
    expect(savedSplits[0].amount, 3000.0);
    expect(savedSplits[1].categoryId, cat2.id);
    expect(savedSplits[1].amount, 1500.0);
  });
}
