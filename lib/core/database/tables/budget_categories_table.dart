import 'package:drift/drift.dart';
import 'budgets_table.dart';
import 'categories_table.dart';

class BudgetCategories extends Table {
  IntColumn get budgetId =>
      integer().references(Budgets, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {budgetId, categoryId};
}
