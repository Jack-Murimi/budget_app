// ignore_for_file: experimental_member_use
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'converters/cents_converter.dart';
import 'tables/accounts_table.dart';
import 'tables/budgets_table.dart';
import 'tables/categories_table.dart';
import 'tables/debts_table.dart';
import 'tables/fuliza_records_table.dart';
import 'tables/payee_category_rules_table.dart';
import 'tables/recurring_transactions_table.dart';
import 'tables/savings_goals_table.dart';
import 'tables/sms_inbox_items_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Transactions,
  Categories,
  FulizaRecords,
  Accounts,
  Budgets,
  RecurringTransactions,
  Debts,
  DebtRepayments,
  SavingsGoals,
  GoalContributions,
  PayeeCategoryRules,
  SmsInboxItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For use in tests only — uses provided executor directly.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 18;

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info("$table")').get();
    return rows.any((row) => row.read<String>('name') == column);
  }

  static Expression<int> _realToCents(String columnName) =>
      CustomExpression<int>('CAST(ROUND("$columnName" * 100) AS INTEGER)');

  static Expression<int> _nullableRealToCents(String columnName) =>
      CustomExpression<int>(
        'CASE WHEN "$columnName" IS NULL THEN NULL '
        'ELSE CAST(ROUND("$columnName" * 100) AS INTEGER) END',
      );

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createPerformanceIndexes();
          await _seedDefaultCategories();
          await _seedDefaultAccounts();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createIndex(
              Index('transactions',
                  'CREATE UNIQUE INDEX IF NOT EXISTS idx_transactions_mpesa_ref ON transactions (mpesa_ref) WHERE mpesa_ref IS NOT NULL'),
            );
          }
          if (from < 3) {
            await m.addColumn(transactions, transactions.fulizaAmount);
            await m.addColumn(transactions, transactions.fulizaFee);
            await m.createTable(fulizaRecords);
          }
          if (from < 4) {
            await customStatement(
              'DELETE FROM fuliza_records WHERE id NOT IN (SELECT MAX(id) FROM fuliza_records GROUP BY mpesa_ref)',
            );
            await m.createIndex(
              Index('fuliza_records',
                  'CREATE UNIQUE INDEX IF NOT EXISTS idx_fuliza_records_mpesa_ref ON fuliza_records (mpesa_ref)'),
            );
          }
          if (from < 5) {
            await m.addColumn(categories, categories.isArchived);
            await m.addColumn(categories, categories.sortOrder);
          }
          if (from < 6) {
            await m.createTable(accounts);
            await m.addColumn(transactions, transactions.accountId);
            await m.addColumn(transactions, transactions.toAccountId);
            final mpesaId = await into(accounts).insert(
              AccountsCompanion.insert(
                name: 'M-Pesa',
                type: const Value('mpesa'),
                colorHex: const Value('#1B5E20'),
                icon: const Value('phone_android'),
                isDefault: const Value(true),
              ),
            );
            await into(accounts).insert(
              AccountsCompanion.insert(
                name: 'Cash',
                type: const Value('cash'),
                colorHex: const Value('#4CAF50'),
                icon: const Value('payments'),
              ),
            );
            await into(accounts).insert(
              AccountsCompanion.insert(
                name: 'Bank',
                type: const Value('bank'),
                colorHex: const Value('#1976D2'),
                icon: const Value('account_balance'),
              ),
            );
            await customUpdate(
              'UPDATE transactions SET account_id = ? WHERE account_id IS NULL',
              variables: [Variable.withInt(mpesaId)],
              updates: {transactions},
            );
          }
          if (from < 7) {
            await m.createTable(budgets);
            await m.addColumn(transactions, transactions.excludeFromBudget);
          }
          if (from < 8) {
            await customStatement('''
          CREATE TABLE IF NOT EXISTS recurring_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_id INTEGER REFERENCES accounts(id),
            category_id INTEGER REFERENCES categories(id),
            amount REAL NOT NULL,
            type TEXT NOT NULL DEFAULT 'expense',
            payee TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT '',
            frequency TEXT NOT NULL DEFAULT 'monthly',
            interval_count INTEGER NOT NULL DEFAULT 1,
            start_date INTEGER NOT NULL,
            end_date INTEGER,
            next_due_date INTEGER NOT NULL,
            auto_record INTEGER NOT NULL DEFAULT 0,
            notify INTEGER NOT NULL DEFAULT 1,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
            if (!await _columnExists('transactions', 'recurrence_id')) {
              await customStatement(
                'ALTER TABLE transactions ADD COLUMN recurrence_id INTEGER REFERENCES recurring_transactions(id)',
              );
            }
            if (!await _columnExists('transactions', 'is_recurring')) {
              await customStatement(
                'ALTER TABLE transactions ADD COLUMN is_recurring INTEGER NOT NULL DEFAULT 0',
              );
            }
          }
          if (from < 9) {
            await m.createTable(debts);
            await m.createTable(debtRepayments);
          }
          if (from < 10) {
            await m.addColumn(transactions, transactions.debtId);
          }
          if (from < 11) {
            await m.createTable(savingsGoals);
            await m.createTable(goalContributions);
          }
          if (from < 12) {
            await m.createTable(payeeCategoryRules);
            await m.createTable(smsInboxItems);
          }
          if (from < 13) {
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_transactions_header ON transactions (header)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_transactions_header_cat ON transactions (header, category_id)',
            );
          }
          if (from < 14) {
            if (!await _columnExists('categories', 'transaction_type')) {
              await m.addColumn(categories, categories.transactionType);
            }
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_categories_type ON categories (transaction_type)',
            );
            // Re-seed taxonomy for existing users
            await _seedDefaultCategories();
          }
          if (from < 15) {
            await customStatement('''
              INSERT INTO categories (name, icon, color_hex, transaction_type, is_default, parent_id, sort_order)
              SELECT 'Loan Given', 'handshake', '#00838F', 'expense', 1, NULL, 0
              WHERE NOT EXISTS (
                SELECT 1 FROM categories WHERE name = 'Loan Given' AND transaction_type = 'expense'
              );
            ''');
            await customStatement('''
              INSERT INTO categories (name, icon, color_hex, transaction_type, is_default, parent_id, sort_order)
              SELECT 'Loan Repayment Received', 'handshake', '#43A047', 'income', 1, NULL, 0
              WHERE NOT EXISTS (
                SELECT 1 FROM categories WHERE name = 'Loan Repayment Received' AND transaction_type = 'income'
              );
            ''');
            await customStatement('''
              INSERT INTO categories (name, icon, color_hex, transaction_type, is_default, parent_id, sort_order)
              SELECT 'Loan Received', 'handshake', '#00838F', 'income', 1, NULL, 0
              WHERE NOT EXISTS (
                SELECT 1 FROM categories WHERE name = 'Loan Received' AND transaction_type = 'income'
              );
            ''');
          }
          if (from < 16) {
            if (!await _columnExists('debts', 'disbursement_shortfall')) {
              await m.addColumn(debts, debts.disbursementShortfall);
            }
          }
          if (from < 17) {
            // Convert all monetary REAL columns to exact INTEGER cents (KES * 100)
            // using Drift's TableMigration so SQLite column affinity becomes INTEGER.
            await m.alterTable(
              TableMigration(
                accounts,
                columnTransformer: {
                  accounts.initialBalance: _realToCents('initial_balance'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                budgets,
                columnTransformer: {
                  budgets.amount: _realToCents('amount'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                fulizaRecords,
                columnTransformer: {
                  fulizaRecords.fulizaAmount: _realToCents('fuliza_amount'),
                  fulizaRecords.accessFee: _realToCents('access_fee'),
                  fulizaRecords.outstandingTotal:
                      _realToCents('outstanding_total'),
                },
              ),
            );
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_fuliza_records_mpesa_ref ON fuliza_records (mpesa_ref)',
            );
            await m.alterTable(
              TableMigration(
                recurringTransactions,
                columnTransformer: {
                  recurringTransactions.amount: _realToCents('amount'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                debts,
                columnTransformer: {
                  debts.principal: _realToCents('principal'),
                  debts.outstanding: _realToCents('outstanding'),
                  debts.interest: _realToCents('interest'),
                  debts.disbursementShortfall:
                      _realToCents('disbursement_shortfall'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                debtRepayments,
                columnTransformer: {
                  debtRepayments.amount: _realToCents('amount'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                savingsGoals,
                columnTransformer: {
                  savingsGoals.targetAmount: _realToCents('target_amount'),
                  savingsGoals.currentAmount: _realToCents('current_amount'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                goalContributions,
                columnTransformer: {
                  goalContributions.amount: _realToCents('amount'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                smsInboxItems,
                columnTransformer: {
                  smsInboxItems.parsedAmount:
                      _nullableRealToCents('parsed_amount'),
                },
              ),
            );
            await m.alterTable(
              TableMigration(
                transactions,
                columnTransformer: {
                  transactions.amount: _realToCents('amount'),
                  transactions.transactionCost:
                      _realToCents('transaction_cost'),
                  transactions.fulizaAmount: _realToCents('fuliza_amount'),
                  transactions.fulizaFee: _realToCents('fuliza_fee'),
                },
              ),
            );
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_transactions_mpesa_ref ON transactions (mpesa_ref) WHERE mpesa_ref IS NOT NULL',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_transactions_header ON transactions (header)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_transactions_header_cat ON transactions (header, category_id)',
            );
          }
          if (from < 18) {
            await _createPerformanceIndexes();
            await _cleanupLegacyDuplicateCategories();
            final catCount = await customSelect(
              'SELECT COUNT(*) AS cnt FROM categories',
            ).getSingle();
            if (catCount.read<int>('cnt') == 0) {
              await _seedDefaultCategories();
            }
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createPerformanceIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_header ON transactions (header)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_header_cat ON transactions (header, category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_categories_type ON categories (transaction_type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions (transaction_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions (account_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_to_account_id ON transactions (to_account_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions (category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_debt_id ON transactions (debt_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_debt_repayments_debt_id ON debt_repayments (debt_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_goal_contributions_goal_id ON goal_contributions (goal_id)',
    );
  }

  Future<void> _cleanupLegacyDuplicateCategories() async {
    // Cleanup: migrate foreign keys pointing to legacy duplicate categories, then remove them
    await customStatement('''
      UPDATE transactions
      SET category_id = (
        SELECT new_c.id FROM categories new_c
        JOIN categories old_c ON old_c.name = new_c.name
        WHERE old_c.id = transactions.category_id
          AND old_c.id != new_c.id
          AND old_c.name IN ('Transport', 'Health', 'Education', 'Other')
        ORDER BY new_c.id DESC LIMIT 1
      )
      WHERE category_id IN (
        SELECT old_c.id FROM categories old_c
        WHERE old_c.name IN ('Transport', 'Health', 'Education', 'Other')
          AND old_c.id NOT IN (
            SELECT MAX(id) FROM categories GROUP BY name
          )
      );
    ''');

    await customStatement('''
      UPDATE recurring_transactions
      SET category_id = (
        SELECT new_c.id FROM categories new_c
        JOIN categories old_c ON old_c.name = new_c.name
        WHERE old_c.id = recurring_transactions.category_id
          AND old_c.id != new_c.id
          AND old_c.name IN ('Transport', 'Health', 'Education', 'Other')
        ORDER BY new_c.id DESC LIMIT 1
      )
      WHERE category_id IN (
        SELECT old_c.id FROM categories old_c
        WHERE old_c.name IN ('Transport', 'Health', 'Education', 'Other')
          AND old_c.id NOT IN (
            SELECT MAX(id) FROM categories GROUP BY name
          )
      );
    ''');

    await customStatement('''
      UPDATE budgets
      SET category_id = (
        SELECT new_c.id FROM categories new_c
        JOIN categories old_c ON old_c.name = new_c.name
        WHERE old_c.id = budgets.category_id
          AND old_c.id != new_c.id
          AND old_c.name IN ('Transport', 'Health', 'Education', 'Other')
        ORDER BY new_c.id DESC LIMIT 1
      )
      WHERE category_id IN (
        SELECT old_c.id FROM categories old_c
        WHERE old_c.name IN ('Transport', 'Health', 'Education', 'Other')
          AND old_c.id NOT IN (
            SELECT MAX(id) FROM categories GROUP BY name
          )
      );
    ''');

    // Delete obsolete and duplicate old categories
    await customStatement('''
      DELETE FROM categories
      WHERE name IN ('Food & Dining', 'Shopping', 'Bills & Utilities', 'Entertainment', 'Savings', 'Income', 'Transfer')
        AND is_default = 1
        AND id NOT IN (SELECT DISTINCT category_id FROM transactions WHERE category_id IS NOT NULL);
    ''');

    // Remove duplicate older rows of Transport, Health, Education, Other (keep the newest)
    await customStatement('''
      DELETE FROM categories
      WHERE name IN ('Transport', 'Health', 'Education', 'Other')
        AND is_default = 1
        AND id NOT IN (
          SELECT MAX(id) FROM categories GROUP BY name, transaction_type
        )
        AND id NOT IN (SELECT DISTINCT category_id FROM transactions WHERE category_id IS NOT NULL);
    ''');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'budget_app_db');
  }

  Future<void> _seedDefaultCategories() async {
    // Helper to insert and return the new ID
    Future<int> addCat(
      String name,
      String icon,
      String color, {
      int? parentId,
      String type = 'expense',
    }) async {
      return await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          icon: Value(icon),
          colorHex: Value(color),
          transactionType: Value(type),
          isDefault: const Value(true),
          parentId: Value(parentId),
        ),
      );
    }

    // ════════════════════════════════════════════════════════════════════════
    // EXPENSE CATEGORIES & SUBCATEGORIES
    // ════════════════════════════════════════════════════════════════════════

    // 1. Food & Groceries
    final food = await addCat('Food & Groceries', 'local_grocery_store', '#E53935');
    await addCat('Supermarket', 'shopping_cart', '#E53935', parentId: food);
    await addCat('Market / Mama Mboga', 'store', '#E53935', parentId: food);
    await addCat('Eating Out', 'restaurant', '#E53935', parentId: food);
    await addCat('Delivery (Glovo/Uber Eats)', 'delivery_dining', '#E53935', parentId: food);
    await addCat('Snacks & Drinks', 'local_cafe', '#E53935', parentId: food);

    // 2. Housing
    final housing = await addCat('Housing', 'home', '#5D4037');
    await addCat('Rent', 'home', '#5D4037', parentId: housing);
    await addCat('Service Charge', 'receipt_long', '#5D4037', parentId: housing);
    await addCat('Repairs & Maintenance', 'build', '#5D4037', parentId: housing);
    await addCat('Furniture & Household Items', 'chair', '#5D4037', parentId: housing);

    // 3. Utilities & Bills
    final utilities = await addCat('Utilities & Bills', 'bolt', '#F4511E');
    await addCat('Electricity (KPLC tokens)', 'bolt', '#F4511E', parentId: utilities);
    await addCat('Water', 'water_drop', '#F4511E', parentId: utilities);
    await addCat('Internet / WiFi', 'wifi', '#F4511E', parentId: utilities);
    await addCat('Airtime & Bundles', 'phone_android', '#F4511E', parentId: utilities);
    await addCat('TV (DStv/Showmax)', 'tv', '#F4511E', parentId: utilities);

    // 4. Transport
    final transport = await addCat('Transport', 'directions_car', '#1E88E5');
    await addCat('Matatu / Bus', 'directions_bus', '#1E88E5', parentId: transport);
    await addCat('Boda / Uber / Bolt', 'local_taxi', '#1E88E5', parentId: transport);
    await addCat('Fuel', 'local_gas_station', '#1E88E5', parentId: transport);
    await addCat('Parking', 'local_parking', '#1E88E5', parentId: transport);
    await addCat('Car Maintenance & Insurance', 'build', '#1E88E5', parentId: transport);

    // 5. Health
    final health = await addCat('Health', 'favorite', '#E91E63');
    await addCat('Hospital / Clinic', 'local_hospital', '#E91E63', parentId: health);
    await addCat('Pharmacy', 'medication', '#E91E63', parentId: health);
    await addCat('SHA / Insurance', 'security', '#E91E63', parentId: health);
    await addCat('Fitness', 'fitness_center', '#E91E63', parentId: health);

    // 6. Education
    final education = await addCat('Education', 'school', '#00897B');
    await addCat('School Fees', 'school', '#00897B', parentId: education);
    await addCat('Books & Supplies', 'menu_book', '#00897B', parentId: education);
    await addCat('Courses & Training', 'laptop', '#00897B', parentId: education);

    // 7. Family & Dependants
    final family = await addCat('Family & Dependants', 'groups', '#8E24AA');
    await addCat('Upkeep / Remittances', 'send', '#8E24AA', parentId: family);
    await addCat('Childcare', 'face', '#8E24AA', parentId: family);
    await addCat('Gifts & Support', 'card_giftcard', '#8E24AA', parentId: family);
    await addCat('Harambee / Contributions', 'groups', '#8E24AA', parentId: family);

    // 8. Personal & Lifestyle
    final lifestyle = await addCat('Personal & Lifestyle', 'checkroom', '#D81B60');
    await addCat('Clothing', 'checkroom', '#D81B60', parentId: lifestyle);
    await addCat('Beauty & Grooming', 'face', '#D81B60', parentId: lifestyle);
    await addCat('Entertainment', 'movie', '#D81B60', parentId: lifestyle);
    await addCat('Subscriptions', 'repeat', '#D81B60', parentId: lifestyle);
    await addCat('Travel & Holidays', 'flight', '#D81B60', parentId: lifestyle);
    await addCat('Betting / Gaming', 'videogame_asset', '#D81B60', parentId: lifestyle);

    // 9. Fees & Charges
    final fees = await addCat('Fees & Charges', 'money_off', '#78909C');
    await addCat('M-Pesa Transaction Fees', 'receipt_long', '#78909C', parentId: fees);
    await addCat('Withdrawal Fees', 'payments', '#78909C', parentId: fees);
    await addCat('Bank Fees', 'account_balance', '#78909C', parentId: fees);
    await addCat('Fuliza / Overdraft Fees', 'sync_problem', '#78909C', parentId: fees);
    await addCat('Excise Duty', 'account_balance_wallet', '#78909C', parentId: fees);

    // 10. Debt Repayment
    final debtRepay = await addCat('Debt Repayment', 'credit_card', '#C62828');
    await addCat('Loan Repayment', 'handshake', '#C62828', parentId: debtRepay);
    await addCat('Fuliza Repayment', 'sync', '#C62828', parentId: debtRepay);
    await addCat('Mobile Loans (Tala/Branch/M-Shwari)', 'phone_android', '#C62828', parentId: debtRepay);
    await addCat('Credit Card', 'credit_card', '#C62828', parentId: debtRepay);

    // 11. Business
    final business = await addCat('Business', 'store', '#00ACC1');
    await addCat('Stock / Supplies', 'inventory_2', '#00ACC1', parentId: business);
    await addCat('Operating Costs', 'receipt_long', '#00ACC1', parentId: business);
    await addCat('Staff', 'groups', '#00ACC1', parentId: business);
    await addCat('Licences & Taxes', 'account_balance', '#00ACC1', parentId: business);

    // 12. Other (Expense)
    final otherExp = await addCat('Other', 'more_horiz', '#757575');
    await addCat('Uncategorized', 'help_outline', '#757575', parentId: otherExp);
    await addCat('Loan Given', 'handshake', '#00838F');

    // ════════════════════════════════════════════════════════════════════════
    // INCOME CATEGORIES & SUBCATEGORIES
    // ════════════════════════════════════════════════════════════════════════
    await addCat('Salary', 'work', '#43A047', type: 'income');
    await addCat('Business / Side Hustle', 'store', '#2E7D32', type: 'income');
    await addCat('Received Money', 'volunteer_activism', '#388E3C', type: 'income');

    final investments = await addCat('Investments', 'savings', '#1B5E20', type: 'income');
    await addCat('Interest', 'trending_up', '#1B5E20', parentId: investments, type: 'income');
    await addCat('Dividends', 'attach_money', '#1B5E20', parentId: investments, type: 'income');
    await addCat('Sacco Returns', 'groups', '#1B5E20', parentId: investments, type: 'income');
    await addCat('Money Market (MMF)', 'account_balance', '#1B5E20', parentId: investments, type: 'income');
    await addCat('Rent Received', 'home', '#1B5E20', parentId: investments, type: 'income');

    await addCat('Gifts & Refunds', 'card_giftcard', '#66BB6A', type: 'income');
    await addCat('Other Income', 'add_circle_outline', '#81C784', type: 'income');
    await addCat('Loan Repayment Received', 'handshake', '#43A047', type: 'income');
    await addCat('Loan Received', 'handshake', '#00838F', type: 'income');

    // ════════════════════════════════════════════════════════════════════════
    // TRANSFER CATEGORIES & SUBCATEGORIES
    // ════════════════════════════════════════════════════════════════════════
    await addCat('Savings / Chama / Sacco Contribution', 'savings', '#0277BD', type: 'transfer');
    await addCat('Own-account transfer (M-Pesa ↔ bank ↔ cash)', 'swap_horiz', '#455A64', type: 'transfer');
    await addCat('Loan received (borrowed principal)', 'account_balance', '#00838F', type: 'transfer');
  }

  Future<void> _seedDefaultAccounts() async {
    final existing = await (select(accounts)..limit(1)).get();
    if (existing.isNotEmpty) return;
    await into(accounts).insert(
      AccountsCompanion.insert(
        name: 'M-Pesa',
        type: const Value('mpesa'),
        colorHex: const Value('#1B5E20'),
        icon: const Value('phone_android'),
        isDefault: const Value(true),
      ),
    );
    await into(accounts).insert(
      AccountsCompanion.insert(
        name: 'Cash',
        type: const Value('cash'),
        colorHex: const Value('#4CAF50'),
        icon: const Value('payments'),
      ),
    );
    await into(accounts).insert(
      AccountsCompanion.insert(
        name: 'Bank',
        type: const Value('bank'),
        colorHex: const Value('#1976D2'),
        icon: const Value('account_balance'),
      ),
    );
  }
}
