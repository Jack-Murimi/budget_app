import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/fuliza/repositories/fuliza_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

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
}
