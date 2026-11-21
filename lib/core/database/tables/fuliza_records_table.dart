import 'package:drift/drift.dart';
import '../converters/cents_converter.dart';

class FulizaRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mpesaRef => text()();
  IntColumn get fulizaAmount => integer().map(const CentsConverter())();
  IntColumn get accessFee => integer()
      .withDefault(const Constant(0))
      .map(const CentsConverter())();
  IntColumn get outstandingTotal => integer()
      .withDefault(const Constant(0))
      .map(const CentsConverter())();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {mpesaRef},
  ];
}
