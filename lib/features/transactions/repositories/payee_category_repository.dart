import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class PayeeCategoryRepository {
  final AppDatabase _db;
  PayeeCategoryRepository(this._db);

  static String _normalise(String payee) => payee.trim().toLowerCase();

  /// Record that [payee] was categorised as [categoryId].
  Future<void> learn(String payee, int categoryId) async {
    final key = _normalise(payee);
    if (key.isEmpty) return;
    await _db.into(_db.payeeCategoryRules).insertOnConflictUpdate(
          PayeeCategoryRulesCompanion.insert(
            payeePattern: key,
            categoryId: categoryId,
            updatedAt: DateTime.now(),
            hitCount: const Value(1),
          ),
        );
    // Increment hit count
    await (_db.update(_db.payeeCategoryRules)
          ..where((r) => r.payeePattern.equals(key)))
        .write(PayeeCategoryRulesCompanion(
      hitCount: Value(await _hitCount(key) + 1),
      updatedAt: Value(DateTime.now()),
      categoryId: Value(categoryId),
    ));
  }

  Future<int> _hitCount(String key) async {
    final row = await (_db.select(_db.payeeCategoryRules)
          ..where((r) => r.payeePattern.equals(key)))
        .getSingleOrNull();
    return row?.hitCount ?? 0;
  }

  /// Returns the best-guess category id for [payee], or null.
  Future<int?> suggest(String payee) async {
    final key = _normalise(payee);
    if (key.isEmpty) return null;
    // Exact match
    final exact = await (_db.select(_db.payeeCategoryRules)
          ..where((r) => r.payeePattern.equals(key)))
        .getSingleOrNull();
    if (exact != null) return exact.categoryId;

    // Prefix / substring match — highest hit count wins
    final rows = await (_db.select(_db.payeeCategoryRules)
          ..where((r) => r.payeePattern.contains(key))
          ..orderBy([(r) => OrderingTerm.desc(r.hitCount)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first.categoryId;
  }

  Future<List<PayeeCategoryRule>> getAll() =>
      _db.select(_db.payeeCategoryRules).get();

  Future<void> delete(String payeePattern) =>
      (_db.delete(_db.payeeCategoryRules)
            ..where((r) => r.payeePattern.equals(payeePattern)))
          .go();
}
