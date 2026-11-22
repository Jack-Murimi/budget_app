import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/services/mpesa_result_handler.dart';
import '../repositories/sms_inbox_repository.dart';
import '../services/sms_inbox_scanner.dart';

class SmsInboxScreen extends ConsumerStatefulWidget {
  final Future<List<RawSms>> Function()? smsLoader;
  final Future<bool> Function()? requestPermission;

  const SmsInboxScreen({
    super.key,
    this.smsLoader,
    this.requestPermission,
  });

  @override
  ConsumerState<SmsInboxScreen> createState() => _SmsInboxScreenState();
}

class _SmsInboxScreenState extends ConsumerState<SmsInboxScreen> {
  List<SmsParseItem>? _items;
  int _alreadyProcessedCount = 0;
  bool _loading = false;
  bool _importing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestAndScan();
  }

  Future<void> _requestAndScan() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final granted = widget.requestPermission != null
          ? await widget.requestPermission!()
          : (await Permission.sms.request()).isGranted;
      if (!mounted) return;
      if (!granted) {
        setState(() {
          _loading = false;
          _error = 'SMS permission denied. Grant it in device Settings.';
        });
        return;
      }

      final raw = widget.smsLoader != null
          ? await widget.smsLoader!()
          : await SmsInboxScanner.readMpesaSms();
      if (!mounted) return;

      final parsed = SmsInboxScanner.scanAndParse(raw);
      final smsRepo = ref.read(smsInboxRepositoryProvider);
      final existingState = await smsRepo.getExistingState();
      if (!mounted) return;

      final pending = <SmsParseItem>[];
      var skipped = 0;
      for (final item in parsed) {
        if (existingState.isAlreadyProcessed(item)) {
          skipped++;
        } else {
          pending.add(item);
        }
      }

      await smsRepo.recordPendingBatch(pending);
      if (!mounted) return;

      pending.sort((a, b) => a.confidence.index.compareTo(b.confidence.index));
      setState(() {
        _items = pending;
        _alreadyProcessedCount = skipped;
        _loading = false;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not read SMS inbox: ${e.message ?? e.code}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to scan SMS inbox: $e';
      });
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAddItem(SmsParseItem item) async {
    final r = item.result;
    final handler = ref.read(mpesaResultHandlerProvider);
    final smsRepo = ref.read(smsInboxRepositoryProvider);

    if (r.type == MpesaTransactionType.fulizaDrawdown ||
        r.type == MpesaTransactionType.fulizaRepayment) {
      final outcome = await handler.handleNonFormResult(r);
      await smsRepo.markStatus(
        ref: r.mpesaRef,
        rawBody: item.raw.body,
        status: 'approved',
      );
      if (!mounted) return;
      setState(() => _items?.remove(item));
      if (outcome.isDuplicate) {
        _toast('Already recorded — ${r.mpesaRef}');
      } else if (r.type == MpesaTransactionType.fulizaRepayment) {
        _toast('Fuliza repayment recorded: ${CurrencyFormatter.format(r.amount)}');
      } else {
        _toast(
          outcome.linkedExisting
              ? 'Fuliza recorded & linked to existing transaction.'
              : 'Fuliza drawdown recorded.',
        );
      }
      return;
    }

    final prep = await handler.prepareForForm(r);
    if (!mounted) return;
    if (prep.duplicate != null) {
      await smsRepo.markStatus(
        ref: r.mpesaRef,
        rawBody: item.raw.body,
        status: 'approved',
      );
      if (!mounted) return;
      setState(() => _items?.remove(item));
      _toast('Already recorded — ${r.mpesaRef}');
      return;
    }

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(parseResult: prep.enriched!),
      ),
    );
    if (saved == true && mounted) {
      await smsRepo.markStatus(
        ref: r.mpesaRef,
        rawBody: item.raw.body,
        status: 'approved',
      );
      if (!mounted) return;
      setState(() => _items?.remove(item));
    }
  }

  Future<void> _dismissItem(SmsParseItem item) async {
    await ref.read(smsInboxRepositoryProvider).markStatus(
          ref: item.result.mpesaRef,
          rawBody: item.raw.body,
          status: 'dismissed',
        );
    if (!mounted) return;
    setState(() => _items?.remove(item));
  }

  Future<void> _importAllHighConfidence(List<SmsParseItem> good) async {
    if (_importing || good.isEmpty) return;
    setState(() => _importing = true);
    try {
      final handler = ref.read(mpesaResultHandlerProvider);
      final smsRepo = ref.read(smsInboxRepositoryProvider);
      final summary =
          await handler.bulkImport(good.map((i) => i.result).toList());
      for (final item in good) {
        await smsRepo.markStatus(
          ref: item.result.mpesaRef,
          rawBody: item.raw.body,
          status: 'approved',
        );
      }
      if (!mounted) return;
      setState(() {
        _items?.removeWhere((item) => good.contains(item));
      });
      _toast(
        'Imported ${summary.importedTransactions} transactions, '
        '${summary.importedFuliza} Fuliza records'
        '${summary.skippedDuplicates > 0 ? ' (${summary.skippedDuplicates} duplicates skipped)' : ''}.',
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan M-Pesa SMS'),
        actions: [
          if (!_loading && !_importing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _requestAndScan,
              tooltip: 'Rescan',
            ),
        ],
      ),
      body: _build(theme),
    );
  }

  Widget _build(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sms_failed_outlined,
                  size: 56, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _requestAndScan,
                child: const Text('Retry'),
              ),
              const TextButton(
                onPressed: openAppSettings,
                child: Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }
    final items = _items ?? [];
    if (items.isEmpty) {
      return Center(
        child: Text(
          _alreadyProcessedCount > 0
              ? 'All M-Pesa messages already imported ($_alreadyProcessedCount).'
              : 'No M-Pesa messages found in inbox.',
        ),
      );
    }

    final good = items.where((i) => i.confidence == SmsConfidence.high).toList();
    final review =
        items.where((i) => i.confidence != SmsConfidence.high).toList();

    return ListView(
      children: [
        if (_alreadyProcessedCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Skipped $_alreadyProcessedCount already recorded or dismissed messages',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        if (good.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ready to Add (${good.length})',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
                FilledButton.icon(
                  onPressed:
                      _importing ? null : () => _importAllHighConfidence(good),
                  icon: _importing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.done_all, size: 18),
                  label: Text('Import all (${good.length})'),
                ),
              ],
            ),
          ),
          ...good.map((i) => _itemTile(theme, i)),
        ],
        if (review.isNotEmpty) ...[
          _sectionHeader(theme, 'Needs Review (${review.length})'),
          ...review.map((i) => _itemTile(theme, i, isReview: true)),
        ],
      ],
    );
  }

  Widget _sectionHeader(ThemeData theme, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.primary)),
      );

  Widget _itemTile(ThemeData theme, SmsParseItem item,
      {bool isReview = false}) {
    final r = item.result;
    final color = isReview
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.primaryContainer;
    final onColor = isReview
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onPrimaryContainer;
    final isFuliza = r.type == MpesaTransactionType.fulizaDrawdown ||
        r.type == MpesaTransactionType.fulizaRepayment;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            isReview ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: onColor,
            size: 20,
          ),
        ),
        title: Text(
          r.isValid
              ? '${r.type.defaultDescription} • ${CurrencyFormatter.format(r.amount)}'
              : 'Unrecognised',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          r.isValid
              ? '${r.counterpartyName.isNotEmpty ? r.counterpartyName : "—"}  •  ${r.transactionDate.toString().substring(0, 16)}'
              : item.raw.body.length > 80
                  ? '${item.raw.body.substring(0, 80)}…'
                  : item.raw.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.isValid)
              FilledButton.tonal(
                onPressed: _importing ? null : () => _handleAddItem(item),
                child: Text(isFuliza ? 'Record' : 'Add'),
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Dismiss',
              onPressed: _importing ? null : () => _dismissItem(item),
            ),
          ],
        ),
      ),
    );
  }
}
