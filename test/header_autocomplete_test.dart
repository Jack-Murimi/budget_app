import 'dart:ffi';
import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/add_transaction/screens/add_transaction_screen.dart';
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
  late int foodId;
  late int groceriesId;
  late int shoppingId;
  late int electronicsId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());

    // Create categories
    foodId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Food & Drinks',
            icon: const Value('restaurant'),
            colorHex: const Value('#FF0000'),
          ),
        );
    groceriesId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Groceries',
            parentId: Value(foodId),
            icon: const Value('local_grocery_store'),
            colorHex: const Value('#FF0000'),
          ),
        );
    shoppingId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Shopping',
            icon: const Value('shopping_bag'),
            colorHex: const Value('#0000FF'),
          ),
        );
    electronicsId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: 'Electronics',
            parentId: Value(shoppingId),
            icon: const Value('devices'),
            colorHex: const Value('#0000FF'),
          ),
        );

    // Seed historical transactions
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Naivas',
            amount: 1200.0,
            transactionDate: DateTime(2026, 1, 1),
            categoryId: Value(groceriesId),
          ),
        );
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Naivas',
            amount: 4500.0,
            transactionDate: DateTime(2026, 1, 2),
            categoryId: Value(electronicsId),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
      'Header autocomplete suggests previously entered headers and fills category/sub-category on tap',
      (tester) async {
    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AddTransactionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the header field (label is 'Header *')
    final headerField = find.widgetWithText(TextFormField, 'Header *');
    expect(headerField, findsOneWidget);

    // Type 'Nai' into the header field
    await tester.enterText(headerField, 'Nai');
    await tester.pumpAndSettle();

    // Verify both suggestions are displayed with category and sub-category
    expect(find.text('Food & Drinks > Groceries'), findsOneWidget);
    expect(find.text('Shopping > Electronics'), findsOneWidget);

    // Tap the Groceries suggestion
    await tester.tap(find.text('Food & Drinks > Groceries'));
    await tester.pumpAndSettle();

    // Header field should now contain 'Naivas'
    final textFormField = tester.widget<TextFormField>(headerField);
    expect(textFormField.controller?.text, 'Naivas');

    // Category selector should now reflect 'Food & Drinks > Groceries'
    expect(find.text('Food & Drinks > Groceries'), findsOneWidget);
  });
}
