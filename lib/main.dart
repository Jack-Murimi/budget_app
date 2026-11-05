import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/app_database.dart';
import 'features/home/screens/main_navigation_screen.dart';
import 'shared/theme/app_theme.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BudgetApp()));
}

class BudgetApp extends ConsumerWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Budget KE',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
