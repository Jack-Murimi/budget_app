import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';

class DatabaseBackupService {
  const DatabaseBackupService(this._db);
  final AppDatabase _db;

  static const _currentVersion = 2;

  // Ordered parent-before-child so restore succeeds under PRAGMA foreign_keys = ON.
  static const _tables = [
    'categories',
    'accounts',
    'budgets',
    'fuliza_records',
    'recurring_transactions',
    'debts',
    'savings_goals',
    'transactions',
    'debt_repayments',
    'goal_contributions',
    'payee_category_rules',
    'sms_inbox_items',
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
        if (table == 'categories') {
          await _db.customStatement('UPDATE categories SET parent_id = NULL');
        }
        await _db.customStatement('DELETE FROM $table');
      }
      for (final table in _tables) {
        final rawRows = tables[table];
        if (rawRows is! List) continue;
        final moneyCols = _moneyColumnsByTable[table] ?? const <String>{};
        var rowMaps = <Map<String, dynamic>>[];
        for (final row in rawRows) {
          if (row is! Map) throw FormatException('Invalid $table row');
          rowMaps.add(Map<String, dynamic>.from(row));
        }
        if (table == 'categories') {
          rowMaps = _orderCategoriesParentFirst(rowMaps);
        }
        for (final values in rowMaps) {
          if (values.isEmpty) continue;
          if (isLegacyRealMoney && moneyCols.isNotEmpty) {
            for (final col in moneyCols) {
              final raw = values[col];
              if (raw is num) {
                values[col] = CentsConverter.toCents(raw.toDouble());
              }
            }
          }
          final entries = values.entries.toList();
          final columns = entries.map((e) => _identifier(e.key)).join(', ');
          final placeholders = List.filled(entries.length, '?').join(', ');
          final args = entries
              .map((e) => e.value is bool ? ((e.value as bool) ? 1 : 0) : e.value)
              .toList();
          await _db.customStatement(
            'INSERT INTO $table ($columns) VALUES ($placeholders)',
            args,
          );
        }
      }
    });
    _db.markTablesUpdated(_db.allTables);
  }

  static List<Map<String, dynamic>> _orderCategoriesParentFirst(
    List<Map<String, dynamic>> rows,
  ) {
    final ordered = <Map<String, dynamic>>[];
    final remaining = List<Map<String, dynamic>>.from(rows);
    final insertedIds = <Object>{};

    while (remaining.isNotEmpty) {
      var progressed = false;
      for (var i = 0; i < remaining.length;) {
        final row = remaining[i];
        final parentId = row['parent_id'];
        if (parentId == null || insertedIds.contains(parentId)) {
          ordered.add(row);
          final id = row['id'];
          if (id != null) insertedIds.add(id);
          remaining.removeAt(i);
          progressed = true;
        } else {
          i++;
        }
      }
      if (!progressed) {
        ordered.addAll(remaining);
        break;
      }
    }
    return ordered;
  }

  static String _identifier(String value) {
    if (!RegExp(r'^[a-z_]+$').hasMatch(value)) {
      throw const FormatException('Invalid backup column');
    }
    return value;
  }
}
