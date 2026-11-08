import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/debt_model.dart';

class DebtRepository {
  final AppDatabase _db;
  const DebtRepository(this._db);

  Stream<List<DebtWithRepayments>> watchAll() =>
      _db.select(_db.debts).watch().asyncMap((debts) async {
        final result = <DebtWithRepayments>[];
        for (final debt in debts) {
          final repayments = await (_db.select(_db.debtRepayments)
                ..where((row) => row.debtId.equals(debt.id)))
              .get();
          final disbursements = await (_db.select(_db.transactions)
                ..where((row) => row.debtId.equals(debt.id))
                ..orderBy([(row) => OrderingTerm.desc(row.transactionDate)]))
              .get();
          result.add(DebtWithRepayments(debt: debt, repayments: repayments, disbursements: disbursements));
        }
        result.sort((a, b) =>
            a.debt.dueDate?.compareTo(b.debt.dueDate ?? DateTime(9999)) ?? 1);
        return result;
      });

  Future<int> create(
      {required String direction,
      required String counterparty,
      required double principal,
      required double interest,
      required String product,
      int? accountId,
      DateTime? dueDate,
      String notes = ''}) {
    if (!{'borrowed', 'lent'}.contains(direction) ||
        principal <= 0 ||
        interest < 0 ||
        counterparty.trim().isEmpty) {
      throw ArgumentError('Invalid debt details');
    }
    return _db.transaction(() async {
      final total = principal + interest;
      final id = await _db.into(_db.debts).insert(DebtsCompanion.insert(
          direction: direction,
          counterparty: counterparty.trim(),
          product: Value(product),
          principal: principal,
          outstanding: total,
          interest: Value(interest),
          accountId: Value(accountId),
          dueDate: Value(dueDate),
          notes: Value(notes.trim())));
      if (accountId != null) {
        await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
            header:
                '${direction == 'borrowed' ? 'Loan received' : 'Loan given'}: ${counterparty.trim()}',
            amount: principal,
            type: Value(direction == 'borrowed' ? 'income' : 'expense'),
            accountId: Value(accountId),
            transactionDate: DateTime.now()));
      }
      return id;
    });
  }

  Future<int?> recordLoanGiven({
    required TransactionsCompanion transaction,
    required String counterparty,
  }) async {
    final name = counterparty.trim();
    final amt = transaction.amount.value;
    if (name.isEmpty || amt <= 0) throw ArgumentError('Counterparty and amount are required');
    return _db.transaction(() async {
      final existing = await (_db.select(_db.debts)
            ..where((row) => row.direction.equals('lent') & row.counterparty.lower().equals(name.toLowerCase()))
            ..limit(1))
          .getSingleOrNull();
      final debtId = existing?.id ?? await _db.into(_db.debts).insert(DebtsCompanion.insert(
        direction: 'lent', counterparty: name, product: const Value('personal'),
        principal: amt, outstanding: amt,
        accountId: Value(transaction.accountId.value),
      ));
      if (existing != null) {
        await (_db.update(_db.debts)..where((row) => row.id.equals(debtId))).write(DebtsCompanion(
          principal: Value(existing.principal + amt),
          outstanding: Value(existing.outstanding + amt),
        ));
      }
      return _db.into(_db.transactions).insert(transaction.copyWith(debtId: Value(debtId)));
    });
  }

  Future<void> repay(
      {required Debt debt,
      required double amount,
      int? accountId,
      DateTime? paymentDate}) async {
    if (amount <= 0 || amount > debt.outstanding + 0.005) {
      throw ArgumentError('Invalid repayment amount');
    }
    await _db.transaction(() async {
      final date = paymentDate ?? DateTime.now();
      final transactionId = accountId == null
          ? null
          : await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                  header: 'Repayment: ${debt.counterparty}',
                  amount: amount,
                  type: Value(
                      debt.direction == 'borrowed' ? 'expense' : 'income'),
                  accountId: Value(accountId),
                  transactionDate: date));
      await _db.into(_db.debtRepayments).insert(DebtRepaymentsCompanion.insert(
          debtId: debt.id,
          amount: amount,
          accountId: Value(accountId),
          paymentDate: date,
          transactionId: Value(transactionId)));
      await (_db.update(_db.debts)..where((row) => row.id.equals(debt.id)))
          .write(DebtsCompanion(
              outstanding: Value(
                  (debt.outstanding - amount).clamp(0, double.infinity))));
    });
  }
}
