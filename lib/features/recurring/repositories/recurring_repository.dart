import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/recurring_model.dart';
import '../services/recurrence_engine.dart';

class RecurringRepository {
  final AppDatabase _db;

  RecurringRepository(this._db);

  Stream<List<RecurringModel>> watchAll({bool includeInactive = true}) {
    final query = '''
      SELECT
        r.*,
        a.name AS account_name,
        c.name AS category_name,
        c.color_hex AS category_color,
        c.icon AS category_icon
      FROM recurring_transactions r
      LEFT JOIN accounts a ON r.account_id = a.id
      LEFT JOIN categories c ON r.category_id = c.id
      ${includeInactive ? '' : 'WHERE r.is_active = 1'}
      ORDER BY r.next_due_date ASC
    ''';

    return _db.customSelect(
      query,
      readsFrom: {_db.recurringTransactions, _db.accounts, _db.categories},
    ).watch().map((rows) => rows.map(_mapRow).toList());
  }

  Stream<List<RecurringModel>> watchUpcoming({int days = 30}) {
    return watchAll(includeInactive: false).map((list) {
      final now = DateTime.now();
      final horizon = now.add(Duration(days: days));
      return list.where((r) => r.nextDueDate.isBefore(horizon)).toList();
    });
  }

  RecurringModel _mapRow(QueryRow row) {
    return RecurringModel(
      id: row.read<int>('id'),
      accountId: row.readNullable<int>('account_id'),
      categoryId: row.readNullable<int>('category_id'),
      amount: row.read<double>('amount'),
      type: row.read<String>('type'),
      payee: row.read<String>('payee'),
      notes: row.read<String>('notes'),
      frequency: row.read<String>('frequency'),
      intervalCount: row.read<int>('interval_count'),
      startDate: DateTime.fromMillisecondsSinceEpoch(row.read<int>('start_date') * 1000),
      endDate: row.readNullable<int>('end_date') != null
          ? DateTime.fromMillisecondsSinceEpoch(row.read<int>('end_date') * 1000)
          : null,
      nextDueDate: DateTime.fromMillisecondsSinceEpoch(row.read<int>('next_due_date') * 1000),
      autoRecord: row.read<int>('auto_record') == 1,
      notify: row.read<int>('notify') == 1,
      isActive: row.read<int>('is_active') == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.read<int>('created_at') * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.read<int>('updated_at') * 1000),
      accountName: row.readNullable<String>('account_name'),
      categoryName: row.readNullable<String>('category_name'),
      categoryColorHex: row.readNullable<String>('category_color'),
      categoryIcon: row.readNullable<String>('category_icon'),
    );
  }

  Future<int> insert(RecurringModel r) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return await _db.customInsert(
      '''
      INSERT INTO recurring_transactions (
        account_id, category_id, amount, type, payee, notes,
        frequency, interval_count, start_date, end_date, next_due_date,
        auto_record, notify, is_active, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<int>(r.accountId),
        Variable<int>(r.categoryId),
        Variable<double>(r.amount),
        Variable<String>(r.type),
        Variable<String>(r.payee),
        Variable<String>(r.notes),
        Variable<String>(r.frequency),
        Variable<int>(r.intervalCount),
        Variable.withDateTime(r.startDate),
        Variable<DateTime>(r.endDate),
        Variable.withDateTime(r.nextDueDate),
        Variable<int>(r.autoRecord ? 1 : 0),
        Variable<int>(r.notify ? 1 : 0),
        Variable<int>(r.isActive ? 1 : 0),
        Variable.withDateTime(DateTime.fromMillisecondsSinceEpoch(now)),
        Variable.withDateTime(DateTime.fromMillisecondsSinceEpoch(now)),
      ],
      updates: {_db.recurringTransactions},
    );
  }

  Future<bool> update(RecurringModel r) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = await _db.customUpdate(
      '''
      UPDATE recurring_transactions SET
        account_id = ?,
        category_id = ?,
        amount = ?,
        type = ?,
        payee = ?,
        notes = ?,
        frequency = ?,
        interval_count = ?,
        start_date = ?,
        end_date = ?,
        next_due_date = ?,
        auto_record = ?,
        notify = ?,
        is_active = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      variables: [
        Variable<int>(r.accountId),
        Variable<int>(r.categoryId),
        Variable<double>(r.amount),
        Variable<String>(r.type),
        Variable<String>(r.payee),
        Variable<String>(r.notes),
        Variable<String>(r.frequency),
        Variable<int>(r.intervalCount),
        Variable.withDateTime(r.startDate),
        Variable<DateTime>(r.endDate),
        Variable.withDateTime(r.nextDueDate),
        Variable<int>(r.autoRecord ? 1 : 0),
        Variable<int>(r.notify ? 1 : 0),
        Variable<int>(r.isActive ? 1 : 0),
        Variable.withDateTime(DateTime.fromMillisecondsSinceEpoch(now)),
        Variable<int>(r.id),
      ],
      updates: {_db.recurringTransactions},
    );
    return updated > 0;
  }

  Future<void> toggleActive(int id, bool isActive) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.customUpdate(
      'UPDATE recurring_transactions SET is_active = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable<int>(isActive ? 1 : 0),
        Variable.withDateTime(DateTime.fromMillisecondsSinceEpoch(now)),
        Variable<int>(id),
      ],
      updates: {_db.recurringTransactions},
    );
  }

  Future<void> delete(int id) async {
    await _db.customUpdate(
      'DELETE FROM recurring_transactions WHERE id = ?',
      variables: [Variable<int>(id)],
      updates: {_db.recurringTransactions},
    );
  }

  /// Mark as paid:
  /// 1. Inserts into transactions table.
  /// 2. Calculates next due date and updates recurring_transactions.
  Future<void> markAsPaid(
    RecurringModel r, {
    DateTime? paidDate,
    double? actualAmount,
  }) async {
    final transactionDate = paidDate ?? DateTime.now();
    final amount = actualAmount ?? r.amount;

    await _db.into(_db.transactions).insert(
      TransactionsCompanion.insert(
        header: r.payee.isNotEmpty ? r.payee : 'Recurring ${r.type}',
        description: Value(r.notes),
        amount: amount,
        type: Value(r.type),
        categoryId: Value(r.categoryId),
        accountId: Value(r.accountId),
        transactionDate: transactionDate,
        isParsed: const Value(false),
      ),
    );

    // Compute next due date
    final nextDate = RecurrenceEngine.nextDue(r);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if end_date reached
    final shouldDeactivate = r.endDate != null && nextDate.isAfter(r.endDate!);

    await _db.customUpdate(
      '''
      UPDATE recurring_transactions SET
        next_due_date = ?,
        is_active = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      variables: [
        Variable.withDateTime(nextDate),
        Variable<int>(shouldDeactivate ? 0 : 1),
        Variable.withDateTime(DateTime.fromMillisecondsSinceEpoch(now)),
        Variable<int>(r.id),
      ],
      updates: {_db.recurringTransactions},
    );
  }

  /// Skip current occurrence without recording a transaction.
  Future<void> skip(RecurringModel r) async {
    final nextDate = RecurrenceEngine.nextDue(r);
    final now = DateTime.now().millisecondsSinceEpoch;
    final shouldDeactivate = r.endDate != null && nextDate.isAfter(r.endDate!);

    await _db.customUpdate(
      '''
      UPDATE recurring_transactions SET
        next_due_date = ?,
        is_active = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      variables: [
        Variable.withDateTime(nextDate),
        Variable<int>(shouldDeactivate ? 0 : 1),
        Variable.withDateTime(DateTime.fromMillisecondsSinceEpoch(now)),
        Variable<int>(r.id),
      ],
      updates: {_db.transactions},
    );
  }
}
