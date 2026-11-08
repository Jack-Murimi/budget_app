import '../../../core/database/app_database.dart';
import 'package:drift/drift.dart';

class CsvImportResult {
  const CsvImportResult(
      {required this.imported, required this.skippedDuplicates});
  final int imported;
  final int skippedDuplicates;
}

class CsvPortabilityService {
  const CsvPortabilityService(this._db);
  final AppDatabase _db;

  Future<String> exportTransactionsCsv({DateTime? start, DateTime? end}) async {
    final query = _db.select(_db.transactions)
      ..orderBy([(row) => OrderingTerm.asc(row.transactionDate)]);
    if (start != null) {
      query.where((row) => row.transactionDate.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where((row) => row.transactionDate.isSmallerThanValue(end));
    }
    final rows = await query.get();
    return _csv([
      const [
        'header',
        'description',
        'amount',
        'type',
        'transaction_date',
        'mpesa_ref',
        'counterparty_name',
        'counterparty_account',
      ],
      ...rows.map((row) => [
            row.header,
            row.description,
            row.amount.toString(),
            row.type,
            row.transactionDate.toUtc().toIso8601String(),
            row.mpesaRef ?? '',
            row.counterpartyName,
            row.counterpartyAccount,
          ]),
    ]);
  }

  Future<String> exportAccountsCsv() async => _csv([
        const ['name', 'type', 'initial_balance', 'currency'],
        ...(await _db.select(_db.accounts).get()).map((row) => [
              row.name,
              row.type,
              row.initialBalance.toString(),
              row.currency,
            ]),
      ]);

  Future<String> exportCategoriesCsv() async => _csv([
        const ['name', 'parent_id', 'icon', 'color_hex'],
        ...(await _db.select(_db.categories).get()).map((row) => [
              row.name,
              row.parentId?.toString() ?? '',
              row.icon,
              row.colorHex,
            ]),
      ]);

  Future<CsvImportResult> importTransactionsCsv(String csv) async {
    final rows = _rows(csv);
    if (rows.isEmpty) {
      return const CsvImportResult(imported: 0, skippedDuplicates: 0);
    }
    final headers =
        rows.first.map((cell) => cell.trim().toLowerCase()).toList();
    String field(List<String> row, String name) {
      final index = headers.indexOf(name);
      return index < 0 || index >= row.length ? '' : row[index].trim();
    }

    var imported = 0;
    var skippedDuplicates = 0;
    for (final row in rows.skip(1)) {
      final header = field(row, 'header');
      final amount = double.tryParse(field(row, 'amount'));
      final date = DateTime.tryParse(field(row, 'transaction_date'));
      if (header.isEmpty || amount == null || amount <= 0 || date == null) {
        continue;
      }
      final payee = field(row, 'counterparty_name');
      final normalizedPayee =
          (payee.isEmpty ? header : payee).trim().toLowerCase();
      final duplicate = await (_db.select(_db.transactions)
            ..where((item) =>
                item.transactionDate.equals(date) &
                item.amount.equals(amount) &
                (item.counterpartyName.lower().equals(normalizedPayee) |
                    item.header.lower().equals(normalizedPayee)))
            ..limit(1))
          .getSingleOrNull();
      if (duplicate != null) {
        skippedDuplicates++;
        continue;
      }
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              header: header,
              description: Value(field(row, 'description')),
              amount: amount,
              type: Value(_type(field(row, 'type'))),
              transactionDate: date,
              mpesaRef: Value(_nullable(field(row, 'mpesa_ref'))),
              counterpartyName: Value(payee),
              counterpartyAccount: Value(field(row, 'counterparty_account')),
            ),
          );
      imported++;
    }
    return CsvImportResult(
        imported: imported, skippedDuplicates: skippedDuplicates);
  }

  static String _type(String value) =>
      {'income', 'expense', 'transfer'}.contains(value) ? value : 'expense';
  static String? _nullable(String value) => value.isEmpty ? null : value;

  static String _csv(List<List<String>> rows) =>
      rows.map((row) => row.map(_escape).join(',')).join('\n');

  static String _escape(String value) => '"${value.replaceAll('"', '""')}"';

  static List<List<String>> _rows(String source) {
    final output = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var quoted = false;
    for (var index = 0; index < source.length; index++) {
      final char = source[index];
      if (char == '"') {
        if (quoted && index + 1 < source.length && source[index + 1] == '"') {
          field.write('"');
          index++;
        } else {
          quoted = !quoted;
        }
      } else if (char == ',' && !quoted) {
        row.add(field.toString());
        field = StringBuffer();
      } else if ((char == '\n' || char == '\r') && !quoted) {
        if (char == '\r' &&
            index + 1 < source.length &&
            source[index + 1] == '\n') {
          index++;
        }
        row.add(field.toString());
        if (row.any((cell) => cell.isNotEmpty)) {
          output.add(row);
        }
        row = <String>[];
        field = StringBuffer();
      } else {
        field.write(char);
      }
    }
    row.add(field.toString());
    if (row.any((cell) => cell.isNotEmpty)) {
      output.add(row);
    }
    return output;
  }
}
