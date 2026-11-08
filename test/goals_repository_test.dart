import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/goals/repositories/goal_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

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
}
