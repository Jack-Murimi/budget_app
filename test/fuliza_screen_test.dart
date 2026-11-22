import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/fuliza/screens/fuliza_screen.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('FulizaScreen shows outstanding balance, total fees, and supports manual repayment',
      (tester) async {
    await db.into(db.fulizaRecords).insert(
          FulizaRecordsCompanion.insert(
            mpesaRef: 'FUL_UI_1',
            fulizaAmount: 300.0,
            accessFee: const Value(3.50),
            outstandingTotal: const Value(303.50),
          ),
        );

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: FulizaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fuliza Outstanding'), findsOneWidget);
    expect(find.textContaining('303.50'), findsWidgets);
    expect(find.textContaining('Total fees paid:'), findsOneWidget);
    expect(find.text('Record Repayment'), findsOneWidget);

    await tester.tap(find.text('Record Repayment'));
    await tester.pumpAndSettle();

    expect(find.text('Record Fuliza Repayment'), findsOneWidget);
    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();

    expect(find.text('No Fuliza Balance'), findsOneWidget);
    expect(find.textContaining('Repaid'), findsOneWidget);
  });
}
