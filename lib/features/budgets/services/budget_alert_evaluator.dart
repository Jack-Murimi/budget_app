import '../models/budget_model.dart';

enum BudgetAlertLevel { warning80, exceeded100 }

class BudgetThresholdAlert {
  final BudgetWithProgress budget;
  final BudgetAlertLevel level;

  const BudgetThresholdAlert({
    required this.budget,
    required this.level,
  });
}

abstract final class BudgetAlertEvaluator {
  /// Returns active budgets that crossed 80% or 100% between [before] and
  /// [after], ordered with exceeded budgets before 80% warnings and specific
  /// category/multi-category budgets before the overall budget.
  static List<BudgetThresholdAlert> evaluateCrossedThresholds({
    required List<BudgetWithProgress> before,
    required List<BudgetWithProgress> after,
  }) {
    final beforeById = {for (final b in before) b.id: b};
    final alerts = <BudgetThresholdAlert>[];

    for (final curr in after) {
      if (curr.isArchived || curr.amount <= 0) continue;
      final prev = beforeById[curr.id];
      final prevPct = (prev != null && prev.amount > 0) ? prev.percentage : 0.0;
      final currPct = curr.percentage;

      if (currPct >= 100.0 && prevPct < 100.0) {
        alerts.add(
          BudgetThresholdAlert(
            budget: curr,
            level: BudgetAlertLevel.exceeded100,
          ),
        );
      } else if (currPct >= 80.0 && prevPct < 80.0) {
        alerts.add(
          BudgetThresholdAlert(
            budget: curr,
            level: BudgetAlertLevel.warning80,
          ),
        );
      }
    }

    alerts.sort((a, b) {
      if (a.level != b.level) {
        return a.level == BudgetAlertLevel.exceeded100 ? -1 : 1;
      }
      if (a.budget.isOverall != b.budget.isOverall) {
        return a.budget.isOverall ? 1 : -1;
      }
      return b.budget.percentage.compareTo(a.budget.percentage);
    });

    return alerts;
  }
}
