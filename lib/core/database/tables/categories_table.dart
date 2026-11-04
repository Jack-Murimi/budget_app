import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  TextColumn get colorHex => text().withDefault(const Constant('#6750A4'))();
  IntColumn get parentId => integer().nullable().references(Categories, #id)();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
