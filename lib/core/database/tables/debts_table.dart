import 'package:drift/drift.dart';
import '../converters/cents_converter.dart';
import 'accounts_table.dart';

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get direction => text()(); // borrowed | lent
  TextColumn get counterparty => text().withLength(min: 1, max: 100)();
  TextColumn get product => text().withDefault(const Constant('personal'))();
  IntColumn get principal => integer().map(const CentsConverter())();
  IntColumn get outstanding => integer().map(const CentsConverter())();
  IntColumn get interest => integer()
      .withDefault(const Constant(0))
      .map(const CentsConverter())();
  // For Bridge/app loans: principal - actual amount credited (e.g. borrow 600 but get 570 → shortfall=30)
  IntColumn get disbursementShortfall => integer()
      .withDefault(const Constant(0))
      .map(const CentsConverter())();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class DebtRepayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(Debts, #id)();
  IntColumn get amount => integer().map(const CentsConverter())();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get paymentDate => dateTime()();
  IntColumn get transactionId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
