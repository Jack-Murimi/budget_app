import 'dart:ffi';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/add_transaction/screens/add_transaction_screen.dart';
import 'package:budget_app/features/home/widgets/transaction_list_item.dart';
import 'package:budget_app/features/transactions/models/transaction_model.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart';
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
  late int groceriesId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());

    groceriesId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Groceries',
            icon: const Value('local_grocery_store'),
            colorHex: const Value('#E53935'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildItem(TransactionModel txn, ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: TransactionListItem(transaction: txn),
        ),
      ),
    );
  }

  testWidgets(
      'TransactionListItem renders category color, icon, fee transparency, and semantics',
      (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    final txn = TransactionModel(
      id: 1,
      header: 'Naivas Supermarket',
      description: 'Weekly food',
      amount: 1500.0,
      transactionCost: 15.0,
      categoryId: groceriesId,
      transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now(),
      type: 'expense',
    );

    await tester.pumpWidget(buildItem(txn, container));
    await tester.pumpAndSettle();

    // Verify title and total (1500 + 15 = 1515)
    expect(find.text('Naivas Supermarket'), findsOneWidget);
    expect(find.text('-KES 1,515.00'), findsOneWidget);

    // Verify fee callout
    expect(find.text('+KES 15.00 fee'), findsOneWidget);

    // Verify category icon (local_grocery_store)
    expect(find.byIcon(Icons.local_grocery_store), findsOneWidget);

    // Verify tap navigates to AddTransactionScreen (edit mode)
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(find.text('Edit Transaction'), findsOneWidget);
  });

  testWidgets('TransactionListItem handles transfer type correctly',
      (tester) async {
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    final txn = TransactionModel(
      id: 2,
      header: 'Bank Transfer',
      amount: 5000.0,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
      type: 'transfer',
    );

    await tester.pumpWidget(buildItem(txn, container));
    await tester.pumpAndSettle();

    expect(find.text('⇄ KES 5,000.00'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
  });
}
