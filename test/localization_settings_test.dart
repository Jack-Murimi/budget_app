import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/screens/debts_screen.dart';
import 'package:budget_app/features/fuliza/screens/fuliza_screen.dart';
import 'package:budget_app/features/goals/screens/goals_screen.dart';
import 'package:budget_app/features/insights/screens/insights_screen.dart';
import 'package:budget_app/features/more/screens/more_screen.dart';
import 'package:budget_app/features/portability/screens/data_portability_screen.dart';
import 'package:budget_app/features/settings/settings_screen.dart';
import 'package:budget_app/l10n/app_localizations.dart';
import 'package:budget_app/main.dart';
import 'package:budget_app/shared/providers/locale_provider.dart';
import 'package:budget_app/shared/providers/theme_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  Widget wrapSwahili(ProviderContainer container, Widget child) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('SettingsScreen switches locale between System, English, and Kiswahili and persists preference',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), isNull);

    await tester.scrollUntilVisible(
      find.text('Kiswahili'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('sw'));
    expect(prefs.getString('app_locale'), 'sw');
    expect(find.text('Mipangilio'), findsOneWidget);
    expect(find.text('Lugha'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(container.read(localeProvider), const Locale('en'));
    expect(prefs.getString('app_locale'), 'en');
    expect(find.text('Settings'), findsOneWidget);

    // Switch back to System default (second one in Appearance+Language)
    await tester.tap(find.text('System default').last);
    await tester.pumpAndSettle();
    expect(container.read(localeProvider), isNull);
    expect(prefs.getString('app_locale'), isNull);
  });

  testWidgets('Localized screens render Kiswahili translations without errors',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final checks = <(Widget, List<String>)>[
      (const MoreScreen(), ['Zaidi', 'Akaunti', 'Mikopo na Madeni']),
      (const DebtsScreen(), ['Mikopo na Madeni', 'Ninawadai', 'Wananidai']),
      (const GoalsScreen(), ['Malengo ya akiba', 'Ongeza lengo']),
      (const FulizaScreen(), ['Fuliza M-PESA', 'Historia ya Matumizi ya Fuliza']),
      (DataPortabilityScreen(db: db), ['Hamisha & hifadhi nakala']),
      (const InsightsScreen(), ['Uchambuzi', 'Muhtasari wa mtiririko wa fedha']),
    ];

    for (final (screen, expectedTexts) in checks) {
      await tester.pumpWidget(wrapSwahili(container, screen));
      await tester.pumpAndSettle();
      for (final text in expectedTexts) {
        expect(find.text(text), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
