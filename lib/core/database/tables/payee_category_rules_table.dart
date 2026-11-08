import 'package:drift/drift.dart';
import 'categories_table.dart';

/// Remembers which category a payee/merchant was last assigned to.
/// Used to suggest a category when the same payee appears again.
class PayeeCategoryRules extends Table {
  // Normalised payee name (lowercase, trimmed)
  TextColumn get payeePattern => text()();

  // The category the user chose for this payee
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  // How many times this rule was reinforced
  IntColumn get hitCount => integer().withDefault(const Constant(1))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {payeePattern};
}
