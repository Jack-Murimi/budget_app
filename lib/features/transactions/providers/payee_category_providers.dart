import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../repositories/payee_category_repository.dart';

final payeeCategoryRepositoryProvider =
    Provider<PayeeCategoryRepository>((ref) {
  return PayeeCategoryRepository(ref.watch(dbProvider));
});
