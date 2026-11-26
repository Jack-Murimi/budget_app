import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/repositories/account_repository.dart';
import 'package:budget_app/features/budgets/repositories/budget_repository.dart';
import 'package:budget_app/features/debts/repositories/debt_repository.dart';
import 'package:budget_app/features/goals/repositories/goal_repository.dart';
import 'package:budget_app/features/home/screens/home_screen.dart';
import 'package:budget_app/features/more/screens/more_screen.dart';
import 'package:budget_app/features/portability/providers/backup_reminder_provider.dart';
import 'package:budget_app/features/portability/screens/data_portability_screen.dart';
import 'package:budget_app/features/recurring/models/recurring_model.dart';
import 'package:budget_app/features/recurring/repositories/recurring_repository.dart';
import 'package:budget_app/features/transactions/models/transaction_model.dart';
import 'package:budget_app/features/transactions/repositories/transaction_repository.dart';
import 'package:budget_app/main.dart';
import 'package:budget_app/shared/providers/theme_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BackupReminderState', () {
    test('evaluates 30-day interval, dismissal, and tracking guards accurately',
        () {
      final now = DateTime(2026, 11, 26, 12);

      // Disabled tracking (no SharedPreferences) -> hidden
      expect(
        const BackupReminderState(isTrackingEnabled: false)
            .shouldShow(hasTransactions: true, now: now),
        isFalse,
      );

      // Empty database -> hidden
      expect(
        const BackupReminderState()
            .shouldShow(hasTransactions: false, now: now),
        isFalse,
      );

      // Never backed up + has transactions -> shown
      const never = BackupReminderState();
      expect(never.daysSinceLastBackup(now: now), isNull);
      expect(never.shouldShow(hasTransactions: true, now: now), isTrue);

      // Recent backup (< 30 days) -> hidden
      final recent = BackupReminderState(
        lastBackupAt: now.subtract(const Duration(days: 12)),
      );
      expect(recent.daysSinceLastBackup(now: now), 12);
      expect(recent.shouldShow(hasTransactions: true, now: now), isFalse);

      // Stale backup (>= 30 days) -> shown
      final stale = BackupReminderState(
        lastBackupAt: now.subtract(const Duration(days: 35)),
      );
      expect(stale.daysSinceLastBackup(now: now), 35);
      expect(stale.shouldShow(hasTransactions: true, now: now), isTrue);

      // Dismissed recently (< 30 days) -> hidden
      final dismissedRecently = BackupReminderState(
        lastBackupAt: now.subtract(const Duration(days: 40)),
        dismissedAt: now.subtract(const Duration(days: 10)),
      );
      expect(
        dismissedRecently.shouldShow(hasTransactions: true, now: now),
        isFalse,
      );

      // Dismissed >= 30 days ago -> shown again
      final dismissedLongAgo = BackupReminderState(
        lastBackupAt: now.subtract(const Duration(days: 70)),
        dismissedAt: now.subtract(const Duration(days: 31)),
      );
      expect(
        dismissedLongAgo.shouldShow(hasTransactions: true, now: now),
        isTrue,
      );
    });
  });

  group('BackupReminderBanner widgets', () {
    testWidgets('HomeScreen shows reminder banner when overdue and persists dismiss',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      addTearDown(db.close);

      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              header: 'Coffee',
              amount: 150,
              transactionDate: DateTime(2026, 11, 20),
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

      expect(find.text('Back up your data'), findsOneWidget);
      expect(
        find.textContaining("haven't exported an encrypted backup yet"),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();

      expect(find.text('Back up your data'), findsNothing);
      expect(prefs.getInt(kBackupReminderDismissedAtKey), isNotNull);
    });

    testWidgets(
        'MoreScreen shows days-ago banner and hides when markBackedUp runs',
        (tester) async {
      final staleMs = DateTime.now()
          .subtract(const Duration(days: 35))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        kLastBackupAtKey: staleMs,
        kBackupReminderDismissedAtKey: DateTime.now()
            .subtract(const Duration(days: 32))
            .millisecondsSinceEpoch,
      });
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      addTearDown(db.close);

      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              header: 'Groceries',
              amount: 800,
              transactionDate: DateTime(2026, 11, 22),
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
          child: const MaterialApp(home: MoreScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back up your data'), findsOneWidget);
      expect(
        find.textContaining('Last backup was 35 days ago'),
        findsOneWidget,
      );

      await container.read(backupReminderProvider.notifier).markBackedUp();
      await tester.pumpAndSettle();

      expect(find.text('Back up your data'), findsNothing);
      expect(prefs.getInt(kLastBackupAtKey), greaterThan(staleMs));
      expect(prefs.getInt(kBackupReminderDismissedAtKey), isNull);
    });

    testWidgets(
        'DataPortabilityScreen notifies on encrypted backup & full CSV export only when saved',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final tempDir = Directory.systemTemp.createTempSync('backup_callback_');
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      });

      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              header: 'Test Item',
              amount: 250,
              transactionDate: DateTime(2026, 11, 25),
            ),
          );

      var completedCount = 0;
      var cancelSave = true;
      final outFile = File(p.join(tempDir.path, 'backup.json'));

      await tester.pumpWidget(
        MaterialApp(
          home: DataPortabilityScreen(
            db: db,
            pickSaveLocation: ({suggestedName}) async {
              if (cancelSave) return null;
              return FileSaveLocation(outFile.path);
            },
            pickDirectoryPath: () async => tempDir.path,
            onBackupCompleted: () => completedCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> waitWhileBusy() async {
        for (var i = 0; i < 400; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump();
          if (find.byType(LinearProgressIndicator).evaluate().isEmpty) {
            return;
          }
        }
      }

      // Cancelled encrypted backup must NOT fire callback
      await tester.tap(find.text('Create encrypted backup'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Passphrase'),
        'strong-passphrase',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm passphrase'),
        'strong-passphrase',
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await waitWhileBusy();
      await tester.pumpAndSettle();
      expect(completedCount, 0);

      // Saved encrypted backup fires callback
      cancelSave = false;
      await tester.tap(find.text('Create encrypted backup'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Passphrase'),
        'strong-passphrase',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm passphrase'),
        'strong-passphrase',
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await waitWhileBusy();
      await tester.pumpAndSettle();
      expect(completedCount, 1);

      // Full CSV export to folder fires callback
      await tester.tap(find.text('Export CSV files'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export all to folder'));
      await tester.pump();
      await waitWhileBusy();
      await tester.pumpAndSettle();
      expect(completedCount, 2);
    });
  });

  group('Foreign Key Audit', () {
    test(
        'PRAGMA foreign_key_check stays clean and cascade deletes clean child tables',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      addTearDown(db.close);

      final accountId = await db.into(db.accounts).insert(
            AccountsCompanion.insert(name: 'Test Wallet'),
          );
      final cat1 = await db.into(db.categories).insert(
            CategoriesCompanion.insert(name: 'Audit Cat 1'),
          );
      final cat2 = await db.into(db.categories).insert(
            CategoriesCompanion.insert(name: 'Audit Cat 2'),
          );

      // 1. budget_categories cascades on budget delete
      final budgetRepo = BudgetRepository(db);
      final budgetId = await budgetRepo.insertBudget(
        BudgetsCompanion.insert(
          name: 'Audit Budget',
          amount: 5000,
          startDate: DateTime(2026, 11, 1),
        ),
        categoryIds: [cat1, cat2],
      );
      expect(
        await (db.select(db.budgetCategories)
              ..where((bc) => bc.budgetId.equals(budgetId)))
            .get(),
        hasLength(2),
      );
      await (db.delete(db.budgets)..where((b) => b.id.equals(budgetId))).go();
      expect(
        await (db.select(db.budgetCategories)
              ..where((bc) => bc.budgetId.equals(budgetId)))
            .get(),
        isEmpty,
      );

      // 2. transaction_splits cascades on transaction delete
      final txnRepo = TransactionRepository(db);
      final splitTxnId = (await txnRepo.insertWithSplits(
        TransactionsCompanion.insert(
          header: 'Naivas Audit',
          amount: 1000,
          type: const Value('expense'),
          transactionDate: DateTime(2026, 11, 10),
          accountId: Value(accountId),
        ),
        [
          TransactionSplitModel(categoryId: cat1, amount: 600),
          TransactionSplitModel(categoryId: cat2, amount: 400),
        ],
      ))!;
      expect(
        await (db.select(db.transactionSplits)
              ..where((s) => s.transactionId.equals(splitTxnId)))
            .get(),
        hasLength(2),
      );
      await (db.delete(db.transactions)..where((t) => t.id.equals(splitTxnId)))
          .go();
      expect(
        await (db.select(db.transactionSplits)
              ..where((s) => s.transactionId.equals(splitTxnId)))
            .get(),
        isEmpty,
      );

      // 3. payee_category_rules cascades on category delete
      final catRuleTarget = await db.into(db.categories).insert(
            CategoriesCompanion.insert(name: 'Rule Cascade Target'),
          );
      await db.into(db.payeeCategoryRules).insert(
            PayeeCategoryRulesCompanion.insert(
              payeePattern: 'java house',
              categoryId: catRuleTarget,
              updatedAt: DateTime(2026, 11, 10),
            ),
          );
      await (db.delete(db.categories)
            ..where((c) => c.id.equals(catRuleTarget)))
          .go();
      expect(
        await (db.select(db.payeeCategoryRules)
              ..where((r) => r.payeePattern.equals('java house')))
            .get(),
        isEmpty,
      );

      // 4. Repository deletes across recurring, debts, goals, and accounts
      final recurringRepo = RecurringRepository(db);
      final recId = await recurringRepo.insert(
        RecurringModel(
          id: 0,
          accountId: accountId,
          categoryId: cat1,
          amount: 1200,
          type: 'expense',
          payee: 'ISP',
          notes: '',
          frequency: 'monthly',
          intervalCount: 1,
          startDate: DateTime(2026, 11, 1),
          nextDueDate: DateTime(2026, 11, 1),
          autoRecord: false,
          notify: true,
          isActive: true,
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 1),
        ),
      );
      await recurringRepo.delete(recId);

      final debtRepo = DebtRepository(db);
      final debtId = await debtRepo.create(
        direction: 'borrowed',
        counterparty: 'Audit Lender',
        principal: 1000,
        interest: 0,
        product: 'personal',
        accountId: accountId,
      );
      await debtRepo.deleteDebt(debtId, deleteLinkedTransactions: true);

      final goalRepo = GoalRepository(db);
      final goalId = await goalRepo.create(name: 'Audit Goal', targetAmount: 2000);
      await goalRepo.contribute(
        goalId: goalId,
        amount: 500,
        accountId: accountId,
      );
      await goalRepo.delete(goalId, deleteLinkedTransactions: true);

      final accountRepo = AccountRepository(db);
      await accountRepo.deleteAccount(accountId);

      final fkViolations =
          await db.customSelect('PRAGMA foreign_key_check').get();
      expect(fkViolations, isEmpty);
    });
  });
}
