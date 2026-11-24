import 'dart:async';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Start SQLite isolate warm-up and SharedPreferences load in parallel
  // without blocking runApp(), so Flutter draws frame 1 immediately.
  final db = AppDatabase();
  final prefsFuture = SharedPreferences.getInstance();
  runApp(_AppBootstrap(db: db, prefsFuture: prefsFuture));
}

class _AppBootstrap extends StatefulWidget {
  final AppDatabase db;
  final Future<SharedPreferences> prefsFuture;

  const _AppBootstrap({
    required this.db,
    required this.prefsFuture,
  });

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    widget.prefsFuture.then((prefs) {
      if (mounted) {
        setState(() => _prefs = prefs);
      }
    });
  }

  @override
  void dispose() {
    widget.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    if (prefs == null) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return ColoredBox(
        color: brightness == Brightness.dark ? Colors.black : Colors.white,
      );
    }

    return ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(widget.db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: BudgetApp(navigatorKey: _navigatorKey),
    );
  }
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
  Timer? _autoRecordTimer;
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
      _autoRecordTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        unawaited(
          ref
              .read(recurringRepositoryProvider)
              .processAutoRecordDue()
              .catchError((_) => 0),
        );
      });
    });
  }

  @override
  void dispose() {
    _autoRecordTimer?.cancel();
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

    Widget buildMaterialApp(ColorScheme? lightScheme, ColorScheme? darkScheme) {
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
    }

    if (!useDynamic) {
      return buildMaterialApp(null, null);
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) =>
          buildMaterialApp(lightDynamic, darkDynamic),
    );
  }
}
