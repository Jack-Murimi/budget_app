import 'package:drift/drift.dart';
import 'accounts_table.dart';

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get direction => text()(); // borrowed | lent
  TextColumn get counterparty => text().withLength(min: 1, max: 100)();
  TextColumn get product => text().withDefault(const Constant('personal'))();
  RealColumn get principal => real()();
  RealColumn get outstanding => real()();
  RealColumn get interest => real().withDefault(const Constant(0.0))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class DebtRepayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(Debts, #id)();
  RealColumn get amount => real()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get paymentDate => dateTime()();
  IntColumn get transactionId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
