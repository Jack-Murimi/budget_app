import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/transaction_model.dart';

// ponytail: direct drift entities; add domain mapper when schema diverges
class TransactionRepository {
  final AppDatabase db;
  const TransactionRepository(this.db);

  Stream<List<TransactionModel>> watchRecent({int limit = 50}) =>
      (db.select(db.transactions)
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
            ..limit(limit))
          .map((row) => row.toModel())
          .watch();

  Stream<List<TransactionModel>> watchMonthSummary({required int year, required int month}) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (db.select(db.transactions)
          ..where((t) =>
              t.transactionDate.isBiggerOrEqualValue(start) &
              t.transactionDate.isSmallerThanValue(end)))
        .map((row) => row.toModel())
        .watch();
  }

  /// Insert a transaction. If mpesaRef is non-null and already exists,
  /// returns null and surfaces a duplicate signal instead of throwing.
  /// Returns the new row ID on success, or null if duplicate.
  Future<int?> insertOrIgnoreDuplicate(TransactionsCompanion transaction) async {
    final ref = transaction.mpesaRef.value;
    if (ref != null && ref.isNotEmpty) {
      final existing = await (db.select(db.transactions)
            ..where((t) => t.mpesaRef.equals(ref)))
          .getSingleOrNull();
      if (existing != null) return null; // duplicate
    }
    return db.into(db.transactions).insert(transaction);
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
    final row = await (db.select(db.transactions)..where((t) => t.mpesaRef.equals(mpesaRef)))
        .getSingleOrNull();
    return row?.toModel();
  }

  Future<void> delete(int id) =>
      (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();

  Stream<List<TransactionModel>> watchAll() =>
      (db.select(db.transactions)
            ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
          .map((row) => row.toModel())
          .watch();

  Future<bool> updateTransaction(TransactionsCompanion transaction) async {
    final count = await (db.update(db.transactions)
          ..where((t) => t.id.equals(transaction.id.value)))
        .write(transaction);
    return count > 0;
  }
}
