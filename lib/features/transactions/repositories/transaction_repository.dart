import 'dart:math' as math;

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../models/header_suggestion.dart';
import '../models/transaction_model.dart';

// ponytail: direct drift entities; add domain mapper when schema diverges
class TransactionRepository {
  final AppDatabase db;
  const TransactionRepository(this.db);

  Future<List<TransactionModel>> _attachSplits(List<Transaction> rows) async {
    if (rows.isEmpty) return const [];
    final ids = [for (final r in rows) r.id];
    final splitRows = await (db.select(db.transactionSplits)
          ..where((s) => s.transactionId.isIn(ids))
          ..orderBy([(s) => OrderingTerm.asc(s.id)]))
        .get();
    final byTxn = <int, List<TransactionSplitModel>>{};
    for (final s in splitRows) {
      byTxn.putIfAbsent(s.transactionId, () => []).add(s.toModel());
    }
    return [
      for (final r in rows) r.toModel(splits: byTxn[r.id] ?? const []),
    ];
  }

  Future<List<TransactionSplitModel>> getSplitsForTransaction(
    int transactionId,
  ) async {
    final rows = await (db.select(db.transactionSplits)
          ..where((s) => s.transactionId.equals(transactionId))
          ..orderBy([(s) => OrderingTerm.asc(s.id)]))
        .get();
    return [for (final s in rows) s.toModel()];
  }

  Stream<List<TransactionModel>> watchRecent({int limit = 50}) => db
      .customSelect(
        'SELECT 1',
        readsFrom: {db.transactions, db.transactionSplits},
      )
      .watch()
      .asyncMap((_) async {
        final rows = await (db.select(db.transactions)
              ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
              ..limit(limit))
            .get();
        return _attachSplits(rows);
      });

