import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/transactions/repositories/payee_category_repository.dart';

void main() {

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

  test('learn increments hit count sequentially and updates category', () async {
    final catId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Bills'),
        );
    final catId2 = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Utilities'),
        );
    await repo.learn('KPLC', catId);
    expect((await repo.getAll()).single.hitCount, 1);

    await repo.learn('KPLC', catId);
    expect((await repo.getAll()).single.hitCount, 2);

    await repo.learn('KPLC', catId2);
    final row = (await repo.getAll()).single;
    expect(row.hitCount, 3);
    expect(row.categoryId, catId2);
  });

  test('suggest matches bidirectionally across query and stored patterns',
      () async {
    final foodId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Groceries'),
        );
    await repo.learn('Naivas', foodId);
    expect(await repo.suggest('NAIVAS SUPERMARKET WESTLANDS'), foodId);

    final transId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Fuel'),
        );
    await repo.learn('TotalEnergies Waiyaki Way', transId);
    expect(await repo.suggest('totalenergies'), transId);
  });
}
