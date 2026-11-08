import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../main.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../transactions/services/mpesa_parser.dart';
import '../services/sms_inbox_scanner.dart';

class SmsInboxScreen extends ConsumerStatefulWidget {
  const SmsInboxScreen({super.key});

  @override
  ConsumerState<SmsInboxScreen> createState() => _SmsInboxScreenState();
}

class _SmsInboxScreenState extends ConsumerState<SmsInboxScreen> {
  List<SmsParseItem>? _items;
  bool _loading = false;
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

    final status = await Permission.sms.request();
    if (!status.isGranted) {
      setState(() {
        _loading = false;
        _error = 'SMS permission denied. Grant it in device Settings.';
      });
      return;
    }

    final raw = await SmsInboxScanner.readMpesaSms();
    if (!mounted) return;

    final items = SmsInboxScanner.scanAndParse(raw)
      ..sort((a, b) => a.confidence.index.compareTo(b.confidence.index));

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan M-Pesa SMS'),
        actions: [
          if (!_loading)
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
              TextButton(
                onPressed: openAppSettings,
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }
    final items = _items ?? [];
    if (items.isEmpty) {
      return const Center(child: Text('No M-Pesa messages found in inbox.'));
    }

    // Split into high-confidence (auto-parseable) and needs-review
    final good = items.where((i) => i.confidence == SmsConfidence.high).toList();
    final review =
        items.where((i) => i.confidence != SmsConfidence.high).toList();

    return ListView(
      children: [
        if (good.isNotEmpty) ...[
          _sectionHeader(theme, 'Ready to Add (${good.length})'),
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
              ? '${r.type.defaultDescription} • KES ${r.amount.toStringAsFixed(2)}'
              : 'Unrecognised',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          r.isValid
              ? '${r.counterpartyName.isNotEmpty ? r.counterpartyName : "—"}  •  ${item.raw.date.toString().substring(0, 16)}'
              : item.raw.body.length > 80
                  ? '${item.raw.body.substring(0, 80)}…'
                  : item.raw.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: r.isValid
            ? FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(parseResult: r),
                  ),
                ),
                child: const Text('Add'),
              )
            : null,
      ),
    );
  }
}
