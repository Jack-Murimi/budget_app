import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../accounts/providers/account_providers.dart';
import '../../accounts/repositories/account_repository.dart';
import '../../fuliza/providers/fuliza_providers.dart';
import '../../fuliza/repositories/fuliza_repository.dart';
import '../models/mpesa_parse_result.dart';
import '../models/transaction_model.dart';
import '../providers/payee_category_providers.dart';
import '../providers/transaction_providers.dart';
import '../repositories/payee_category_repository.dart';
import '../repositories/transaction_repository.dart';

class MpesaActionOutcome {
  final bool isDuplicate;
  final bool linkedExisting;
  const MpesaActionOutcome({
    required this.isDuplicate,
    this.linkedExisting = false,
  });
}

class BulkImportSummary {
  final int importedTransactions;
  final int importedFuliza;
  final int skippedDuplicates;

  const BulkImportSummary({
    required this.importedTransactions,
    required this.importedFuliza,
    required this.skippedDuplicates,
  });

  int get totalImported => importedTransactions + importedFuliza;
}

class BatchPreviewItem {
  final MpesaParseResult result;
  final bool isDuplicate;
  final int? suggestedCategoryId;

  const BatchPreviewItem({
    required this.result,
    required this.isDuplicate,
    this.suggestedCategoryId,
  });

  bool get isFulizaEvent =>
      result.type == MpesaTransactionType.fulizaDrawdown ||
      result.type == MpesaTransactionType.fulizaRepayment;
}

class MpesaResultHandler {
  final TransactionRepository transactionRepo;
  final FulizaRepository fulizaRepo;
  final AccountRepository accountRepo;
  final PayeeCategoryRepository payeeRepo;

  const MpesaResultHandler({
    required this.transactionRepo,
    required this.fulizaRepo,
    required this.accountRepo,
    required this.payeeRepo,
  });

  /// Persists non-form M-Pesa events (`fulizaDrawdown` and `fulizaRepayment`).
  Future<MpesaActionOutcome> handleNonFormResult(MpesaParseResult result) async {
    if (result.type == MpesaTransactionType.fulizaDrawdown) {
      final isDuplicate = await fulizaRepo.insertDrawdown(
        FulizaRecordsCompanion.insert(
          mpesaRef: result.mpesaRef,
          fulizaAmount: result.fulizaAmount,
          accessFee: Value(result.fulizaAccessFee),
          outstandingTotal: Value(result.outstandingTotal),
          dueDate: Value(result.fulizaDueDate),
          createdAt: Value(result.transactionDate),
        ),
      );
      if (isDuplicate) return const MpesaActionOutcome(isDuplicate: true);

      final linked = await transactionRepo.updateFulizaFields(
        mpesaRef: result.mpesaRef,
        fulizaAmount: result.fulizaAmount,
        fulizaFee: result.fulizaAccessFee,
      );
      return MpesaActionOutcome(isDuplicate: false, linkedExisting: linked);
    }

    if (result.type == MpesaTransactionType.fulizaRepayment) {
      final isDuplicate = await fulizaRepo.recordRepayment(
        mpesaRef: result.mpesaRef,
        amount: result.amount,
        isFull: result.isFullFulizaRepayment,
        explicitOutstanding: result.hasExplicitFulizaOutstanding
            ? result.outstandingTotal
            : null,
        date: result.transactionDate,
      );
      return MpesaActionOutcome(isDuplicate: isDuplicate);
    }

    throw ArgumentError('Unsupported non-form M-Pesa type: ${result.type}');
  }

  /// Checks duplicate status and enriches the parse result with any saved
  /// Fuliza drawdown details before opening the transaction confirmation form.
  Future<({TransactionModel? duplicate, MpesaParseResult? enriched})>
      prepareForForm(MpesaParseResult result) async {
    if (result.mpesaRef.isNotEmpty) {
      final existing = await transactionRepo.getByRef(result.mpesaRef);
      if (existing != null) {
        return (duplicate: existing, enriched: null);
      }
    }

    final fulizaRecord = result.mpesaRef.isEmpty
        ? null
        : await fulizaRepo.getByRef(result.mpesaRef);
    final enriched = fulizaRecord == null
        ? result
        : result.copyWith(
            fulizaAmount: fulizaRecord.fulizaAmount,
            fulizaAccessFee: fulizaRecord.accessFee,
          );
    return (duplicate: null, enriched: enriched);
  }

  /// Prepares a batch of parsed M-Pesa results for preview by marking
  /// duplicates (both against the DB and within the batch) and resolving
  /// payee category suggestions.
  Future<List<BatchPreviewItem>> prepareBatchPreview(
    List<MpesaParseResult> results,
  ) async {
    final seenKeys = <(String, bool)>{};
    final items = <BatchPreviewItem>[];

    for (final r in results) {
      if (!r.isValid) continue;
      final isFuliza = r.type == MpesaTransactionType.fulizaDrawdown ||
          r.type == MpesaTransactionType.fulizaRepayment;
      final ref = r.mpesaRef.trim();

      var isDuplicate = false;
      if (ref.isNotEmpty) {
        if (!seenKeys.add((ref, isFuliza))) {
          isDuplicate = true;
        } else if (isFuliza) {
          isDuplicate = await fulizaRepo.getByRef(ref) != null;
        } else {
          isDuplicate = await transactionRepo.getByRef(ref) != null;
        }
      }

      int? suggestedCatId;
      if (!isDuplicate && !isFuliza) {
        final payee = r.counterpartyName.trim();
        if (payee.isNotEmpty) {
          suggestedCatId = await payeeRepo.suggest(payee);
        }
      }

      items.add(
        BatchPreviewItem(
          result: r,
          isDuplicate: isDuplicate,
          suggestedCategoryId: suggestedCatId,
        ),
      );
    }

    return items;
  }

