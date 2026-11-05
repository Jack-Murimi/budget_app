import 'package:drift/drift.dart';
import 'categories_table.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  TextColumn get period => text().withDefault(const Constant('monthly'))(); // monthly, weekly, custom
  IntColumn get categoryId => integer().nullable().references(Categories, #id)(); // null = overall budget
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
