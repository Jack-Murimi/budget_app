import 'package:budget_app/core/database/app_database.dart';
import 'package:budget_app/features/accounts/repositories/account_repository.dart';
import 'package:budget_app/features/fuliza/repositories/fuliza_repository.dart';
import 'package:budget_app/features/transactions/repositories/payee_category_repository.dart';
import 'package:budget_app/features/transactions/repositories/transaction_repository.dart';
import 'package:budget_app/features/transactions/services/mpesa_parser.dart';
import 'package:budget_app/features/transactions/services/mpesa_result_handler.dart';
import 'package:budget_app/features/transactions/widgets/batch_mpesa_paste_sheet.dart';
import 'package:budget_app/l10n/app_localizations.dart';
import 'package:budget_app/main.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  late AppDatabase db;
  late TransactionRepository txnRepo;
  late FulizaRepository fulizaRepo;
  late AccountRepository accountRepo;
  late PayeeCategoryRepository payeeRepo;
  late MpesaResultHandler handler;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    txnRepo = TransactionRepository(db);
    fulizaRepo = FulizaRepository(db);
    accountRepo = AccountRepository(db);
    payeeRepo = PayeeCategoryRepository(db);
    handler = MpesaResultHandler(
      transactionRepo: txnRepo,
      fulizaRepo: fulizaRepo,
      accountRepo: accountRepo,
      payeeRepo: payeeRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('prepareBatchPreview flags DB & in-batch duplicates while allowing paired Fuliza drawdown',
      () async {
    await txnRepo.insert(
      TransactionsCompanion.insert(
        header: 'Existing Txn',
        amount: 70.0,
        transactionDate: DateTime(2026, 12, 3),
        mpesaRef: const Value('EX1AA22B33'),
      ),
    );
    await fulizaRepo.insertDrawdown(
      FulizaRecordsCompanion.insert(
        mpesaRef: 'FL1AA22B33',
        fulizaAmount: 200.0,
      ),
    );

    const block = '''
EX1AA22B33 Confirmed. Ksh70.00 sent to JOHN DOE 0712345678 on 3/12/26 at 10:41 PM. New M-PESA balance is Ksh500.00.
NW1AA22B33 Confirmed. Ksh500.00 paid to NAIVAS. on 4/12/26 at 1:00 PM. New M-PESA balance is Ksh1,500.00.
NW1AA22B33 Confirmed. Ksh500.00 paid to NAIVAS. on 4/12/26 at 1:00 PM. New M-PESA balance is Ksh1,500.00.
NW1AA22B33 Confirmed. Fuliza M-PESA amount is Ksh250.00. Access Fee charged Ksh2.50. Total Fuliza M-PESA outstanding amount is Ksh252.50 due on 4/1/27.
FL1AA22B33 Confirmed. Fuliza M-PESA amount is Ksh200.00. Access Fee charged Ksh2.00. Total Fuliza M-PESA outstanding amount is Ksh202.00 due on 4/1/27.
''';
    final split = MpesaParser.parseBatch(block);
    final preview = await handler.prepareBatchPreview(split.valid);

    expect(preview, hasLength(5));
    expect(preview[0].isDuplicate, isTrue); // existing DB transaction
    expect(preview[1].isDuplicate, isFalse); // new NAIVAS txn
    expect(preview[2].isDuplicate, isTrue); // repeat NAIVAS txn in batch
    expect(preview[3].isDuplicate, isFalse); // paired Fuliza drawdown sharing NW1AA22B33
    expect(preview[4].isDuplicate, isTrue); // existing DB Fuliza drawdown
  });

  test('bulkImportWithOverrides applies category overrides, links Fuliza, and learns payee',
      () async {
    final cats = await db.select(db.categories).get();
    final chosenCat = cats.firstWhere((c) => c.transactionType == 'expense');

    const block = '''
PR1AA22B33 Confirmed. Ksh1,000.00 paid to CARREFOUR. on 5/12/26 at 4:00 PM. New M-PESA balance is Ksh0.00. Transaction cost, Ksh0.00
PR1AA22B33 Confirmed. Fuliza M-PESA amount is Ksh300.00. Access Fee charged Ksh3.00. Total Fuliza M-PESA outstanding amount is Ksh303.00 due on 5/1/27.
''';
    final split = MpesaParser.parseBatch(block);
    final summary = await handler.bulkImportWithOverrides([
      (result: split.valid[0], categoryId: chosenCat.id),
      (result: split.valid[1], categoryId: null),
    ]);

    expect(summary.importedTransactions, 1);
    expect(summary.importedFuliza, 1);
    expect(summary.skippedDuplicates, 0);

    final saved = await txnRepo.getByRef('PR1AA22B33');
    expect(saved, isNotNull);
    expect(saved!.categoryId, chosenCat.id);
    expect(saved.fulizaAmount, 300.0);
    expect(saved.fulizaFee, 3.0);

    final learnedCat = await payeeRepo.suggest('CARREFOUR');
    expect(learnedCat, chosenCat.id);
  });

  testWidgets('BatchMpesaPasteSheet previews ready + duplicate messages and imports selected items',
      (tester) async {
    await txnRepo.insert(
      TransactionsCompanion.insert(
        header: 'Existing John',
        amount: 70.0,
        transactionDate: DateTime(2026, 12, 3),
        mpesaRef: const Value('UK3QX11U87'),
      ),
    );

    const block = '''
UK3QX11U87 Confirmed. Ksh70.00 sent to JOHN DOE 0712345678 on 3/12/26 at 10:41 PM. New M-PESA balance is Ksh500.00.
VK4QX22V99 Confirmed. Ksh500.00 paid to KPLC PREPAID. on 15/10/26 at 8:00 PM. New M-PESA balance is Ksh2,000.00.
''';

    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    BulkImportSummary? resultSummary;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    resultSummary = await showBatchMpesaPasteSheet(
                      ctx,
                      initialText: block,
                    );
                  },
                  child: const Text('Open Batch'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Batch'));
    await tester.pumpAndSettle();

    expect(find.text('Batch Import M-Pesa'), findsOneWidget);
    expect(find.text('1 ready'), findsOneWidget);
    expect(find.text('1 duplicate'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Import 1'), findsOneWidget);

    await tester.tap(find.text('Import 1'));
    await tester.pumpAndSettle();

    expect(resultSummary, isNotNull);
    expect(resultSummary!.importedTransactions, 1);
    final imported = await txnRepo.getByRef('VK4QX22V99');
    expect(imported, isNotNull);
    expect(imported!.amount, 500.0);
  });
}
