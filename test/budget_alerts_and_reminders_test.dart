import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/core/services/reminder_notification_service.dart';
import 'package:budget_app/features/budgets/models/budget_model.dart';
import 'package:budget_app/features/budgets/providers/budget_providers.dart';
import 'package:budget_app/features/budgets/repositories/budget_repository.dart';
import 'package:budget_app/features/budgets/services/budget_alert_evaluator.dart';
import 'package:budget_app/features/debts/models/debt_model.dart';
import 'package:budget_app/features/home/screens/home_screen.dart';
import 'package:budget_app/features/recurring/models/recurring_model.dart';
import 'package:budget_app/main.dart';
import 'package:budget_app/shared/providers/theme_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {

  BudgetWithProgress makeBudget({
    required int id,
    required String name,
    required double amount,
    required double spent,
    int? categoryId,
    bool isArchived = false,
  }) {
    final now = DateTime(2026, 11, 1);
    return BudgetWithProgress(
      budget: Budget(
        id: id,
        name: name,
        amount: amount,
        categoryId: categoryId,
        period: 'monthly',
        startDate: now,
        rollover: false,
        isArchived: isArchived,
        createdAt: now,
      ),
      spent: spent,
    );
  }

  group('BudgetAlertEvaluator', () {
    test('detects newly crossed 80% and 100% thresholds without repeating already-crossed levels',
        () {
      final before = [
        makeBudget(id: 1, name: 'Overall', amount: 10000, spent: 7500),
        makeBudget(
          id: 2,
          name: 'Food',
          amount: 2000,
          spent: 1800,
          categoryId: 10,
        ),
        makeBudget(
          id: 3,
          name: 'Transport',
          amount: 1000,
          spent: 850,
          categoryId: 11,
        ),
      ];
      final after = [
        // 75% -> 82%: crossed 80%
        makeBudget(id: 1, name: 'Overall', amount: 10000, spent: 8200),
        // 90% -> 105%: crossed 100%
        makeBudget(
          id: 2,
          name: 'Food',
          amount: 2000,
          spent: 2100,
          categoryId: 10,
        ),
        // 85% -> 92%: already >=80% before, <100% now -> no alert
        makeBudget(
          id: 3,
          name: 'Transport',
          amount: 1000,
          spent: 920,
          categoryId: 11,
        ),
      ];

      final alerts = BudgetAlertEvaluator.evaluateCrossedThresholds(
        before: before,
        after: after,
      );

      expect(alerts, hasLength(2));
      expect(alerts[0].budget.id, 2);
      expect(alerts[0].level, BudgetAlertLevel.exceeded100);
      expect(alerts[1].budget.id, 1);
      expect(alerts[1].level, BudgetAlertLevel.warning80);
    });
  });

  group('PinnedBudgetsNotifier', () {
    test('enforces max 3 pins and persists in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(pinnedBudgetIdsProvider.notifier);
      expect(notifier.toggle(10), isTrue);
      expect(notifier.toggle(20), isTrue);
      expect(notifier.toggle(30), isTrue);
      expect(notifier.toggle(40), isFalse);
      expect(container.read(pinnedBudgetIdsProvider), equals([10, 20, 30]));
      expect(
        prefs.getStringList('pinned_budget_ids'),
        equals(['10', '20', '30']),
      );

      expect(notifier.toggle(20), isTrue);
      expect(container.read(pinnedBudgetIdsProvider), equals([10, 30]));
      expect(notifier.toggle(40), isTrue);
      expect(container.read(pinnedBudgetIdsProvider), equals([10, 30, 40]));
    });
  });

  group('ReminderNotificationService.buildDueReminders', () {
    test('includes notify-enabled recurring bills, unsettled debts, and active Fuliza due within 3 days',
        () {
      final now = DateTime(2026, 11, 26, 10, 0);
      final recurring = [
        RecurringModel(
          id: 1,
          payee: 'Rent',
          amount: 20000,
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 11, 1),
          nextDueDate: DateTime(2026, 11, 27),
          notify: true,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        RecurringModel(
          id: 2,
          payee: 'Silent Sub',
          amount: 500,
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 11, 1),
          nextDueDate: DateTime(2026, 11, 26),
          notify: false,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final debts = [
        DebtWithRepayments(
          debt: Debt(
            id: 5,
            counterparty: 'Jane',
            direction: 'borrowed',
            product: 'personal',
            principal: 1500,
            interest: 0,
            disbursementShortfall: 0,
            outstanding: 1500,
            dueDate: DateTime(2026, 11, 25),
            notes: '',
            createdAt: now,
          ),
          repayments: const [],
        ),
        DebtWithRepayments(
          debt: Debt(
            id: 6,
            counterparty: 'Settled Friend',
            direction: 'lent',
            product: 'personal',
            principal: 500,
            interest: 0,
            disbursementShortfall: 0,
            outstanding: 0,
            dueDate: DateTime(2026, 11, 26),
            notes: '',
            createdAt: now,
          ),
          repayments: const [],
        ),
      ];
      final fuliza = FulizaRecord(
        id: 9,
        mpesaRef: 'FZ12345678',
        fulizaAmount: 400,
        accessFee: 4,
        outstandingTotal: 404,
        dueDate: DateTime(2026, 11, 28),
        createdAt: now,
      );

      final reminders = ReminderNotificationService.buildDueReminders(
        recurring: recurring,
        debts: debts,
        latestFuliza: fuliza,
        now: now,
      );

      expect(reminders, hasLength(3));
      expect(
        reminders.map((r) => r.kind),
        containsAll([
          ReminderKind.debtDue,
          ReminderKind.recurringBill,
          ReminderKind.fulizaDue,
        ]),
      );
      expect(reminders.any((r) => r.title.contains('Silent Sub')), isFalse);
      expect(
        reminders.any((r) => r.title.contains('Settled Friend')),
        isFalse,
      );
      expect(
        reminders.firstWhere((r) => r.kind == ReminderKind.debtDue).isOverdue,
        isTrue,
      );
    });
  });

  testWidgets('HomeScreen renders pinned budgets and due debt/Fuliza banner',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    addTearDown(db.close);

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final foodCat = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Food & Dining'),
        );

    final budgetRepo = BudgetRepository(db);
    await budgetRepo.insertBudget(
      BudgetsCompanion.insert(
        name: 'Overall',
        amount: 40000,
        startDate: monthStart,
      ),
    );
    final pinnedId = await budgetRepo.insertBudget(
      BudgetsCompanion.insert(
        name: 'Eating Out Limit',
        amount: 5000,
        startDate: monthStart,
      ),
      categoryIds: [foodCat],
    );
    await prefs.setStringList('pinned_budget_ids', ['$pinnedId']);

    await db.into(db.debts).insert(
          DebtsCompanion.insert(
            counterparty: 'Alice',
            direction: 'borrowed',
            principal: 2000,
            outstanding: 2000,
            dueDate: Value(now.add(const Duration(days: 1))),
          ),
        );

    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pinned Budgets'), findsOneWidget);
    expect(find.text('Eating Out Limit'), findsOneWidget);
    expect(find.text('1 debt or Fuliza balance due soon'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
