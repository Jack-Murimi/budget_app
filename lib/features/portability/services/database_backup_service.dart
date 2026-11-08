import '../../../core/database/app_database.dart';

class DatabaseBackupService {
  const DatabaseBackupService(this._db);
  final AppDatabase _db;

  static const _tables = [
    'categories',
    'accounts',
    'budgets',
    'fuliza_records',
    'recurring_transactions',
    'debts',
    'debt_repayments',
    'savings_goals',
    'goal_contributions',
    'transactions',
  ];

  Future<Map<String, dynamic>> snapshot() async {
    final tables = <String, dynamic>{};
    for (final table in _tables) {
      final rows = await _db.customSelect('SELECT * FROM $table').get();
      tables[table] = rows.map((row) => row.data).toList();
    }
    return {'version': 1, 'tables': tables};
  }

  Future<void> restore(Map<String, dynamic> snapshot) async {
    if (snapshot['version'] != 1 || snapshot['tables'] is! Map) {
      throw FormatException('Unsupported backup snapshot');
    }
    final tables = snapshot['tables'] as Map<String, dynamic>;
    await _db.transaction(() async {
      for (final table in _tables.reversed) {
        await _db.customStatement('DELETE FROM $table');
      }
      for (final table in _tables) {
        final rows = tables[table];
        if (rows is! List) continue;
        for (final row in rows) {
          if (row is! Map) throw FormatException('Invalid $table row');
          final values = Map<String, dynamic>.from(row);
          final columns = values.keys.map(_identifier).join(', ');
          final data = values.values.map(_value).join(', ');
          await _db
              .customStatement('INSERT INTO $table ($columns) VALUES ($data)');
        }
      }
    });
  }

  static String _identifier(String value) {
    if (!RegExp(r'^[a-z_]+$').hasMatch(value)) {
      throw FormatException('Invalid backup column');
    }
    return value;
  }

  static String _value(dynamic value) {
    if (value == null) return 'NULL';
    if (value is num) return value.toString();
    if (value is bool) return value ? '1' : '0';
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}
