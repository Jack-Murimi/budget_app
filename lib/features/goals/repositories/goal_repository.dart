import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';

class GoalRepository {
  const GoalRepository(this._db);
  final AppDatabase _db;

  Stream<List<SavingsGoal>> watchAll() => (_db.select(_db.savingsGoals)
        ..orderBy([
          (row) => OrderingTerm.asc(
                const CustomExpression<int>(
                    'CASE WHEN target_date IS NULL THEN 1 ELSE 0 END'),
              ),
          (row) => OrderingTerm.asc(row.targetDate),
          (row) => OrderingTerm.asc(row.id),
        ]))
      .watch();

  Stream<List<GoalContribution>> watchContributions(int goalId) =>
      (_db.select(_db.goalContributions)
            ..where((row) => row.goalId.equals(goalId))
            ..orderBy([
              (row) => OrderingTerm.desc(row.contributionDate),
              (row) => OrderingTerm.desc(row.id),
            ]))
          .watch();

  Future<int> create({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
  }) {
    final targetCents = CentsConverter.toCents(targetAmount);
    if (name.trim().isEmpty || targetCents <= 0) {
      throw ArgumentError('A name and positive target are required');
    }
    return _db.into(_db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            name: name.trim(),
            targetAmount: CentsConverter.fromCents(targetCents),
            targetDate: Value(targetDate),
          ),
        );
  }

  Future<bool> update({
    required int id,
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    bool clearTargetDate = false,
  }) async {
    final targetCents = CentsConverter.toCents(targetAmount);
    if (name.trim().isEmpty || targetCents <= 0) {
      throw ArgumentError('A name and positive target are required');
    }
    final existing = await (_db.select(_db.savingsGoals)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) return false;

    final updated = await (_db.update(_db.savingsGoals)
          ..where((row) => row.id.equals(id)))
        .write(
      SavingsGoalsCompanion(
        name: Value(name.trim()),
        targetAmount: Value(CentsConverter.fromCents(targetCents)),
        targetDate: clearTargetDate
            ? const Value(null)
            : (targetDate != null
                ? Value(targetDate)
                : Value(existing.targetDate)),
      ),
    );
    return updated > 0;
  }

  Future<void> delete(
    int id, {
    bool deleteLinkedTransactions = false,
  }) async {
    await _db.transaction(() async {
      final contributions = await (_db.select(_db.goalContributions)
            ..where((row) => row.goalId.equals(id)))
          .get();
      final txnIds = contributions
          .map((c) => c.transactionId)
          .whereType<int>()
          .toList();

      await (_db.delete(_db.goalContributions)
            ..where((row) => row.goalId.equals(id)))
          .go();

      if (deleteLinkedTransactions && txnIds.isNotEmpty) {
        await (_db.delete(_db.transactions)
              ..where((t) => t.id.isIn(txnIds)))
            .go();
      }

      await (_db.delete(_db.savingsGoals)..where((row) => row.id.equals(id)))
          .go();
    });
  }

  Future<void> contribute({
    required int goalId,
    required double amount,
    int? accountId,
    DateTime? contributionDate,
  }) async {
    final amountCents = CentsConverter.toCents(amount);
    if (amountCents <= 0) throw ArgumentError('Contribution must be positive');
    final normalizedAmount = CentsConverter.fromCents(amountCents);
    await _db.transaction(() async {
      final goal = await (_db.select(_db.savingsGoals)
            ..where((row) => row.id.equals(goalId)))
          .getSingle();
      final date = contributionDate ?? DateTime.now();
      final transactionId = accountId == null
          ? null
          : await _db.into(_db.transactions).insert(
                TransactionsCompanion.insert(
                  header: 'Goal contribution: ${goal.name}',
                  amount: normalizedAmount,
                  type: const Value('transfer'),
                  accountId: Value(accountId),
                  transactionDate: date,
                ),
              );
      await _db.into(_db.goalContributions).insert(
            GoalContributionsCompanion.insert(
              goalId: goalId,
              amount: normalizedAmount,
              accountId: Value(accountId),
              transactionId: Value(transactionId),
              contributionDate: date,
            ),
          );
      final updatedCents =
          CentsConverter.toCents(goal.currentAmount) + amountCents;
      await (_db.update(_db.savingsGoals)
            ..where((row) => row.id.equals(goalId)))
          .write(
        SavingsGoalsCompanion(
          currentAmount: Value(CentsConverter.fromCents(updatedCents)),
        ),
      );
    });
  }

  Future<void> deleteContribution(
    int contributionId, {
    bool deleteLinkedTransaction = false,
  }) async {
    await _db.transaction(() async {
      final contribution = await (_db.select(_db.goalContributions)
            ..where((row) => row.id.equals(contributionId)))
          .getSingleOrNull();
      if (contribution == null) return;

      final goal = await (_db.select(_db.savingsGoals)
            ..where((row) => row.id.equals(contribution.goalId)))
          .getSingleOrNull();

      await (_db.delete(_db.goalContributions)
            ..where((row) => row.id.equals(contributionId)))
          .go();

      if (deleteLinkedTransaction && contribution.transactionId != null) {
        await (_db.delete(_db.transactions)
              ..where((t) => t.id.equals(contribution.transactionId!)))
            .go();
      }

      if (goal != null) {
        final newCents = math.max(
          0,
          CentsConverter.toCents(goal.currentAmount) -
              CentsConverter.toCents(contribution.amount),
        );
        await (_db.update(_db.savingsGoals)
              ..where((row) => row.id.equals(goal.id)))
            .write(
          SavingsGoalsCompanion(
            currentAmount: Value(CentsConverter.fromCents(newCents)),
          ),
        );
      }
    });
  }
}
