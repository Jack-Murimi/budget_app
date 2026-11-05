import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../repositories/account_repository.dart';
import '../models/account_model.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(dbProvider));
});

final accountsWithBalanceProvider = StreamProvider<List<AccountWithBalance>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAccountsWithBalance();
});

final totalNetWorthProvider = Provider<AsyncValue<double>>((ref) {
  final accountsAsync = ref.watch(accountsWithBalanceProvider);
  return accountsAsync.whenData((accounts) {
    return accounts
      .where((a) => !a.isArchived)
      .fold(0.0, (sum, a) => sum + a.balance);
  });
});
