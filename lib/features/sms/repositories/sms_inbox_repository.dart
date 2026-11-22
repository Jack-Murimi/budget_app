import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../services/sms_inbox_scanner.dart';

class ExistingSmsState {
  final Set<String> transactionRefs;
  final Set<String> fulizaRefs;
  final Set<String> processedBodies;

  const ExistingSmsState({
    required this.transactionRefs,
    required this.fulizaRefs,
    required this.processedBodies,
  });

  bool isAlreadyProcessed(SmsParseItem item) {
    final body = item.raw.body.trim();
    if (processedBodies.contains(body)) return true;

    final ref = item.result.mpesaRef.trim();
    if (ref.isEmpty) return false;

    if (item.result.type == MpesaTransactionType.fulizaDrawdown ||
        item.result.type == MpesaTransactionType.fulizaRepayment) {
      return fulizaRefs.contains(ref);
    }
    return transactionRefs.contains(ref);
  }
}

class SmsInboxRepository {
  final AppDatabase db;
  const SmsInboxRepository(this.db);

  /// Loads M-Pesa refs already recorded in transactions/fuliza_records and
  /// SMS bodies already approved or dismissed in sms_inbox_items.
  Future<ExistingSmsState> getExistingState() async {
    final txRefs = <String>{};
    final fulizaRefs = <String>{};

    final txRows = await db.customSelect(
      'SELECT mpesa_ref FROM transactions WHERE mpesa_ref IS NOT NULL',
    ).get();
    for (final r in txRows) {
      final v = r.readNullable<String>('mpesa_ref')?.trim();
      if (v != null && v.isNotEmpty) txRefs.add(v);
    }

    final fulizaRows = await db.customSelect(
      'SELECT mpesa_ref FROM fuliza_records WHERE mpesa_ref IS NOT NULL',
    ).get();
    for (final r in fulizaRows) {
      final v = r.readNullable<String>('mpesa_ref')?.trim();
      if (v != null && v.isNotEmpty) fulizaRefs.add(v);
    }

    final inboxRows = await (db.select(db.smsInboxItems)
          ..where((i) => i.status.isIn(const ['approved', 'dismissed'])))
        .get();
    final bodies = {for (final r in inboxRows) r.rawBody.trim()};

    return ExistingSmsState(
      transactionRefs: txRefs,
      fulizaRefs: fulizaRefs,
      processedBodies: bodies,
    );
  }

  /// Records newly discovered SMS items as 'pending' if not already tracked
  /// (deduplicated by raw SMS body so paired Fuliza + spend messages with
  /// the same M-Pesa ref are both preserved).
  Future<void> recordPendingBatch(List<SmsParseItem> items) async {
    if (items.isEmpty) return;
    await db.transaction(() async {
      final existing = await db.select(db.smsInboxItems).get();
      final existingBodies = {for (final row in existing) row.rawBody.trim()};

      for (final item in items) {
        final ref = item.result.mpesaRef.trim();
        final body = item.raw.body.trim();
        if (existingBodies.contains(body)) continue;

        await db.into(db.smsInboxItems).insert(
              SmsInboxItemsCompanion.insert(
                rawBody: item.raw.body,
                parsedType:
                    Value(item.result.isValid ? item.result.type.name : null),
                parsedAmount:
                    Value(item.result.isValid ? item.result.amount : null),
                parsedPayee: Value(
                  item.result.counterpartyName.isNotEmpty
                      ? item.result.counterpartyName
                      : null,
                ),
                parsedRef: Value(ref.isNotEmpty ? ref : null),
                parsedDate: Value(item.raw.date.millisecondsSinceEpoch),
                status: const Value('pending'),
                parseNote: Value(item.result.errorMessage),
                createdAt: DateTime.now(),
              ),
            );
        existingBodies.add(body);
      }
    });
  }

  /// Updates an SMS inbox item status ('approved' | 'dismissed') keyed by
  /// [rawBody], inserting a record if none exists yet.
  Future<void> markStatus({
    String? ref,
    required String rawBody,
    required String status,
  }) async {
    final cleanRef = ref?.trim();
    final cleanBody = rawBody.trim();
    await db.transaction(() async {
      var updated = await (db.update(db.smsInboxItems)
            ..where((i) => i.rawBody.equals(rawBody)))
          .write(SmsInboxItemsCompanion(status: Value(status)));
      if (updated == 0 && cleanRef != null && cleanRef.isNotEmpty) {
        updated = await (db.update(db.smsInboxItems)
              ..where((i) => i.parsedRef.equals(cleanRef)))
            .write(SmsInboxItemsCompanion(status: Value(status)));
      }
      if (updated == 0 && cleanBody.isNotEmpty) {
        await db.into(db.smsInboxItems).insert(
              SmsInboxItemsCompanion.insert(
                rawBody: rawBody,
                parsedRef: Value(
                  (cleanRef != null && cleanRef.isNotEmpty) ? cleanRef : null,
                ),
                status: Value(status),
                createdAt: DateTime.now(),
              ),
            );
      }
    });
  }
}

final smsInboxRepositoryProvider = Provider<SmsInboxRepository>((ref) {
  return SmsInboxRepository(ref.watch(dbProvider));
});
