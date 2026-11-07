import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'categories_table.dart';

class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get type => text().withDefault(const Constant('expense'))(); // income | expense | transfer
  TextColumn get payee => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  // frequency: daily | weekly | monthly | yearly | custom
  TextColumn get frequency => text().withDefault(const Constant('monthly'))();
  IntColumn get intervalCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get autoRecord => boolean().withDefault(const Constant(false))();
  BoolColumn get notify => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
