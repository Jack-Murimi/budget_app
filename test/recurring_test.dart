import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/recurring/models/recurring_model.dart';
import 'package:budget_app/features/recurring/repositories/recurring_repository.dart';
import 'package:budget_app/features/recurring/services/recurrence_engine.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  }

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

      // 1. Transaction should exist in ledger
      final txns = await db.select(db.transactions).get();
      expect(txns.length, 1);
      expect(txns.first.header, 'KPLC Electricity');
      expect(txns.first.amount, 2500.0);

      // 2. Next due date should have advanced to December
      final updated = (await db.select(db.recurringTransactions).get())
          .firstWhere((r) => r.id == id);
      expect(updated.nextDueDate.month, 12);
      expect(updated.nextDueDate.day, 10);
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
  });
}
