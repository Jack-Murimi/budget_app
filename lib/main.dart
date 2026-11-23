import 'dart:async';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/app_database.dart';
import 'core/services/deep_link_service.dart';
import 'features/add_transaction/screens/add_transaction_screen.dart';
import 'features/home/screens/main_navigation_screen.dart';
import 'features/recurring/providers/recurring_providers.dart';
import 'features/settings/auth_gate.dart';
import 'features/settings/auth_service.dart';
import 'features/sms/screens/sms_inbox_screen.dart';
import 'l10n/l10n.dart';
import 'shared/providers/locale_provider.dart';
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
  GoogleFonts.config.allowRuntimeFetching = false;
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
  final Stream<String>? deepLinkStream;

  const BudgetApp({
    super.key,
    required this.navigatorKey,
    this.deepLinkStream,
  });

  @override
  ConsumerState<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends ConsumerState<BudgetApp> {
  StreamSubscription<String>? _deepLinkSub;
  String? _pendingDeepLink;

  @override
  void initState() {
    super.initState();
    _deepLinkSub = DeepLinkService.listen(
      widget.navigatorKey,
      stream: widget.deepLinkStream,
      onAddTransaction: () => _handleDeepLink('budgetke://add_transaction'),
      onScanSms: () => _handleDeepLink('budgetke://scan_sms'),
      onLink: _handleDeepLink,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(recurringRepositoryProvider).processAutoRecordDue().catchError((_) => 0),
      );
    });
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  void _handleDeepLink(String link) {
    if (!mounted) return;
    if (ref.read(appLockedProvider)) {
      _pendingDeepLink = link;
      return;
    }
    _dispatchDeepLink(link);
  }

  void _dispatchDeepLink(String link) {
    final nav = widget.navigatorKey.currentState;
    if (nav == null) return;
    if (link.startsWith('budgetke://add_transaction')) {
      nav.push(
        MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
      );
    } else if (link.startsWith('budgetke://scan_sms')) {
      nav.push(
        MaterialPageRoute(builder: (_) => const SmsInboxScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final oled = ref.watch(oledDarkProvider);
    final useDynamic = ref.watch(dynamicColorProvider);

    ref.listen<bool>(appLockedProvider, (prev, locked) {
      if (prev == true && !locked && _pendingDeepLink != null) {
        final link = _pendingDeepLink!;
        _pendingDeepLink = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _dispatchDeepLink(link);
        });
      }
    });

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = useDynamic ? lightDynamic : null;
        final darkScheme = useDynamic ? darkDynamic : null;

        return MaterialApp(
          navigatorKey: widget.navigatorKey,
          onGenerateTitle: (ctx) => ctx.l10n.appTitle,
          locale: locale,
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
