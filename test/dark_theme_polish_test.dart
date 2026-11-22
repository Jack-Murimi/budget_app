import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/debts/screens/bridge_charges_screen.dart';
import 'package:budget_app/features/debts/screens/debts_screen.dart';
import 'package:budget_app/features/fuliza/screens/fuliza_screen.dart';
import 'package:budget_app/features/home/screens/main_navigation_screen.dart';
import 'package:budget_app/features/home/widgets/floating_action_buttons.dart';
import 'package:budget_app/features/recurring/models/recurring_model.dart';
import 'package:budget_app/features/recurring/repositories/recurring_repository.dart';
import 'package:budget_app/features/recurring/screens/recurring_screen.dart';
import 'package:budget_app/main.dart';
import 'package:budget_app/shared/theme/app_theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MainNavigationScreen shows HomeFloatingActionButtons only on Home/Transactions and uses logo_dark.svg in dark mode',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(null, true),
          home: const MainNavigationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Home tab (0) shows HomeFloatingActionButtons and logo_dark.svg
    expect(find.byType(HomeFloatingActionButtons), findsOneWidget);
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture).first);
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      'assets/logo_dark.svg',
    );

    // Transactions tab (1) keeps HomeFloatingActionButtons
    await tester.tap(find.text('Transactions').last);
    await tester.pumpAndSettle();
    expect(find.byType(HomeFloatingActionButtons), findsOneWidget);

    // Budgets tab (2) hides HomeFloatingActionButtons so BudgetsScreen FAB has no overlap
    await tester.tap(find.text('Budgets').last);
    await tester.pumpAndSettle();
    expect(find.byType(HomeFloatingActionButtons), findsNothing);

    // More tab (3) hides HomeFloatingActionButtons
    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    expect(find.byType(HomeFloatingActionButtons), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RecurringScreen, DebtsScreen, BridgeChargesScreen, and FulizaScreen render cleanly under OLED dark theme',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final now = DateTime.now();
    await RecurringRepository(db).insert(
      RecurringModel(
        id: 0,
        payee: 'Due Tomorrow',
        amount: 500,
        type: 'expense',
        frequency: 'monthly',
        startDate: now.add(const Duration(days: 1)),
        nextDueDate: now.add(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    for (final screen in const <Widget>[
      RecurringScreen(),
      DebtsScreen(),
      BridgeChargesScreen(),
      FulizaScreen(),
    ]) {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark(null, true),
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
