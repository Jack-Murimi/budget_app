import 'package:drift/drift.dart';

class FulizaRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mpesaRef => text()();
  RealColumn get fulizaAmount => real()();
  RealColumn get accessFee => real().withDefault(const Constant(0.0))();
  RealColumn get outstandingTotal => real().withDefault(const Constant(0.0))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {mpesaRef},
  ];
}
