import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/recurring/models/recurring_model.dart';
import 'package:budget_app/features/recurring/repositories/recurring_repository.dart';
import 'package:budget_app/features/recurring/screens/add_edit_recurring_screen.dart';
import 'package:budget_app/features/recurring/screens/recurring_screen.dart';
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
  late RecurringRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = RecurringRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('Upcoming tab filters by 30-day horizon and MarkPaid validates amount > 0',
      (tester) async {
    final now = DateTime.now();
    await repo.insert(
      RecurringModel(
        id: 0,
        payee: 'Due Soon Internet',
        amount: 3000,
        type: 'expense',
        frequency: 'monthly',
        startDate: now.add(const Duration(days: 5)),
        nextDueDate: now.add(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repo.insert(
      RecurringModel(
        id: 0,
        payee: 'Far Away Insurance',
        amount: 15000,
        type: 'expense',
        frequency: 'yearly',
        startDate: now.add(const Duration(days: 90)),
        nextDueDate: now.add(const Duration(days: 90)),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RecurringScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Upcoming & Due only shows Due Soon Internet
    expect(find.text('Due Soon Internet'), findsOneWidget);
    expect(find.text('Far Away Insurance'), findsNothing);

    // Switch to All Subscriptions
    await tester.tap(find.text('All Subscriptions'));
    await tester.pumpAndSettle();
    expect(find.text('Far Away Insurance'), findsOneWidget);

    // Back to Upcoming and test Mark as Paid validation
    await tester.tap(find.text('Upcoming & Due'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as Paid'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount Paid (KES)'),
      '0',
    );
    await tester.tap(find.text('Confirm Paid'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a positive amount'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  testWidgets('AddEditRecurringScreen validates interval >= 1 and clears endDate cleanly',
      (tester) async {
    final now = DateTime.now();
    final id = await repo.insert(
      RecurringModel(
        id: 0,
        payee: 'Gym',
        amount: 2500,
        type: 'expense',
        frequency: 'monthly',
        startDate: now,
        nextDueDate: now,
        endDate: now.add(const Duration(days: 60)),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final saved = (await repo.watchAll().first).single;

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: AddEditRecurringScreen(recurringToEdit: saved),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Invalid interval 0 is rejected
    await tester.enterText(find.widgetWithText(TextFormField, 'Interval'), '0');
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Must be >= 1'));
    expect(find.text('Must be >= 1'), findsOneWidget);

    // Fix interval, clear endDate, save
    await tester.enterText(find.widgetWithText(TextFormField, 'Interval'), '1');
    await tester.ensureVisible(find.byIcon(Icons.clear).first);
    await tester.tap(find.byIcon(Icons.clear).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    final afterEdit = (await db.select(db.recurringTransactions).get())
        .firstWhere((r) => r.id == id);
    expect(afterEdit.endDate, isNull);
  });
}
