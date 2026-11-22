import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class PayeeCategoryRepository {
  final AppDatabase _db;
  PayeeCategoryRepository(this._db);

  static String _normalise(String payee) => payee.trim().toLowerCase();

  /// Record that [payee] was categorised as [categoryId], atomically
  /// reinforcing [hitCount] on repeated calls.
  Future<void> learn(String payee, int categoryId) async {
    final key = _normalise(payee);
    if (key.isEmpty) return;
    await _db.customInsert(
      '''
      INSERT INTO payee_category_rules (payee_pattern, category_id, hit_count, updated_at)
      VALUES (?, ?, 1, ?)
      ON CONFLICT(payee_pattern) DO UPDATE SET
        category_id = excluded.category_id,
        hit_count = payee_category_rules.hit_count + 1,
        updated_at = excluded.updated_at
      ''',
      variables: [
        Variable.withString(key),
        Variable.withInt(categoryId),
        Variable.withDateTime(DateTime.now()),
      ],
      updates: {_db.payeeCategoryRules},
    );
  }

  /// Returns the best-guess category id for [payee], or null.
  Future<int?> suggest(String payee) async {
    final key = _normalise(payee);
    if (key.isEmpty) return null;
    // Exact match first
    final exact = await (_db.select(_db.payeeCategoryRules)
          ..where((r) => r.payeePattern.equals(key)))
        .getSingleOrNull();
    if (exact != null) return exact.categoryId;

    // Bidirectional containment match — highest hit count wins, then longest pattern
    final rows = await _db.customSelect(
      '''
      SELECT category_id
      FROM payee_category_rules
      WHERE INSTR(LOWER(payee_pattern), ?) > 0
         OR INSTR(?, LOWER(payee_pattern)) > 0
      ORDER BY hit_count DESC, LENGTH(payee_pattern) DESC
      LIMIT 1
      ''',
      variables: [
        Variable.withString(key),
        Variable.withString(key),
      ],
      readsFrom: {_db.payeeCategoryRules},
    ).get();
    return rows.isEmpty ? null : rows.first.read<int>('category_id');
  }

  Future<List<PayeeCategoryRule>> getAll() =>
      _db.select(_db.payeeCategoryRules).get();

  Future<void> delete(String payeePattern) =>
      (_db.delete(_db.payeeCategoryRules)
            ..where((r) => r.payeePattern.equals(payeePattern)))
          .go();
}
