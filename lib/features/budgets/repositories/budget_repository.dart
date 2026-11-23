import 'dart:math' as math;

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../models/budget_model.dart';
import '../utils/budget_period_helper.dart';

class BudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  Stream<List<BudgetWithProgress>> watchBudgetsWithProgress({
    DateTime? asOf,
    bool includeArchived = false,
  }) {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.budgets, _db.transactions, _db.categories},
        )
        .watch()
        .asyncMap((_) async {
      final now = asOf ?? DateTime.now();
      final budgetsQuery = _db.select(_db.budgets);
      if (!includeArchived) {
        budgetsQuery.where((b) => b.isArchived.equals(false));
      }
      final budgets = await budgetsQuery.get();
      if (budgets.isEmpty) return const <BudgetWithProgress>[];

      final allCategories = await _db.select(_db.categories).get();
      final categoriesById = <int, Category>{
        for (final c in allCategories) c.id: c,
      };
      final childrenByParentId = <int, List<int>>{};
      for (final c in allCategories) {
        if (c.parentId != null) {
          childrenByParentId.putIfAbsent(c.parentId!, () => []).add(c.id);
        }
      }

      final windows = <({
        Budget budget,
        (DateTime, DateTime) current,
        (DateTime, DateTime)? previous,
        Set<int>? categoryIds,
      })>[];
      DateTime? minStart;
      DateTime? maxEnd;

      for (final budget in budgets) {
        final current = BudgetPeriodHelper.getPeriodWindow(budget, now);
        final prevCandidate =
            BudgetPeriodHelper.getPreviousPeriodWindow(budget, now);
        final budgetStartDay = DateTime(
          budget.startDate.year,
          budget.startDate.month,
          budget.startDate.day,
        );
        final previous = (budget.rollover &&
                prevCandidate != null &&
                budgetStartDay.isBefore(current.$1))
            ? prevCandidate
            : null;

        if (minStart == null || current.$1.isBefore(minStart)) {
          minStart = current.$1;
        }
        if (maxEnd == null || current.$2.isAfter(maxEnd)) {
          maxEnd = current.$2;
        }
        if (previous != null) {
          if (previous.$1.isBefore(minStart)) minStart = previous.$1;
          if (previous.$2.isAfter(maxEnd)) maxEnd = previous.$2;
        }

        final categoryIds = budget.categoryId == null
            ? null
            : <int>{
                budget.categoryId!,
                ...?childrenByParentId[budget.categoryId!],
              };
        windows.add((
          budget: budget,
          current: current,
          previous: previous,
          categoryIds: categoryIds,
        ));
      }

      final txns = await (_db.select(_db.transactions)
            ..where((t) => t.type.equals('expense'))
            ..where((t) => t.excludeFromBudget.equals(false))
            ..where((t) => t.transactionDate.isBiggerOrEqualValue(minStart!))
            ..where((t) => t.transactionDate.isSmallerThanValue(maxEnd!)))
          .get();

      final results = <BudgetWithProgress>[];
      for (final entry in windows) {
        final budget = entry.budget;
        final categoryIds = entry.categoryIds;

        int spentCents = 0;
        int prevSpentCents = 0;
        for (final t in txns) {
          if (categoryIds != null &&
              (t.categoryId == null || !categoryIds.contains(t.categoryId))) {
            continue;
          }
          final dt = t.transactionDate;
          final costCents = CentsConverter.toCents(t.amount) +
              CentsConverter.toCents(t.transactionCost) +
              CentsConverter.toCents(t.fulizaFee);

          if (!dt.isBefore(entry.current.$1) && dt.isBefore(entry.current.$2)) {
            spentCents += costCents;
          }
          final prev = entry.previous;
          if (prev != null && !dt.isBefore(prev.$1) && dt.isBefore(prev.$2)) {
            prevSpentCents += costCents;
          }
        }

        final rolloverCents = entry.previous == null
            ? 0
            : math.max(0, CentsConverter.toCents(budget.amount) - prevSpentCents);

        final category = budget.categoryId != null
            ? categoriesById[budget.categoryId!]
            : null;

        results.add(BudgetWithProgress(
          budget: budget,
          spent: CentsConverter.fromCents(spentCents),
          rolloverAmount: CentsConverter.fromCents(rolloverCents),
          categoryName: category?.name,
          categoryColorHex: category?.colorHex,
          categoryIcon: category?.icon,
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
    final (start, end) = BudgetPeriodHelper.getPeriodWindow(budget, now);

    return _db
        .customSelect('SELECT 1', readsFrom: {_db.transactions, _db.categories})
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

  static (DateTime, DateTime) getPeriodWindow(Budget budget, DateTime now) =>
      BudgetPeriodHelper.getPeriodWindow(budget, now);

  static (DateTime, DateTime)? getPreviousPeriodWindow(
    Budget budget,
    DateTime now,
  ) =>
      BudgetPeriodHelper.getPreviousPeriodWindow(budget, now);

  Future<List<int>> _getCategoryAndSubcategories(int categoryId) async {
    final subcats = await (_db.select(_db.categories)
          ..where((c) => c.parentId.equals(categoryId)))
        .get();
    return [categoryId, ...subcats.map((c) => c.id)];
  }
}
