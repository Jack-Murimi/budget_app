import 'dart:math' as math;

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../models/debt_model.dart';

class DebtRepository {
  final AppDatabase _db;
  const DebtRepository(this._db);

  Stream<List<DebtWithRepayments>> watchAll() => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {_db.debts, _db.debtRepayments, _db.transactions},
      )
      .watch()
      .asyncMap((_) async {
        final debts = await _db.select(_db.debts).get();
        final result = <DebtWithRepayments>[];
        for (final debt in debts) {
          final repayments = await (_db.select(_db.debtRepayments)
                ..where((row) => row.debtId.equals(debt.id)))
              .get();
          final disbursements = await (_db.select(_db.transactions)
                ..where((row) => row.debtId.equals(debt.id))
                ..orderBy([(row) => OrderingTerm.desc(row.transactionDate)]))
              .get();
          result.add(DebtWithRepayments(
              debt: debt,
              repayments: repayments,
              disbursements: disbursements));
        }
        result.sort((a, b) {
          final da = a.debt.dueDate;
          final db = b.debt.dueDate;
          if (da == null && db == null) return a.debt.id.compareTo(b.debt.id);
          if (da == null) return 1;
          if (db == null) return -1;
          final cmp = da.compareTo(db);
          return cmp != 0 ? cmp : a.debt.id.compareTo(b.debt.id);
        });
        return result;
      });

  Stream<List<DebtWithRepayments>> watchLent() => watchAll().map(
      (all) => all.where((d) => d.debt.direction == 'lent' && !d.isSettled).toList());

  Stream<List<DebtWithRepayments>> watchBorrowed() => watchAll().map((all) =>
      all.where((d) => d.debt.direction == 'borrowed' && !d.isSettled).toList());

  static String? _normalizeRef(Value<String?> ref) {
    if (!ref.present) return null;
    final trimmed = ref.value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Future<bool> _hasDuplicateRef(String? normalizedRef) async {
    if (normalizedRef == null) return false;
    final existing = await (_db.select(_db.transactions)
          ..where((t) => t.mpesaRef.equals(normalizedRef))
          ..limit(1))
        .getSingleOrNull();
    return existing != null;
  }

  Future<int> create({
    required String direction,
    required String counterparty,
    required double principal,
    required double interest,
    required String product,
    double disbursementShortfall = 0.0,
    int? accountId,
    DateTime? dueDate,
    String notes = '',
  }) {
    final principalCents = CentsConverter.toCents(principal);
    final interestCents = CentsConverter.toCents(interest);
    final shortfallCents = CentsConverter.toCents(disbursementShortfall);
    if (!{'borrowed', 'lent'}.contains(direction) ||
        principalCents <= 0 ||
        interestCents < 0 ||
        shortfallCents < 0 ||
        counterparty.trim().isEmpty) {
      throw ArgumentError('Invalid debt details');
    }
    return _db.transaction(() async {
      final totalCents = principalCents + interestCents;
      final id = await _db.into(_db.debts).insert(DebtsCompanion.insert(
          direction: direction,
          counterparty: counterparty.trim(),
          product: Value(product),
          principal: CentsConverter.fromCents(principalCents),
          outstanding: CentsConverter.fromCents(totalCents),
          interest: Value(CentsConverter.fromCents(interestCents)),
          disbursementShortfall:
              Value(CentsConverter.fromCents(shortfallCents)),
          accountId: Value(accountId),
          dueDate: Value(dueDate),
          notes: Value(notes.trim())));
      if (accountId != null) {
        final creditedCents = (direction == 'borrowed' &&
                shortfallCents > 0 &&
                shortfallCents < principalCents)
            ? principalCents - shortfallCents
            : principalCents;
        await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
            header:
                '${direction == 'borrowed' ? 'Loan received' : 'Loan given'}: ${counterparty.trim()}',
            amount: CentsConverter.fromCents(creditedCents),
            type: Value(direction == 'borrowed' ? 'income' : 'expense'),
            accountId: Value(accountId),
            debtId: Value(id),
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
    final amtCents = CentsConverter.toCents(transaction.amount.value);
    if (name.isEmpty || amtCents <= 0) {
      throw ArgumentError('Counterparty and amount are required');
    }
    final normalizedRef = _normalizeRef(transaction.mpesaRef);
    return _db.transaction(() async {
      if (await _hasDuplicateRef(normalizedRef)) return null;

      final existing = await (_db.select(_db.debts)
            ..where((row) =>
                row.direction.equals('lent') &
                row.counterparty.lower().equals(name.toLowerCase()))
            ..limit(1))
          .getSingleOrNull();
      final debtId = existing?.id ??
          await _db.into(_db.debts).insert(DebtsCompanion.insert(
                direction: 'lent',
                counterparty: name,
                product: const Value('personal'),
                principal: CentsConverter.fromCents(amtCents),
                outstanding: CentsConverter.fromCents(amtCents),
                accountId: Value(transaction.accountId.value),
              ));
      if (existing != null) {
        final newPrincipal =
            CentsConverter.toCents(existing.principal) + amtCents;
        final newOutstanding =
            CentsConverter.toCents(existing.outstanding) + amtCents;
        await (_db.update(_db.debts)..where((row) => row.id.equals(debtId)))
            .write(DebtsCompanion(
          principal: Value(CentsConverter.fromCents(newPrincipal)),
          outstanding: Value(CentsConverter.fromCents(newOutstanding)),
        ));
      }
      return _db.into(_db.transactions).insert(
            transaction.copyWith(
              debtId: Value(debtId),
              mpesaRef: Value(normalizedRef),
            ),
          );
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
    final principalCents = CentsConverter.toCents(transaction.amount.value);
    if (name.isEmpty || principalCents <= 0) {
      throw ArgumentError('Counterparty and amount are required');
    }
    final actualCents = actualReceived == null
        ? principalCents
        : CentsConverter.toCents(actualReceived);
    final shortfallCents =
        (actualCents < principalCents) ? (principalCents - actualCents) : 0;
    final isBridge =
        product == 'bridge' || name.toLowerCase().contains('bridge');
    final resolvedProduct = isBridge ? 'bridge' : product;
    final normalizedRef = _normalizeRef(transaction.mpesaRef);

    return _db.transaction(() async {
      if (await _hasDuplicateRef(normalizedRef)) return null;

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
                principal: CentsConverter.fromCents(principalCents),
                outstanding: CentsConverter.fromCents(principalCents),
                interest: const Value(0.0),
                disbursementShortfall:
                    Value(CentsConverter.fromCents(shortfallCents)),
                accountId: Value(transaction.accountId.value),
                dueDate: Value(dueDate),
              ));

      if (existing != null) {
        final newPrincipal =
            CentsConverter.toCents(existing.principal) + principalCents;
        final newOutstanding =
            CentsConverter.toCents(existing.outstanding) + principalCents;
        final newShortfall =
            CentsConverter.toCents(existing.disbursementShortfall) +
                shortfallCents;
        await (_db.update(_db.debts)..where((row) => row.id.equals(debtId)))
            .write(DebtsCompanion(
          principal: Value(CentsConverter.fromCents(newPrincipal)),
          outstanding: Value(CentsConverter.fromCents(newOutstanding)),
          disbursementShortfall: Value(CentsConverter.fromCents(newShortfall)),
        ));
      }

      final txCompanion = transaction.copyWith(
        amount: Value(CentsConverter.fromCents(actualCents)),
        debtId: Value(debtId),
        mpesaRef: Value(normalizedRef),
      );
      return _db.into(_db.transactions).insert(txCompanion);
    });
  }

  Future<void> repay({
    required Debt debt,
    required double amount,
    int? accountId,
    DateTime? paymentDate,
    int? transactionId,
  }) async {
    final amountCents = CentsConverter.toCents(amount);
    if (amountCents <= 0) {
      throw ArgumentError('Invalid repayment amount');
    }
    await _db.transaction(() async {
      final freshDebt = await (_db.select(_db.debts)
            ..where((row) => row.id.equals(debt.id)))
          .getSingle();
      final outstandingCents = CentsConverter.toCents(freshDebt.outstanding);
      if (freshDebt.direction == 'lent' && amountCents > outstandingCents) {
        throw ArgumentError('Invalid repayment amount');
      }
      final date = paymentDate ?? DateTime.now();
      final txId = transactionId ??
          (accountId == null
              ? null
              : await _db.into(_db.transactions).insert(
                  TransactionsCompanion.insert(
                      header: 'Repayment: ${freshDebt.counterparty}',
                      amount: CentsConverter.fromCents(amountCents),
                      type: Value(freshDebt.direction == 'borrowed'
                          ? 'expense'
                          : 'income'),
                      accountId: Value(accountId),
                      transactionDate: date)));
      await _db.into(_db.debtRepayments).insert(DebtRepaymentsCompanion.insert(
          debtId: freshDebt.id,
          amount: CentsConverter.fromCents(amountCents),
          accountId: Value(accountId),
          paymentDate: date,
          transactionId: Value(txId)));

      await _applyRepaymentToDebt(freshDebt, amountCents);
    });
  }

  /// Atomically inserts a repayment [transaction] (unless duplicate [mpesaRef]),
  /// inserts its [DebtRepayments] row, and updates the [debts] row in one DB transaction.
  /// Returns the new transaction id, or `null` if a duplicate [mpesaRef] exists.
  Future<int?> recordRepaymentWithTransaction({
    required int debtId,
    required TransactionsCompanion transaction,
  }) async {
    final amountCents = CentsConverter.toCents(transaction.amount.value);
    if (amountCents <= 0) {
      throw ArgumentError('Invalid repayment amount');
    }
    final normalizedRef = _normalizeRef(transaction.mpesaRef);
    return _db.transaction(() async {
      if (await _hasDuplicateRef(normalizedRef)) return null;

      final freshDebt = await (_db.select(_db.debts)
            ..where((row) => row.id.equals(debtId)))
          .getSingle();
      final outstandingCents = CentsConverter.toCents(freshDebt.outstanding);
      if (freshDebt.direction == 'lent' && amountCents > outstandingCents) {
        throw ArgumentError('Invalid repayment amount');
      }

      // Do not set debtId on repayment transactions; debt_id is for disbursements.
      final txId = await _db.into(_db.transactions).insert(
            transaction.copyWith(
              mpesaRef: Value(normalizedRef),
              debtId: const Value(null),
            ),
          );

      await _db.into(_db.debtRepayments).insert(DebtRepaymentsCompanion.insert(
          debtId: debtId,
          amount: CentsConverter.fromCents(amountCents),
          accountId: Value(
              transaction.accountId.present ? transaction.accountId.value : null),
          paymentDate: transaction.transactionDate.value,
          transactionId: Value(txId)));

      await _applyRepaymentToDebt(freshDebt, amountCents);
      return txId;
    });
  }

  Future<void> _applyRepaymentToDebt(Debt freshDebt, int amountCents) async {
    final outstandingCents = CentsConverter.toCents(freshDebt.outstanding);
    final interestCents = CentsConverter.toCents(freshDebt.interest);
    final extraInterestCents =
        (freshDebt.direction == 'borrowed' && amountCents > outstandingCents)
            ? (amountCents - outstandingCents)
            : 0;
    final newOutstandingCents = math.max(0, outstandingCents - amountCents);
    final newInterestCents = interestCents + extraInterestCents;

    await (_db.update(_db.debts)..where((row) => row.id.equals(freshDebt.id)))
        .write(DebtsCompanion(
      outstanding: Value(CentsConverter.fromCents(newOutstandingCents)),
      interest: Value(CentsConverter.fromCents(newInterestCents)),
    ));
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
                    lastRepayment
                        .isAfter(from.subtract(const Duration(seconds: 1)))) &&
                (to == null ||
                    lastRepayment.isBefore(to.add(const Duration(days: 1))));
            return inCreatedRange || inRepaidRange;
          }).toList());
}
