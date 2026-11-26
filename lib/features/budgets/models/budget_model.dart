import '../../../core/database/app_database.dart';

class BudgetCategoryBreakdown {
  final Category category;
  final double spent;
  final int transactionCount;

  const BudgetCategoryBreakdown({
    required this.category,
    required this.spent,
    required this.transactionCount,
  });
}

class BudgetWithProgress {
  final Budget budget;
  final double spent;
  final double rolloverAmount;
  final List<Category> categories;
  final List<BudgetCategoryBreakdown> categoryBreakdown;
  final String? categoryName;
  final String? categoryColorHex;
  final String? categoryIcon;

  const BudgetWithProgress({
    required this.budget,
    required this.spent,
    this.rolloverAmount = 0.0,
    this.categories = const [],
    this.categoryBreakdown = const [],
    this.categoryName,
    this.categoryColorHex,
    this.categoryIcon,
  });

  int get id => budget.id;
  String get name => budget.name;
  double get baseAmount => budget.amount;
  double get amount => budget.amount + rolloverAmount;
  String get period => budget.period;
  int? get categoryId =>
      categories.isNotEmpty ? categories.first.id : budget.categoryId;
  List<int> get categoryIds => categories.isNotEmpty
      ? categories.map((c) => c.id).toList()
      : (budget.categoryId != null ? [budget.categoryId!] : const []);
  bool get isOverall => categories.isEmpty && budget.categoryId == null;
  bool get isMultiCategory => categories.length > 1;
  String get categorySummary => categories.isNotEmpty
      ? categories.map((c) => c.name).join(' · ')
      : (categoryName ?? '');
  double get remaining => amount - spent;
  double get progress => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  double get percentage => amount > 0 ? (spent / amount * 100) : 0.0;
  bool get isOverBudget => spent > amount;
  bool get isArchived => budget.isArchived;
}

class BudgetFormResult {
  final BudgetsCompanion companion;
  final List<int> categoryIds;

  const BudgetFormResult({
    required this.companion,
    required this.categoryIds,
  });
}
