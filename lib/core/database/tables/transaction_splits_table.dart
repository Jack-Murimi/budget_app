import 'package:drift/drift.dart';
import '../converters/cents_converter.dart';
import 'categories_table.dart';
import 'transactions_table.dart';

class TransactionSplits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get amount => integer().map(const CentsConverter())();
  TextColumn get note => text().withDefault(const Constant(''))();
}
