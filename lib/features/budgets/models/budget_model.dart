import '../../../core/database/app_database.dart';

class BudgetWithProgress {
  final Budget budget;
  final double spent;
  final String? categoryName;
  final String? categoryColorHex;
  final String? categoryIcon;

  const BudgetWithProgress({
    required this.budget,
    required this.spent,
    this.categoryName,
    this.categoryColorHex,
    this.categoryIcon,
  });

  int get id => budget.id;
  String get name => budget.name;
  double get amount => budget.amount;
  String get period => budget.period;
  int? get categoryId => budget.categoryId;
  bool get isOverall => budget.categoryId == null;
  double get remaining => amount - spent;
  double get progress => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  double get percentage => amount > 0 ? (spent / amount * 100) : 0.0;
  bool get isOverBudget => spent > amount;
  bool get isArchived => budget.isArchived;
}
