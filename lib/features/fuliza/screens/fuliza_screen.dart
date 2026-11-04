import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../providers/fuliza_providers.dart';

class FulizaScreen extends ConsumerWidget {
  const FulizaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestFulizaProvider);
    final recordsAsync = ref.watch(fulizaRecordsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fuliza M-PESA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Outstanding balance card
          latestAsync.when(
            data: (latest) => _OutstandingCard(latest: latest),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          // History
          Text('Fuliza Usage History', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          recordsAsync.when(
            data: (records) => records.isEmpty
                ? const _EmptyFuliza()
                : Column(
                    children: records.map((r) => _FulizaListItem(record: r)).toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  final FulizaRecord? latest;
  const _OutstandingCard({this.latest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outstanding = latest?.outstandingTotal ?? 0;
    final dueDate = latest?.dueDate;
    final overdue = dueDate != null && dueDate.isBefore(DateTime.now());

    return Card(
      color: outstanding > 0
          ? (overdue ? theme.colorScheme.errorContainer : Colors.orange.shade50)
          : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  outstanding > 0 ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: outstanding > 0
                      ? (overdue ? theme.colorScheme.error : Colors.orange.shade700)
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  outstanding > 0 ? 'Fuliza Outstanding' : 'No Fuliza Balance',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            if (outstanding > 0) ...[
              const SizedBox(height: 12),
              Text(
                CurrencyFormatter.format(outstanding),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: overdue ? theme.colorScheme.error : Colors.orange.shade800,
                ),
              ),
              if (dueDate != null)
                Text(
                  'Due ${DateFormat('dd MMM yyyy').format(dueDate)}${overdue ? ' — OVERDUE' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: overdue ? theme.colorScheme.error : Colors.orange.shade700,
                    fontWeight: overdue ? FontWeight.bold : FontWeight.normal,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.sync, color: Colors.orange.shade700),
        ),
        title: Text(
          CurrencyFormatter.format(record.fulizaAmount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ref: ${record.mpesaRef}'),
            Text('Access fee: ${CurrencyFormatter.format(record.accessFee)}'),
            if (record.dueDate != null)
              Text('Due: ${DateFormat('dd MMM yyyy').format(record.dueDate!)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Outstanding',
              style: theme.textTheme.labelSmall,
            ),
            Text(
              CurrencyFormatter.format(record.outstandingTotal),
              style: TextStyle(
                color: Colors.orange.shade700,
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
          Icon(Icons.check_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('No Fuliza usage recorded', style: Theme.of(context).textTheme.titleMedium),
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
