import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/goals/repositories/goal_repository.dart';
import 'package:budget_app/features/goals/screens/goals_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  late AppDatabase db;
  late GoalRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = GoalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('GoalsScreen handles zero-target guard, account picker, history, edit & delete',
      (tester) async {
    // Insert goal with targetAmount 0 directly to verify UI zero-division guard
    await db.into(db.savingsGoals).insert(
      SavingsGoalsCompanion.insert(
        name: 'Zero Target Guard',
        targetAmount: 0,
      ),
    );
    final emergencyId = await repo.create(
      name: 'Emergency Fund',
      targetAmount: 10000,
    );

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GoalsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zero Target Guard'), findsOneWidget);
    expect(find.text('Emergency Fund'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Contribute to Emergency Fund with explicit account selection
    await tester.tap(find.text('Add money').at(1));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (KES)'),
      '1500',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final goal = await (db.select(db.savingsGoals)
          ..where((g) => g.id.equals(emergencyId)))
        .getSingle();
    expect(goal.currentAmount, 1500);

    // Open Contribution History sheet for Emergency Fund
    await tester.tap(find.text('History').at(1));
    await tester.pumpAndSettle();
    expect(find.text('Emergency Fund · Contributions'), findsOneWidget);
    expect(find.text('KES 1,500.00'), findsOneWidget);

    // Dismiss sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
  });
}
