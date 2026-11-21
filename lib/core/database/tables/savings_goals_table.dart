import 'package:drift/drift.dart';
import '../converters/cents_converter.dart';
import 'accounts_table.dart';
import 'transactions_table.dart';

class SavingsGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get targetAmount => integer().map(const CentsConverter())();
  IntColumn get currentAmount => integer()
      .withDefault(const Constant(0))
      .map(const CentsConverter())();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class GoalContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(SavingsGoals, #id)();
  IntColumn get amount => integer().map(const CentsConverter())();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
  DateTimeColumn get contributionDate => dateTime()();
}
