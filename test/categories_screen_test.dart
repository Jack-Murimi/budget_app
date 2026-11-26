import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/categories/screens/categories_screen.dart';
import 'package:budget_app/main.dart';

void main() {

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CategoriesScreen()),
    );
  }

  testWidgets('renders categories list', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pump();
    
    // Wait for stream to emit
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Food & Groceries'), findsOneWidget);
  });

  testWidgets('toggle archived filter', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Archived'), findsOneWidget);
    
    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('open add category dialog', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Category'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('create new category', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'My Custom Category');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Scroll down to find newly appended top-level category if not in immediate viewport
    final newCatFinder = find.text('My Custom Category');
    await tester.scrollUntilVisible(newCatFinder, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    expect(newCatFinder, findsOneWidget);
  });

  testWidgets('archive category', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    final archiveButton = find.byIcon(Icons.archive).first;
    await tester.tap(archiveButton);
    await tester.pumpAndSettle();

    final categories = await db.select(db.categories).get();
    expect(categories.any((c) => c.isArchived), true);
  });

  testWidgets('expand category shows subcategories', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food & Groceries'));
    await tester.pumpAndSettle();

    expect(find.text('Supermarket'), findsOneWidget);
    expect(find.text('Eating Out'), findsOneWidget);
  });

  testWidgets('editing a subcategory preserves parentId', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food & Groceries'));
    await tester.pumpAndSettle();

    final subTile = find.ancestor(
      of: find.text('Supermarket'),
      matching: find.byType(ListTile),
    );
    final editBtn = find.descendant(of: subTile, matching: find.byIcon(Icons.edit));
    await tester.ensureVisible(editBtn);
    await tester.pumpAndSettle();
    await tester.tap(editBtn);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Supermarket Updated');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final cats = await db.select(db.categories).get();
    final food = cats.firstWhere((c) => c.name == 'Food & Groceries');
    final edited = cats.firstWhere((c) => c.name == 'Supermarket Updated');
    expect(edited.parentId, food.id);
  });

  testWidgets('drag handles have sequential indices matching item position', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    final handles = tester
        .widgetList<ReorderableDragStartListener>(
          find.byType(ReorderableDragStartListener),
        )
        .toList();
    expect(handles.length, greaterThan(1));
    for (var i = 0; i < handles.length; i++) {
      expect(handles[i].index, i);
    }
  });

  testWidgets('switching type tab filters categories and defaults new category type', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food & Groceries'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Freelance Gig');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final cats = await db.select(db.categories).get();
    final created = cats.firstWhere((c) => c.name == 'Freelance Gig');
    expect(created.transactionType, 'income');
  });
}
