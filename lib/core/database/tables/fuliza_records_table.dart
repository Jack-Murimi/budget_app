import 'package:drift/drift.dart';

class FulizaRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mpesaRef => text()(); // links to paired transaction
  RealColumn get fulizaAmount => real()(); // amount Fuliza credited
  RealColumn get accessFee => real().withDefault(const Constant(0.0))();
  RealColumn get outstandingTotal => real().withDefault(const Constant(0.0))(); // total outstanding at time of this drawdown
  DateTimeColumn get dueDate => dateTime().nullable()(); // repayment due date
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
