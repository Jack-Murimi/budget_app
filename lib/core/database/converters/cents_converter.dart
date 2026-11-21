import 'package:drift/drift.dart';

/// Stores monetary values in SQLite as exact integer cents (`KES * 100`),
/// preventing floating-point drift in storage and arithmetic.
class CentsConverter extends TypeConverter<double, int> {
  const CentsConverter();

  /// Converts a KES amount (e.g. `150.50`) to exact integer cents (`15050`).
  static int toCents(double kes) => (kes * 100).round();

  /// Converts integer cents (`15050`) back to a KES amount (`150.50`).
  static double fromCents(int cents) => cents / 100.0;

  @override
  double fromSql(int fromDb) => fromCents(fromDb);

  @override
  int toSql(double value) => toCents(value);
}
