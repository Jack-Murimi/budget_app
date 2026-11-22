import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

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
    final accounts = await _db.select(_db.accounts).get();
    final categories = await _db.select(_db.categories).get();
    final accountNames = {for (final a in accounts) a.id: a.name};
    final categoryNames = {for (final c in categories) c.id: c.name};

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
        'transaction_cost',
        'fuliza_amount',
        'fuliza_fee',
        'category_name',
        'account_name',
        'to_account_name',
        'exclude_from_budget',
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
            row.transactionCost.toString(),
            row.fulizaAmount.toString(),
            row.fulizaFee.toString(),
            row.categoryId == null ? '' : (categoryNames[row.categoryId!] ?? ''),
            row.accountId == null ? '' : (accountNames[row.accountId!] ?? ''),
            row.toAccountId == null
                ? ''
                : (accountNames[row.toAccountId!] ?? ''),
            row.excludeFromBudget ? 'true' : 'false',
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

    return _db.transaction(() async {
      final accounts = await _db.select(_db.accounts).get();
      final defaultAccountId = accounts
              .where((a) => a.isDefault)
              .firstOrNull
              ?.id ??
          accounts.firstOrNull?.id;
      final accountIdsByName = {
        for (final a in accounts) a.name.trim().toLowerCase(): a.id,
      };
      final validAccountIds = {for (final a in accounts) a.id};

      final categories = await _db.select(_db.categories).get();
      final categoryIdsByName = {
        for (final c in categories) c.name.trim().toLowerCase(): c.id,
      };
      final validCategoryIds = {for (final c in categories) c.id};

      int? resolveAccountId(String nameField, String idField) {
        final byId = int.tryParse(idField);
        if (byId != null && validAccountIds.contains(byId)) return byId;
        if (nameField.isNotEmpty) {
          return accountIdsByName[nameField.toLowerCase()];
        }
        return null;
      }

      int? resolveCategoryId(String nameField, String idField) {
        final byId = int.tryParse(idField);
        if (byId != null && validCategoryIds.contains(byId)) return byId;
        if (nameField.isNotEmpty) {
          return categoryIdsByName[nameField.toLowerCase()];
        }
        return null;
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

        final mpesaRef = _nullable(field(row, 'mpesa_ref'));
        if (mpesaRef != null) {
          final existingRef = await (_db.select(_db.transactions)
                ..where((item) => item.mpesaRef.equals(mpesaRef))
                ..limit(1))
              .getSingleOrNull();
          if (existingRef != null) {
            skippedDuplicates++;
            continue;
          }
        }

        final payee = field(row, 'counterparty_name');
        final normalizedPayee =
            (payee.isEmpty ? header : payee).trim().toLowerCase();
        final duplicate = await (_db.select(_db.transactions)
              ..where((item) =>
                  item.transactionDate.equals(date) &
                  item.amount.equalsValue(amount) &
                  (item.counterpartyName.lower().equals(normalizedPayee) |
                      item.header.lower().equals(normalizedPayee)))
              ..limit(1))
            .getSingleOrNull();
        if (duplicate != null) {
          skippedDuplicates++;
          continue;
        }

        final type = _type(field(row, 'type'));
        final accountId = resolveAccountId(
              field(row, 'account_name'),
              field(row, 'account_id'),
            ) ??
            defaultAccountId;
        final toAccountId = type == 'transfer'
            ? resolveAccountId(
                field(row, 'to_account_name'),
                field(row, 'to_account_id'),
              )
            : null;
        final categoryId = resolveCategoryId(
          field(row, 'category_name'),
          field(row, 'category_id'),
        );
        final cost = _nonNegativeDouble(field(row, 'transaction_cost'));
        final fulizaAmount = _nonNegativeDouble(field(row, 'fuliza_amount'));
        final fulizaFee = _nonNegativeDouble(field(row, 'fuliza_fee'));
        final excludeRaw = field(row, 'exclude_from_budget').toLowerCase();
        final excludeFromBudget = excludeRaw == 'true' || excludeRaw == '1';

        await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                header: header,
                description: Value(field(row, 'description')),
                amount: amount,
                transactionCost: Value(cost),
                fulizaAmount: Value(fulizaAmount),
                fulizaFee: Value(fulizaFee),
                type: Value(type),
                categoryId: Value(categoryId),
                transactionDate: date,
                mpesaRef: Value(mpesaRef),
                counterpartyName: Value(payee),
                counterpartyAccount: Value(field(row, 'counterparty_account')),
                accountId: Value(accountId),
                toAccountId: Value(toAccountId),
                excludeFromBudget: Value(excludeFromBudget),
              ),
            );
        imported++;
      }
      return CsvImportResult(
          imported: imported, skippedDuplicates: skippedDuplicates);
    });
  }

  static double _nonNegativeDouble(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null || !parsed.isFinite || parsed < 0) return 0.0;
    return parsed;
  }

  static String _type(String value) =>
      {'income', 'expense', 'transfer'}.contains(value) ? value : 'expense';
  static String? _nullable(String value) => value.isEmpty ? null : value;

  static String _csv(List<List<String>> rows) =>
      rows.map((row) => row.map(_escape).join(',')).join('\n');

  static String _sanitizeFormula(String value) {
    if (value.isEmpty) return value;
    final first = value[0];
    if (first == '=' ||
        first == '+' ||
        first == '@' ||
        first == '\t' ||
        first == '\r') {
      return "'$value";
    }
    if (first == '-' && double.tryParse(value) == null) {
      return "'$value";
    }
    return value;
  }

  static String _escape(String value) =>
      '"${_sanitizeFormula(value).replaceAll('"', '""')}"';

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
