import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text().withDefault(const Constant('mpesa'))();
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('KES'))();
  TextColumn get colorHex => text().withDefault(const Constant('#1B5E20'))();
  TextColumn get icon => text().withDefault(const Constant('account_balance_wallet'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
