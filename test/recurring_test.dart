import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/recurring/models/recurring_model.dart';
import 'package:budget_app/features/recurring/repositories/recurring_repository.dart';
import 'package:budget_app/features/recurring/services/recurrence_engine.dart';

void main() {

  group('RecurrenceEngine', () {
    test('calculateNextDate advances daily correctly', () {
      final start = DateTime(2026, 11, 1, 10, 0);
      final next = RecurrenceEngine.calculateNextDate(start, 'daily', 3);
      expect(next, DateTime(2026, 11, 4, 10, 0));
    });

    test('calculateNextDate advances weekly correctly', () {
      final start = DateTime(2026, 11, 1, 10, 0);
      final next = RecurrenceEngine.calculateNextDate(start, 'weekly', 2);
      expect(next, DateTime(2026, 11, 15, 10, 0));
    });

    test('calculateNextDate advances monthly with day clamping', () {
      final jan31 = DateTime(2026, 1, 31, 12, 0);
      final feb = RecurrenceEngine.calculateNextDate(jan31, 'monthly', 1);
      expect(feb, DateTime(2026, 2, 28, 12, 0));

      final apr = RecurrenceEngine.calculateNextDate(jan31, 'monthly', 3);
      expect(apr, DateTime(2026, 4, 30, 12, 0));
    });

    test('calculateNextDate advances yearly correctly', () {
      final start = DateTime(2026, 11, 7, 9, 30);
      final next = RecurrenceEngine.calculateNextDate(start, 'yearly', 1);
      expect(next, DateTime(2027, 11, 7, 9, 30));
    });

    test('frequency labels format properly', () {
      expect(RecurrenceEngine.frequencyLabel('monthly', 1), 'Monthly');
      expect(RecurrenceEngine.frequencyLabel('weekly', 1), 'Weekly');
      expect(RecurrenceEngine.frequencyLabel('weekly', 2), 'Every 2 weeks');
      expect(RecurrenceEngine.frequencyLabel('daily', 5), 'Every 5 days');
      expect(RecurrenceEngine.frequencyLabel('monthly', 3), 'Every 3 months');
    });

    test('nextDue anchors month-end day across short months and leap years', () {
      final jan31 = DateTime(2026, 1, 31, 9, 0);
      final rule = RecurringModel(
        id: 1,
        amount: 1000,
        startDate: jan31,
        nextDueDate: jan31,
        frequency: 'monthly',
        createdAt: jan31,
        updatedAt: jan31,
      );
      final feb = RecurrenceEngine.nextDue(rule);
      expect(feb, DateTime(2026, 2, 28, 9, 0));

      final mar = RecurrenceEngine.nextDue(rule.copyWith(nextDueDate: feb));
      expect(mar, DateTime(2026, 3, 31, 9, 0));

      final feb29 = DateTime(2024, 2, 29, 9, 0);
      final yearly = RecurringModel(
        id: 2,
        amount: 2000,
        startDate: feb29,
        nextDueDate: feb29,
        frequency: 'yearly',
        createdAt: feb29,
        updatedAt: feb29,
      );
      final y2025 = RecurrenceEngine.nextDue(yearly);
      expect(y2025, DateTime(2025, 2, 28, 9, 0));
      final y2028 = RecurrenceEngine.nextDue(
        yearly.copyWith(nextDueDate: DateTime(2027, 2, 28, 9, 0)),
      );
      expect(y2028, DateTime(2028, 2, 29, 9, 0));
    });
  });

  group('RecurringModel', () {
    test('copyWith clears nullable fields and isOverdueAt uses calendar days', () {
      final dueToday = DateTime(2026, 11, 22, 0, 0);
      final item = RecurringModel(
        id: 1,
        amount: 500,
        startDate: dueToday,
        nextDueDate: dueToday,
        endDate: DateTime(2027, 1, 1),
        categoryId: 3,
        createdAt: dueToday,
        updatedAt: dueToday,
      );

      final cleared = item.copyWith(clearEndDate: true, clearCategoryId: true);
      expect(cleared.endDate, isNull);
      expect(cleared.categoryId, isNull);

      expect(item.isOverdueAt(DateTime(2026, 11, 22, 18, 0)), isFalse);
      expect(item.isDueSoonAt(DateTime(2026, 11, 22, 18, 0)), isTrue);
      expect(item.isOverdueAt(DateTime(2026, 11, 23, 0, 1)), isTrue);
    });
  });

  group('RecurringRepository', () {
    late AppDatabase db;
    late RecurringRepository repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      repo = RecurringRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert and watch recurring transactions', () async {
      final now = DateTime(2026, 11, 1);
      final item = RecurringModel(
        id: 0,
        payee: 'Netflix',
        amount: 1100.0,
        type: 'expense',
        frequency: 'monthly',
        intervalCount: 1,
        startDate: now,
        nextDueDate: now.add(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );

      final id = await repo.insert(item);
      expect(id, greaterThan(0));

      final items = await repo.watchAll().first;
      expect(items.length, 1);
      expect(items.first.payee, 'Netflix');
      expect(items.first.amount, 1100.0);
      expect(items.first.isActive, true);
    });

    test('markAsPaid logs transaction and advances nextDueDate', () async {
      final start = DateTime(2026, 11, 10);
      final item = RecurringModel(
        id: 0,
        payee: 'KPLC Electricity',
        amount: 2500.0,
        type: 'expense',
        frequency: 'monthly',
        intervalCount: 1,
        startDate: start,
        nextDueDate: start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repo.insert(item);
      final inserted = (await repo.watchAll().first).first;

      // Mark as paid
      await repo.markAsPaid(inserted, paidDate: DateTime(2026, 11, 10));

      // 1. Transaction should exist in ledger with recurrence link
      final txns = await db.select(db.transactions).get();
      expect(txns.length, 1);
      expect(txns.first.header, 'KPLC Electricity');
      expect(txns.first.amount, 2500.0);
      expect(txns.first.recurrenceId, id);
      expect(txns.first.isRecurring, isTrue);

      // 2. Next due date should have advanced to December
      final updated = (await db.select(db.recurringTransactions).get())
          .firstWhere((r) => r.id == id);
      expect(updated.nextDueDate.month, 12);
      expect(updated.nextDueDate.day, 10);

      // 3. Deleting recurring rule succeeds under PRAGMA foreign_keys = ON
      await repo.delete(id);
      final afterDeleteTxns = await db.select(db.transactions).get();
      expect(afterDeleteTxns.single.recurrenceId, isNull);
    });

    test('skip advances nextDueDate without logging transaction', () async {
      final start = DateTime(2026, 11, 15);
      final item = RecurringModel(
        id: 0,
        payee: 'Gym Membership',
        amount: 3000.0,
        type: 'expense',
        frequency: 'monthly',
        intervalCount: 1,
        startDate: start,
        nextDueDate: start,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repo.insert(item);
      final inserted = (await repo.watchAll().first).first;

      await repo.skip(inserted);

      // No transaction logged
      final txns = await db.select(db.transactions).get();
      expect(txns, isEmpty);

      // Next due date advanced
      final updated = (await db.select(db.recurringTransactions).get())
          .firstWhere((r) => r.id == id);
      expect(updated.nextDueDate.month, 12);
      expect(updated.nextDueDate.day, 15);
    });

    test('toggleActive pauses and resumes recurring item', () async {
      final item = RecurringModel(
        id: 0,
        payee: 'Spotify',
        amount: 500.0,
        type: 'expense',
        frequency: 'monthly',
        intervalCount: 1,
        startDate: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repo.insert(item);
      await repo.toggleActive(id, false);

      var list = await repo.watchAll().first;
      expect(list.first.isActive, false);

      await repo.toggleActive(id, true);
      list = await repo.watchAll().first;
      expect(list.first.isActive, true);
    });

    test('delete removes recurring transaction', () async {
      final item = RecurringModel(
        id: 0,
        payee: 'Old Subscription',
        amount: 100.0,
        type: 'expense',
        frequency: 'monthly',
        intervalCount: 1,
        startDate: DateTime.now(),
        nextDueDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repo.insert(item);
      await repo.delete(id);

      final list = await repo.watchAll().first;
      expect(list, isEmpty);
    });

    test('processAutoRecordDue logs due autoRecord items and skips manual items', () async {
      final start = DateTime(2026, 11, 1);
      await repo.insert(
        RecurringModel(
          id: 0,
          payee: 'Auto Rent',
          amount: 12000.0,
          type: 'expense',
          frequency: 'monthly',
          intervalCount: 1,
          startDate: start,
          nextDueDate: start,
          autoRecord: true,
          createdAt: start,
          updatedAt: start,
        ),
      );
      await repo.insert(
        RecurringModel(
          id: 0,
          payee: 'Manual Water',
          amount: 500.0,
          type: 'expense',
          frequency: 'monthly',
          intervalCount: 1,
          startDate: start,
          nextDueDate: start,
          autoRecord: false,
          createdAt: start,
          updatedAt: start,
        ),
      );

      final count = await repo.processAutoRecordDue(asOf: DateTime(2026, 11, 10));
      expect(count, 1);

      final txns = await db.select(db.transactions).get();
      expect(txns.length, 1);
      expect(txns.single.header, 'Auto Rent');
      expect(txns.single.isRecurring, isTrue);

      final items = await repo.watchAll().first;
      final autoRule = items.firstWhere((r) => r.payee == 'Auto Rent');
      expect(autoRule.nextDueDate.month, 12);
    });
  });
}
