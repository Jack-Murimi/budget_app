import 'dart:ffi';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/categories/repositories/category_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDatabase db;
  late CategoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('default categories seeded on DB creation', () async {
    final all = await repo.getAll();
    expect(all.isNotEmpty, true);
    expect(all.any((c) => c.name == 'Food & Groceries'), true);
    expect(all.any((c) => c.name == 'Transport'), true);
    expect(all.any((c) => c.name == 'Salary'), true);
  });

  test('getTopLevel returns only parent categories', () async {
    final topLevel = await repo.getTopLevel();
    expect(topLevel.isNotEmpty, true);
    for (final cat in topLevel) {
      expect(cat.parentId, isNull);
    }
    expect(topLevel.any((c) => c.name == 'Food & Groceries'), true);
    expect(topLevel.any((c) => c.name == 'Transport'), true);
  });

  test('getChildren returns child categories', () async {
    final topLevel = await repo.getTopLevel();
    final foodCategory = topLevel.firstWhere((c) => c.name == 'Food & Groceries');
    
    final children = await repo.getChildren(foodCategory.id);
    expect(children.isNotEmpty, true);
    for (final child in children) {
      expect(child.parentId, foodCategory.id);
    }
    expect(children.any((c) => c.name == 'Supermarket'), true);
    expect(children.any((c) => c.name == 'Eating Out'), true);
  });

  test('getAll returns all categories', () async {
    final all = await repo.getAll();
    final topLevel = await repo.getTopLevel();
    
    expect(all.length, greaterThan(topLevel.length));
  });

  test('insertCategory creates new category', () async {
    final id = await repo.insertCategory(
      CategoriesCompanion.insert(
        name: 'Test Category',
        icon: const Value('work'),
        colorHex: const Value('#FF5722'),
      ),
    );
    
    expect(id, greaterThan(0));
    final all = await repo.getAll();
    expect(all.any((c) => c.name == 'Test Category'), true);
  });

  test('updateCategory modifies existing category', () async {
    final topLevel = await repo.getTopLevel();
    final cat = topLevel.first;
    
    await repo.updateCategory(
      CategoriesCompanion(
        id: Value(cat.id),
        name: const Value('Updated Name'),
      ),
    );
    
    final all = await repo.getAll();
    final updated = all.firstWhere((c) => c.id == cat.id);
    expect(updated.name, 'Updated Name');
  });

  test('archiveCategory hides category by default', () async {
    final topLevel = await repo.getTopLevel();
    final cat = topLevel.first;
    
    await repo.archiveCategory(cat.id);
    
    final active = await repo.getAll(includeArchived: false);
    expect(active.any((c) => c.id == cat.id), false);
    
    final withArchived = await repo.getAll(includeArchived: true);
    expect(withArchived.any((c) => c.id == cat.id), true);
  });

  test('archiveCategory with archive=false unarchives', () async {
    final topLevel = await repo.getTopLevel();
    final cat = topLevel.first;
    
    await repo.archiveCategory(cat.id, archive: true);
    await repo.archiveCategory(cat.id, archive: false);
    
    final active = await repo.getAll(includeArchived: false);
    expect(active.any((c) => c.id == cat.id), true);
  });

  test('reorderCategories updates sortOrder', () async {
    final topLevel = await repo.getTopLevel();
    expect(topLevel.length, greaterThanOrEqualTo(3));
    
    final ids = topLevel.map((c) => c.id).toList();
    final reversed = ids.reversed.toList();
    
    await repo.reorderCategories(reversed);
    
    final reordered = await repo.getTopLevel();
    expect(reordered.first.id, reversed.first);
    expect(reordered.last.id, reversed.last);
  });

  test('getAll respects sortOrder', () async {
    final topLevel = await repo.getTopLevel();
    expect(topLevel.length, greaterThanOrEqualTo(3));
    
    final allIds = topLevel.map((c) => c.id).toList();
    final reversed = allIds.reversed.toList();
    
    await repo.reorderCategories(reversed);
    
    final sorted = await repo.getTopLevel();
    expect(sorted.first.id, reversed.first);
    expect(sorted[1].id, reversed[1]);
    expect(sorted.last.id, reversed.last);
  });

  test('reorderCategories works for subcategories', () async {
    final topLevel = await repo.getTopLevel();
    final parent = topLevel.firstWhere((c) => c.name == 'Food & Groceries');
    
    final children = await repo.getChildren(parent.id);
    expect(children.length, greaterThanOrEqualTo(2));
    
    final childIds = children.map((c) => c.id).toList();
    final reversed = childIds.reversed.toList();
    
    await repo.reorderCategories(reversed);
    
    final reordered = await repo.getChildren(parent.id);
    expect(reordered.first.id, reversed.first);
    expect(reordered.last.id, reversed.last);
  });
}
