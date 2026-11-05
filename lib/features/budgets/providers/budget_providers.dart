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

final overallBudgetProvider = StreamProvider<BudgetWithProgress?>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgetsWithProgress().map(
    (budgets) => budgets.where((b) => b.isOverall && !b.isArchived).firstOrNull,
  );
});

final budgetTransactionsAsyncProvider = FutureProvider.autoDispose.family<List<Transaction>, Budget>((ref, budget) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return await repo.watchBudgetTransactions(budget).first;
});


