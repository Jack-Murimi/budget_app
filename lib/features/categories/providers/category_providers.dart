import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(dbProvider));
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final categoriesByIdProvider = Provider<Map<int, Category>>((ref) {
  final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const [];
  return {for (final c in categories) c.id: c};
});

final categoriesByFilterProvider = StreamProvider.autoDispose.family<
    List<Category>, ({bool includeArchived, String? transactionType})>(
  (ref, filter) => ref.watch(categoryRepositoryProvider).watchAll(
        includeArchived: filter.includeArchived,
        transactionType: filter.transactionType,
      ),
);
