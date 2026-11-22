import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../models/account_model.dart';

class AccountRepository {
  final AppDatabase db;

  const AccountRepository(this.db);

  Stream<List<AccountWithBalance>> watchAccountsWithBalance({bool includeArchived = false}) {
    final trigger = db.customSelect(
      'SELECT 1',
      readsFrom: {db.accounts, db.transactions},
    ).watch();

    return trigger.asyncMap((_) async {
      final accounts = await getAll(includeArchived: includeArchived);
      final transactions = await db.select(db.transactions).get();

      final accountsWithBalance = accounts.map((account) {
        int balanceCents = CentsConverter.toCents(account.initialBalance);

        for (final t in transactions) {
          if (t.accountId == account.id) {
            if (t.type == 'income') {
              balanceCents += CentsConverter.toCents(t.amount);
            } else if (t.type == 'expense') {
              balanceCents -= CentsConverter.toCents(t.amount) +
                  CentsConverter.toCents(t.transactionCost) +
                  CentsConverter.toCents(t.fulizaFee);
            } else if (t.type == 'transfer') {
              balanceCents -= CentsConverter.toCents(t.amount) +
                  CentsConverter.toCents(t.transactionCost);
            }
          }

          if (t.toAccountId == account.id && t.type == 'transfer') {
            balanceCents += CentsConverter.toCents(t.amount);
          }
        }

        return AccountWithBalance(
          account: account,
          balance: CentsConverter.fromCents(balanceCents),
        );
      }).toList();

      accountsWithBalance.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });

      return accountsWithBalance;
    });
  }

  Stream<List<Transaction>> watchTransactionsByAccount(int accountId) {
    return (db.select(db.transactions)
          ..where((t) => t.accountId.equals(accountId) | t.toAccountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  Future<List<Account>> getAll({bool includeArchived = false}) {
    return (db.select(db.accounts)
      ..where((a) => includeArchived ? const Constant(true) : a.isArchived.equals(false)))
      .get();
  }

  Future<Account?> getDefaultAccount() {
    return (db.select(db.accounts)..where((a) => a.isDefault.equals(true)))
      .getSingleOrNull();
  }

  Future<int> insertAccount(AccountsCompanion account) {
    return db.into(db.accounts).insert(account);
  }

  Future<bool> updateAccount(AccountsCompanion account) async {
    final count = await (db.update(db.accounts)..where((a) => a.id.equals(account.id.value))).write(account);
    return count > 0;
  }

  Future<void> archiveAccount(int id, {bool archive = true}) {
    return (db.update(db.accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(isArchived: Value(archive)));
  }

  Future<void> setDefault(int id) async {
    await db.transaction(() async {
      await (db.update(db.accounts))
          .write(const AccountsCompanion(isDefault: Value(false)));
      await (db.update(db.accounts)..where((a) => a.id.equals(id)))
          .write(const AccountsCompanion(isDefault: Value(true)));
    });
  }

  Future<void> deleteAccount(int id) async {
    await db.transaction(() async {
      final allAccounts = await db.select(db.accounts).get();
      if (allAccounts.length <= 1) {
        throw StateError('Cannot delete the last remaining account');
      }
      final target = allAccounts.where((a) => a.id == id).firstOrNull;
      if (target == null) return;
      if (target.isDefault) {
        throw StateError(
          'Cannot delete the default account. Set another account as default first.',
        );
      }

      final hasTxn = await (db.select(db.transactions)
            ..where((t) => t.accountId.equals(id) | t.toAccountId.equals(id))
            ..limit(1))
          .getSingleOrNull();
      final hasRecurring = await (db.select(db.recurringTransactions)
            ..where((r) => r.accountId.equals(id))
            ..limit(1))
          .getSingleOrNull();
      final hasDebt = await (db.select(db.debts)
            ..where((d) => d.accountId.equals(id))
            ..limit(1))
          .getSingleOrNull();
      final hasRepay = await (db.select(db.debtRepayments)
            ..where((r) => r.accountId.equals(id))
            ..limit(1))
          .getSingleOrNull();
      final hasGoal = await (db.select(db.goalContributions)
            ..where((c) => c.accountId.equals(id))
            ..limit(1))
          .getSingleOrNull();

      if (hasTxn != null ||
          hasRecurring != null ||
          hasDebt != null ||
          hasRepay != null ||
          hasGoal != null) {
        throw StateError(
          'Cannot delete an account with linked transactions or records. Archive it instead.',
        );
      }

      await (db.delete(db.accounts)..where((a) => a.id.equals(id))).go();
    });
  }

  Future<int?> correctBalance({
    required int accountId,
    required double currentBalance,
    required double targetBalance,
  }) async {
    final diffCents = CentsConverter.toCents(targetBalance) -
        CentsConverter.toCents(currentBalance);
    if (diffCents == 0) return null;

    if (diffCents > 0) {
      return await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          type: const Value('income'),
          header: 'Balance Adjustment',
          description: Value(
              'Corrected balance to KES ${targetBalance.toStringAsFixed(2)}'),
          amount: CentsConverter.fromCents(diffCents),
          accountId: Value(accountId),
          transactionDate: DateTime.now(),
          excludeFromBudget: const Value(true),
        ),
      );
    } else {
      return await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          type: const Value('expense'),
          header: 'Balance Adjustment',
          description: Value(
              'Corrected balance to KES ${targetBalance.toStringAsFixed(2)}'),
          amount: CentsConverter.fromCents(-diffCents),
          accountId: Value(accountId),
          transactionDate: DateTime.now(),
          excludeFromBudget: const Value(true),
        ),
      );
    }
  }

  Future<int> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    double transactionCost = 0.0,
    String note = '',
    DateTime? date,
  }) {
    return db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        type: const Value('transfer'),
        header: 'Transfer',
        description: Value(note),
        amount: amount,
        transactionCost: Value(transactionCost),
        accountId: Value(fromAccountId),
        toAccountId: Value(toAccountId),
        transactionDate: date ?? DateTime.now(),
      ),
    );
  }
}
