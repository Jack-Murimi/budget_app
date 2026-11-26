import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/budgets/models/budget_model.dart';
import 'package:budget_app/features/budgets/repositories/budget_repository.dart';

void main() {

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

    test('custom period uses startDate and inclusive endDate', () async {
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Holiday Budget',
          amount: 10000.0,
          period: const Value('custom'),
          startDate: DateTime(2026, 12, 10),
          endDate: Value(DateTime(2026, 12, 20)),
        ),
      );

      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Before window',
          amount: 500.0,
          type: const Value('expense'),
          transactionDate: DateTime(2026, 12, 9, 23, 59),
          accountId: Value(account),
        ),
      );
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'On end date',
          amount: 1200.0,
          type: const Value('expense'),
          transactionDate: DateTime(2026, 12, 20, 18, 0),
          accountId: Value(account),
        ),
      );
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'After end date',
          amount: 700.0,
          type: const Value('expense'),
          transactionDate: DateTime(2026, 12, 21, 0, 1),
          accountId: Value(account),
        ),
      );

      final progress = await repo
          .watchBudgetsWithProgress(asOf: DateTime(2026, 12, 15))
          .first;
      expect(progress.single.spent, 1200.0);
    });

    test('rollover carries over unused amount from previous period only when eligible', () async {
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Eligible Rollover',
          amount: 5000.0,
          period: const Value('monthly'),
          startDate: DateTime(2026, 10, 1),
          rollover: const Value(true),
        ),
      );
      await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Brand New Rollover',
          amount: 4000.0,
          period: const Value('monthly'),
          startDate: DateTime(2026, 11, 5),
          rollover: const Value(true),
        ),
      );

      // Spent 3000 in October -> 2000 unspent rolls over to Eligible in November
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Oct Spend',
          amount: 3000.0,
          type: const Value('expense'),
          transactionDate: DateTime(2026, 10, 15),
          accountId: Value(account),
        ),
      );

      final list = await repo
          .watchBudgetsWithProgress(asOf: DateTime(2026, 11, 15))
          .first;
      final eligible = list.firstWhere((b) => b.name == 'Eligible Rollover');
      final brandNew = list.firstWhere((b) => b.name == 'Brand New Rollover');

      expect(eligible.rolloverAmount, 2000.0);
      expect(eligible.amount, 7000.0);
      expect(eligible.remaining, 7000.0);

      expect(brandNew.rolloverAmount, 0.0);
      expect(brandNew.amount, 4000.0);
    });

    test('multi-category budget combines subcategories from different parents', () async {
      final asOf = DateTime(2026, 11, 15);
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      final foodParent = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Food'),
      );
      final eatingOut = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Eating Out',
          parentId: Value(foodParent),
        ),
      );
      final snacks = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Snacks',
          parentId: Value(foodParent),
        ),
      );
      final giftsParent = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Gifts'),
      );
      final friendTreats = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Treats',
          parentId: Value(giftsParent),
        ),
      );

      final budgetId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Social & Snacks',
          amount: 10000.0,
          startDate: DateTime(2026, 11, 1),
        ),
        categoryIds: [eatingOut, friendTreats],
      );
      final budget = await (db.select(db.budgets)
            ..where((b) => b.id.equals(budgetId)))
          .getSingle();

      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Lunch',
          amount: 1200.0,
          type: const Value('expense'),
          categoryId: Value(eatingOut),
          transactionDate: DateTime(2026, 11, 4),
          accountId: Value(account),
        ),
      );
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Coffee for Friend',
          amount: 600.0,
          type: const Value('expense'),
          categoryId: Value(friendTreats),
          transactionDate: DateTime(2026, 11, 5),
          accountId: Value(account),
        ),
      );
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Other Snack',
          amount: 900.0,
          type: const Value('expense'),
          categoryId: Value(snacks),
          transactionDate: DateTime(2026, 11, 6),
          accountId: Value(account),
        ),
      );

      final progress =
          (await repo.watchBudgetsWithProgress(asOf: asOf).first).single;
      expect(progress.isOverall, false);
      expect(progress.isMultiCategory, true);
      expect(progress.spent, 1800.0);
      expect(progress.categorySummary, 'Eating Out · Treats');

      final txns = await repo.watchBudgetTransactions(budget, asOf: asOf).first;
      expect(
        txns.map((t) => t.header),
        equals(['Coffee for Friend', 'Lunch']),
      );
    });

    test('multi-category budget combines parent + subcategory without double-counting overlap',
        () async {
      final asOf = DateTime(2026, 11, 15);
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      final foodParent = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Food'),
      );
      final groceries = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Groceries',
          parentId: Value(foodParent),
        ),
      );
      final miscParent = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Miscellaneous'),
      );
      final impulse = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Impulse',
          parentId: Value(miscParent),
        ),
      );

      final budgetId = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Food & Impulse',
          amount: 12000.0,
          startDate: DateTime(2026, 11, 1),
        ),
        // Intentionally include overlapping parent + child to verify deduplication.
        categoryIds: [foodParent, groceries, impulse],
      );
      final budget = await (db.select(db.budgets)
            ..where((b) => b.id.equals(budgetId)))
          .getSingle();

      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Naivas',
          amount: 2500.0,
          type: const Value('expense'),
          categoryId: Value(groceries),
          transactionDate: DateTime(2026, 11, 3),
          accountId: Value(account),
        ),
      );
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Gadget',
          amount: 1500.0,
          type: const Value('expense'),
          categoryId: Value(impulse),
          transactionDate: DateTime(2026, 11, 4),
          accountId: Value(account),
        ),
      );

      final progress =
          (await repo.watchBudgetsWithProgress(asOf: asOf).first).single;
      expect(progress.spent, 4000.0);

      final txns = await repo.watchBudgetTransactions(budget, asOf: asOf).first;
      expect(txns, hasLength(2));
    });

    test('updateBudget transitions between overall, multi, single, and deleteBudget cascades',
        () async {
      final catA = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Cat A'),
      );
      final catB = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Cat B'),
      );

      final id = await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Flexible Budget',
          amount: 5000.0,
          startDate: DateTime(2026, 11, 1),
        ),
      );
      expect(await repo.getBudgetCategoryIds(id), isEmpty);

      // overall -> multi
      await repo.updateBudget(
        BudgetsCompanion(id: Value(id)),
        categoryIds: [catA, catB],
      );
      expect(await repo.getBudgetCategoryIds(id), unorderedEquals([catA, catB]));

      // multi -> single
      await repo.updateBudget(
        BudgetsCompanion(id: Value(id)),
        categoryIds: [catB],
      );
      expect(await repo.getBudgetCategoryIds(id), equals([catB]));

      // single -> overall
      await repo.updateBudget(
        BudgetsCompanion(id: Value(id)),
        categoryIds: const [],
      );
      expect(await repo.getBudgetCategoryIds(id), isEmpty);
      final savedOverall = await (db.select(db.budgets)
            ..where((b) => b.id.equals(id)))
          .getSingle();
      expect(savedOverall.categoryId, isNull);

      // multi -> delete cascades
      await repo.updateBudget(
        BudgetsCompanion(id: Value(id)),
        categoryIds: [catA, catB],
      );
      expect(await repo.getBudgetCategoryIds(id), hasLength(2));
      await repo.deleteBudget(id);
      expect(await db.select(db.budgetCategories).get(), isEmpty);
    });

    test('categoryBreakdown aggregates per-category spend, rolls up unselected subcategories, and sorts descending',
        () async {
      final asOf = DateTime(2026, 11, 15);
      final account = await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'M-Pesa'),
      );
      final treats = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Treats',
          colorHex: const Value('#E91E63'),
        ),
      );
      final treatsCoffee = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Coffee Treats',
          parentId: Value(treats),
          colorHex: const Value('#F06292'),
        ),
      );
      final misc = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Miscellaneous',
          colorHex: const Value('#9C27B0'),
        ),
      );
      final snacks = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          name: 'Snacks',
          colorHex: const Value('#FF9800'),
        ),
      );

      await repo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Discretionary',
          amount: 10000.0,
          startDate: DateTime(2026, 11, 1),
        ),
        categoryIds: [treats, misc, snacks],
      );

      // Subcategory rolls up into selected parent Treats
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Artcaffe',
          amount: 1200.0,
          transactionCost: const Value(20.0),
          type: const Value('expense'),
          categoryId: Value(treatsCoffee),
          transactionDate: DateTime(2026, 11, 2),
          accountId: Value(account),
        ),
      );
      // Direct expense on Misc (largest total)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Phone Cable',
          amount: 2000.0,
          type: const Value('expense'),
          categoryId: Value(misc),
          transactionDate: DateTime(2026, 11, 3),
          accountId: Value(account),
        ),
      );
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          header: 'Adapter',
          amount: 500.0,
          type: const Value('expense'),
          categoryId: Value(misc),
          transactionDate: DateTime(2026, 11, 4),
          accountId: Value(account),
        ),
      );

      final progress =
          (await repo.watchBudgetsWithProgress(asOf: asOf).first).single;
      expect(progress.categoryBreakdown, hasLength(3));
      expect(progress.categoryBreakdown[0].category.id, misc);
      expect(progress.categoryBreakdown[0].spent, 2500.0);
      expect(progress.categoryBreakdown[0].transactionCount, 2);
      expect(progress.categoryBreakdown[1].category.id, treats);
      expect(progress.categoryBreakdown[1].spent, 1220.0);
      expect(progress.categoryBreakdown[1].transactionCount, 1);
      expect(progress.categoryBreakdown[2].category.id, snacks);
      expect(progress.categoryBreakdown[2].spent, 0.0);
      expect(progress.categoryBreakdown[2].transactionCount, 0);
    });
  });
}
