import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';
import '../../../core/database/app_database.dart';

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(dbProvider);
  return BudgetRepository(db);
});

final budgetsWithProgressProvider = StreamProvider<List<BudgetWithProgress>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgetsWithProgress();
});

final allBudgetsWithProgressProvider =
    StreamProvider<List<BudgetWithProgress>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgetsWithProgress(includeArchived: true);
});

final overallBudgetProvider = Provider<AsyncValue<BudgetWithProgress?>>((ref) {
  final budgetsAsync = ref.watch(budgetsWithProgressProvider);
  return budgetsAsync.whenData(
    (budgets) => budgets.where((b) => b.isOverall && !b.isArchived).firstOrNull,
  );
});

final budgetTransactionsAsyncProvider =
    StreamProvider.autoDispose.family<List<Transaction>, Budget>((ref, budget) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgetTransactions(budget);
});


