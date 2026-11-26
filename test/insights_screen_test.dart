import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/insights/providers/insights_providers.dart';
import 'package:budget_app/features/insights/screens/insights_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('InsightsScreen renders empty state when no transactions exist',
      (tester) async {
    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: InsightsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Cashflow summary'), findsOneWidget);
    expect(find.text('No cashflow in this period'), findsOneWidget);
    expect(find.text('Net worth trend'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('No expenses in this period'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('No expenses in this period'), findsOneWidget);
  });

  testWidgets('InsightsScreen switches periods and renders metrics, charts, and Other bucket',
      (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastMonthDate = DateTime(now.year, now.month - 1, 12);

    // Income & expenses for this month
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Salary',
            amount: 10000.0,
            type: const Value('income'),
            transactionDate: today,
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Last month rent',
            amount: 2000.0,
            type: const Value('expense'),
            transactionDate: lastMonthDate,
          ),
        );

    for (var i = 1; i <= 6; i++) {
      final catId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(name: 'Category $i'),
          );
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              header: 'Expense $i',
              amount: (i * 200).toDouble(),
              type: const Value('expense'),
              categoryId: Value(catId),
              transactionDate: today,
            ),
          );
    }

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: InsightsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Total this month expense = 200+400+600+800+1000+1200 = 4,200; previous = 2,000 => +110%
    expect(find.text('KES 10,000.00'), findsWidgets);
    expect(find.text('KES 4,200.00'), findsOneWidget);
    expect(find.text('KES 5,800.00'), findsOneWidget);
    expect(find.text('Up 110% from previous period'), findsOneWidget);
    expect(find.textContaining('Avg daily spend:'), findsOneWidget);
    expect(find.text('Daily cashflow'), findsOneWidget);

    // Switch to This year (monthly cashflow aggregation)
    await tester.tap(find.text('This year'));
    await tester.pumpAndSettle();
    expect(container.read(insightsPeriodProvider), InsightsPeriod.year);
    expect(find.text('Monthly cashflow'), findsOneWidget);

    // Switch to Last month
    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();
    expect(container.read(insightsPeriodProvider), InsightsPeriod.lastMonth);
    expect(find.text('KES 2,000.00'), findsWidgets);

    // Switch back to This month and verify Top 5 + Other category breakdown
    await tester.tap(find.text('This month'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Other'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Spending by category'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
  });
}