  /// Atomically imports a batch of parsed M-Pesa messages with optional
  /// per-item category overrides (drawdowns first so paired transactions
  /// attach Fuliza details, then regular/reversal transactions, then Fuliza
  /// repayments chronologically).
  Future<BulkImportSummary> bulkImportWithOverrides(
    List<({MpesaParseResult result, int? categoryId})> items,
  ) async {
    return fulizaRepo.db.transaction(() async {
      final defaultAcc = await accountRepo.getDefaultAccount();
      final accountId = defaultAcc?.id;

      final drawdowns = items
          .where((i) =>
              i.result.isValid &&
              i.result.type == MpesaTransactionType.fulizaDrawdown)
          .toList()
        ..sort((a, b) =>
            a.result.transactionDate.compareTo(b.result.transactionDate));

      final repayments = items
          .where((i) =>
              i.result.isValid &&
              i.result.type == MpesaTransactionType.fulizaRepayment)
          .toList()
        ..sort((a, b) =>
            a.result.transactionDate.compareTo(b.result.transactionDate));

      final regular = items
          .where((i) =>
              i.result.isValid &&
              i.result.type != MpesaTransactionType.fulizaDrawdown &&
              i.result.type != MpesaTransactionType.fulizaRepayment)
          .toList()
        ..sort((a, b) =>
            a.result.transactionDate.compareTo(b.result.transactionDate));

      var importedTxns = 0;
      var importedFuliza = 0;
      var skipped = 0;

      for (final d in drawdowns) {
        final outcome = await handleNonFormResult(d.result);
        if (outcome.isDuplicate) {
          skipped++;
        } else {
          importedFuliza++;
        }
      }

      for (final item in regular) {
        final r = item.result;
        final prep = await prepareForForm(r);
        if (prep.duplicate != null || prep.enriched == null) {
          skipped++;
          continue;
        }
        final enriched = prep.enriched!;
        final payee = enriched.counterpartyName.trim();
        final suggestedCatId =
            payee.isNotEmpty ? await payeeRepo.suggest(payee) : null;
        final chosenCategoryId = item.categoryId ?? suggestedCatId;
        final normalizedRef =
            enriched.mpesaRef.trim().isEmpty ? null : enriched.mpesaRef.trim();
        final isReversal = enriched.type == MpesaTransactionType.reversal;

        final companion = TransactionsCompanion.insert(
          header: enriched.autoDescription,
          description: Value(payee),
          amount: enriched.amount,
          transactionCost: Value(enriched.transactionCost),
          fulizaAmount: Value(enriched.fulizaAmount),
          fulizaFee: Value(enriched.fulizaAccessFee),
          type: Value(enriched.resolvedTransactionType),
          categoryId: Value(chosenCategoryId),
          transactionDate: enriched.transactionDate,
          mpesaRef: Value(normalizedRef),
          counterpartyName: Value(payee),
          counterpartyAccount: Value(enriched.counterpartyAccount),
          isParsed: const Value(true),
          accountId: Value(accountId),
          excludeFromBudget: Value(isReversal),
        );

        final id = isReversal
            ? await transactionRepo.insertReversalAndMarkOriginal(
                companion,
                enriched.counterpartyAccount,
              )
            : await transactionRepo.insertOrIgnoreDuplicate(companion);

        if (id == null) {
          skipped++;
        } else {
          importedTxns++;
          if (item.categoryId != null && payee.isNotEmpty) {
            await payeeRepo.learn(payee, item.categoryId!);
          }
        }
      }

      for (final rep in repayments) {
        final outcome = await handleNonFormResult(rep.result);
        if (outcome.isDuplicate) {
          skipped++;
        } else {
          importedFuliza++;
        }
      }

      return BulkImportSummary(
        importedTransactions: importedTxns,
        importedFuliza: importedFuliza,
        skippedDuplicates: skipped,
      );
    });
  }

  /// Imports a batch of valid parsed M-Pesa messages (drawdowns first so
  /// paired transactions attach Fuliza details, then regular/reversal
  /// transactions, then Fuliza repayments chronologically).
  Future<BulkImportSummary> bulkImport(List<MpesaParseResult> results) {
    return bulkImportWithOverrides(
      results.map((r) => (result: r, categoryId: null)).toList(),
    );
  }
}

final mpesaResultHandlerProvider = Provider<MpesaResultHandler>((ref) {
  return MpesaResultHandler(
    transactionRepo: ref.watch(transactionRepositoryProvider),
    fulizaRepo: ref.watch(fulizaRepositoryProvider),
    accountRepo: ref.watch(accountRepositoryProvider),
    payeeRepo: ref.watch(payeeCategoryRepositoryProvider),
  );
});
