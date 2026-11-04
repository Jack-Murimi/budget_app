// ponytail: basic drift query ceiling; add caching/mapping when needed
import '../../../core/database/app_database.dart';

class CategoryRepository {
  final AppDatabase db;
  const CategoryRepository(this.db);

  Stream<List<Category>> watchAll() => db.select(db.categories).watch();
  Future<List<Category>> getAll() => db.select(db.categories).get();

  /// Returns only top-level categories (parentId is null).
  Future<List<Category>> getTopLevel() =>
      (db.select(db.categories)..where((c) => c.parentId.isNull())).get();

  /// Returns sub-categories for a given parent ID.
  Future<List<Category>> getChildren(int parentId) =>
      (db.select(db.categories)..where((c) => c.parentId.equals(parentId))).get();
}
