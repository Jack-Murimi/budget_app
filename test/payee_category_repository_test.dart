import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/transactions/repositories/payee_category_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  late AppDatabase db;
  late PayeeCategoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PayeeCategoryRepository(db);
  });

  tearDown(() => db.close());

  test('learn and suggest exact match', () async {
    // Need a category first
    final catId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Food'),
        );
    await repo.learn('Naivas Supermarket', catId);
    expect(await repo.suggest('Naivas Supermarket'), catId);
  });

  test('suggest normalises case', () async {
    final catId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Transport'),
        );
    await repo.learn('NAIROBI MATATU', catId);
    expect(await repo.suggest('nairobi matatu'), catId);
  });

  test('suggest returns null for unknown payee', () async {
    expect(await repo.suggest('UNKNOWN MERCHANT'), null);
  });

  test('learn increments hit count', () async {
    final catId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Bills'),
        );
    await repo.learn('KPLC', catId);
    await repo.learn('KPLC', catId);
    final rows = await repo.getAll();
    expect(rows.first.hitCount, greaterThan(1));
  });
}
