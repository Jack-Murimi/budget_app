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

class HomeFloatingActionButtons extends ConsumerStatefulWidget {
  const HomeFloatingActionButtons({super.key});

  @override
  ConsumerState<HomeFloatingActionButtons> createState() =>
      _HomeFloatingActionButtonsState();
}

class _HomeFloatingActionButtonsState
    extends ConsumerState<HomeFloatingActionButtons> {
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
          context.l10n.somethingWentWrong,
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
    final l10n = context.l10n;

    if (text.isEmpty) {
      _toast(l10n.clipboardEmpty);
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
    final handler = ref.read(mpesaResultHandlerProvider);
    final l10n = context.l10n;

    if (result.type == MpesaTransactionType.fulizaDrawdown) {
      final outcome = await handler.handleNonFormResult(result);
      if (!mounted) return;
      if (outcome.isDuplicate) {
        _toast(l10n.fulizaAlreadyRecorded, seconds: 3);
      } else {
        _toast(
          outcome.linkedExisting
              ? l10n.fulizaLinkedToast
              : l10n.fulizaRecordedToast,
        );
      }
      return;
    }

    if (result.type == MpesaTransactionType.fulizaRepayment) {
      final outcome = await handler.handleNonFormResult(result);
      if (!mounted) return;
      if (outcome.isDuplicate) {
        _toast(l10n.fulizaRepayAlreadyRecorded, seconds: 3);
      } else {
        _toast(
          l10n.fulizaRepaidToast(CurrencyFormatter.format(result.amount)),
          color: Colors.green.shade700,
          seconds: 5,
        );
      }
      return;
    }

    final prep = await handler.prepareForForm(result);
    if (!mounted) return;
    if (prep.duplicate != null) {
      _toast(
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
    final result = MpesaParser.parse(text);
    if (!result.isValid) {
      setState(
        () => _error = l10n.couldNotParseError(result.errorMessage ?? ''),
      );
      return;
    }
    Navigator.pop(context, result);
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
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.parse)),
      ],
    );
  }
}
