import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/services/mpesa_parser.dart';
import '../../transactions/services/mpesa_result_handler.dart';
import '../../transactions/widgets/batch_mpesa_paste_sheet.dart';

class HomeFloatingActionButtons extends ConsumerStatefulWidget {
  const HomeFloatingActionButtons({super.key});

  static Future<void> pasteFromClipboard(
    BuildContext context,
    WidgetRef ref,
  ) =>
      _pasteAndParseFlow(context, ref);

  static Future<void> handleIncomingMpesaText(
    BuildContext context,
    WidgetRef ref,
    String text, {
    bool fromShare = false,
  }) =>
      _handleIncomingTextFlow(context, ref, text, fromShare: fromShare);

  static Future<void> openBatchPaste(
    BuildContext context,
    WidgetRef ref, {
    String initialText = '',
  }) =>
      _openBatchPasteFlow(context, ref, initialText: initialText);

  @override
  ConsumerState<HomeFloatingActionButtons> createState() =>
      _HomeFloatingActionButtonsState();
}

void _showMpesaToast(
  BuildContext context,
  String message, {
  Color? color,
  int seconds = 4,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: seconds),
        backgroundColor: color,
      ),
    );
}

Future<void> _pasteAndParseFlow(BuildContext context, WidgetRef ref) async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  final text = data?.text?.trim() ?? '';
  if (!context.mounted) return;
  final l10n = context.l10n;

  if (text.isEmpty) {
    _showMpesaToast(context, l10n.clipboardEmpty);
    return;
  }

  await _handleIncomingTextFlow(context, ref, text, fromShare: false);
}

Future<void> _handleIncomingTextFlow(
  BuildContext context,
  WidgetRef ref,
  String text, {
  required bool fromShare,
}) async {
  final l10n = context.l10n;
  final batch = MpesaParser.parseBatch(text);

  if (batch.valid.length >= 2) {
    await _openBatchPasteFlow(context, ref, initialText: text);
    return;
  }

  if (batch.valid.length == 1) {
    await _handleMpesaParseResult(context, ref, batch.valid.first);
    return;
  }

  if (fromShare) {
    _showMpesaToast(context, l10n.sharedTextNotMpesa);
    return;
  }

  final action = await showDialog<_PasteDialogAction>(
    context: context,
    builder: (_) => _PasteDialog(initialText: text),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _PasteSingle(:final result):
      await _handleMpesaParseResult(context, ref, result);
    case _PasteBatch(:final rawText):
      await _openBatchPasteFlow(context, ref, initialText: rawText);
  }
}

Future<void> _openBatchPasteFlow(
  BuildContext context,
  WidgetRef ref, {
  String initialText = '',
}) async {
  final summary = await showBatchMpesaPasteSheet(
    context,
    initialText: initialText,
  );
  if (summary == null || !context.mounted) return;
  final l10n = context.l10n;
  if (summary.totalImported == 0) {
    _showMpesaToast(context, l10n.batchImportNothingNew);
  } else if (summary.skippedDuplicates > 0) {
    _showMpesaToast(
      context,
      l10n.batchImportSuccessWithSkipped(
        summary.totalImported,
        summary.skippedDuplicates,
      ),
      color: Colors.green.shade700,
    );
  } else {
    _showMpesaToast(
      context,
      l10n.batchImportSuccess(summary.totalImported),
      color: Colors.green.shade700,
    );
  }
}

Future<void> _handleMpesaParseResult(
  BuildContext context,
  WidgetRef ref,
  MpesaParseResult result,
) async {
  final handler = ref.read(mpesaResultHandlerProvider);
  final l10n = context.l10n;

  if (result.type == MpesaTransactionType.fulizaDrawdown) {
    final outcome = await handler.handleNonFormResult(result);
    if (!context.mounted) return;
    if (outcome.isDuplicate) {
      _showMpesaToast(context, l10n.fulizaAlreadyRecorded, seconds: 3);
    } else {
      _showMpesaToast(
        context,
        outcome.linkedExisting
            ? l10n.fulizaLinkedToast
            : l10n.fulizaRecordedToast,
      );
    }
    return;
  }

  if (result.type == MpesaTransactionType.fulizaRepayment) {
    final outcome = await handler.handleNonFormResult(result);
    if (!context.mounted) return;
    if (outcome.isDuplicate) {
      _showMpesaToast(context, l10n.fulizaRepayAlreadyRecorded, seconds: 3);
    } else {
      _showMpesaToast(
        context,
        l10n.fulizaRepaidToast(CurrencyFormatter.format(result.amount)),
        color: Colors.green.shade700,
        seconds: 5,
      );
    }
    return;
  }

  final prep = await handler.prepareForForm(result);
  if (!context.mounted) return;
  if (prep.duplicate != null) {
    _showMpesaToast(
      context,
      l10n.alreadyRecordedWithDate(
        result.mpesaRef,
        DateFormatter.formatDate(prep.duplicate!.transactionDate),
      ),
    );
    return;
  }

  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => AddTransactionScreen(parseResult: prep.enriched),
    ),
  );
}

class _HomeFloatingActionButtonsState
    extends ConsumerState<HomeFloatingActionButtons> {
  // Guards against double-taps starting two parse/save flows at once.
  bool _busy = false;

  void _toast(String message, {Color? color, int seconds = 4}) =>
      _showMpesaToast(context, message, color: color, seconds: seconds);

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
          context.l10n.somethingWentWrong,
          color: Theme.of(context).colorScheme.error,
        );
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _pasteAndParse() => _pasteAndParseFlow(context, ref);

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'fab_parse',
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          onPressed: () {
            HapticFeedback.lightImpact();
            _run(_pasteAndParse);
          },
          tooltip: l10n.pasteMpesaSmsTooltip,
          child: const Icon(Icons.content_paste_rounded),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'fab_add_manual',
          onPressed: () {
            HapticFeedback.lightImpact();
            _run(
              () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              ),
            );
          },
          tooltip: l10n.addManuallyTooltip,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ],
    );
  }
}

sealed class _PasteDialogAction {
  const _PasteDialogAction();
}

final class _PasteSingle extends _PasteDialogAction {
  final MpesaParseResult result;
  const _PasteSingle(this.result);
}

final class _PasteBatch extends _PasteDialogAction {
  final String rawText;
  const _PasteBatch(this.rawText);
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
    final l10n = context.l10n;
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = l10n.pasteMpesaFirstError);
      return;
    }
    final batch = MpesaParser.parseBatch(text);
    if (batch.valid.length >= 2) {
      Navigator.pop(context, _PasteBatch(text));
      return;
    }
    if (batch.valid.length == 1) {
      Navigator.pop(context, _PasteSingle(batch.valid.first));
      return;
    }
    final result = MpesaParser.parse(text);
    if (!result.isValid) {
      setState(
        () => _error = l10n.couldNotParseError(result.errorMessage ?? ''),
      );
      return;
    }
    Navigator.pop(context, _PasteSingle(result));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.pasteMpesaSmsTitle),
      content: TextField(
        controller: _controller,
        maxLines: 6,
        autofocus: true,
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          hintText: l10n.pasteMpesaHint,
          border: const OutlineInputBorder(),
          errorText: _error,
          errorMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, _PasteBatch(_controller.text.trim())),
          child: Text(l10n.batchImportAction),
        ),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.parse)),
      ],
    );
  }
}
