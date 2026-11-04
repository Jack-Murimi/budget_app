import 'package:drift/drift.dart';
import 'categories_table.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get header => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get amount => real()();
  RealColumn get transactionCost => real().withDefault(const Constant(0.0))();
  RealColumn get fulizaAmount => real().withDefault(const Constant(0.0))(); // amount Fuliza covered
  RealColumn get fulizaFee => real().withDefault(const Constant(0.0))(); // Fuliza access fee
  TextColumn get type => text().withDefault(const Constant('expense'))(); // income | expense | transfer
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get mpesaRef => text().nullable()(); // M-Pesa transaction code
  TextColumn get counterpartyName => text().withDefault(const Constant(''))(); // Naivas, John Doe, etc.
  TextColumn get counterpartyAccount => text().withDefault(const Constant(''))(); // phone or paybill
  BoolColumn get isParsed => boolean().withDefault(const Constant(false))(); // came from SMS parse
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {mpesaRef}, // nullable unique: two nulls are allowed (manual entries), but same ref = duplicate
  ];
}
