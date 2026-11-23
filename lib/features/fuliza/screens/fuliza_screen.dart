import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';
import '../providers/fuliza_providers.dart';

class FulizaScreen extends ConsumerWidget {
  const FulizaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestFulizaProvider);
    final recordsAsync = ref.watch(fulizaRecordsProvider);
    final totalFeesAsync = ref.watch(fulizaTotalFeesProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fulizaTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          latestAsync.when(
            data: (latest) => FadeSlideIn(
              child: _OutstandingCard(
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
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          Text(l10n.fulizaUsageHistory, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          recordsAsync.when(
            data: (records) => records.isEmpty
                ? const _EmptyFuliza()
                : Column(
                    children: [
                      for (final (i, r) in records.indexed)
                        FadeSlideIn(
                          index: i + 1,
                          dy: 10,
                          child: _FulizaListItem(record: r),
                        ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(l10n.errorLabel('$e')),
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
    final l10n = context.l10n;
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
                ? l10n.fulizaBalanceCleared
                : l10n.fulizaRepaymentRecorded(
                    CurrencyFormatter.format(amount),
                  ),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.recordFulizaRepayment),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountCtrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.amountKES,
            helperText: l10n.outstandingHelper(
              CurrencyFormatter.format(widget.outstanding),
            ),
            border: const OutlineInputBorder(),
          ),
          validator: (v) {
            final parsed = double.tryParse(
              (v ?? '').replaceAll(',', '').trim(),
            );
            if (parsed == null || !parsed.isFinite || parsed <= 0) {
              return l10n.errorValidPositiveAmount;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final parsed = double.parse(
              _amountCtrl.text.replaceAll(',', '').trim(),
            );
            Navigator.pop(context, parsed);
          },
          child: Text(l10n.record),
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
    final l10n = context.l10n;
    final outstanding = latest?.outstandingTotal ?? 0;
    final dueDate = latest?.dueDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = dueDate == null
        ? null
        : DateTime(dueDate.year, dueDate.month, dueDate.day);
    final overdue = dueDay != null && dueDay.isBefore(today);

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              Color.lerp(cardColor, theme.colorScheme.surface, 0.14)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -28,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fgColor.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        outstanding > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: fgColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        outstanding > 0
                            ? l10n.fulizaOutstanding
                            : l10n.noFulizaBalance,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: fgColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (outstanding > 0) ...[
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AnimatedAmount(
                        value: outstanding,
                        format: CurrencyFormatter.format,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: fgColor,
                        ),
                      ),
                    ),
                    if (dueDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        overdue
                            ? l10n.dueDateOverdue(
                                DateFormat('dd MMM yyyy').format(dueDate),
                              )
                            : l10n.dueDateLabel(
                                DateFormat('dd MMM yyyy').format(dueDate),
                              ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: fgColor,
                          fontWeight:
                              overdue ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                    if (onRecordRepayment != null) ...[
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: onRecordRepayment,
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(l10n.recordRepaymentButton),
                      ),
                    ],
                  ],
                  if (totalFees > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.totalFeesPaid(CurrencyFormatter.format(totalFees)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: fgColor.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
    final l10n = context.l10n;
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
              ? l10n.repaidAmount(CurrencyFormatter.format(displayAmount))
              : CurrencyFormatter.format(displayAmount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.refPrefix(record.mpesaRef)),
            if (!isRepayment || record.accessFee > 0)
              Text(
                l10n.accessFeeRow(CurrencyFormatter.format(record.accessFee)),
              ),
            if (record.dueDate != null)
              Text(
                l10n.dueColonDate(
                  DateFormat('dd MMM yyyy').format(record.dueDate!),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.outstanding,
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.noFulizaUsageRecorded,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.pasteFulizaHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
