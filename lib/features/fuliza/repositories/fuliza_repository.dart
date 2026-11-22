import 'dart:math' as math;

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';

class FulizaRepository {
  final AppDatabase db;
  const FulizaRepository(this.db);

  /// Insert a Fuliza drawdown. Returns true if already recorded (duplicate), false if new.
  Future<bool> insertDrawdown(FulizaRecordsCompanion record) async {
    final existing = await getByRef(record.mpesaRef.value);
    if (existing != null) return true; // duplicate
    await db.into(db.fulizaRecords).insert(record);
    return false;
  }

  /// Record a Fuliza repayment (full, partial, or manual), reducing or clearing
  /// [outstandingTotal]. Returns true if [mpesaRef] already exists (duplicate).
  Future<bool> recordRepayment({
    required String mpesaRef,
    required double amount,
    bool isFull = false,
    double? explicitOutstanding,
    DateTime? date,
  }) async {
    final amountCents = CentsConverter.toCents(amount);
    if (amountCents <= 0) {
      throw ArgumentError('Repayment amount must be positive');
    }
    return db.transaction(() async {
      final existing = await getByRef(mpesaRef);
      if (existing != null) return true; // duplicate

      final latest = await (db.select(db.fulizaRecords)
            ..orderBy([
              (f) => OrderingTerm.desc(f.createdAt),
              (f) => OrderingTerm.desc(f.id),
            ])
            ..limit(1))
          .getSingleOrNull();

      final int newOutstandingCents;
      if (explicitOutstanding != null) {
        newOutstandingCents =
            math.max(0, CentsConverter.toCents(explicitOutstanding));
      } else if (isFull) {
        newOutstandingCents = 0;
      } else {
        final prevCents = CentsConverter.toCents(latest?.outstandingTotal ?? 0);
        newOutstandingCents = math.max(0, prevCents - amountCents);
      }

      await db.into(db.fulizaRecords).insert(
            FulizaRecordsCompanion.insert(
              mpesaRef: mpesaRef,
              // Negative fulizaAmount distinguishes repayment entries in usage history.
              fulizaAmount: -CentsConverter.fromCents(amountCents),
              accessFee: const Value(0.0),
              outstandingTotal:
                  Value(CentsConverter.fromCents(newOutstandingCents)),
              dueDate: Value(newOutstandingCents == 0 ? null : latest?.dueDate),
              createdAt: date != null ? Value(date) : const Value.absent(),
            ),
          );
      return false;
    });
  }

  /// All Fuliza records, newest first.
  Stream<List<FulizaRecord>> watchAll() => (db.select(db.fulizaRecords)
        ..orderBy([
          (f) => OrderingTerm.desc(f.createdAt),
          (f) => OrderingTerm.desc(f.id),
        ]))
      .watch();

  /// Latest outstanding total and due date (most recent record).
  Stream<FulizaRecord?> watchLatest() => (db.select(db.fulizaRecords)
        ..orderBy([
          (f) => OrderingTerm.desc(f.createdAt),
          (f) => OrderingTerm.desc(f.id),
        ])
        ..limit(1))
      .watchSingleOrNull();

  /// Stream of total access fees paid across all Fuliza usage.
  Stream<double> watchTotalFees() => watchAll().map((rows) {
        final totalCents = rows.fold<int>(
          0,
          (sum, r) => sum + CentsConverter.toCents(r.accessFee),
        );
        return CentsConverter.fromCents(totalCents);
      });

  /// Total access fees paid across all Fuliza usage.
  Future<double> totalFees() async {
    final rows = await db.select(db.fulizaRecords).get();
    final totalCents = rows.fold<int>(
      0,
      (sum, r) => sum + CentsConverter.toCents(r.accessFee),
    );
    return CentsConverter.fromCents(totalCents);
  }

  /// Get record by M-Pesa ref.
  Future<FulizaRecord?> getByRef(String ref) async {
    final rows = await (db.select(db.fulizaRecords)
          ..where((f) => f.mpesaRef.equals(ref))
          ..orderBy([
            (f) => OrderingTerm.desc(f.createdAt),
            (f) => OrderingTerm.desc(f.id),
          ])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }
}
