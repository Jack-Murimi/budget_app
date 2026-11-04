import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(dbProvider));
});

final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchRecent();
});

class MonthSummary {
  final double totalExpenses;
  final double totalIncome;
  final String month;

  const MonthSummary({
    required this.totalExpenses,
    required this.totalIncome,
    required this.month,
  });

  double get net => totalIncome - totalExpenses;
}

final monthSummaryProvider = StreamProvider<MonthSummary>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  return repo.watchMonthSummary(year: now.year, month: now.month).map((rows) {
    double expenses = 0;
    double income = 0;
    for (final t in rows) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expenses += t.amount;
      }
    }
    return MonthSummary(
      totalExpenses: expenses,
      totalIncome: income,
      month: DateFormat('MMMM yyyy').format(now),
    );
  });
});

/// Action provider: insert a transaction and return its ID.
final insertTransactionProvider = Provider<Future<int> Function(TransactionsCompanion)>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.insert;
});

