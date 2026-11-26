import 'dart:math' as math;

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../transactions/models/transaction_split_allocator.dart';
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
          readsFrom: {
            _db.budgets,
            _db.budgetCategories,
            _db.transactions,
            _db.transactionSplits,
            _db.categories,
          },
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

      final budgetCategoryRows = await _db.select(_db.budgetCategories).get();
      final linkedCatIdsByBudgetId = <int, List<int>>{};
      for (final row in budgetCategoryRows) {
        linkedCatIdsByBudgetId
            .putIfAbsent(row.budgetId, () => [])
            .add(row.categoryId);
      }

      final windows = <({
        Budget budget,
        (DateTime, DateTime) current,
        (DateTime, DateTime)? previous,
        List<Category> selectedCategories,
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

        final linkedIds = linkedCatIdsByBudgetId[budget.id];
        final rawSelectedIds = (linkedIds != null && linkedIds.isNotEmpty)
            ? linkedIds
            : (budget.categoryId != null ? [budget.categoryId!] : const <int>[]);

        final selectedCategories = [
          for (final cid in rawSelectedIds.toSet())
            if (categoriesById[cid] != null) categoriesById[cid]!,
        ]..sort((a, b) {
            final so = a.sortOrder.compareTo(b.sortOrder);
            return so != 0 ? so : a.name.compareTo(b.name);
          });

        final categoryIds = rawSelectedIds.isEmpty
            ? null
            : <int>{
                for (final cid in rawSelectedIds) ...[
                  cid,
                  ...?childrenByParentId[cid],
                ],
              };

        windows.add((
          budget: budget,
          current: current,
          previous: previous,
          selectedCategories: selectedCategories,
          categoryIds: categoryIds,
        ));
      }

      final txns = await (_db.select(_db.transactions)
            ..where((t) => t.type.equals('expense'))
            ..where((t) => t.excludeFromBudget.equals(false))
            ..where((t) => t.transactionDate.isBiggerOrEqualValue(minStart!))
            ..where((t) => t.transactionDate.isSmallerThanValue(maxEnd!)))
          .get();

      final txnIds = [for (final t in txns) t.id];
      final splitsByTxnId = <int, List<TransactionSplit>>{};
      if (txnIds.isNotEmpty) {
        final splitRows = await (_db.select(_db.transactionSplits)
              ..where((s) => s.transactionId.isIn(txnIds)))
            .get();
        for (final s in splitRows) {
          splitsByTxnId.putIfAbsent(s.transactionId, () => []).add(s);
        }
      }

      final results = <BudgetWithProgress>[];
      for (final entry in windows) {
        final budget = entry.budget;
        final categoryIds = entry.categoryIds;

        final Map<int, int> bucketByCatId = {};
        if (entry.selectedCategories.length > 1) {
          for (final cat in entry.selectedCategories) {
            bucketByCatId[cat.id] = cat.id;
          }
          for (final cat in entry.selectedCategories) {
            for (final childId
                in childrenByParentId[cat.id] ?? const <int>[]) {
              bucketByCatId.putIfAbsent(childId, () => cat.id);
            }
          }
        }

        int spentCents = 0;
        int prevSpentCents = 0;
        final spentCentsByCat = <int, int>{};
        final countByCat = <int, int>{};
        for (final t in txns) {
          final dt = t.transactionDate;
          final inCurrent =
              !dt.isBefore(entry.current.$1) && dt.isBefore(entry.current.$2);
          final prev = entry.previous;
          final inPrev =
              prev != null && !dt.isBefore(prev.$1) && dt.isBefore(prev.$2);
          if (!inCurrent && !inPrev) continue;

          final rawSplits = splitsByTxnId[t.id] ?? const <TransactionSplit>[];
          final amountCents = CentsConverter.toCents(t.amount);
          final feeCents = CentsConverter.toCents(t.transactionCost) +
              CentsConverter.toCents(t.fulizaFee);
          final allocations = TransactionSplitAllocator.allocateExpenseCents(
            fallbackCategoryId: t.categoryId,
            amountCents: amountCents,
            feeCents: feeCents,
            splits: [
              for (final s in rawSplits)
                (
                  categoryId: s.categoryId,
                  amountCents: CentsConverter.toCents(s.amount),
                ),
            ],
          );

          final seenBucketsInTxn = <int>{};
          for (final alloc in allocations) {
            if (categoryIds != null &&
                (alloc.categoryId == null ||
                    !categoryIds.contains(alloc.categoryId))) {
              continue;
            }
            if (inCurrent) {
              spentCents += alloc.cents;
              if (bucketByCatId.isNotEmpty && alloc.categoryId != null) {
                final bucketId = bucketByCatId[alloc.categoryId!];
                if (bucketId != null) {
                  spentCentsByCat[bucketId] =
                      (spentCentsByCat[bucketId] ?? 0) + alloc.cents;
                  if (seenBucketsInTxn.add(bucketId)) {
                    countByCat[bucketId] = (countByCat[bucketId] ?? 0) + 1;
                  }
                }
              }
            }
            if (inPrev) {
              prevSpentCents += alloc.cents;
            }
          }
        }

        final rolloverCents = entry.previous == null
            ? 0
            : math.max(0, CentsConverter.toCents(budget.amount) - prevSpentCents);

        final selected = entry.selectedCategories;
        final breakdown = selected.length <= 1
            ? const <BudgetCategoryBreakdown>[]
            : ([
                for (final cat in selected)
                  BudgetCategoryBreakdown(
                    category: cat,
                    spent: CentsConverter.fromCents(
                      spentCentsByCat[cat.id] ?? 0,
                    ),
                    transactionCount: countByCat[cat.id] ?? 0,
                  ),
              ]..sort((a, b) {
                final cmp = b.spent.compareTo(a.spent);
                return cmp != 0
                    ? cmp
                    : a.category.name.compareTo(b.category.name);
              }));

        final String? categoryName;
        if (selected.isEmpty) {
          categoryName = null;
        } else if (selected.length == 1) {
          categoryName = selected.first.name;
        } else {
          categoryName = selected.map((c) => c.name).join(' · ');
        }

        results.add(BudgetWithProgress(
          budget: budget,
          spent: CentsConverter.fromCents(spentCents),
          rolloverAmount: CentsConverter.fromCents(rolloverCents),
          categories: selected,
          categoryBreakdown: breakdown,
          categoryName: categoryName,
          categoryColorHex: selected.isNotEmpty ? selected.first.colorHex : null,
          categoryIcon: selected.length == 1 ? selected.first.icon : null,
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

    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.budgets,
            _db.budgetCategories,
            _db.transactions,
            _db.transactionSplits,
            _db.categories,
          },
        )
        .watch()
        .asyncMap((_) async {
      final liveBudget = await (_db.select(_db.budgets)
                ..where((b) => b.id.equals(budget.id)))
              .getSingleOrNull() ??
          budget;
      final (start, end) = BudgetPeriodHelper.getPeriodWindow(liveBudget, now);

      final linkedRows = await (_db.select(_db.budgetCategories)
            ..where((bc) => bc.budgetId.equals(liveBudget.id)))
          .get();
      final rawIds = linkedRows.isNotEmpty
          ? linkedRows.map((r) => r.categoryId).toList()
          : (liveBudget.categoryId != null
              ? [liveBudget.categoryId!]
              : const <int>[]);

      final expandedIds = await _expandCategoryIds(rawIds);

      final query = _db.select(_db.transactions)
        ..where((t) => t.type.equals('expense'))
        ..where((t) => t.excludeFromBudget.equals(false))
        ..where((t) => t.transactionDate.isBiggerOrEqualValue(start))
        ..where((t) => t.transactionDate.isSmallerThanValue(end))
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

      if (expandedIds.isNotEmpty) {
        final expList = expandedIds.toList();
        final splitRows = await (_db.select(_db.transactionSplits)
              ..where((s) => s.categoryId.isIn(expList)))
            .get();
        final splitTxnIds = {for (final s in splitRows) s.transactionId}.toList();
        if (splitTxnIds.isEmpty) {
          query.where((t) => t.categoryId.isIn(expList));
        } else {
          query.where(
            (t) => t.categoryId.isIn(expList) | t.id.isIn(splitTxnIds),
          );
        }
      }

      return query.get();
    });
  }

  Future<int> insertBudget(
    BudgetsCompanion budget, {
    List<int>? categoryIds,
  }) {
    return _db.transaction(() async {
      if (categoryIds != null) {
        final ids = categoryIds.toSet().toList();
        final id = await _db.into(_db.budgets).insert(
              budget.copyWith(
                categoryId: Value(ids.isEmpty ? null : ids.first),
              ),
            );
        if (ids.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.budgetCategories,
              [
                for (final cid in ids)
                  BudgetCategoriesCompanion.insert(
                    budgetId: id,
                    categoryId: cid,
                  ),
              ],
            );
          });
        }
        return id;
      }

      final id = await _db.into(_db.budgets).insert(budget);
      if (budget.categoryId.present && budget.categoryId.value != null) {
        await _db.into(_db.budgetCategories).insert(
              BudgetCategoriesCompanion.insert(
                budgetId: id,
                categoryId: budget.categoryId.value!,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      return id;
    });
  }

  Future<bool> updateBudget(
    BudgetsCompanion budget, {
    List<int>? categoryIds,
  }) {
    return _db.transaction(() async {
      final budgetId = budget.id.value;
      if (categoryIds != null) {
        final ids = categoryIds.toSet().toList();
        final count = await (_db.update(_db.budgets)
              ..where((b) => b.id.equals(budgetId)))
            .write(
          budget.copyWith(
            categoryId: Value(ids.isEmpty ? null : ids.first),
          ),
        );
        await (_db.delete(_db.budgetCategories)
              ..where((bc) => bc.budgetId.equals(budgetId)))
            .go();
        if (ids.isNotEmpty) {
          await _db.batch((b) {
            b.insertAll(
              _db.budgetCategories,
              [
                for (final cid in ids)
                  BudgetCategoriesCompanion.insert(
                    budgetId: budgetId,
                    categoryId: cid,
                  ),
              ],
            );
          });
        }
        return count > 0;
      }

      final count = await (_db.update(_db.budgets)
            ..where((b) => b.id.equals(budgetId)))
          .write(budget);
      if (budget.categoryId.present) {
        await (_db.delete(_db.budgetCategories)
              ..where((bc) => bc.budgetId.equals(budgetId)))
            .go();
        if (budget.categoryId.value != null) {
          await _db.into(_db.budgetCategories).insert(
                BudgetCategoriesCompanion.insert(
                  budgetId: budgetId,
                  categoryId: budget.categoryId.value!,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
      return count > 0;
    });
  }

  Future<List<int>> getBudgetCategoryIds(int budgetId) async {
    final rows = await (_db.select(_db.budgetCategories)
          ..where((bc) => bc.budgetId.equals(budgetId)))
        .get();
    return rows.map((r) => r.categoryId).toList();
  }

  Future<void> deleteBudget(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.budgetCategories)
            ..where((bc) => bc.budgetId.equals(id)))
          .go();
      await (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
    });
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

  Future<Set<int>> _expandCategoryIds(List<int> rawIds) async {
    if (rawIds.isEmpty) return const <int>{};
    final subcats = await (_db.select(_db.categories)
          ..where((c) => c.parentId.isIn(rawIds)))
        .get();
    return <int>{...rawIds, ...subcats.map((c) => c.id)};
  }
}
