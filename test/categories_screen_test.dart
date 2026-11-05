import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/categories/screens/categories_screen.dart';
import 'package:budget_app/main.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: const MaterialApp(home: CategoriesScreen()),
    );
  }

  testWidgets('renders categories list', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    
    // Wait for FutureBuilder to complete
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
  });

  testWidgets('toggle archived filter', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Archived'), findsOneWidget);
    
    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('open add category dialog', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Category'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('create new category', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'My Custom Category');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('My Custom Category'), findsOneWidget);
  });

  testWidgets('archive category', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final archiveButton = find.byIcon(Icons.archive).first;
    await tester.tap(archiveButton);
    await tester.pumpAndSettle();

    final categories = await db.select(db.categories).get();
    expect(categories.any((c) => c.isArchived), true);
  });

  testWidgets('expand category shows subcategories', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Restaurant'), findsOneWidget);
  });
}
