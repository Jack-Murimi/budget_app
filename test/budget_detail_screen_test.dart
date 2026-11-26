import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/budgets/repositories/budget_repository.dart';
import 'package:budget_app/features/budgets/screens/budget_detail_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  late AppDatabase db;
  late BudgetRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = BudgetRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> unmountTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets('BudgetDetailScreen shows rollover, over-budget, edit, archive & delete',
      (tester) async {
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    final id = await db.into(db.budgets).insert(
          BudgetsCompanion.insert(
            name: 'Groceries',
            amount: 5000.0,
            period: const Value('monthly'),
            startDate: lastMonthStart,
            rollover: const Value(true),
          ),
        );
    // Spend 3000 last month -> 2000 rollover into this month (total = 7000)
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Last Month Food',
            amount: 3000.0,
            type: const Value('expense'),
            transactionDate: DateTime(now.year, now.month - 1, 15),
          ),
        );

    final initial =
        (await repo.watchBudgetsWithProgress().first).firstWhere((b) => b.id == id);
    expect(initial.rolloverAmount, 2000.0);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          BudgetDetailScreen(budgetWithProgress: initial),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.text('Includes KES 2,000.00 rollover from previous period'),
      findsOneWidget,
    );
    expect(find.text('KES 0.00 / KES 7,000.00'), findsOneWidget);

    // Exceed budget (spent 8000 > 7000) -> shows Over budget by KES 1,000.00
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Huge Haul',
            amount: 8000.0,
            type: const Value('expense'),
            transactionDate: now,
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Huge Haul'), findsOneWidget);
    expect(find.text('Over budget by KES 1,000.00'), findsOneWidget);

    // Archive and unarchive toggle
    await tester.tap(find.byTooltip('Archive budget'));
    await tester.pumpAndSettle();
    expect(find.text('Budget archived'), findsOneWidget);
    expect(find.byTooltip('Unarchive budget'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(BudgetDetailScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Unarchive budget'));
    await tester.pumpAndSettle();
    expect(find.text('Budget unarchived'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(BudgetDetailScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    // Edit budget
    await tester.tap(find.byTooltip('Edit budget'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Name *'),
      'Household Food',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Budget updated'), findsOneWidget);
    expect(find.text('Household Food'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(BudgetDetailScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    // Delete budget -> pops screen and removes row
    await tester.tap(find.byTooltip('Delete budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetDetailScreen), findsNothing);
    expect(find.text('Budget deleted'), findsOneWidget);
    expect(await db.select(db.budgets).get(), isEmpty);

    await unmountTree(tester);
  });

  testWidgets('BudgetDetailScreen shows Category Breakdown for multi-category budget and toggles pin to Home',
      (tester) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final catTreats = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Treats',
            colorHex: const Value('#E91E63'),
          ),
        );
    final catMisc = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Miscellaneous',
            colorHex: const Value('#9C27B0'),
          ),
        );

    final id = await repo.insertBudget(
      BudgetsCompanion.insert(
        name: 'Fun & Misc',
        amount: 5000.0,
        period: const Value('monthly'),
        startDate: monthStart,
      ),
      categoryIds: [catTreats, catMisc],
    );

    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Java Coffee',
            amount: 1500.0,
            type: const Value('expense'),
            categoryId: Value(catTreats),
            transactionDate: now,
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Gift Wrap',
            amount: 500.0,
            type: const Value('expense'),
            categoryId: Value(catMisc),
            transactionDate: now,
          ),
        );

    final initial =
        (await repo.watchBudgetsWithProgress().first).firstWhere((b) => b.id == id);
    expect(initial.isMultiCategory, isTrue);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: BudgetDetailScreen(budgetWithProgress: initial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final breakdownCard = find.ancestor(
      of: find.text('Category Breakdown'),
      matching: find.byType(Card),
    );
    expect(breakdownCard, findsOneWidget);
    expect(
      find.descendant(
        of: breakdownCard,
        matching: find.text('KES 1,500.00'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: breakdownCard,
        matching: find.text('KES 500.00'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('75% of spent'), findsOneWidget);
    expect(find.textContaining('25% of spent'), findsOneWidget);

    await tester.tap(find.byTooltip('Pin to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Pinned to Home'), findsOneWidget);
    expect(find.byTooltip('Unpin from Home'), findsOneWidget);

    await unmountTree(tester);
  });
}
