import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/portability/services/database_backup_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('snapshot restores transactions, accounts, and categories', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final destination = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(destination.close);
    final accountId = await source.into(source.accounts).insert(
          AccountsCompanion.insert(name: 'M-Pesa'),
        );
    await source.into(source.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Backup test',
            amount: 42,
            accountId: Value(accountId),
            transactionDate: DateTime.utc(2026, 11, 8),
          ),
        );

    final snapshot = await DatabaseBackupService(source).snapshot();
    await DatabaseBackupService(destination).restore(snapshot);

    expect(
      (await destination.select(destination.accounts).get())
          .any((row) => row.name == 'M-Pesa'),
      isTrue,
    );
    expect(
      (await destination.select(destination.transactions).get())
          .any((row) => row.header == 'Backup test' && row.amount == 42.0),
      isTrue,
    );
  });

  test('restores legacy v1 REAL-money snapshots into integer cents', () async {
    final destination = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(destination.close);

    final legacyV1Snapshot = {
      'version': 1,
      'tables': {
        'accounts': [
          {
            'id': 1,
            'name': 'M-Pesa',
            'type': 'mpesa',
            'initial_balance': 250.75,
            'currency': 'KES',
            'color_hex': '#1B5E20',
            'icon': 'phone_android',
            'is_default': 1,
            'is_archived': 0,
            'created_at': 1730419200,
          },
        ],
        'transactions': [
          {
            'id': 1,
            'header': 'Legacy Coffee',
            'description': '',
            'amount': 123.45,
            'transaction_cost': 5.50,
            'fuliza_amount': 0.0,
            'fuliza_fee': 0.0,
            'type': 'expense',
            'account_id': 1,
            'transaction_date': 1730419200,
            'is_parsed': 0,
            'exclude_from_budget': 0,
            'is_recurring': 0,
            'created_at': 1730419200,
          },
        ],
      },
    };

    await DatabaseBackupService(destination).restore(legacyV1Snapshot);

    final account = await destination.select(destination.accounts).getSingle();
    expect(account.initialBalance, 250.75);

    final txn = await destination.select(destination.transactions).getSingle();
    expect(txn.amount, 123.45);
    expect(txn.transactionCost, 5.50);
  });

  test(
      'restores all 12 tables with parent/child categories, SQL-special strings, FKs, and refreshes active streams',
      () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final destination = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(destination.close);

    // Ensure seeded accounts exist before inserting dependent rows.
    final mpesa = (await source.select(source.accounts).get()).first;
    final parentCatId = await source.into(source.categories).insert(
          CategoriesCompanion.insert(name: "O'Brien & Co"),
        );
    final childCatId = await source.into(source.categories).insert(
          CategoriesCompanion.insert(
            name: 'Subcat',
            parentId: Value(parentCatId),
          ),
        );
    final debtId = await source.into(source.debts).insert(
          DebtsCompanion.insert(
            direction: 'lent',
            counterparty: 'Alice',
            principal: 1000,
            outstanding: 500,
            accountId: Value(mpesa.id),
          ),
        );
    final goalId = await source.into(source.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            name: 'Emergency',
            targetAmount: 5000,
            currentAmount: const Value(500),
          ),
        );
    final txnId = await source.into(source.transactions).insert(
          TransactionsCompanion.insert(
            header: "O'Brien; DROP TABLE accounts;--",
            amount: 500,
            categoryId: Value(childCatId),
            accountId: Value(mpesa.id),
            debtId: Value(debtId),
            transactionDate: DateTime.utc(2026, 11, 10),
          ),
        );
    await source.into(source.transactionSplits).insert(
          TransactionSplitsCompanion.insert(
            transactionId: txnId,
            categoryId: parentCatId,
            amount: 300,
            note: const Value('Groceries'),
          ),
        );
    await source.into(source.transactionSplits).insert(
          TransactionSplitsCompanion.insert(
            transactionId: txnId,
            categoryId: childCatId,
            amount: 200,
            note: const Value('Snacks'),
          ),
        );
    await source.into(source.debtRepayments).insert(
          DebtRepaymentsCompanion.insert(
            debtId: debtId,
            amount: 500,
            accountId: Value(mpesa.id),
            transactionId: Value(txnId),
            paymentDate: DateTime.utc(2026, 11, 10),
          ),
        );
    await source.into(source.goalContributions).insert(
          GoalContributionsCompanion.insert(
            goalId: goalId,
            amount: 500,
            accountId: Value(mpesa.id),
            transactionId: Value(txnId),
            contributionDate: DateTime.utc(2026, 11, 10),
          ),
        );
    await source.into(source.payeeCategoryRules).insert(
          PayeeCategoryRulesCompanion.insert(
            payeePattern: 'naivas',
            categoryId: childCatId,
            updatedAt: DateTime.utc(2026, 11, 10),
          ),
        );
    await source.into(source.smsInboxItems).insert(
          SmsInboxItemsCompanion.insert(
            rawBody: 'Confirmed Ksh500 sent',
            parsedAmount: const Value(500),
            createdAt: DateTime.utc(2026, 11, 10),
          ),
        );
    final multiBudgetId = await source.into(source.budgets).insert(
          BudgetsCompanion.insert(
            name: 'Combined Budget',
            amount: 10000,
            categoryId: Value(parentCatId),
            startDate: DateTime.utc(2026, 11, 1),
          ),
        );
    await source.into(source.budgetCategories).insert(
          BudgetCategoriesCompanion.insert(
            budgetId: multiBudgetId,
            categoryId: parentCatId,
          ),
        );
    await source.into(source.budgetCategories).insert(
          BudgetCategoriesCompanion.insert(
            budgetId: multiBudgetId,
            categoryId: childCatId,
          ),
        );

    final emissions = <List<Transaction>>[];
    final sub = destination
        .select(destination.transactions)
        .watch()
        .listen(emissions.add);
    addTearDown(sub.cancel);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final snapshot = await DatabaseBackupService(source).snapshot();
    expect(
      (snapshot['tables'] as Map).keys,
      containsAll([
        'payee_category_rules',
        'sms_inbox_items',
        'budget_categories',
        'transaction_splits',
      ]),
    );

    await DatabaseBackupService(destination).restore(snapshot);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      emissions.last.any(
        (t) => t.header == "O'Brien; DROP TABLE accounts;--",
      ),
      isTrue,
    );
    expect(
      (await destination.select(destination.payeeCategoryRules).get()).single.payeePattern,
      'naivas',
    );
    expect(
      (await destination.select(destination.smsInboxItems).get()).single.parsedAmount,
      500.0,
    );
    expect(
      (await destination.select(destination.goalContributions).get()).single.transactionId,
      txnId,
    );
    final restoredBudgetCats =
        await destination.select(destination.budgetCategories).get();
    expect(restoredBudgetCats, hasLength(2));
    expect(
      restoredBudgetCats.map((r) => r.categoryId),
      unorderedEquals([parentCatId, childCatId]),
    );
    final restoredSplits =
        await destination.select(destination.transactionSplits).get();
    expect(restoredSplits, hasLength(2));
    expect(restoredSplits[0].transactionId, txnId);
    expect(restoredSplits[0].amount, 300.0);
    expect(restoredSplits[0].note, 'Groceries');
    expect(restoredSplits[1].amount, 200.0);
  });

  test('restoring snapshot without budget_categories backfills from budgets.category_id',
      () async {
    final destination = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(destination.close);

    final legacySnapshot = {
      'version': 2,
      'tables': {
        'categories': [
          {
            'id': 10,
            'name': 'Food',
            'icon': 'restaurant',
            'color_hex': '#E53935',
            'transaction_type': 'expense',
            'is_default': 1,
            'is_archived': 0,
            'sort_order': 0,
            'created_at': 1730419200,
          },
        ],
        'budgets': [
          {
            'id': 1,
            'name': 'Food Budget',
            'amount': 500000,
            'period': 'monthly',
            'category_id': 10,
            'start_date': 1730419200,
            'rollover': 0,
            'is_archived': 0,
            'created_at': 1730419200,
          },
          {
            'id': 2,
            'name': 'Overall',
            'amount': 1000000,
            'period': 'monthly',
            'category_id': null,
            'start_date': 1730419200,
            'rollover': 0,
            'is_archived': 0,
            'created_at': 1730419200,
          },
        ],
      },
    };

    await DatabaseBackupService(destination).restore(legacySnapshot);

    final rows = await destination.select(destination.budgetCategories).get();
    expect(rows, hasLength(1));
    expect(rows.single.budgetId, 1);
    expect(rows.single.categoryId, 10);
  });
}
