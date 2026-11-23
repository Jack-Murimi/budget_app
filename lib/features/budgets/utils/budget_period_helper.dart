import '../../../core/database/app_database.dart';

/// Shared date-window and remaining-days calculations for budgets.
abstract final class BudgetPeriodHelper {
  /// Returns the half-open `[start, end)` window for [budget] at [now].
  static (DateTime, DateTime) getPeriodWindow(Budget budget, DateTime now) {
    switch (budget.period) {
      case 'monthly':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start, end);
      case 'weekly':
        final weekday = now.weekday;
        final start = DateTime(now.year, now.month, now.day - (weekday - 1));
        final end = start.add(const Duration(days: 7));
        return (start, end);
      default:
        final start = DateTime(
          budget.startDate.year,
          budget.startDate.month,
          budget.startDate.day,
        );
        if (budget.endDate != null) {
          final exclusiveEnd = DateTime(
            budget.endDate!.year,
            budget.endDate!.month,
            budget.endDate!.day + 1,
          );
          final minEnd = start.add(const Duration(days: 1));
          return (start, exclusiveEnd.isBefore(minEnd) ? minEnd : exclusiveEnd);
        }
        return (start, start.add(const Duration(days: 30)));
    }
  }

  /// Returns the immediately preceding `[start, end)` window for rollover
  /// calculation, or `null` for non-recurring custom budgets.
  static (DateTime, DateTime)? getPreviousPeriodWindow(
    Budget budget,
    DateTime now,
  ) {
    switch (budget.period) {
      case 'monthly':
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 1);
        return (start, end);
      case 'weekly':
        final weekday = now.weekday;
        final currentStart =
            DateTime(now.year, now.month, now.day - (weekday - 1));
        final prevStart = currentStart.subtract(const Duration(days: 7));
        return (prevStart, currentStart);
      default:
        return null;
    }
  }

  /// Returns non-negative calendar days remaining in [budget]'s current window.
  static int daysRemaining(Budget budget, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final (_, end) = getPeriodWindow(budget, current);
    final endDay = DateTime(end.year, end.month, end.day);
    return endDay.difference(today).inDays.clamp(0, 999999);
  }
}
