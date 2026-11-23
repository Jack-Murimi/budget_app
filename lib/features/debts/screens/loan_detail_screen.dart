import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/motion.dart';
import '../models/debt_model.dart';
import '../providers/debt_providers.dart';
import '../widgets/debt_dialogs.dart';

class LoanDetailScreen extends ConsumerWidget {
  final DebtWithRepayments item;

  const LoanDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final debtsAsync = ref.watch(debtsProvider);
    final currentItem = debtsAsync.value?.firstWhere(
          (d) => d.debt.id == item.debt.id,
          orElse: () => item,
        ) ??
        item;
    final debt = currentItem.debt;
    final isSettled = currentItem.isSettled;
    final isBorrowed = debt.direction == 'borrowed';
    final disbursementLabel =
        isBorrowed ? l10n.loanReceivedLabel : l10n.loanDisbursedLabel;

    final entries = <_TimelineEntry>[];
    for (final d in currentItem.disbursements) {
      final note = d.description.trim().isNotEmpty
          ? d.description.trim()
          : ((d.header.startsWith('Loan given') ||
                  d.header.startsWith('Loan received'))
              ? ''
              : d.header);
      entries.add(
        _TimelineEntry(
          date: d.transactionDate,
          type: disbursementLabel,
          amount: d.amount,
          isRepayment: false,
          isBorrowed: isBorrowed,
          note: note,
        ),
      );
    }
    for (final r in currentItem.repayments) {
      entries.add(
        _TimelineEntry(
          date: r.paymentDate,
          type: l10n.repaymentLabel,
          amount: r.amount,
          isRepayment: true,
          isBorrowed: isBorrowed,
          repayment: r,
        ),
      );
    }
    if (currentItem.disbursements.isEmpty) {
      entries.add(
        _TimelineEntry(
          date: debt.createdAt,
          type: disbursementLabel,
          amount: debt.principal,
          isRepayment: false,
          isBorrowed: isBorrowed,
          note: debt.notes,
        ),
      );
    }
    entries.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(debt.counterparty),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editDebtTooltip,
            onPressed: () => _editDebt(context, debt),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteDebtTooltip,
            onPressed: () => _deleteDebt(context, ref, debt),
          ),
        ],
      ),
      floatingActionButton: isSettled
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _repay(context, debt),
              icon: const Icon(Icons.payment),
              label: Text(l10n.recordRepayment),
            ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          FadeSlideIn(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBorrowed
                                    ? l10n.totalBorrowed
                                    : l10n.totalLent,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(debt.principal),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.repaid,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(currentItem.repaid),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (debt.interest > 0 || debt.dueDate != null) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          if (debt.interest > 0)
                            Text(
                              l10n.interestFeesLabel(
                                CurrencyFormatter.format(debt.interest),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          if (debt.dueDate != null)
                            Text(
                              l10n.dueColonDate(
                                DateFormatter.formatDate(debt.dueDate!),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.outstanding,
                          style: theme.textTheme.titleSmall,
                        ),
                        AnimatedAmount(
                          value: debt.outstanding,
                          format: CurrencyFormatter.format,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSettled
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l10n.timeline,
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.noTransactionHistory)),
            )
          else
            for (final (i, entry) in entries.indexed)
              FadeSlideIn(
                index: i + 1,
                dy: 10,
                child: _TimelineCard(
                  entry: entry,
                  onDeleteRepayment: entry.repayment == null
                      ? null
                      : () => _deleteRepayment(
                            context,
                            ref,
                            entry.repayment!,
                          ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _repay(BuildContext context, Debt debt) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => RecordRepaymentDialog(debt: debt),
    );
  }

  Future<void> _editDebt(BuildContext context, Debt debt) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => CreateEditDebtDialog(debtToEdit: debt),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.debtUpdated)),
      );
    }
  }

  Future<void> _deleteDebt(
    BuildContext context,
    WidgetRef ref,
    Debt debt,
  ) async {
    final l10n = context.l10n;
    final res = await showDialog<({bool confirmed, bool deleteLinked})>(
      context: context,
      builder: (_) => ConfirmDeleteWithLinkedTxnsDialog(
        title: l10n.deleteDebtTitle,
        message: l10n.deleteDebtConfirm(debt.counterparty),
      ),
    );
    if (res?.confirmed != true) return;
    await ref.read(debtRepositoryProvider).deleteDebt(
          debt.id,
          deleteLinkedTransactions: res!.deleteLinked,
        );
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deletedItemToast(debt.counterparty))),
      );
    }
  }

  Future<void> _deleteRepayment(
    BuildContext context,
    WidgetRef ref,
    DebtRepayment repayment,
  ) async {
    final l10n = context.l10n;
    final res = await showDialog<({bool confirmed, bool deleteLinked})>(
      context: context,
      builder: (_) => ConfirmDeleteWithLinkedTxnsDialog(
        title: l10n.deleteRepaymentTitle,
        message: l10n.deleteRepaymentConfirm(
          CurrencyFormatter.format(repayment.amount),
        ),
        checkboxLabel: l10n.alsoDeleteLinkedTxn,
      ),
    );
    if (res?.confirmed != true) return;
    await ref.read(debtRepositoryProvider).deleteRepayment(
          repayment.id,
          deleteLinkedTransaction: res!.deleteLinked,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.repaymentDeleted)),
      );
    }
  }
}

class _TimelineEntry {
  final DateTime date;
  final String type;
  final double amount;
  final bool isRepayment;
  final bool isBorrowed;
  final String note;
  final DebtRepayment? repayment;

  const _TimelineEntry({
    required this.date,
    required this.type,
    required this.amount,
    required this.isRepayment,
    required this.isBorrowed,
    this.note = '',
    this.repayment,
  });
}

class _TimelineCard extends StatelessWidget {
  final _TimelineEntry entry;
  final VoidCallback? onDeleteRepayment;

  const _TimelineCard({
    required this.entry,
    this.onDeleteRepayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRepayment = entry.isRepayment;
    final color = isRepayment
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;
    final containerBg = isRepayment
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.tertiaryContainer;
    final containerFg = isRepayment
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onTertiaryContainer;
    final iconData = isRepayment
        ? (entry.isBorrowed ? Icons.north_east : Icons.south_west)
        : (entry.isBorrowed ? Icons.south_west : Icons.north_east);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: containerBg,
              child: Icon(
                iconData,
                color: containerFg,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.type,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatDate(entry.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.note,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${isRepayment ? '-' : '+'} ${CurrencyFormatter.format(entry.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isRepayment ? color : null,
              ),
            ),
            if (onDeleteRepayment != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                tooltip: context.l10n.deleteRepaymentTooltip,
                onPressed: onDeleteRepayment,
              ),
          ],
        ),
      ),
    );
  }
}
