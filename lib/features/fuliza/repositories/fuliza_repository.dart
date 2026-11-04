import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class FulizaRepository {
  final AppDatabase db;
  const FulizaRepository(this.db);

  /// Save a Fuliza drawdown record.
  Future<int> insertDrawdown(FulizaRecordsCompanion record) =>
      db.into(db.fulizaRecords).insertOnConflictUpdate(record);

  /// All Fuliza records, newest first.
  Stream<List<FulizaRecord>> watchAll() =>
      (db.select(db.fulizaRecords)
            ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
          .watch();

  /// Latest outstanding total and due date (most recent record).
  Stream<FulizaRecord?> watchLatest() =>
      (db.select(db.fulizaRecords)
            ..orderBy([(f) => OrderingTerm.desc(f.createdAt)])
            ..limit(1))
          .watchSingleOrNull();

  /// Total access fees paid across all Fuliza usage.
  Future<double> totalFees() async {
    final rows = await db.select(db.fulizaRecords).get();
    return rows.fold<double>(0.0, (sum, r) => sum + r.accessFee);
  }

  /// Get record by M-Pesa ref.
  Future<FulizaRecord?> getByRef(String ref) =>
      (db.select(db.fulizaRecords)..where((f) => f.mpesaRef.equals(ref)))
          .getSingleOrNull();
}
