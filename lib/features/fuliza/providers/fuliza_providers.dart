import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../repositories/fuliza_repository.dart';

final fulizaRepositoryProvider = Provider<FulizaRepository>((ref) {
  return FulizaRepository(ref.watch(dbProvider));
});

final fulizaRecordsProvider = StreamProvider<List<FulizaRecord>>((ref) {
  return ref.watch(fulizaRepositoryProvider).watchAll();
});

final latestFulizaProvider = StreamProvider<FulizaRecord?>((ref) {
  return ref.watch(fulizaRepositoryProvider).watchLatest();
});
