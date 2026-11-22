import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';

class GoalRepository {
  const GoalRepository(this._db);
  final AppDatabase _db;

  Stream<List<SavingsGoal>> watchAll() => (_db.select(_db.savingsGoals)
        ..orderBy([(row) => OrderingTerm.asc(row.targetDate)]))
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
}
