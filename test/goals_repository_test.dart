import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/goals/repositories/goal_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('contribution updates progress and creates a linked transfer', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = GoalRepository(db);
    final accountId = await db.into(db.accounts).insert(
          AccountsCompanion.insert(name: 'M-Pesa'),
        );
    final goalId = await repo.create(
      name: 'Emergency fund',
      targetAmount: 10000,
      targetDate: DateTime(2027, 1, 1),
    );

    await repo.contribute(goalId: goalId, amount: 2500, accountId: accountId);

    final goal = await (db.select(db.savingsGoals)
          ..where((row) => row.id.equals(goalId)))
        .getSingle();
    final contribution = await (db.select(db.goalContributions)
          ..where((row) => row.goalId.equals(goalId)))
        .getSingle();
    final transaction = await (db.select(db.transactions)
          ..where((row) => row.id.equals(contribution.transactionId!)))
        .getSingle();

    expect(goal.currentAmount, 2500);
    expect(contribution.amount, 2500);
    expect(transaction.type, 'transfer');
    expect(transaction.accountId, accountId);
  });

  test('watchAll sorts targetDate NULLS LAST and update/delete/deleteContribution reconcile state',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = GoalRepository(db);
    final accountId = await db.into(db.accounts).insert(
          AccountsCompanion.insert(name: 'M-Pesa'),
        );

    final noDateId = await repo.create(name: 'Open Savings', targetAmount: 5000);
    final datedId = await repo.create(
      name: 'School Fees',
      targetAmount: 10000,
      targetDate: DateTime(2027, 2, 1),
    );

    final ordered = await repo.watchAll().first;
    expect(ordered.map((g) => g.id).toList(), [datedId, noDateId]);

    await repo.contribute(goalId: datedId, amount: 3000, accountId: accountId);
    final contribs = await repo.watchContributions(datedId).first;
    expect(contribs.length, 1);

    await repo.deleteContribution(contribs.single.id, deleteLinkedTransaction: true);
    final afterDelContrib = await (db.select(db.savingsGoals)
          ..where((g) => g.id.equals(datedId)))
        .getSingle();
    expect(afterDelContrib.currentAmount, 0);
    expect(await db.select(db.transactions).get(), isEmpty);

    await repo.update(
      id: datedId,
      name: 'College Fees',
      targetAmount: 12000,
      clearTargetDate: true,
    );
    final updatedGoal = await (db.select(db.savingsGoals)
          ..where((g) => g.id.equals(datedId)))
        .getSingle();
    expect(updatedGoal.name, 'College Fees');
    expect(updatedGoal.targetAmount, 12000);
    expect(updatedGoal.targetDate, isNull);

    await repo.contribute(goalId: datedId, amount: 500, accountId: accountId);
    await repo.delete(datedId, deleteLinkedTransactions: true);
    expect(await db.select(db.goalContributions).get(), isEmpty);
    expect(await db.select(db.transactions).get(), isEmpty);
  });
}
