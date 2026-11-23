import 'dart:ffi';
import 'dart:io';

import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/portability/screens/data_portability_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/open.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  late AppDatabase db;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = Directory.systemTemp.createTempSync('data_portability_test_');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<void> waitWhileBusy(WidgetTester tester) async {
    for (var i = 0; i < 400; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) {
        return;
      }
    }
  }

  void clearSnackBars(WidgetTester tester) {
    ScaffoldMessenger.of(tester.element(find.byType(DataPortabilityScreen)))
        .clearSnackBars();
  }

  testWidgets('DataPortabilityScreen exports single CSV and handles cancelled save',
      (tester) async {
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Matatu Fare',
            amount: 100.0,
            transactionDate: DateTime(2026, 11, 1),
          ),
        );

    final outFile = File(p.join(tempDir.path, 'transactions.csv'));
    var returnNull = false;

    await tester.pumpWidget(
      MaterialApp(
        home: DataPortabilityScreen(
          db: db,
          pickSaveLocation: ({suggestedName}) async {
            if (returnNull) return null;
            return FileSaveLocation(outFile.path);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Export Transactions CSV
    await tester.tap(find.text('Export CSV files'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transactions CSV'));
    await tester.pump();
    await waitWhileBusy(tester);
    await tester.pumpAndSettle();

    expect(outFile.existsSync(), isTrue);
    expect(outFile.readAsStringSync(), contains('Matatu Fare'));
    expect(find.text('CSV export saved.'), findsOneWidget);

    // Clear snackbar, then cancel save dialog -> must NOT show saved snackbar
    clearSnackBars(tester);
    await tester.pumpAndSettle();

    returnNull = true;
    await tester.tap(find.text('Export CSV files'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accounts CSV'));
    await tester.pump();
    await waitWhileBusy(tester);
    await tester.pumpAndSettle();

    expect(find.text('CSV export saved.'), findsNothing);
  });

  testWidgets('DataPortabilityScreen exports all CSVs to folder and imports CSV with dedupe',
      (tester) async {
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Coffee Shop',
            amount: 250.0,
            mpesaRef: const Value('REFCSV001'),
            transactionDate: DateTime(2026, 11, 2),
          ),
        );

    final importCsv = File(p.join(tempDir.path, 'import.csv'));
    importCsv.writeAsStringSync(
      'header,description,amount,type,transaction_date,mpesa_ref\n'
      'Coffee Shop,Cafe,250.0,expense,2026-11-02T10:00:00Z,REFCSV001\n'
      'Naivas,Groceries,500.0,expense,2026-11-03T12:00:00Z,REFCSV002\n',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DataPortabilityScreen(
          db: db,
          pickDirectoryPath: () async => tempDir.path,
          pickOpenFile: ({acceptedTypeGroups = const []}) async =>
              XFile(importCsv.path),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Export all to folder
    await tester.tap(find.text('Export CSV files'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export all to folder'));
    await tester.pump();
    await waitWhileBusy(tester);
    await tester.pumpAndSettle();

    expect(File(p.join(tempDir.path, 'transactions.csv')).existsSync(), isTrue);
    expect(File(p.join(tempDir.path, 'accounts.csv')).existsSync(), isTrue);
    expect(File(p.join(tempDir.path, 'categories.csv')).existsSync(), isTrue);
    expect(find.text('Exported 3 CSV files.'), findsOneWidget);

    clearSnackBars(tester);
    await tester.pumpAndSettle();

    // Import CSV
    await tester.tap(find.text('Import transactions CSV'));
    await tester.pump();
    await waitWhileBusy(tester);
    await tester.pumpAndSettle();

    expect(find.text('Imported 1; skipped 1 duplicates.'), findsOneWidget);
    final txns = await db.select(db.transactions).get();
    expect(txns.any((t) => t.mpesaRef == 'REFCSV002'), isTrue);
  });

  testWidgets('DataPortabilityScreen validates passphrase, creates encrypted backup, and restores it',
      (tester) async {
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            header: 'Saved Forever',
            amount: 1234.0,
            transactionDate: DateTime(2026, 11, 5),
          ),
        );

    final backupFile = File(p.join(tempDir.path, 'budget-ke-backup.json'));

    await tester.pumpWidget(
      MaterialApp(
        home: DataPortabilityScreen(
          db: db,
          pickSaveLocation: ({suggestedName}) async =>
              FileSaveLocation(backupFile.path),
          pickOpenFile: ({acceptedTypeGroups = const []}) async =>
              XFile(backupFile.path),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Create encrypted backup dialog
    await tester.tap(find.text('Create encrypted backup'));
    await tester.pumpAndSettle();

    // Empty passphrase validation
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Passphrase is required'), findsOneWidget);

    // Short passphrase & mismatch validation
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Passphrase'),
      'short',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm passphrase'),
      'different',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(find.text('Passphrases do not match'), findsOneWidget);

    // Valid passphrase creates encrypted backup (600k PBKDF2 in Isolate.run)
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Passphrase'),
      'strong-passphrase',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm passphrase'),
      'strong-passphrase',
    );
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await waitWhileBusy(tester);
    await tester.pumpAndSettle();

    expect(backupFile.existsSync(), isTrue);
    expect(find.text('Encrypted backup saved.'), findsOneWidget);

    clearSnackBars(tester);
    await tester.pumpAndSettle();

    // Delete the transaction so restore has observable effect
    await db.delete(db.transactions).go();
    expect(await db.select(db.transactions).get(), isEmpty);

    // Restore encrypted backup
    await tester.tap(find.text('Restore encrypted backup'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Passphrase'),
      'strong-passphrase',
    );
    await tester.tap(find.text('Continue'));
    await tester.pump();

    var confirmShown = false;
    for (var i = 0; i < 400; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
      if (find.text('Replace current data?').evaluate().isNotEmpty) {
        confirmShown = true;
        break;
      }
    }
    expect(confirmShown, isTrue);

    await tester.tap(find.text('Restore'));
    await tester.pump();
    await waitWhileBusy(tester);
    await tester.pumpAndSettle();

    expect(find.text('Backup restored.'), findsOneWidget);
    final restored = await db.select(db.transactions).get();
    expect(restored.any((t) => t.header == 'Saved Forever'), isTrue);
  });
}
