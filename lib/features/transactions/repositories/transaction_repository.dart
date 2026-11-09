import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/header_suggestion.dart';
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