  Stream<List<TransactionModel>> watchMonthSummary({
    required int year,
    required int month,
  }) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return db
        .customSelect(
          'SELECT 1',
          readsFrom: {db.transactions, db.transactionSplits},
        )
        .watch()
        .asyncMap((_) async {
      final rows = await (db.select(db.transactions)
            ..where((t) =>
                t.transactionDate.isBiggerOrEqualValue(start) &
                t.transactionDate.isSmallerThanValue(end)))
          .get();
      return _attachSplits(rows);
    });
  }

  void _validateSplits(
    TransactionsCompanion transaction,
    List<TransactionSplitModel> splits,
  ) {
    if (splits.length < 2) {
      throw ArgumentError('Split transactions require at least 2 rows');
    }
    var sumCents = 0;
    for (final s in splits) {
      final c = CentsConverter.toCents(s.amount);
      if (c <= 0) {
        throw ArgumentError('Each split amount must be greater than zero');
      }
      sumCents += c;
    }
    final totalCents = CentsConverter.toCents(transaction.amount.value);
    if (sumCents != totalCents) {
      throw ArgumentError(
        'Split amounts ($sumCents cents) must equal transaction amount ($totalCents cents)',
      );
    }
  }

  /// Inserts a transaction along with optional [splits] atomically.
  /// When [splits] is non-empty, validates at least 2 positive rows matching
  /// the transaction amount and sets the parent `categoryId` to the first split.
  Future<int?> insertWithSplits(
    TransactionsCompanion transaction,
    List<TransactionSplitModel> splits,
  ) {
    if (splits.isEmpty) return insertOrIgnoreDuplicate(transaction);
    _validateSplits(transaction, splits);
    return db.transaction(() async {
      final id = await insertOrIgnoreDuplicate(
        transaction.copyWith(categoryId: Value(splits.first.categoryId)),
      );
      if (id == null) return null;
      await db.batch((b) {
        b.insertAll(
          db.transactionSplits,
          [
            for (final s in splits)
              TransactionSplitsCompanion.insert(
                transactionId: id,
                categoryId: s.categoryId,
                amount: s.amount,
                note: Value(s.note),
              ),
          ],
        );
      });
      return id;
    });
  }

  /// Updates a transaction and replaces its split rows atomically.
  Future<bool> updateWithSplits(
    TransactionsCompanion transaction,
    List<TransactionSplitModel> splits,
  ) {
    if (splits.isNotEmpty) {
      _validateSplits(transaction, splits);
    }
    return db.transaction(() async {
      final txnId = transaction.id.value;
      final effective = splits.isNotEmpty
          ? transaction.copyWith(categoryId: Value(splits.first.categoryId))
          : transaction;
      final updated = await updateTransaction(effective);
      if (!updated) return false;
      await (db.delete(db.transactionSplits)
            ..where((s) => s.transactionId.equals(txnId)))
          .go();
      if (splits.isNotEmpty) {
        await db.batch((b) {
          b.insertAll(
            db.transactionSplits,
            [
              for (final s in splits)
                TransactionSplitsCompanion.insert(
                  transactionId: txnId,
                  categoryId: s.categoryId,
                  amount: s.amount,
                  note: Value(s.note),
                ),
            ],
          );
        });
      }
      return true;
    });
  }

  /// Insert a transaction. Normalizes blank mpesaRef to null. If mpesaRef is
  /// non-null and already exists, returns null instead of throwing.
  Future<int?> insertOrIgnoreDuplicate(TransactionsCompanion transaction) async {
    final rawRef =
        transaction.mpesaRef.present ? transaction.mpesaRef.value?.trim() : null;
    final normalizedRef =
        (rawRef == null || rawRef.isEmpty) ? null : rawRef;
    final normalizedCompanion = transaction.mpesaRef.present
        ? transaction.copyWith(mpesaRef: Value(normalizedRef))
        : transaction;
    if (normalizedRef != null) {
      final existing = await (db.select(db.transactions)
            ..where((t) => t.mpesaRef.equals(normalizedRef)))
          .getSingleOrNull();
      if (existing != null) return null; // duplicate
    }
    return db.into(db.transactions).insert(normalizedCompanion);
  }

  // Keep original insert for internal use / tests
  Future<int> insert(TransactionsCompanion transaction) =>
      db.into(db.transactions).insert(transaction);

  /// If a transaction with [mpesaRef] exists, update its fulizaAmount and fulizaFee.
  /// Returns true if a transaction was found and updated.
  Future<bool> updateFulizaFields({
    required String mpesaRef,
    required double fulizaAmount,
    required double fulizaFee,
  }) async {
    final existing = await (db.select(db.transactions)
          ..where((t) => t.mpesaRef.equals(mpesaRef)))
        .getSingleOrNull();
    if (existing == null) return false;

    await (db.update(db.transactions)
          ..where((t) => t.mpesaRef.equals(mpesaRef)))
        .write(TransactionsCompanion(
          fulizaAmount: Value(fulizaAmount),
          fulizaFee: Value(fulizaFee),
        ));
    return true;
  }

  Future<TransactionModel?> getByRef(String mpesaRef) async {
    final row = await (db.select(db.transactions)
          ..where((t) => t.mpesaRef.equals(mpesaRef)))
        .getSingleOrNull();
    return row?.toModel();
  }

  /// Inserts a reversal transaction (excluded from budget) and atomically marks
  /// the matching [originalMpesaRef] transaction as reversed and excluded from budget.
  /// Returns the new reversal ID, or `null` if the reversal [mpesaRef] already exists.
  Future<int?> insertReversalAndMarkOriginal(
    TransactionsCompanion reversal,
    String originalMpesaRef,
  ) async {
    return db.transaction(() async {
      final rawRef =
          reversal.mpesaRef.present ? reversal.mpesaRef.value?.trim() : null;
      final normalizedRef =
          (rawRef == null || rawRef.isEmpty) ? null : rawRef;
      if (normalizedRef != null) {
        final existing = await (db.select(db.transactions)
              ..where((t) => t.mpesaRef.equals(normalizedRef)))
            .getSingleOrNull();
        if (existing != null) return null;
      }

      final reversalId = await db.into(db.transactions).insert(
            reversal.copyWith(
              mpesaRef: Value(normalizedRef),
              excludeFromBudget: const Value(true),
            ),
          );

      final origRef = originalMpesaRef.trim();
      if (origRef.isNotEmpty) {
        final original = await (db.select(db.transactions)
              ..where((t) => t.mpesaRef.equals(origRef)))
            .getSingleOrNull();
        if (original != null) {
          final updatedDesc = original.description.startsWith('[REVERSED]')
              ? original.description
              : '[REVERSED] ${original.description}'.trim();
          await (db.update(db.transactions)
                ..where((t) => t.id.equals(original.id)))
              .write(TransactionsCompanion(
            description: Value(updatedDesc),
            excludeFromBudget: const Value(true),
          ));
        }
      }

      return reversalId;
    });
  }

  /// Deletes transaction [id] and reconciles any linked goal contributions,
  /// debt repayments, and debt disbursement records atomically.
  Future<void> delete(int id) async {
    await db.transaction(() async {
      final txn = await (db.select(db.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (txn == null) return;

      // 1. Reconcile linked goal contributions before deleting the transaction (FK).
      final contributions = await (db.select(db.goalContributions)
            ..where((c) => c.transactionId.equals(id)))
          .get();
      for (final c in contributions) {
        final goal = await (db.select(db.savingsGoals)
              ..where((g) => g.id.equals(c.goalId)))
            .getSingleOrNull();
        if (goal != null) {
          final updatedCents = math.max(
            0,
            CentsConverter.toCents(goal.currentAmount) -
                CentsConverter.toCents(c.amount),
          );
          await (db.update(db.savingsGoals)
                ..where((g) => g.id.equals(goal.id)))
              .write(SavingsGoalsCompanion(
            currentAmount: Value(CentsConverter.fromCents(updatedCents)),
          ));
        }
        await (db.delete(db.goalContributions)
              ..where((row) => row.id.equals(c.id)))
            .go();
      }

      // 2. Reconcile linked debt repayments.
      final repayments = await (db.select(db.debtRepayments)
            ..where((r) => r.transactionId.equals(id)))
          .get();
      for (final r in repayments) {
        final debt = await (db.select(db.debts)
              ..where((d) => d.id.equals(r.debtId)))
            .getSingleOrNull();
        if (debt != null) {
          final updatedOutstanding =
              CentsConverter.toCents(debt.outstanding) +
                  CentsConverter.toCents(r.amount);
          await (db.update(db.debts)..where((d) => d.id.equals(debt.id)))
              .write(DebtsCompanion(
            outstanding: Value(CentsConverter.fromCents(updatedOutstanding)),
          ));
        }
        await (db.delete(db.debtRepayments)
              ..where((row) => row.id.equals(r.id)))
            .go();
      }

      // 3. Delete the transaction itself.
      await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();

      // 4. Reconcile linked debt disbursement if this transaction created/added to a debt.
      final linkedDebtId = txn.debtId;
      if (linkedDebtId != null) {
        final remainingTxns = await (db.select(db.transactions)
              ..where((t) => t.debtId.equals(linkedDebtId)))
            .get();
        final remainingRepayments = await (db.select(db.debtRepayments)
              ..where((r) => r.debtId.equals(linkedDebtId)))
            .get();
        if (remainingTxns.isEmpty && remainingRepayments.isEmpty) {
          await (db.delete(db.debts)
                ..where((d) => d.id.equals(linkedDebtId)))
              .go();
        } else {
          final debt = await (db.select(db.debts)
                ..where((d) => d.id.equals(linkedDebtId)))
              .getSingleOrNull();
          if (debt != null) {
            final amtCents = CentsConverter.toCents(txn.amount);
            final newPrincipal =
                math.max(0, CentsConverter.toCents(debt.principal) - amtCents);
            final newOutstanding = math.max(
                0, CentsConverter.toCents(debt.outstanding) - amtCents);
            await (db.update(db.debts)..where((d) => d.id.equals(debt.id)))
                .write(DebtsCompanion(
              principal: Value(CentsConverter.fromCents(newPrincipal)),
              outstanding: Value(CentsConverter.fromCents(newOutstanding)),
            ));
          }
        }
      }
    });
  }

  Stream<List<TransactionModel>> watchAll() => db
      .customSelect(
        'SELECT 1',
        readsFrom: {db.transactions, db.transactionSplits},
      )
      .watch()
      .asyncMap((_) async {
        final rows = await (db.select(db.transactions)
              ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
            .get();
        return _attachSplits(rows);
      });

  /// Updates a transaction and reconciles linked goal contributions,
  /// debt repayments, and debt disbursement amounts atomically.
  Future<bool> updateTransaction(TransactionsCompanion transaction) async {
    return db.transaction(() async {
      final oldTxn = await (db.select(db.transactions)
            ..where((t) => t.id.equals(transaction.id.value)))
          .getSingleOrNull();
      if (oldTxn == null) return false;

      var normalized = transaction;
      if (transaction.mpesaRef.present) {
        final rawRef = transaction.mpesaRef.value?.trim();
        normalized = transaction.copyWith(
          mpesaRef: Value(rawRef == null || rawRef.isEmpty ? null : rawRef),
        );
      }

      final count = await (db.update(db.transactions)
            ..where((t) => t.id.equals(oldTxn.id)))
          .write(normalized);

      final newAmount =
          normalized.amount.present ? normalized.amount.value : oldTxn.amount;
      final deltaCents = CentsConverter.toCents(newAmount) -
          CentsConverter.toCents(oldTxn.amount);
      final newDate = normalized.transactionDate.present
          ? normalized.transactionDate.value
          : null;
      final newAccountId = normalized.accountId.present
          ? normalized.accountId
          : const Value<int?>.absent();

      if (deltaCents != 0 || newDate != null || newAccountId.present) {
        final contributions = await (db.select(db.goalContributions)
              ..where((c) => c.transactionId.equals(oldTxn.id)))
            .get();
        for (final c in contributions) {
          if (deltaCents != 0) {
            final goal = await (db.select(db.savingsGoals)
                  ..where((g) => g.id.equals(c.goalId)))
                .getSingleOrNull();
            if (goal != null) {
              final updatedGoalCents = math.max(
                0,
                CentsConverter.toCents(goal.currentAmount) + deltaCents,
              );
              await (db.update(db.savingsGoals)
                    ..where((g) => g.id.equals(goal.id)))
                  .write(SavingsGoalsCompanion(
                currentAmount:
                    Value(CentsConverter.fromCents(updatedGoalCents)),
              ));
            }
          }
          await (db.update(db.goalContributions)
                ..where((row) => row.id.equals(c.id)))
              .write(GoalContributionsCompanion(
            amount: deltaCents != 0 ? Value(newAmount) : const Value.absent(),
            contributionDate:
                newDate != null ? Value(newDate) : const Value.absent(),
            accountId: newAccountId,
          ));
        }

        final repayments = await (db.select(db.debtRepayments)
              ..where((r) => r.transactionId.equals(oldTxn.id)))
            .get();
        for (final r in repayments) {
          if (deltaCents != 0) {
            final debt = await (db.select(db.debts)
                  ..where((d) => d.id.equals(r.debtId)))
                .getSingleOrNull();
            if (debt != null) {
              final outCents = CentsConverter.toCents(debt.outstanding);
              final intCents = CentsConverter.toCents(debt.interest);
              int newOutCents;
              var newIntCents = intCents;
              if (deltaCents > 0) {
                if (debt.direction == 'borrowed' && deltaCents > outCents) {
                  newIntCents += deltaCents - outCents;
                  newOutCents = 0;
                } else {
                  newOutCents = math.max(0, outCents - deltaCents);
                }
              } else {
                newOutCents = outCents - deltaCents;
              }
              await (db.update(db.debts)..where((d) => d.id.equals(debt.id)))
                  .write(DebtsCompanion(
                outstanding: Value(CentsConverter.fromCents(newOutCents)),
                interest: Value(CentsConverter.fromCents(newIntCents)),
              ));
            }
          }
          await (db.update(db.debtRepayments)
                ..where((row) => row.id.equals(r.id)))
              .write(DebtRepaymentsCompanion(
            amount: deltaCents != 0 ? Value(newAmount) : const Value.absent(),
            paymentDate:
                newDate != null ? Value(newDate) : const Value.absent(),
            accountId: newAccountId,
          ));
        }

        if (deltaCents != 0 && oldTxn.debtId != null) {
          final debt = await (db.select(db.debts)
                ..where((d) => d.id.equals(oldTxn.debtId!)))
              .getSingleOrNull();
          if (debt != null) {
            final newPrincipal = math.max(
                0, CentsConverter.toCents(debt.principal) + deltaCents);
            final newOutstanding = math.max(
                0, CentsConverter.toCents(debt.outstanding) + deltaCents);
            await (db.update(db.debts)..where((d) => d.id.equals(debt.id)))
                .write(DebtsCompanion(
              principal: Value(CentsConverter.fromCents(newPrincipal)),
              outstanding: Value(CentsConverter.fromCents(newOutstanding)),
            ));
          }
        }
      }

      return count > 0;
    });
  }

  /// Returns up to 3 distinct header + category suggestions matching [query].
  /// Ranked by prefix match first, then recency (most recently used).
  Future<List<HeaderSuggestion>> getHeaderSuggestions(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return const [];

    final pattern = '%$clean%';
    final prefix = '$clean%';

    final results = await db.customSelect(
      '''
      SELECT 
        t.header,
        t.category_id,
        c.name AS category_name,
        c.parent_id AS category_parent_id,
        p.name AS parent_category_name,
        MAX(t.transaction_date) AS max_date,
        MAX(t.id) AS max_id
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      LEFT JOIN categories p ON c.parent_id = p.id
      WHERE t.header IS NOT NULL 
        AND TRIM(t.header) != '' 
        AND LOWER(t.header) LIKE LOWER(?)
      GROUP BY LOWER(TRIM(t.header)), t.category_id
      ORDER BY 
        CASE WHEN LOWER(TRIM(t.header)) LIKE LOWER(?) THEN 0 ELSE 1 END,
        MAX(t.transaction_date) DESC,
        MAX(t.id) DESC
      LIMIT 3
      ''',
      variables: [
        Variable.withString(pattern),
        Variable.withString(prefix),
      ],
      readsFrom: {db.transactions, db.categories},
    ).get();

    return results.map((row) {
      return HeaderSuggestion(
        header: row.read<String>('header'),
        categoryId: row.readNullable<int>('category_id'),
        categoryName: row.readNullable<String>('category_name'),
        parentCategoryId: row.readNullable<int>('category_parent_id'),
        parentCategoryName: row.readNullable<String>('parent_category_name'),
      );
    }).toList();
  }
}
