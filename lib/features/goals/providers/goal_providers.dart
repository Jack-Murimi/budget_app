import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.watch(dbProvider)),
);

final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>(
  (ref) => ref.watch(goalRepositoryProvider).watchAll(),
);
