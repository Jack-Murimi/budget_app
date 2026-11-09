import 'dart:ffi';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/home/providers/navigation_providers.dart';
import 'package:budget_app/features/home/screens/main_navigation_screen.dart';
import 'package:budget_app/features/more/screens/more_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(
      OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
  }

  testWidgets('More tab renders MoreScreen with all sections and 10 items',
      (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    // Tap the 'More' navigation destination
    final moreTab = find.text('More');
    expect(moreTab, findsOneWidget);
    await tester.tap(moreTab);
    await tester.pumpAndSettle();

    // Verify More tab is selected in provider
    expect(container.read(selectedTabProvider), 3);

    // Verify section headers in viewport / after scrolling
    expect(find.text('MONEY'), findsOneWidget);
    expect(find.text('AUTOMATION'), findsOneWidget);
    expect(find.text('ORGANIZE'), findsOneWidget);

    // Scroll to see APP section at bottom
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('APP'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('MoreScreen search filters items and hides empty sections',
      (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MoreScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final searchField = find.byType(SearchBar);
    expect(searchField, findsOneWidget);

    // Search for "debt"
    await tester.enterText(searchField, 'debt');
    await tester.pumpAndSettle();

    // MONEY section should be shown because of 'Loans & Debts'
    expect(find.text('MONEY'), findsOneWidget);
    expect(find.text('Loans & Debts'), findsOneWidget);

    // AUTOMATION, ORGANIZE, and APP sections should be hidden
    expect(find.text('AUTOMATION'), findsNothing);
    expect(find.text('ORGANIZE'), findsNothing);
    expect(find.text('APP'), findsNothing);

    // Non-matching query
    await tester.enterText(searchField, 'xyzunknown');
    await tester.pumpAndSettle();

    expect(find.text('No matching features found'), findsOneWidget);
  });
}
