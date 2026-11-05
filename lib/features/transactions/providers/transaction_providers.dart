import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(dbProvider));
});

final recentTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
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

final allTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

final transactionSearchQueryProvider = StateProvider<String>((ref) => '');
final transactionTypeFilterProvider = StateProvider<String>((ref) => 'all'); // 'all', 'expense', 'income', 'transfer'
final transactionCategoryFilterProvider = StateProvider<int?>((ref) => null);
final transactionDateRangeFilterProvider = StateProvider<String>((ref) => 'all'); // 'all', 'today', 'this_week', 'this_month'
final transactionAccountFilterProvider = StateProvider<int?>((ref) => null);

final filteredTransactionsProvider = Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final allAsync = ref.watch(allTransactionsProvider);
  final query = ref.watch(transactionSearchQueryProvider).trim().toLowerCase();
  final type = ref.watch(transactionTypeFilterProvider);
  final categoryId = ref.watch(transactionCategoryFilterProvider);
  final dateRange = ref.watch(transactionDateRangeFilterProvider);
  final accountId = ref.watch(transactionAccountFilterProvider);

  return allAsync.whenData((txns) {
    return txns.where((t) {
      if (query.isNotEmpty) {
        final matchesHeader = t.header.toLowerCase().contains(query);
        final matchesDesc = t.description.toLowerCase().contains(query);
        final matchesRef = t.mpesaRef?.toLowerCase().contains(query) ?? false;
        final matchesCounterparty = t.counterpartyName.toLowerCase().contains(query);
        if (!matchesHeader && !matchesDesc && !matchesRef && !matchesCounterparty) {
          return false;
        }
      }

      if (type != 'all' && t.type != type) {
        return false;
      }

      if (categoryId != null && t.categoryId != categoryId) {
        return false;
      }

      if (accountId != null && t.accountId != accountId && t.toAccountId != accountId) {
        return false;
      }

      if (dateRange != 'all') {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if (dateRange == 'today') {
          if (t.transactionDate.isBefore(today)) return false;
        } else if (dateRange == 'this_week') {
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          if (t.transactionDate.isBefore(startOfWeek)) return false;
        } else if (dateRange == 'this_month') {
          final startOfMonth = DateTime(now.year, now.month, 1);
          if (t.transactionDate.isBefore(startOfMonth)) return false;
        }
      }

      return true;
    }).toList();
  });
});

