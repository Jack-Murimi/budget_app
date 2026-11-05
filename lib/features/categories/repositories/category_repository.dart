// ponytail: basic drift query ceiling; add caching/mapping when needed
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class CategoryRepository {
  final AppDatabase db;
  const CategoryRepository(this.db);

  Stream<List<Category>> watchAll({bool includeArchived = false}) {
    final query = db.select(db.categories)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]);
    if (!includeArchived) {
      query.where((c) => c.isArchived.equals(false));
    }
    return query.watch();
  }

  Future<List<Category>> getAll({bool includeArchived = false}) {
    final query = db.select(db.categories)
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]);
    if (!includeArchived) {
      query.where((c) => c.isArchived.equals(false));
    }
    return query.get();
  }

  Future<List<Category>> getTopLevel({bool includeArchived = false}) {
    final query = db.select(db.categories)
      ..where((c) => c.parentId.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    if (!includeArchived) {
      query.where((c) => c.isArchived.equals(false));
    }
    return query.get();
  }

  Future<List<Category>> getChildren(int parentId, {bool includeArchived = false}) {
    final query = db.select(db.categories)
      ..where((c) => c.parentId.equals(parentId))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]);
    if (!includeArchived) {
      query.where((c) => c.isArchived.equals(false));
    }
    return query.get();
  }

  Future<Category?> getCategoryById(int id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCategory(CategoriesCompanion category) =>
      db.into(db.categories).insert(category);

  Future<bool> updateCategory(CategoriesCompanion category) =>
      db.update(db.categories).replace(category);

  Future<void> archiveCategory(int id, {bool archive = true}) =>
      (db.update(db.categories)..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(isArchived: Value(archive)));

  Future<void> reorderCategories(List<int> orderedIds) async {
    await db.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(
          db.categories,
          CategoriesCompanion(sortOrder: Value(i)),
          where: (c) => c.id.equals(orderedIds[i]),
        );
      }
    });
  }
}
