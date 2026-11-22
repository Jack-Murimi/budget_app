import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../shared/utils/cashflow_calculator.dart';
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
  final accounts = ref.watch(allAccountsWithBalanceProvider);
  final transactions = ref.watch(allTransactionsProvider);
  return accounts.whenData((items) {
    final openingCents = items.fold<int>(
        0, (sum, item) => sum + CentsConverter.toCents(item.account.initialBalance));
    final openingBalance = CentsConverter.fromCents(openingCents);
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
  var balanceCents = CentsConverter.toCents(openingBalance);
  final dailyChangesCents = <DateTime, int>{};
  for (final item in items) {
    if (item.accountId == null) continue;
    final changeCents = switch (item.type) {
      'income' => CentsConverter.toCents(item.amount),
      'expense' => -CashflowCalculator.expenseTotalCents(item),
      'transfer' => -CentsConverter.toCents(item.transactionCost),
      _ => 0,
    };
    if (item.transactionDate.isBefore(range.start)) {
      balanceCents += changeCents;
    } else if (range.contains(item.transactionDate)) {
      final day = DateTime(item.transactionDate.year,
          item.transactionDate.month, item.transactionDate.day);
      dailyChangesCents[day] = (dailyChangesCents[day] ?? 0) + changeCents;
    }
  }
  final trend = <DateTime, double>{};
  for (var day = range.start;
      day.isBefore(range.end);
      day = DateTime(day.year, day.month, day.day + 1)) {
    balanceCents += dailyChangesCents[day] ?? 0;
    trend[day] = CentsConverter.fromCents(balanceCents);
  }
  return trend;
}

DateTime _previousPeriodStart(DateRange range) {
  final start = range.start;
  final end = range.end;
  if (start.day == 1 && end == DateTime(start.year, start.month + 1, 1)) {
    return DateTime(start.year, start.month - 1, 1);
  }
  if (start.month == 1 &&
      start.day == 1 &&
      end == DateTime(start.year + 1, 1, 1)) {
    return DateTime(start.year - 1, 1, 1);
  }
  return start.subtract(end.difference(start));
}

InsightsSummary buildInsightsSummary(
    List<TransactionModel> items, DateRange range) {
  var incomeCents = 0;
  var expensesCents = 0;
  var previousExpensesCents = 0;
  final dailyCents = <DateTime, List<int>>{};
  final previousStart = _previousPeriodStart(range);
  for (final item in items) {
    if (range.contains(item.transactionDate)) {
      final day = DateTime(item.transactionDate.year,
          item.transactionDate.month, item.transactionDate.day);
      final totals = dailyCents.putIfAbsent(day, () => [0, 0]);
      if (item.type == 'income') {
        final amountCents = CentsConverter.toCents(item.amount);
        incomeCents += amountCents;
        totals[0] += amountCents;
      } else if (item.type == 'expense') {
        final expenseCents = CashflowCalculator.expenseTotalCents(item);
        expensesCents += expenseCents;
        totals[1] += expenseCents;
      }
    } else if (!item.transactionDate.isBefore(previousStart) &&
        item.transactionDate.isBefore(range.start) &&
        item.type == 'expense') {
      previousExpensesCents += CashflowCalculator.expenseTotalCents(item);
    }
  }
  return InsightsSummary(
    income: CentsConverter.fromCents(incomeCents),
    expenses: CentsConverter.fromCents(expensesCents),
    previousExpenses: CentsConverter.fromCents(previousExpensesCents),
    byDay: {
      for (final entry in dailyCents.entries)
        entry.key: Cashflow(
          CentsConverter.fromCents(entry.value[0]),
          CentsConverter.fromCents(entry.value[1]),
        )
    },
  );
}
