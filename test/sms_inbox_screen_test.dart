import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/sms/screens/sms_inbox_screen.dart';
import 'package:budget_app/features/sms/services/sms_inbox_scanner.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('deduplicates existing transactions/Fuliza and bulk-imports pending items',
      (tester) async {
    // Pre-existing transaction and Fuliza record must be skipped on scan.
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Existing',
            amount: 100.0,
            mpesaRef: const Value('OLDTXN001'),
            transactionDate: DateTime(2026, 11, 1),
          ),
        );
    await db.into(db.fulizaRecords).insert(
          FulizaRecordsCompanion.insert(
            mpesaRef: 'OLDFUL001',
            fulizaAmount: 50.0,
          ),
        );

    final messages = [
      RawSms(
        id: '1',
        address: 'MPESA',
        body:
            'OLDTXN001 Confirmed. Ksh100.00 paid to EXISTING SHOP. on 1/11/26 at 9:00 AM. New M-PESA balance is Ksh900.00.',
        date: DateTime(2026, 11, 1, 9),
      ),
      RawSms(
        id: '2',
        address: 'MPESA',
        body:
            'OLDFUL001 Confirmed. Fuliza M-PESA amount is Ksh50.00. Access Fee charged Ksh0.50. Total Fuliza M-PESA outstanding amount is Ksh50.50 due on 1/12/26.',
        date: DateTime(2026, 11, 1, 9, 1),
      ),
      RawSms(
        id: '3',
        address: 'MPESA',
        body:
            'NEWTXN002 Confirmed. Ksh170.00 paid to NAIVAS. on 2/11/26 at 10:00 AM. New M-PESA balance is Ksh0.00. Transaction cost, Ksh0.00',
        date: DateTime(2026, 11, 2, 10),
      ),
      RawSms(
        id: '4',
        address: 'MPESA',
        body:
            'NEWTXN002 Confirmed. Fuliza M-PESA amount is Ksh70.00. Access Fee charged Ksh0.70. Total Fuliza M-PESA outstanding amount is Ksh70.70 due on 2/12/26.',
        date: DateTime(2026, 11, 2, 10),
      ),
      RawSms(
        id: '5',
        address: 'MPESA',
        body:
            'NEWREP003 Confirmed. Ksh70.70 used to fully pay your outstanding fuliza M-PESA balance on 3/11/26 at 11:00 AM. New M-PESA balance is Ksh500.00.',
        date: DateTime(2026, 11, 3, 11),
      ),
    ];

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SmsInboxScreen(
            requestPermission: () async => true,
            smsLoader: () async => messages,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 2 pre-existing messages skipped; 3 new high-confidence messages ready.
    expect(
      find.text('Skipped 2 already recorded or dismissed messages'),
      findsOneWidget,
    );
    expect(find.text('Ready to Add (3)'), findsOneWidget);
    expect(find.text('Import all (3)'), findsOneWidget);

    await tester.tap(find.text('Import all (3)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('All M-Pesa messages already imported'), findsOneWidget);

    final txns = await db.select(db.transactions).get();
    final naivas = txns.firstWhere((t) => t.mpesaRef == 'NEWTXN002');
    expect(naivas.fulizaAmount, 70.0);
    expect(naivas.fulizaFee, 0.70);

    final fulizas = await db.select(db.fulizaRecords).get();
    expect(fulizas.any((f) => f.mpesaRef == 'NEWREP003' && f.outstandingTotal == 0.0), isTrue);

    final inboxRows = await db.select(db.smsInboxItems).get();
    expect(inboxRows.where((r) => r.status == 'approved').length, 3);
  });

  testWidgets('surfaces PlatformException error with Retry button instead of swallowing it',
      (tester) async {
    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SmsInboxScreen(
            requestPermission: () async => true,
            smsLoader: () async => throw PlatformException(
              code: 'SMS_ERROR',
              message: 'ContentProvider failed',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('ContentProvider failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('dismisses item and remembers dismissed state across rescans',
      (tester) async {
    final msg = RawSms(
      id: '10',
      address: 'MPESA',
      body:
          'DISMISS01 Confirmed. Ksh250.00 paid to JAVA HOUSE. on 4/11/26 at 1:00 PM. New M-PESA balance is Ksh500.00.',
      date: DateTime(2026, 11, 4, 13),
    );

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SmsInboxScreen(
            requestPermission: () async => true,
            smsLoader: () async => [msg],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('JAVA HOUSE'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.textContaining('JAVA HOUSE'), findsNothing);

    // Rescan must keep dismissed message excluded.
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.textContaining('JAVA HOUSE'), findsNothing);
    expect(find.textContaining('All M-Pesa messages already imported'), findsOneWidget);
  });
}
