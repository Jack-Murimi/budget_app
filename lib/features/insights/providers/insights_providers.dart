import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../accounts/providers/account_providers.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_providers.dart';

enum InsightsPeriod { week, month, lastMonth, year, custom }

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);
}

final insightsPeriodProvider =
    StateProvider<InsightsPeriod>((ref) => InsightsPeriod.month);
final insightsCustomRangeProvider = StateProvider<DateRange?>((ref) => null);

final insightsRangeProvider = Provider<DateRange>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (ref.watch(insightsPeriodProvider)) {
    case InsightsPeriod.week:
      return DateRange(today.subtract(Duration(days: today.weekday - 1)),
          today.add(const Duration(days: 1)));
    case InsightsPeriod.month:
      return DateRange(
          DateTime(now.year, now.month), DateTime(now.year, now.month + 1));
    case InsightsPeriod.lastMonth:
      return DateRange(
          DateTime(now.year, now.month - 1), DateTime(now.year, now.month));
    case InsightsPeriod.year:
      return DateRange(DateTime(now.year), DateTime(now.year + 1));
    case InsightsPeriod.custom:
      return ref.watch(insightsCustomRangeProvider) ??
          DateRange(
              DateTime(now.year, now.month), DateTime(now.year, now.month + 1));
  }
});

final insightsTransactionsProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final range = ref.watch(insightsRangeProvider);
  return ref.watch(allTransactionsProvider).whenData(
        (items) => items
            .where((item) => range.contains(item.transactionDate))
            .toList(),
      );
});

class InsightsSummary {
  final double income;
  final double expenses;
  final double previousExpenses;
  final Map<DateTime, Cashflow> byDay;

  const InsightsSummary({
    required this.income,
    required this.expenses,
    required this.previousExpenses,
    required this.byDay,
  });

  double get net => income - expenses;
  double get expenseDelta => previousExpenses == 0
      ? 0
      : (expenses - previousExpenses) / previousExpenses;
}

class Cashflow {
  final double income;
  final double expenses;
  const Cashflow(this.income, this.expenses);
}

final insightsSummaryProvider = Provider<AsyncValue<InsightsSummary>>((ref) {
  final range = ref.watch(insightsRangeProvider);
  return ref
      .watch(allTransactionsProvider)
      .whenData((items) => buildInsightsSummary(items, range));
});

final netWorthTrendProvider =
    Provider<AsyncValue<Map<DateTime, double>>>((ref) {
  final range = ref.watch(insightsRangeProvider);
  final accounts = ref.watch(accountsWithBalanceProvider);
  final transactions = ref.watch(allTransactionsProvider);
  return accounts.whenData((items) {
    final openingBalance =
        items.fold<double>(0, (sum, item) => sum + item.account.initialBalance);
    return transactions
            .whenData(
              (rows) => buildNetWorthTrend(rows, range, openingBalance),
            )
            .valueOrNull ??
        const <DateTime, double>{};
  });
});

Map<DateTime, double> buildNetWorthTrend(
  List<TransactionModel> items,
  DateRange range,
  double openingBalance,
) {
  var balance = openingBalance;
  final dailyChanges = <DateTime, double>{};
  for (final item in items) {
    if (item.accountId == null) continue;
    final change = switch (item.type) {
      'income' => item.amount,
      'expense' => -item.amount - item.transactionCost - item.fulizaFee,
      'transfer' => -item.transactionCost,
      _ => 0.0,
    };
    if (item.transactionDate.isBefore(range.start)) {
      balance += change;
    } else if (range.contains(item.transactionDate)) {
      final day = DateTime(item.transactionDate.year,
          item.transactionDate.month, item.transactionDate.day);
      dailyChanges[day] = (dailyChanges[day] ?? 0) + change;
    }
  }
  final trend = <DateTime, double>{};
  for (var day = range.start;
      day.isBefore(range.end);
      day = day.add(const Duration(days: 1))) {
    balance += dailyChanges[day] ?? 0;
    trend[day] = balance;
  }
  return trend;
}

InsightsSummary buildInsightsSummary(
    List<TransactionModel> items, DateRange range) {
  var income = 0.0;
  var expenses = 0.0;
  var previousExpenses = 0.0;
  final daily = <DateTime, List<double>>{};
  final previousStart = range.start.subtract(range.end.difference(range.start));
  for (final item in items) {
    if (range.contains(item.transactionDate)) {
      final day = DateTime(item.transactionDate.year,
          item.transactionDate.month, item.transactionDate.day);
      final totals = daily.putIfAbsent(day, () => [0, 0]);
      if (item.type == 'income') {
        income += item.amount;
        totals[0] += item.amount;
      } else if (item.type == 'expense') {
        expenses += item.amount;
        totals[1] += item.amount;
      }
    } else if (!item.transactionDate.isBefore(previousStart) &&
        item.transactionDate.isBefore(range.start) &&
        item.type == 'expense') {
      previousExpenses += item.amount;
    }
  }
  return InsightsSummary(
    income: income,
    expenses: expenses,
    previousExpenses: previousExpenses,
    byDay: {
      for (final entry in daily.entries)
        entry.key: Cashflow(entry.value[0], entry.value[1])
    },
  );
}
