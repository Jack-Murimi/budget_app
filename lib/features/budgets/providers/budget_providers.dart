import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../../../shared/providers/theme_provider.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';

const _kPinnedBudgetsKey = 'pinned_budget_ids';

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

class PinnedBudgetsNotifier extends Notifier<List<int>> {
  static const int maxPinned = 3;

  @override
  List<int> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs?.getStringList(_kPinnedBudgetsKey) ?? const [];
    final parsed = <int>[];
    for (final s in raw) {
      final id = int.tryParse(s);
      if (id != null && !parsed.contains(id)) {
        parsed.add(id);
        if (parsed.length == maxPinned) break;
      }
    }
    return parsed;
  }

  bool isPinned(int id) => state.contains(id);

  /// Toggles pin state for [id]. Returns `false` if already at [maxPinned]
  /// when attempting to pin a new budget; otherwise `true`.
  bool toggle(int id) {
    if (state.contains(id)) {
      unpin(id);
      return true;
    }
    if (state.length >= maxPinned) return false;
    final next = [...state, id];
    state = next;
    _persist(next);
    return true;
  }

  void unpin(int id) {
    if (!state.contains(id)) return;
    final next = state.where((e) => e != id).toList();
    state = next;
    _persist(next);
  }

  void _persist(List<int> ids) {
    ref.read(sharedPreferencesProvider)?.setStringList(
          _kPinnedBudgetsKey,
          [for (final id in ids) id.toString()],
        );
  }
}

final pinnedBudgetIdsProvider =
    NotifierProvider<PinnedBudgetsNotifier, List<int>>(
  PinnedBudgetsNotifier.new,
);

final pinnedBudgetsProvider =
    Provider<AsyncValue<List<BudgetWithProgress>>>((ref) {
  final budgetsAsync = ref.watch(budgetsWithProgressProvider);
  final pinnedIds = ref.watch(pinnedBudgetIdsProvider);
  return budgetsAsync.whenData((budgets) {
    final byId = {
      for (final b in budgets)
        if (!b.isOverall && !b.isArchived) b.id: b,
    };
    return [
      for (final id in pinnedIds)
        if (byId[id] != null) byId[id]!,
    ].take(PinnedBudgetsNotifier.maxPinned).toList();
  });
});


