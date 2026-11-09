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

class HomeFloatingActionButtons extends ConsumerStatefulWidget {
  const HomeFloatingActionButtons({super.key});

  @override
  ConsumerState<HomeFloatingActionButtons> createState() =>
      _HomeFloatingActionButtonsState();
}

class _HomeFloatingActionButtonsState
    extends ConsumerState<HomeFloatingActionButtons> {
  static const _reversedTag = '[REVERSED]';

  // Guards against double-taps starting two parse/save flows at once.
  bool _busy = false;

  // ── Helpers ────────────────────────────────────────────────────────────

  void _toast(String message, {Color? color, int seconds = 4}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars() // don't queue messages behind each other
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: seconds),
          backgroundColor: color,
        ),
      );
  }

  /// Runs [action] once at a time and turns any exception into a friendly
  /// message (details go to the log, not the user).
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    _busy = true;
    try {
      await action();
    } catch (e, st) {
      debugPrint('M-Pesa flow error: $e\n$st');
      if (mounted) {
        _toast(
          'Something went wrong. Please try again.',
          color: Theme.of(context).colorScheme.error,
        );
      }
    } finally {
      _busy = false;
    }
  }

  // ── Flow ───────────────────────────────────────────────────────────────

  Future<void> _pasteAndParse() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;

    if (text.isEmpty) {
      _toast('Clipboard is empty. Copy an M-Pesa SMS first.');
      return;
    }

    var result = MpesaParser.parse(text);

    if (!result.isValid) {
      // Open the editor pre-filled so the user can fix a bad copy,
      // instead of making them paste again into an empty box.
      final fixed = await showDialog<MpesaParseResult>(
        context: context,
        builder: (_) => _PasteDialog(initialText: text),
      );
      if (fixed == null || !mounted) return;
      result = fixed;
    }

    await _handleParseResult(result);
  }

  Future<void> _handleParseResult(MpesaParseResult result) async {
    if (result.type == MpesaTransactionType.fulizaDrawdown) {
      return _handleFulizaDrawdown(result);
    }
    if (result.type == MpesaTransactionType.fulizaRepayment) {
      return _handleFulizaRepayment(result);
    }

    final txnRepo = ref.read(transactionRepositoryProvider);

    // Duplicate check FIRST. This also stops a re-pasted reversal from
    // annotating the original transaction a second time.
    if (result.mpesaRef.isNotEmpty) {
      final existing = await txnRepo.getByRef(result.mpesaRef);
      if (!mounted) return;
      if (existing != null) {
        _toast(
          'Already recorded — ${result.mpesaRef} was saved on '
          '${DateFormatter.formatDate(existing.transactionDate)}.',
        );
        return;
      }
    }

    if (result.type == MpesaTransactionType.reversal) {
      await _markOriginalReversed(result);
      // Fall through: open the form so the user confirms the reversal income.
    }

    // Enrich the form if a Fuliza record was already saved for this ref.
    final fulizaRecord = result.mpesaRef.isEmpty
        ? null
        : await ref.read(fulizaRepositoryProvider).getByRef(result.mpesaRef);
    if (!mounted) return;

    final enriched = fulizaRecord == null
        ? result
        : result.copyWith(
            fulizaAmount: fulizaRecord.fulizaAmount,
            fulizaAccessFee: fulizaRecord.accessFee,
          );

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
          builder: (_) => AddTransactionScreen(parseResult: enriched)),
    );
  }

  Future<void> _handleFulizaDrawdown(MpesaParseResult result) async {
    final isDuplicate = await ref.read(fulizaRepositoryProvider).insertDrawdown(
          FulizaRecordsCompanion.insert(
            mpesaRef: result.mpesaRef,
            fulizaAmount: result.fulizaAmount,
            accessFee: Value(result.fulizaAccessFee),
            outstandingTotal: Value(result.outstandingTotal),
            dueDate: Value(result.fulizaDueDate),
          ),
        );
    if (!mounted) return;

    if (isDuplicate) {
      _toast('Already recorded — this Fuliza was saved before.', seconds: 3);
      return;
    }

    // New record: also update the paired transaction if it's already saved.
    final updated =
        await ref.read(transactionRepositoryProvider).updateFulizaFields(
              mpesaRef: result.mpesaRef,
              fulizaAmount: result.fulizaAmount,
              fulizaFee: result.fulizaAccessFee,
            );

    _toast(
      updated
          ? 'Fuliza linked ✓  Transaction updated with Fuliza details.'
          : 'Fuliza recorded ✓  Paste the paired M-Pesa send message next.',
    );
  }

  // Fuliza repayment is auto-deducted by M-Pesa, so it's info only here.
  void _handleFulizaRepayment(MpesaParseResult result) {
    _toast(
      'Fuliza repaid: ${CurrencyFormatter.format(result.amount)}  •  '
      'New balance: ${CurrencyFormatter.format(result.newBalance)}',
      color: Colors.green.shade700,
      seconds: 5,
    );
  }

  Future<void> _markOriginalReversed(MpesaParseResult result) async {
    final origRef =
        result.counterpartyAccount; // original M-Pesa ref lives here
    if (origRef.isEmpty) return;

    final repo = ref.read(transactionRepositoryProvider);
    final original = await repo.getByRef(origRef);

    // Idempotent: never stack "[REVERSED] [REVERSED] ..."
    if (original == null || original.description.startsWith(_reversedTag)) {
      return;
    }

    await repo.updateTransaction(
      TransactionsCompanion(
        id: Value(original.id),
        description: Value('$_reversedTag ${original.description}'),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'fab_parse',
          onPressed: () => _run(_pasteAndParse),
          tooltip: 'Paste M-Pesa SMS',
          child: const Icon(Icons.content_paste_rounded),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'fab_add_manual',
          onPressed: () => _run(
            () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            ),
          ),
          tooltip: 'Add Manually',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Owns its controller (so it gets disposed) and validates inline,
/// staying open on a bad parse instead of closing and toasting.
class _PasteDialog extends StatefulWidget {
  final String initialText;
  const _PasteDialog({this.initialText = ''});

  @override
  State<_PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends State<_PasteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Paste an M-Pesa message first.');
      return;
    }
    final result = MpesaParser.parse(text);
    if (!result.isValid) {
      setState(() => _error = 'Could not parse: ${result.errorMessage}');
      return;
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Paste M-Pesa SMS'),
      content: TextField(
        controller: _controller,
        maxLines: 6,
        autofocus: true,
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          hintText: 'Paste your M-Pesa message here...',
          border: const OutlineInputBorder(),
          errorText: _error,
          errorMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Parse')),
      ],
    );
  }
}
