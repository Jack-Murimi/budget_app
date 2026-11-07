import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../models/recurring_model.dart';
import '../providers/recurring_providers.dart';
import '../services/recurrence_engine.dart';
import 'add_edit_recurring_screen.dart';

class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  int _selectedTab = 0; // 0 = Upcoming & Due, 1 = All Subscriptions

  Future<void> _confirmMarkPaid(BuildContext context, RecurringModel item) async {
    final amountCtrl = TextEditingController(text: item.amount.toStringAsFixed(2));
    DateTime paidDate = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Record "${item.payee}" as Paid?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This will log a transaction in your ledger and advance the due date to the next cycle.'),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Paid (KES)',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Payment Date'),
                subtitle: Text(DateFormat('EEE, d MMM yyyy').format(paidDate)),
                trailing: TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: paidDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setS(() => paidDate = d);
                  },
                  child: const Text('Change'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm Paid'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final actual = double.tryParse(amountCtrl.text.replaceAll(',', ''));
      await ref.read(recurringRepositoryProvider).markAsPaid(
        item,
        paidDate: paidDate,
        actualAmount: actual,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recorded "${item.payee}" payment ✓'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _confirmSkip(BuildContext context, RecurringModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Skip this occurrence?'),
        content: Text('Skip payment for "${item.payee}"? Next due date will advance to the following cycle without creating a ledger transaction.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Skip')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recurringRepositoryProvider).skip(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Skipped "${item.payee}" occurrence')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, RecurringModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recurring Item?'),
        content: Text('Delete "${item.payee}"? Past recorded transactions will remain in your ledger.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recurringRepositoryProvider).delete(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${item.payee}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(recurringSummaryProvider);
    final allAsync = ref.watch(allRecurringProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring & Bills'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_add_recurring',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditRecurringScreen()),
        ),
        tooltip: 'Add Recurring Bill',
        child: const Icon(Icons.add),
      ),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allItems) {
          final upcomingItems = allItems.where((r) => r.isActive).toList()
            ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              // Summary card
              summaryAsync.when(
                data: (s) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Monthly Commitments', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: s.overdueCount > 0 ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.overdueCount > 0 ? '${s.overdueCount} Overdue' : '${s.activeCount} Active',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: s.overdueCount > 0 ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expenses', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                                Text(
                                  CurrencyFormatter.format(s.monthlyExpense),
                                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Income', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                                Text(
                                  CurrencyFormatter.format(s.monthlyIncome),
                                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Segmented view toggle
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Upcoming & Due'), icon: Icon(Icons.schedule)),
                  ButtonSegment(value: 1, label: Text('All Subscriptions'), icon: Icon(Icons.list_alt)),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (set) => setState(() => _selectedTab = set.first),
              ),
              const SizedBox(height: 16),

              // Items List
              if (_selectedTab == 0) ...[
                if (upcomingItems.isEmpty)
                  _buildEmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'No upcoming bills due',
                    subtitle: 'Add subscriptions or recurring expenses to stay ahead of upcoming payments.',
                  )
                else
                  ...upcomingItems.map((item) => _RecurringItemCard(
                    item: item,
                    onMarkPaid: () => _confirmMarkPaid(context, item),
                    onSkip: () => _confirmSkip(context, item),
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddEditRecurringScreen(recurringToEdit: item)),
                    ),
                    onToggleActive: (val) => ref.read(recurringRepositoryProvider).toggleActive(item.id, val),
                    onDelete: () => _confirmDelete(context, item),
                  )),
              ] else ...[
                if (allItems.isEmpty)
                  _buildEmptyState(
                    icon: Icons.repeat,
                    title: 'No recurring transactions',
                    subtitle: 'Set up recurring bills, salaries, rent, and subscriptions.',
                  )
                else
                  ...allItems.map((item) => _RecurringItemCard(
                    item: item,
                    onMarkPaid: () => _confirmMarkPaid(context, item),
                    onSkip: () => _confirmSkip(context, item),
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddEditRecurringScreen(recurringToEdit: item)),
                    ),
                    onToggleActive: (val) => ref.read(recurringRepositoryProvider).toggleActive(item.id, val),
                    onDelete: () => _confirmDelete(context, item),
                  )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _RecurringItemCard extends StatelessWidget {
  final RecurringModel item;
  final VoidCallback onMarkPaid;
  final VoidCallback onSkip;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onDelete;

  const _RecurringItemCard({
    required this.item,
    required this.onMarkPaid,
    required this.onSkip,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = item.type == 'income';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(item.nextDueDate.year, item.nextDueDate.month, item.nextDueDate.day);
    final daysUntil = due.difference(today).inDays;

    final (Color badgeBg, Color badgeFg, String badgeText) = switch (daysUntil) {
      < 0 => (theme.colorScheme.errorContainer, theme.colorScheme.onErrorContainer, 'Overdue by ${-daysUntil}d'),
      0 => (theme.colorScheme.errorContainer, theme.colorScheme.onErrorContainer, 'Due Today'),
      1 => (Colors.amber.shade100, Colors.amber.shade900, 'Due Tomorrow'),
      <= 3 => (Colors.amber.shade100, Colors.amber.shade900, 'Due in ${daysUntil}d'),
      _ => (theme.colorScheme.surfaceContainerHighest, theme.colorScheme.onSurfaceVariant, DateFormat('d MMM').format(item.nextDueDate)),
    };

    return Opacity(
      opacity: item.isActive ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isIncome ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward_rounded : Icons.repeat,
                      color: isIncome ? theme.colorScheme.primary : theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.payee,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          RecurrenceEngine.frequencyLabel(item.frequency, item.intervalCount),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? theme.colorScheme.primary : theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(color: badgeFg, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      switch (val) {
                        case 'edit': onEdit();
                        case 'toggle': onToggleActive(!item.isActive);
                        case 'delete': onDelete();
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(item.isActive ? 'Pause' : 'Resume'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    ],
                  ),
                ],
              ),
              if (item.categoryName != null || item.accountName != null || item.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.categoryName != null)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(item.categoryName!),
                        padding: EdgeInsets.zero,
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                    if (item.accountName != null)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.account_balance_wallet_outlined, size: 14),
                        label: Text(item.accountName!),
                        padding: EdgeInsets.zero,
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ],
              if (item.isActive) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      onPressed: onSkip,
                      icon: const Icon(Icons.skip_next, size: 16),
                      label: const Text('Skip'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                      onPressed: onMarkPaid,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark as Paid'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
