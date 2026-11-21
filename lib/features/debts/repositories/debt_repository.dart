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

  Stream<List<DebtWithRepayments>> watchLent() =>
      watchAll().map((all) => all.where((d) => d.debt.direction == 'lent' && !d.isSettled).toList());

  Stream<List<DebtWithRepayments>> watchBorrowed() =>
      watchAll().map((all) => all.where((d) => d.debt.direction == 'borrowed' && !d.isSettled).toList());

  Future<int> create(
      {required String direction,
      required String counterparty,
      required double principal,
      required double interest,
      required String product,
      double disbursementShortfall = 0.0,
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
          disbursementShortfall: Value(disbursementShortfall),
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

  Future<int?> recordLoanReceived({
    required TransactionsCompanion transaction,
    required String counterparty,
    double? actualReceived,
    String product = 'personal',
    DateTime? dueDate,
  }) async {
    final name = counterparty.trim();
    final principal = transaction.amount.value;
    if (name.isEmpty || principal <= 0) throw ArgumentError('Counterparty and amount are required');
    final actual = actualReceived ?? principal;
    final shortfall = (actual < principal) ? (principal - actual) : 0.0;
    final isBridge = product == 'bridge' || name.toLowerCase().contains('bridge');
    final resolvedProduct = isBridge ? 'bridge' : product;

    return _db.transaction(() async {
      final existing = await (_db.select(_db.debts)
            ..where((row) =>
                row.direction.equals('borrowed') &
                row.counterparty.lower().equals(name.toLowerCase()) &
                row.outstanding.isBiggerThanValue(0))
            ..limit(1))
          .getSingleOrNull();

      final debtId = existing?.id ??
          await _db.into(_db.debts).insert(DebtsCompanion.insert(
                direction: 'borrowed',
                counterparty: name,
                product: Value(resolvedProduct),
                principal: principal,
                outstanding: principal,
                interest: const Value(0.0),
                disbursementShortfall: Value(shortfall),
                accountId: Value(transaction.accountId.value),
                dueDate: Value(dueDate),
              ));

      if (existing != null) {
        await (_db.update(_db.debts)..where((row) => row.id.equals(debtId))).write(DebtsCompanion(
          principal: Value(existing.principal + principal),
          outstanding: Value(existing.outstanding + principal),
          disbursementShortfall: Value(existing.disbursementShortfall + shortfall),
        ));
      }

      final txCompanion = transaction.copyWith(
        amount: Value(actual),
        debtId: Value(debtId),
      );
      return _db.into(_db.transactions).insert(txCompanion);
    });
  }

  Future<void> repay(
      {required Debt debt,
      required double amount,
      int? accountId,
      DateTime? paymentDate,
      int? transactionId}) async {
    if (amount <= 0) {
      throw ArgumentError('Invalid repayment amount');
    }
    if (debt.direction == 'lent' && amount > debt.outstanding + 0.005) {
      throw ArgumentError('Invalid repayment amount');
    }
    await _db.transaction(() async {
      final date = paymentDate ?? DateTime.now();
      final txId = transactionId ??
          (accountId == null
              ? null
              : await _db.into(_db.transactions).insert(
                  TransactionsCompanion.insert(
                      header: 'Repayment: ${debt.counterparty}',
                      amount: amount,
                      type: Value(
                          debt.direction == 'borrowed' ? 'expense' : 'income'),
                      accountId: Value(accountId),
                      transactionDate: date)));
      await _db.into(_db.debtRepayments).insert(DebtRepaymentsCompanion.insert(
          debtId: debt.id,
          amount: amount,
          accountId: Value(accountId),
          paymentDate: date,
          transactionId: Value(txId)));

      final extraInterest =
          (debt.direction == 'borrowed' && amount > debt.outstanding)
              ? (amount - debt.outstanding)
              : 0.0;
      final newOutstanding =
          (debt.outstanding - amount).clamp(0.0, double.infinity);
      final newInterest = debt.interest + extraInterest;

      await (_db.update(_db.debts)..where((row) => row.id.equals(debt.id)))
          .write(DebtsCompanion(
              outstanding: Value(newOutstanding),
              interest: Value(newInterest)));
    });
  }

  Stream<List<DebtWithRepayments>> watchBridgeDebts({
    DateTime? from,
    DateTime? to,
  }) =>
      watchAll().map((all) => all.where((d) {
            final isBridge = d.debt.product == 'bridge' ||
                d.debt.counterparty.toLowerCase().contains('bridge');
            if (!isBridge) return false;
            if (from == null && to == null) return true;
            final createdAt = d.debt.createdAt;
            final lastRepayment =
                d.repayments.isNotEmpty ? d.repayments.last.paymentDate : null;
            final inCreatedRange = (from == null ||
                    createdAt.isAfter(from.subtract(const Duration(seconds: 1)))) &&
                (to == null ||
                    createdAt.isBefore(to.add(const Duration(days: 1))));
            final inRepaidRange = lastRepayment != null &&
                (from == null ||
                    lastRepayment.isAfter(from.subtract(const Duration(seconds: 1)))) &&
                (to == null ||
                    lastRepayment.isBefore(to.add(const Duration(days: 1))));
            return inCreatedRange || inRepaidRange;
          }).toList());
}
