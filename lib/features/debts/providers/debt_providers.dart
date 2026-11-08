import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../models/debt_model.dart';
import '../repositories/debt_repository.dart';

final debtRepositoryProvider =
    Provider((ref) => DebtRepository(ref.watch(dbProvider)));
final debtsProvider = StreamProvider<List<DebtWithRepayments>>(
    (ref) => ref.watch(debtRepositoryProvider).watchAll());
