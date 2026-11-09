import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../fuliza/providers/fuliza_providers.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../transactions/services/mpesa_parser.dart';

class HomeFloatingActionButtons extends ConsumerWidget {
  const HomeFloatingActionButtons({super.key});

  Future<void> _handleParseResult(
      BuildContext context, WidgetRef ref, MpesaParseResult result) async {
    if (result.type == MpesaTransactionType.fulizaDrawdown) {
      final isDuplicate = await ref.read(fulizaRepositoryProvider).insertDrawdown(
        FulizaRecordsCompanion.insert(
          mpesaRef: result.mpesaRef,
          fulizaAmount: result.fulizaAmount,
          accessFee: Value(result.fulizaAccessFee),
          outstandingTotal: Value(result.outstandingTotal),
          dueDate: Value(result.fulizaDueDate),
        ),
      );

      if (!context.mounted) return;

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already recorded — this Fuliza was saved before.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 600, left: 16, right: 16), // push to top
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // New record — also update paired transaction if already saved
      final updated = await ref.read(transactionRepositoryProvider).updateFulizaFields(
        mpesaRef: result.mpesaRef,
        fulizaAmount: result.fulizaAmount,
        fulizaFee: result.fulizaAccessFee,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated
                ? 'Fuliza linked ✓  Transaction updated with Fuliza details.'
                : 'Fuliza recorded ✓  Paste the paired M-Pesa send message next.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Fuliza repayment — auto-deducted by M-Pesa, not a manual transaction
    if (result.type == MpesaTransactionType.fulizaRepayment) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fuliza repaid: ${CurrencyFormatter.format(result.amount)}  •  New balance: ${CurrencyFormatter.format(result.newBalance)}',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green.shade700,
        ),
      );
      return;
    }

    // Reversal — annotate the original transaction if it exists
    if (result.type == MpesaTransactionType.reversal) {
      final origRef = result.counterpartyAccount; // original mpesa ref stored here
      if (origRef.isNotEmpty) {
        final original = await ref.read(transactionRepositoryProvider).getByRef(origRef);
        if (original != null) {
          // Add a note to the original transaction flagging it as reversed
          await ref.read(transactionRepositoryProvider).updateTransaction(
            TransactionsCompanion(
              id: Value(original.id),
              description: Value('[REVERSED] ${original.description}'),
            ),
          );
        }
      }
      // Fall through to open the form so user confirms the reversal income entry
    }

    // Normal transaction — check duplicate FIRST before opening form
    if (result.mpesaRef.isNotEmpty) {
      final existingTxn = await ref.read(transactionRepositoryProvider).getByRef(result.mpesaRef);
      if (existingTxn != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Already recorded — ${result.mpesaRef} was saved on ${DateFormatter.formatDate(existingTxn.transactionDate)}.'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 600, left: 16, right: 16),
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    // Check if Fuliza record already saved for this ref (to enrich the form)
    final fulizaRecord =
        await ref.read(fulizaRepositoryProvider).getByRef(result.mpesaRef);
    final enrichedResult = fulizaRecord != null
        ? result.copyWith(
            fulizaAmount: fulizaRecord.fulizaAmount,
            fulizaAccessFee: fulizaRecord.accessFee,
          )
        : result;

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(parseResult: enrichedResult),
      ),
    );
  }

  Future<void> _onPasteAndParse(BuildContext context, WidgetRef ref) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!context.mounted) return;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty. Copy an M-Pesa SMS first.')),
      );
      return;
    }

    final result = MpesaParser.parse(text);

    if (!result.isValid) {
      _showPasteDialog(context, ref);
      return;
    }

    try {
      await _handleParseResult(context, ref, result);
    } catch (e, st) {
      debugPrint('Parse error: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showPasteDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Paste M-Pesa SMS'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Paste your M-Pesa message here...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final text = controller.text.trim();
              if (text.isEmpty) return;
              final result = MpesaParser.parse(text);
              if (!result.isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not parse: ${result.errorMessage}')),
                );
                return;
              }
              try {
                await _handleParseResult(context, ref, result);
              } catch (e, st) {
                debugPrint('Parse error: $e\n$st');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Parse'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'fab_parse',
          onPressed: () => _onPasteAndParse(context, ref),
          tooltip: 'Paste M-Pesa SMS',
          child: const Icon(Icons.content_paste_rounded),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'fab_add_manual',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          ),
          tooltip: 'Add Manually',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
