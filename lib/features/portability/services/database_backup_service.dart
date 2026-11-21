import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';

class DatabaseBackupService {
  const DatabaseBackupService(this._db);
  final AppDatabase _db;

  static const _currentVersion = 2;

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

  static const Map<String, Set<String>> _moneyColumnsByTable = {
    'accounts': {'initial_balance'},
    'budgets': {'amount'},
    'fuliza_records': {'fuliza_amount', 'access_fee', 'outstanding_total'},
    'recurring_transactions': {'amount'},
    'debts': {'principal', 'outstanding', 'interest', 'disbursement_shortfall'},
    'debt_repayments': {'amount'},
    'savings_goals': {'target_amount', 'current_amount'},
    'goal_contributions': {'amount'},
    'transactions': {'amount', 'transaction_cost', 'fuliza_amount', 'fuliza_fee'},
    'sms_inbox_items': {'parsed_amount'},
  };

  Future<Map<String, dynamic>> snapshot() async {
    final tables = <String, dynamic>{};
    for (final table in _tables) {
      final rows = await _db.customSelect('SELECT * FROM $table').get();
      tables[table] = rows.map((row) => row.data).toList();
    }
    return {'version': _currentVersion, 'tables': tables};
  }

  Future<void> restore(Map<String, dynamic> snapshot) async {
    final version = snapshot['version'];
    if ((version != 1 && version != _currentVersion) ||
        snapshot['tables'] is! Map) {
      throw const FormatException('Unsupported backup snapshot');
    }
    final isLegacyRealMoney = version == 1;
    final tables = snapshot['tables'] as Map<String, dynamic>;
    await _db.transaction(() async {
      for (final table in _tables.reversed) {
        await _db.customStatement('DELETE FROM $table');
      }
      for (final table in _tables) {
        final rows = tables[table];
        if (rows is! List) continue;
        final moneyCols = _moneyColumnsByTable[table] ?? const <String>{};
        for (final row in rows) {
          if (row is! Map) throw FormatException('Invalid $table row');
          final values = Map<String, dynamic>.from(row);
          if (isLegacyRealMoney && moneyCols.isNotEmpty) {
            for (final col in moneyCols) {
              final raw = values[col];
              if (raw is num) {
                values[col] = CentsConverter.toCents(raw.toDouble());
              }
            }
          }
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
      throw const FormatException('Invalid backup column');
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
