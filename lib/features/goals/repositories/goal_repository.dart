import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

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
    if (name.trim().isEmpty || targetAmount <= 0) {
      throw ArgumentError('A name and positive target are required');
    }
    return _db.into(_db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            name: name.trim(),
            targetAmount: targetAmount,
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
    if (amount <= 0) throw ArgumentError('Contribution must be positive');
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
                  amount: amount,
                  type: const Value('transfer'),
                  accountId: Value(accountId),
                  transactionDate: date,
                ),
              );
      await _db.into(_db.goalContributions).insert(
            GoalContributionsCompanion.insert(
              goalId: goalId,
              amount: amount,
              accountId: Value(accountId),
              transactionId: Value(transactionId),
              contributionDate: date,
            ),
          );
      await (_db.update(_db.savingsGoals)
            ..where((row) => row.id.equals(goalId)))
          .write(
        SavingsGoalsCompanion(
          currentAmount: Value(goal.currentAmount + amount),
        ),
      );
    });
  }
}
