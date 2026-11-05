import 'dart:ffi';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/budgets/models/budget_model.dart';
import 'package:budget_app/features/budgets/repositories/budget_repository.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  }

  late AppDatabase db;
  late BudgetRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = BudgetRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetRepository', () {
    test('insert overall and category-specific budgets with proper ordering', () async {
      final food = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Food',
          colorHex: const Value('#FF0000'),
        ),
      );

      final overallId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Monthly Budget',
          amount: 50000.0,
          startDate: DateTime(2026, 11, 1),
        ),
      );

      final categoryId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food Budget',
          amount: 15000.0,
          categoryId: Value(food),
          startDate: DateTime(2026, 11, 1),
        ),
      );

      expect(overallId, greaterThan(0));
      expect(categoryId, greaterThan(0));

      final progressList = await repo.watchBudgetsWithProgress(asOf: DateTime(2026, 11, 15)).first;
      expect(progressList.length, 2);
      expect(progressList[0].isOverall, true);
      expect(progressList[0].name, 'Monthly Budget');
      expect(progressList[1].isOverall, false);
      expect(progressList[1].categoryId, food);
      expect(progressList[1].categoryName, 'Food');
      expect(progressList[1].categoryColorHex, '#FF0000');
    });

    test('watchBudgetsWithProgress emits updated progress when a new transaction is added', () async {
      final asOf = DateTime(2026, 11, 15);
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      final food = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Food'),
      );

      await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food Budget',
          amount: 10000.0,
          categoryId: Value(food),
          startDate: DateTime(2026, 11, 1),
        ),
      );

      final stream = repo.watchBudgetsWithProgress(asOf: asOf);

      final expectation = expectLater(
        stream,
        emitsInOrder([
          predicate<List<BudgetWithProgress>>(
            (list) => list.length == 1 && list.first.spent == 0.0,
          ),
          predicate<List<BudgetWithProgress>>(
            (list) => list.length == 1 && list.first.spent == 2550.0,
          ),
        ]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Groceries',
          amount: 2500.0,
          transactionCost: const Value(50.0),
          type: const Value('expense'),
          categoryId: Value(food),
          transactionDate: DateTime(2026, 11, 5),
          accountId: Value(account),
        ),
      );

      await expectation;
    });

    test('watchBudgetTransactions streams matching transactions and emits updates', () async {
      final asOf = DateTime(2026, 11, 15);
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      final food = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Food'),
      );
      final transport = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Transport'),
      );

      final budgetId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food Budget',
          amount: 10000.0,
          categoryId: Value(food),
          startDate: DateTime(2026, 11, 1),
        ),
      );
      final budget = await (db.select(db.budgets)..where((b) => b.id.equals(budgetId))).getSingle();

      // In-period Food expense (should match)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Groceries',
          amount: 2000.0,
          type: const Value('expense'),
          categoryId: Value(food),
          transactionDate: DateTime(2026, 11, 5),
          accountId: Value(account),
        ),
      );

      // In-period Transport expense (should NOT match)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Taxi',
          amount: 800.0,
          type: const Value('expense'),
          categoryId: Value(transport),
          transactionDate: DateTime(2026, 11, 6),
          accountId: Value(account),
        ),
      );

      // Excluded expense (should NOT match)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Gift Dinner',
          amount: 1000.0,
          type: const Value('expense'),
          categoryId: Value(food),
          transactionDate: DateTime(2026, 11, 7),
          excludeFromBudget: const Value(true),
          accountId: Value(account),
        ),
      );

      // Out-of-period expense (should NOT match)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'October Food',
          amount: 500.0,
          type: const Value('expense'),
          categoryId: Value(food),
          transactionDate: DateTime(2026, 10, 20),
          accountId: Value(account),
        ),
      );

      final stream = repo.watchBudgetTransactions(budget, asOf: asOf);

      final expectation = expectLater(
        stream,
        emitsInOrder([
          predicate<List<Transaction>>(
            (txns) => txns.length == 1 && txns.first.header == 'Groceries',
          ),
          predicate<List<Transaction>>(
            (txns) =>
                txns.length == 2 &&
                txns.first.header == 'Dinner' &&
                txns.last.header == 'Groceries',
          ),
        ]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Insert another matching transaction (Dinner on 11/12, more recent than 11/5)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Dinner',
          amount: 1500.0,
          type: const Value('expense'),
          categoryId: Value(food),
          transactionDate: DateTime(2026, 11, 12),
          accountId: Value(account),
        ),
      );

      await expectation;
    });

    test('expense in subcategory counts towards parent category budget', () async {
      final asOf = DateTime(2026, 11, 15);
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      final parentCat = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Food & Dining'),
      );
      final subCat = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Groceries',
          parentId: Value(parentCat),
        ),
      );

      final budgetId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food Budget',
          amount: 10000.0,
          categoryId: Value(parentCat),
          startDate: DateTime(2026, 11, 1),
        ),
      );
      final budget = await (db.select(db.budgets)..where((b) => b.id.equals(budgetId))).getSingle();

      // Add expense to subcategory
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Carrefour Groceries',
          amount: 3200.0,
          transactionCost: const Value(50.0),
          type: const Value('expense'),
          categoryId: Value(subCat),
          transactionDate: DateTime(2026, 11, 10),
          accountId: Value(account),
        ),
      );

      // Verify watchBudgetsWithProgress counts subcategory transaction towards parent category budget
      final progressList = await repo.watchBudgetsWithProgress(asOf: asOf).first;
      expect(progressList.length, 1);
      final progress = progressList.first;
      expect(progress.spent, 3250.0);
      expect(progress.remaining, 6750.0);
      expect(progress.categoryName, 'Food & Dining');

      // Verify watchBudgetTransactions includes subcategory transaction
      final txns = await repo.watchBudgetTransactions(budget, asOf: asOf).first;
      expect(txns.length, 1);
      expect(txns.first.header, 'Carrefour Groceries');
      expect(txns.first.categoryId, subCat);
    });

    test('updateBudget updates budget and returns true', () async {
      final budgetId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Monthly Budget',
          amount: 50000.0,
          startDate: DateTime(2026, 11, 1),
        ),
      );

      final updated = await repo.updateBudget(
        BudgetsCompanion(
          id: Value(budgetId),
          name: const Value('Updated Budget'),
          amount: const Value(60000.0),
        ),
      );
      expect(updated, true);

      final saved = await (db.select(db.budgets)..where((b) => b.id.equals(budgetId))).getSingle();
      expect(saved.name, 'Updated Budget');
      expect(saved.amount, 60000.0);
      expect(saved.startDate, DateTime(2026, 11, 1));
    });

    test('deleteBudget deletes budget', () async {
      final budgetId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Monthly Budget',
          amount: 50000.0,
          startDate: DateTime(2026, 11, 1),
        ),
      );

      await repo.deleteBudget(budgetId);

      final budgets = await db.select(db.budgets).get();
      expect(budgets.isEmpty, true);
    });

    test('archiveBudget toggles archive status', () async {
      final budgetId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Budget To Archive',
          amount: 5000.0,
          startDate: DateTime(2026, 11, 1),
        ),
      );

      await repo.archiveBudget(budgetId, archive: true);

      final active = await repo.watchBudgetsWithProgress(includeArchived: false).first;
      expect(active.isEmpty, true);

      final all = await repo.watchBudgetsWithProgress(includeArchived: true).first;
      expect(all.length, 1);
      expect(all.first.isArchived, true);
    });

    test('over-budget calculation and progress flags', () async {
      final asOf = DateTime(2026, 11, 15);
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      final food = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Food'),
      );

      await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food Budget',
          amount: 5000.0,
          categoryId: Value(food),
          startDate: DateTime(2026, 11, 1),
        ),
      );

      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Big Feast',
          amount: 6000.0,
          fulizaFee: const Value(40.0),
          type: const Value('expense'),
          categoryId: Value(food),
          transactionDate: DateTime(2026, 11, 10),
          accountId: Value(account),
        ),
      );

      final progressList = await repo.watchBudgetsWithProgress(asOf: asOf).first;
      expect(progressList.length, 1);
      final bp = progressList.first;

      expect(bp.spent, 6040.0);
      expect(bp.remaining, -1040.0);
      expect(bp.isOverBudget, true);
      expect(bp.progress, 1.0); // clamped to 1.0
      expect(bp.percentage, closeTo(120.8, 0.1));
    });
  });
}
