import 'dart:ffi' hide Size;
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/transactions/providers/transaction_providers.dart';
import 'package:budget_app/features/transactions/screens/transactions_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
      header: 'Grocery',
      amount: 50.0,
      transactionDate: DateTime.now(),
      type: const Value('expense'),
      mpesaRef: const Value('REF001'),
    ));
    
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
      header: 'Salary',
      amount: 1000.0,
      transactionDate: DateTime.now(),
      type: const Value('income'),
      mpesaRef: const Value('REF002'),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('renders transactions from in-memory DB', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TransactionsScreen()),
      ),
    );
    
    await tester.pumpAndSettle();
    
    expect(find.text('Grocery'), findsWidgets);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('2 transactions'), findsOneWidget);
  });

  testWidgets('search filters out non-matching items', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TransactionsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Grocery');
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(ListTile), matching: find.text('Grocery')), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(find.text('1 transaction'), findsOneWidget);
  });

  testWidgets('type filter chips filter items', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TransactionsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(ListTile), matching: find.text('Grocery')), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(find.text('1 transaction'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Grocery'), findsNothing);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('1 transaction'), findsOneWidget);
  });

  testWidgets('delete button opens confirmation dialog', (tester) async {
    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TransactionsScreen()),
      ),
    );
    
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    
    expect(find.text('Delete Transaction'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('renders leading type icons for income, expense, and transfer', (tester) async {
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
      header: 'To Savings',
      amount: 200.0,
      transactionDate: DateTime.now(),
      type: const Value('transfer'),
      mpesaRef: const Value('REF003'),
    ));

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TransactionsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
  });

  testWidgets('This Week active chip label, parent category filter matching subcategories, and narrow summary bar',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final parentId = await db.into(db.categories).insert(
      CategoriesCompanion.insert(name: 'TransportParent'),
    );
    final subId = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'UberSub',
        parentId: Value(parentId),
      ),
    );
    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        header: 'Ride Share',
        amount: 450.0,
        transactionDate: DateTime.now(),
        type: const Value('expense'),
        categoryId: Value(subId),
      ),
    );

    final container = ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    container.read(transactionDateRangeFilterProvider.notifier).state = 'this_week';
    container.read(transactionCategoryFilterProvider.notifier).state = parentId;

    final errors = <FlutterErrorDetails>[];
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TransactionsScreen()),
        ),
      );
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = prevOnError;
    }

    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('Ride Share'), findsOneWidget);
    expect(find.text('Grocery'), findsNothing);
    expect(
      errors,
      isEmpty,
      reason: errors.map((e) => e.toString()).join('\n---\n'),
    );
  });
}
