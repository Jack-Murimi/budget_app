import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../models/debt_model.dart';
import '../providers/debt_providers.dart';

class LoanDetailScreen extends ConsumerWidget {
  final DebtWithRepayments item;

  const LoanDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debtsAsync = ref.watch(debtsProvider);
    final currentItem = debtsAsync.value?.firstWhere(
          (d) => d.debt.id == item.debt.id,
          orElse: () => item,
        ) ??
        item;
    final debt = currentItem.debt;
    final isSettled = currentItem.isSettled;

    final entries = <_TimelineEntry>[];
    for (final d in currentItem.disbursements) {
      final note = d.description.trim().isNotEmpty
          ? d.description.trim()
          : (d.header.startsWith('Loan given') ? '' : d.header);
      entries.add(_TimelineEntry(
        date: d.transactionDate,
        type: 'Loan disbursed',
        amount: d.amount,
        isRepayment: false,
        note: note,
      ));
    }
    for (final r in currentItem.repayments) {
      entries.add(_TimelineEntry(
        date: r.paymentDate,
        type: 'Repayment',
        amount: r.amount,
        isRepayment: true,
      ));
    }
    if (currentItem.disbursements.isEmpty) {
      entries.add(_TimelineEntry(
        date: debt.createdAt,
        type: 'Loan disbursed',
        amount: debt.principal,
        isRepayment: false,
        note: debt.notes,
      ));
    }
    entries.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: Text(debt.counterparty)),
      floatingActionButton: isSettled
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _repay(context, ref, debt),
              icon: const Icon(Icons.payment),
              label: const Text('Record repayment'),
            ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              'Total lent',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(debt.principal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                              'Repaid',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(currentItem.repaid),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Outstanding',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(debt.outstanding),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSettled ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Timeline',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No transaction history')),
            )
          else
            ...entries.map((entry) => _TimelineCard(entry: entry)),
        ],
      ),
    );
  }

  Future<void> _repay(BuildContext context, WidgetRef ref, Debt debt) async {
    final amount = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Repay ${debt.counterparty}'),
        content: TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText:
                'Amount, max ${CurrencyFormatter.format(debt.outstanding)}',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(amount.text);
              if (value == null) {
                return;
              }
              final account =
                  await ref.read(accountRepositoryProvider).getDefaultAccount();
              try {
                await ref
                    .read(debtRepositoryProvider)
                    .repay(debt: debt, amount: value, accountId: account?.id);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } on ArgumentError {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Enter an amount up to the outstanding balance'),
                  ),
                );
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  final DateTime date;
  final String type;
  final double amount;
  final bool isRepayment;
  final String note;

  const _TimelineEntry({
    required this.date,
    required this.type,
    required this.amount,
    required this.isRepayment,
    this.note = '',
  });
}

class _TimelineCard extends StatelessWidget {
  final _TimelineEntry entry;

  const _TimelineCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRepayment = entry.isRepayment;
    final color = isRepayment ? Colors.green : Colors.orange;

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
              backgroundColor: color.withAlpha(25),
              child: Icon(
                isRepayment ? Icons.south_west : Icons.north_east,
                color: color,
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
                color: isRepayment ? Colors.green : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
