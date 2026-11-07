import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../models/recurring_model.dart';
import '../repositories/recurring_repository.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  final db = ref.watch(dbProvider);
  return RecurringRepository(db);
});

final allRecurringProvider = StreamProvider<List<RecurringModel>>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.watchAll(includeInactive: true);
});

final upcomingRecurringProvider = StreamProvider<List<RecurringModel>>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.watchUpcoming(days: 30);
});

final dueOrOverdueRecurringProvider = Provider<AsyncValue<List<RecurringModel>>>((ref) {
  final allAsync = ref.watch(allRecurringProvider);
  return allAsync.whenData((list) {
    return list.where((r) => r.isActive && (r.isOverdue || r.isDueSoon(days: 3))).toList();
  });
});

class RecurringSummary {
  final double monthlyExpense;
  final double monthlyIncome;
  final int activeCount;
  final int overdueCount;

  const RecurringSummary({
    required this.monthlyExpense,
    required this.monthlyIncome,
    required this.activeCount,
    required this.overdueCount,
  });
}

final recurringSummaryProvider = Provider<AsyncValue<RecurringSummary>>((ref) {
  final allAsync = ref.watch(allRecurringProvider);
  return allAsync.whenData((list) {
    double exp = 0;
    double inc = 0;
    int active = 0;
    int overdue = 0;

    for (final r in list) {
      if (!r.isActive) continue;
      active++;
      if (r.isOverdue) overdue++;

      // Normalize to monthly equivalent
      final mult = switch (r.frequency.toLowerCase()) {
        'daily' => 30.0 / (r.intervalCount > 0 ? r.intervalCount : 1),
        'weekly' => 4.33 / (r.intervalCount > 0 ? r.intervalCount : 1),
        'yearly' => (1.0 / 12.0) / (r.intervalCount > 0 ? r.intervalCount : 1),
        _ => 1.0 / (r.intervalCount > 0 ? r.intervalCount : 1),
      };

      if (r.type == 'income') {
        inc += r.amount * mult;
      } else {
        exp += r.amount * mult;
      }
    }

    return RecurringSummary(
      monthlyExpense: exp,
      monthlyIncome: inc,
      activeCount: active,
      overdueCount: overdue,
    );
  });
});
