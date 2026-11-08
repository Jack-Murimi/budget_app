import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/app_database.dart';
import 'core/services/deep_link_service.dart';
import 'features/add_transaction/screens/add_transaction_screen.dart';
import 'features/home/screens/main_navigation_screen.dart';
import 'features/settings/auth_gate.dart';
import 'l10n/app_localizations.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/theme/app_theme.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: BudgetApp(navigatorKey: _navigatorKey),
    ),
  );
}

class BudgetApp extends ConsumerStatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const BudgetApp({super.key, required this.navigatorKey});

  @override
  ConsumerState<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends ConsumerState<BudgetApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkService.listen(
      widget.navigatorKey,
      onAddTransaction: () {
        widget.navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        );
      },
      onScanSms: () {
        // Push the paste dialog on top of whatever is current
        widget.navigatorKey.currentState?.push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const _ScanSmsPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final oled = ref.watch(oledDarkProvider);
    final useDynamic = ref.watch(dynamicColorProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = useDynamic ? lightDynamic : null;
        final darkScheme = useDynamic ? darkDynamic : null;

        return MaterialApp(
          navigatorKey: widget.navigatorKey,
          title: 'Budget KE',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(lightScheme),
          darkTheme: AppTheme.dark(darkScheme, oled),
          themeMode: themeMode,
          home: const AuthGate(child: MainNavigationScreen()),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Thin wrapper that shows the paste-SMS dialog immediately.
class _ScanSmsPage extends StatefulWidget {
  const _ScanSmsPage();

  @override
  State<_ScanSmsPage> createState() => _ScanSmsPageState();
}

class _ScanSmsPageState extends State<_ScanSmsPage> {
  @override
  void initState() {
    super.initState();
    // Show dialog after first frame so we have a valid context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(); // pop this transparent page
      // The MainNavigationScreen's FAB logic handles the paste dialog;
      // we just navigate home and let the user tap the FAB.
      // ponytail: could directly show the dialog here with a proper Riverpod ref.
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
