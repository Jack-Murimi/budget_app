import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  Stream<List<BudgetWithProgress>> watchBudgetsWithProgress({
    DateTime? asOf,
    bool includeArchived = false,
  }) {
    final now = asOf ?? DateTime.now();

    return _db
        .customSelect('SELECT 1', readsFrom: {_db.budgets, _db.transactions, _db.categories})
        .watch()
        .asyncMap((_) async {
      final budgetsQuery = _db.select(_db.budgets);
      if (!includeArchived) {
        budgetsQuery.where((b) => b.isArchived.equals(false));
      }
      final budgets = await budgetsQuery.get();
      final results = <BudgetWithProgress>[];

      for (final budget in budgets) {
        final (start, end) = _getPeriodWindow(budget.period, now);
        
        // Get all category IDs to match (parent + subcategories)
        final categoryIds = budget.categoryId == null 
            ? <int>[]
            : await _getCategoryAndSubcategories(budget.categoryId!);

        // Query transactions for this period
        final query = _db.select(_db.transactions).join([])
          ..where(_db.transactions.type.equals('expense'))
          ..where(_db.transactions.excludeFromBudget.equals(false))
          ..where(_db.transactions.transactionDate.isBiggerOrEqualValue(start))
          ..where(_db.transactions.transactionDate.isSmallerThanValue(end));

        if (categoryIds.isNotEmpty) {
          query.where(_db.transactions.categoryId.isIn(categoryIds));
        }

        final txns = await query
            .map((row) => row.readTable(_db.transactions))
            .get();

        final spent = txns.fold<double>(
          0.0,
          (sum, t) => sum + t.amount + t.transactionCost + t.fulizaFee,
        );

        // Get category info if needed
        String? categoryName;
        String? categoryColorHex;
        String? categoryIcon;

        if (budget.categoryId != null) {
          final category = await (_db.select(_db.categories)
                ..where((c) => c.id.equals(budget.categoryId!)))
              .getSingleOrNull();
          if (category != null) {
            categoryName = category.name;
            categoryColorHex = category.colorHex;
            categoryIcon = category.icon;
          }
        }

        results.add(BudgetWithProgress(
          budget: budget,
          spent: spent,
          categoryName: categoryName,
          categoryColorHex: categoryColorHex,
          categoryIcon: categoryIcon,
        ));
      }

      // Sort: overall budget first, then by name
      results.sort((a, b) {
        if (a.isOverall && !b.isOverall) return -1;
        if (!a.isOverall && b.isOverall) return 1;
        return a.name.compareTo(b.name);
      });

      return results;
    });
  }

  Stream<List<Transaction>> watchBudgetTransactions(
    Budget budget, {
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final (start, end) = _getPeriodWindow(budget.period, now);

    return _db
        .customSelect('SELECT 1', readsFrom: {_db.transactions})
        .watch()
        .asyncMap((_) async {
      final categoryIds = budget.categoryId == null
          ? <int>[]
          : await _getCategoryAndSubcategories(budget.categoryId!);

      final query = _db.select(_db.transactions)
        ..where((t) => t.type.equals('expense'))
        ..where((t) => t.excludeFromBudget.equals(false))
        ..where((t) => t.transactionDate.isBiggerOrEqualValue(start))
        ..where((t) => t.transactionDate.isSmallerThanValue(end))
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

      if (categoryIds.isNotEmpty) {
        query.where((t) => t.categoryId.isIn(categoryIds));
      }

      return query.get();
    });
  }

  Future<int> insertBudget(BudgetsCompanion budget) {
    return _db.into(_db.budgets).insert(budget);
  }

  Future<bool> updateBudget(BudgetsCompanion budget) async {
    final count = await (_db.update(_db.budgets)
          ..where((b) => b.id.equals(budget.id.value)))
        .write(budget);
    return count > 0;
  }

  Future<void> deleteBudget(int id) {
    return (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
  }

  Future<void> archiveBudget(int id, {bool archive = true}) {
    return (_db.update(_db.budgets)..where((b) => b.id.equals(id)))
        .write(BudgetsCompanion(isArchived: Value(archive)));
  }

  (DateTime, DateTime) _getPeriodWindow(String period, DateTime now) {
    switch (period) {
      case 'monthly':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start, end);
      case 'weekly':
        final weekday = now.weekday;
        final start = DateTime(now.year, now.month, now.day - (weekday - 1));
        final end = start.add(const Duration(days: 7));
        return (start, end);
      default:
        // For custom periods, use the budget's startDate and endDate
        // This is a simplified fallback
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start, end);
    }
  }

  Future<List<int>> _getCategoryAndSubcategories(int categoryId) async {
    final subcats = await (_db.select(_db.categories)
          ..where((c) => c.parentId.equals(categoryId)))
        .get();
    return [categoryId, ...subcats.map((c) => c.id)];
  }
}
