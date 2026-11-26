import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/add_transaction/screens/add_transaction_screen.dart';
import 'package:budget_app/features/settings/auth_gate.dart';
import 'package:budget_app/features/settings/auth_service.dart';
import 'package:budget_app/main.dart';
import 'package:budget_app/shared/providers/theme_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/open.dart';

class _FakeAuthService extends AuthService {
  bool nextAvailable = true;
  bool nextAuthenticate = true;
  final List<bool> secureFlags = [];
  int authenticateCalls = 0;

  @override
  Future<void> setSecureFlag(bool enable) async {
    secureFlags.add(enable);
  }

  @override
  Future<bool> biometricAvailable() async => nextAvailable;

  @override
  Future<bool> authenticate({String? localizedReason}) async {
    authenticateCalls++;
    return nextAuthenticate;
  }
}

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  testWidgets('locks immediately on first frame when biometrics enabled and unlocks on auth',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bio_enabled': true,
      'auto_lock_seconds': 0,
    });
    final prefs = await SharedPreferences.getInstance();
    final fakeAuth = _FakeAuthService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authServiceProvider.overrideWithValue(fakeAuth),
        ],
        child: const MaterialApp(
          home: AuthGate(child: Scaffold(body: Text('SECRET_BALANCE'))),
        ),
      ),
    );

    // Frame 1 must never render protected child content.
    expect(find.text('App Locked'), findsOneWidget);
    expect(find.text('SECRET_BALANCE'), findsNothing);
    expect(fakeAuth.secureFlags, contains(true));

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(fakeAuth.authenticateCalls, 1);
    expect(find.text('SECRET_BALANCE'), findsOneWidget);
    expect(find.text('App Locked'), findsNothing);
    expect(fakeAuth.secureFlags.last, isFalse);
  });

  testWidgets('does not re-lock on inactive lifecycle state, but locks on paused',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bio_enabled': true,
      'auto_lock_seconds': 0,
    });
    final prefs = await SharedPreferences.getInstance();
    final fakeAuth = _FakeAuthService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authServiceProvider.overrideWithValue(fakeAuth),
        ],
        child: const MaterialApp(
          home: AuthGate(child: Scaffold(body: Text('SECRET_BALANCE'))),
        ),
      ),
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('SECRET_BALANCE'), findsOneWidget);

    // Transient inactive (e.g. system prompt) should keep app unlocked on resume.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('SECRET_BALANCE'), findsOneWidget);
    expect(find.text('App Locked'), findsNothing);

    // Genuine background pause should lock on resume when autoLock == 0.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('App Locked'), findsOneWidget);
    expect(find.text('SECRET_BALANCE'), findsNothing);
  });

  testWidgets('queues deep links while locked and opens target after unlock',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bio_enabled': true,
      'auto_lock_seconds': 0,
    });
    final prefs = await SharedPreferences.getInstance();
    final fakeAuth = _FakeAuthService();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final linkCtrl = StreamController<String>();
    final navKey = GlobalKey<NavigatorState>();
    addTearDown(db.close);
    addTearDown(linkCtrl.close);
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        authServiceProvider.overrideWithValue(fakeAuth),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: BudgetApp(
          navigatorKey: navKey,
          deepLinkStream: linkCtrl.stream,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('App Locked'), findsOneWidget);

    linkCtrl.add('budgetke://add_transaction');
    await tester.pump();
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.text('App Locked'), findsOneWidget);

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });

  testWidgets('debug add_transaction deep link opens AddTransactionScreen when unlocked',
      (tester) async {
    SharedPreferences.setMockInitialValues({'bio_enabled': false});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final linkCtrl = StreamController<String>();
    final navKey = GlobalKey<NavigatorState>();
    addTearDown(db.close);
    addTearDown(linkCtrl.close);

    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: BudgetApp(
          navigatorKey: navKey,
          deepLinkStream: linkCtrl.stream,
        ),
      ),
    );
    await tester.pump();

    linkCtrl.add('budgetke-debug://add_transaction');
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });
}
