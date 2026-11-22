import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../providers/fuliza_providers.dart';

class FulizaScreen extends ConsumerWidget {
  const FulizaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestFulizaProvider);
    final recordsAsync = ref.watch(fulizaRecordsProvider);
    final totalFeesAsync = ref.watch(fulizaTotalFeesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fuliza M-PESA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          latestAsync.when(
            data: (latest) => _OutstandingCard(
              latest: latest,
              totalFees: totalFeesAsync.valueOrNull ?? 0.0,
              onRecordRepayment: (latest?.outstandingTotal ?? 0) > 0
                  ? () => _showRepayDialog(
                        context,
                        ref,
                        latest!.outstandingTotal,
                      )
                  : null,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          Text('Fuliza Usage History', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          recordsAsync.when(
            data: (records) => records.isEmpty
                ? const _EmptyFuliza()
                : Column(
                    children: records
                        .map((r) => _FulizaListItem(record: r))
                        .toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRepayDialog(
    BuildContext context,
    WidgetRef ref,
    double outstanding,
  ) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _FulizaRepayDialog(outstanding: outstanding),
    );
    if (amount == null) return;
    final isFull =
        CentsConverter.toCents(amount) >= CentsConverter.toCents(outstanding);
    await ref.read(fulizaRepositoryProvider).recordRepayment(
          mpesaRef: 'MANUAL-${DateTime.now().microsecondsSinceEpoch}',
          amount: amount,
          isFull: isFull,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFull
                ? 'Fuliza balance cleared.'
                : 'Fuliza repayment of ${CurrencyFormatter.format(amount)} recorded.',
          ),
        ),
      );
    }
  }
}

class _FulizaRepayDialog extends StatefulWidget {
  final double outstanding;
  const _FulizaRepayDialog({required this.outstanding});

  @override
  State<_FulizaRepayDialog> createState() => _FulizaRepayDialogState();
}

class _FulizaRepayDialogState extends State<_FulizaRepayDialog> {
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.outstanding.toStringAsFixed(2),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Fuliza Repayment'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountCtrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount (KES)',
            helperText:
                'Outstanding: ${CurrencyFormatter.format(widget.outstanding)}',
            border: const OutlineInputBorder(),
          ),
          validator: (v) {
            final parsed = double.tryParse(
              (v ?? '').replaceAll(',', '').trim(),
            );
            if (parsed == null || !parsed.isFinite || parsed <= 0) {
              return 'Enter a valid positive amount';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final parsed = double.parse(
              _amountCtrl.text.replaceAll(',', '').trim(),
            );
            Navigator.pop(context, parsed);
          },
          child: const Text('Record'),
        ),
      ],
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  final FulizaRecord? latest;
  final double totalFees;
  final VoidCallback? onRecordRepayment;
  const _OutstandingCard({
    this.latest,
    required this.totalFees,
    this.onRecordRepayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outstanding = latest?.outstandingTotal ?? 0;
    final dueDate = latest?.dueDate;
    final overdue = dueDate != null && dueDate.isBefore(DateTime.now());

    final cardColor = outstanding > 0
        ? (overdue
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.tertiaryContainer)
        : theme.colorScheme.primaryContainer;
    final fgColor = outstanding > 0
        ? (overdue
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onTertiaryContainer)
        : theme.colorScheme.onPrimaryContainer;

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  outstanding > 0
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle,
                  color: fgColor,
                ),
                const SizedBox(width: 8),
                Text(
                  outstanding > 0
                      ? 'Fuliza Outstanding'
                      : 'No Fuliza Balance',
                  style: theme.textTheme.titleSmall?.copyWith(color: fgColor),
                ),
              ],
            ),
            if (outstanding > 0) ...[
              const SizedBox(height: 12),
              Text(
                CurrencyFormatter.format(outstanding),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
              if (dueDate != null)
                Text(
                  'Due ${DateFormat('dd MMM yyyy').format(dueDate)}${overdue ? ' — OVERDUE' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: fgColor,
                    fontWeight: overdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              if (onRecordRepayment != null) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onRecordRepayment,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Record Repayment'),
                ),
              ],
            ],
            if (totalFees > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Total fees paid: ${CurrencyFormatter.format(totalFees)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FulizaListItem extends StatelessWidget {
  final FulizaRecord record;
  const _FulizaListItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRepayment = record.fulizaAmount < 0;
    final displayAmount = record.fulizaAmount.abs();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRepayment
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.tertiaryContainer,
          child: Icon(
            isRepayment ? Icons.check_circle_outline : Icons.sync,
            color: isRepayment
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onTertiaryContainer,
          ),
        ),
        title: Text(
          isRepayment
              ? 'Repaid ${CurrencyFormatter.format(displayAmount)}'
              : CurrencyFormatter.format(displayAmount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ref: ${record.mpesaRef}'),
            if (!isRepayment || record.accessFee > 0)
              Text('Access fee: ${CurrencyFormatter.format(record.accessFee)}'),
            if (record.dueDate != null)
              Text('Due: ${DateFormat('dd MMM yyyy').format(record.dueDate!)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Outstanding',
              style: theme.textTheme.labelSmall,
            ),
            Text(
              CurrencyFormatter.format(record.outstandingTotal),
              style: TextStyle(
                color: record.outstandingTotal > 0
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _EmptyFuliza extends StatelessWidget {
  const _EmptyFuliza();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('No Fuliza usage recorded',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Paste Fuliza M-PESA SMS messages to track your Fuliza usage',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
