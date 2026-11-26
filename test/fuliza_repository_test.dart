import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/fuliza/repositories/fuliza_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {

  late AppDatabase db;
  late FulizaRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FulizaRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insertDrawdown and getByRef work properly', () async {
    await repo.insertDrawdown(
      FulizaRecordsCompanion.insert(
        mpesaRef: 'UK3QX11U87',
        fulizaAmount: 70.0,
        accessFee: const Value(0.70),
        outstandingTotal: const Value(102.68),
        dueDate: Value(DateTime(2026, 12, 3)),
      ),
    );

    final record = await repo.getByRef('UK3QX11U87');
    expect(record, isNotNull);
    expect(record!.fulizaAmount, 70.0);
    expect(record.accessFee, 0.70);
    expect(record.outstandingTotal, 102.68);
    expect(record.dueDate, DateTime(2026, 12, 3));

    final totalFees = await repo.totalFees();
    expect(totalFees, 0.70);
  });

  test('recordRepayment reduces and clears outstandingTotal and deduplicates mpesaRef',
      () async {
    await repo.insertDrawdown(
      FulizaRecordsCompanion.insert(
        mpesaRef: 'DR1',
        fulizaAmount: 200.0,
        accessFee: const Value(2.0),
        outstandingTotal: const Value(202.0),
        dueDate: Value(DateTime(2026, 12, 1)),
        createdAt: Value(DateTime(2026, 11, 1)),
      ),
    );

    final dup1 = await repo.recordRepayment(
      mpesaRef: 'REP1',
      amount: 52.0,
      isFull: false,
      date: DateTime(2026, 11, 2),
    );
    expect(dup1, isFalse);

    var latest = await repo.watchLatest().first;
    expect(latest!.outstandingTotal, 150.0);
    expect(latest.fulizaAmount, -52.0);
    expect(latest.dueDate, DateTime(2026, 12, 1));

    // Duplicate repayment ref must be skipped.
    final dup2 = await repo.recordRepayment(
      mpesaRef: 'REP1',
      amount: 52.0,
      isFull: false,
    );
    expect(dup2, isTrue);

    // Full settlement clears outstandingTotal and dueDate.
    await repo.recordRepayment(
      mpesaRef: 'REP2',
      amount: 150.0,
      isFull: true,
      date: DateTime(2026, 11, 3),
    );
    latest = await repo.watchLatest().first;
    expect(latest!.outstandingTotal, 0.0);
    expect(latest.dueDate, isNull);
    expect(await repo.watchTotalFees().first, 2.0);
  });
}
