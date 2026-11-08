import 'package:drift/drift.dart';

/// Staging queue for SMS messages that could not be fully parsed or
/// need user review before being saved as transactions.
class SmsInboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Raw SMS body
  TextColumn get rawBody => text()();

  // Parsed data (may be partial)
  TextColumn get parsedType =>
      text().nullable()(); // e.g. 'sendMoney', 'paybill', null=unknown
  RealColumn get parsedAmount => real().nullable()();
  TextColumn get parsedPayee => text().nullable()();
  TextColumn get parsedRef => text().nullable()();
  IntColumn get parsedDate => integer().nullable()(); // ms since epoch

  // 'pending' | 'approved' | 'dismissed'
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  // Error/reason why it needs review
  TextColumn get parseNote => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}
