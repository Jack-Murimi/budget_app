import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/goals/repositories/goal_repository.dart';
import 'package:budget_app/features/goals/screens/goals_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

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

  Future<void> unmountTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets('GoalsScreen shows empty state and validates goal creation',
      (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GoalsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No savings goals'), findsOneWidget);
    expect(
      find.text('Set a target, then allocate money from an account.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Add goal'));
    await tester.pumpAndSettle();

    // Empty name and zero target rejected
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Target (KES)'),
      '0',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a goal name'), findsOneWidget);
    expect(find.text('Enter a positive target amount'), findsOneWidget);

    // Valid creation succeeds
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Goal name'),
      'Vacation Fund',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Target (KES)'),
      '25000',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Vacation Fund'), findsOneWidget);
    expect(find.text('Savings goal saved'), findsOneWidget);
    await unmountTree(tester);
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

    var goal = await (db.select(db.savingsGoals)
          ..where((g) => g.id.equals(emergencyId)))
        .getSingle();
    expect(goal.currentAmount, 1500);

    // Open Contribution History sheet for Emergency Fund and delete contribution
    await tester.tap(find.text('History').at(1));
    await tester.pumpAndSettle();
    expect(find.text('Emergency Fund · Contributions'), findsOneWidget);
    expect(find.text('KES 1,500.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete contribution'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    goal = await (db.select(db.savingsGoals)
          ..where((g) => g.id.equals(emergencyId)))
        .getSingle();
    expect(goal.currentAmount, 0);
    expect(find.text('No contributions recorded yet.'), findsOneWidget);

    // Dismiss sheet and drain Drift autoDispose StreamQueryStore timer
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.pump(Duration.zero);

    // Edit Emergency Fund via popup menu
    await tester.tap(find.byType(PopupMenuButton<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Goal name'),
      'Rainy Day Fund',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Rainy Day Fund'), findsOneWidget);

    // Delete Rainy Day Fund via popup menu
    await tester.tap(find.byType(PopupMenuButton<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Rainy Day Fund'), findsNothing);

    await unmountTree(tester);
  });
}
