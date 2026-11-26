import 'dart:async';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/app_database.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/reminder_notification_service.dart';
import 'features/add_transaction/screens/add_transaction_screen.dart';
import 'features/debts/providers/debt_providers.dart';
import 'features/fuliza/providers/fuliza_providers.dart';
import 'features/home/screens/main_navigation_screen.dart';
import 'features/home/widgets/floating_action_buttons.dart';
import 'features/recurring/providers/recurring_providers.dart';
import 'features/settings/auth_gate.dart';
import 'features/settings/auth_service.dart';
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

Future<(ColorScheme?, ColorScheme?)> _preloadDynamicSchemes() async {
  try {
    final palette = await DynamicColorPlugin.getCorePalette().timeout(
      const Duration(milliseconds: 120),
      onTimeout: () => null,
    );
    if (palette == null) return (null, null);
    return (
      palette.toColorScheme(),
      palette.toColorScheme(brightness: Brightness.dark),
    );
  } catch (_) {
    return (null, null);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Start SQLite isolate warm-up, SharedPreferences, and dynamic palette
  // concurrently so MaterialApp renders once on frame 1 with final colors.
  final db = AppDatabase();
  final prefsFuture = SharedPreferences.getInstance();
  final schemesFuture = _preloadDynamicSchemes();

  final prefs = await prefsFuture;
  final (lightDynamic, darkDynamic) = await schemesFuture;

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWith((ref) {
          ref.onDispose(() => db.close());
          return db;
        }),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: BudgetApp(
        navigatorKey: _navigatorKey,
        initialLightDynamic: lightDynamic,
        initialDarkDynamic: darkDynamic,
        dynamicColorsPreloaded: true,
      ),
    ),
  );
}

class BudgetApp extends ConsumerStatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Stream<String>? deepLinkStream;
  final ColorScheme? initialLightDynamic;
  final ColorScheme? initialDarkDynamic;
  final bool dynamicColorsPreloaded;

  const BudgetApp({
    super.key,
    required this.navigatorKey,
    this.deepLinkStream,
    this.initialLightDynamic,
    this.initialDarkDynamic,
    this.dynamicColorsPreloaded = false,
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
      onLink: _handleDeepLink,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _autoRecordTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        unawaited(_runStartupTasks());
      });
    });
  }

  @override
  void dispose() {
    _autoRecordTimer?.cancel();
    _deepLinkSub?.cancel();
    super.dispose();
  }

  Future<void> _runStartupTasks() async {
    try {
      await ref.read(recurringRepositoryProvider).processAutoRecordDue();
    } catch (_) {}
    if (!mounted) return;
    try {
      final recurring = await ref
          .read(recurringRepositoryProvider)
          .watchAll(includeInactive: true)
          .first;
      final debts = await ref.read(debtRepositoryProvider).watchAll().first;
      final latestFuliza =
          await ref.read(fulizaRepositoryProvider).watchLatest().first;
      if (!mounted) return;
      await ref.read(reminderNotificationServiceProvider).syncReminders(
            recurring: recurring,
            debts: debts,
            latestFuliza: latestFuliza,
            requestPermission: true,
          );
    } catch (_) {}
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
    final host = Uri.tryParse(link)?.host;
    if (host == 'add_transaction') {
      nav.push(
        MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
      );
      return;
    }
    if (host == 'share_text') {
      final sharedText = DeepLinkService.extractSharedText(link);
      if (sharedText != null) {
        unawaited(
          HomeFloatingActionButtons.handleIncomingMpesaText(
            nav.context,
            ref,
            sharedText,
            fromShare: true,
          ),
        );
      }
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

    if (widget.dynamicColorsPreloaded) {
      return buildMaterialApp(
        widget.initialLightDynamic,
        widget.initialDarkDynamic,
      );
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) =>
          buildMaterialApp(lightDynamic, darkDynamic),
    );
  }
}
