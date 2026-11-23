import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/l10n.dart';
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

  Future<void> _confirmMarkPaid(
    BuildContext context,
    RecurringModel item,
  ) async {
    final l10n = context.l10n;
    final result = await showDialog<({double amount, DateTime paidDate})>(
      context: context,
      builder: (_) => _MarkPaidDialog(item: item),
    );

    if (result == null) return;

    await ref.read(recurringRepositoryProvider).markAsPaid(
          item,
          paidDate: result.paidDate,
          actualAmount: result.amount,
        );
    if (mounted) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(l10n.recordedPaymentToast(item.payee)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmSkip(BuildContext context, RecurringModel item) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.skipOccurrenceTitle),
        content: Text(l10n.skipOccurrenceBody(item.payee)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.skip),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recurringRepositoryProvider).skip(item);
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text(l10n.skippedOccurrenceToast(item.payee))),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, RecurringModel item) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecurringTitle),
        content: Text(l10n.deleteRecurringBody(item.payee)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recurringRepositoryProvider).delete(item.id);
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text(l10n.deletedItemToast(item.payee))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final summaryAsync = ref.watch(recurringSummaryProvider);
    final allAsync = ref.watch(allRecurringProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringTitle),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_add_recurring',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditRecurringScreen()),
        ),
        tooltip: l10n.addRecurringTooltip,
        child: const Icon(Icons.add),
      ),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorLabel('$e'))),
        data: (allItems) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final horizon = today.add(const Duration(days: 30));
          final upcomingItems = allItems.where((r) {
            if (!r.isActive) return false;
            final dueDay = DateTime(
              r.nextDueDate.year,
              r.nextDueDate.month,
              r.nextDueDate.day,
            );
            return !dueDay.isAfter(horizon);
          }).toList()
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
                            Text(
                              l10n.monthlyCommitments,
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(color: theme.colorScheme.outline),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: s.overdueCount > 0
                                    ? theme.colorScheme.errorContainer
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.overdueCount > 0
                                    ? l10n.overdueCountBadge(s.overdueCount)
                                    : l10n.activeCountBadge(s.activeCount),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: s.overdueCount > 0
                                      ? theme.colorScheme.onErrorContainer
                                      : theme.colorScheme.onPrimaryContainer,
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
                                Text(
                                  l10n.expensesLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(s.monthlyExpense),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.income,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(s.monthlyIncome),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(l10n.upcomingAndDue),
                    icon: const Icon(Icons.schedule),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(l10n.allSubscriptions),
                    icon: const Icon(Icons.list_alt),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (set) =>
                    setState(() => _selectedTab = set.first),
              ),
              const SizedBox(height: 16),

              // Items List
              if (_selectedTab == 0) ...[
                if (upcomingItems.isEmpty)
                  _buildEmptyState(
                    icon: Icons.check_circle_outline,
                    title: l10n.noUpcomingBillsDue,
                    subtitle: l10n.noUpcomingBillsDueDesc,
                  )
                else
                  ...upcomingItems.map(
                    (item) => _RecurringItemCard(
                      item: item,
                      onMarkPaid: () => _confirmMarkPaid(context, item),
                      onSkip: () => _confirmSkip(context, item),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditRecurringScreen(recurringToEdit: item),
                        ),
                      ),
                      onToggleActive: (val) => ref
                          .read(recurringRepositoryProvider)
                          .toggleActive(item.id, val),
                      onDelete: () => _confirmDelete(context, item),
                    ),
                  ),
              ] else ...[
                if (allItems.isEmpty)
                  _buildEmptyState(
                    icon: Icons.repeat,
                    title: l10n.noRecurringTransactions,
                    subtitle: l10n.noRecurringTransactionsDesc,
                  )
                else
                  ...allItems.map(
                    (item) => _RecurringItemCard(
                      item: item,
                      onMarkPaid: () => _confirmMarkPaid(context, item),
                      onSkip: () => _confirmSkip(context, item),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditRecurringScreen(recurringToEdit: item),
                        ),
                      ),
                      onToggleActive: (val) => ref
                          .read(recurringRepositoryProvider)
                          .toggleActive(item.id, val),
                      onDelete: () => _confirmDelete(context, item),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MarkPaidDialog extends StatefulWidget {
  final RecurringModel item;

  const _MarkPaidDialog({required this.item});

  @override
  State<_MarkPaidDialog> createState() => _MarkPaidDialogState();
}

class _MarkPaidDialogState extends State<_MarkPaidDialog> {
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.item.amount.toStringAsFixed(2),
  );
  final _formKey = GlobalKey<FormState>();
  DateTime _paidDate = DateTime.now();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.recordPaidTitle(widget.item.payee)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recordPaidBody),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amountPaidKes,
                border: const OutlineInputBorder(),
                prefixText: 'KES ',
              ),
              validator: (v) {
                final parsed = double.tryParse(
                  (v ?? '').replaceAll(',', '').trim(),
                );
                if (parsed == null || !parsed.isFinite || parsed <= 0) {
                  return l10n.errorPositiveAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(l10n.paymentDate),
              subtitle: Text(DateFormat('EEE, d MMM yyyy').format(_paidDate)),
              trailing: TextButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _paidDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null && mounted) setState(() => _paidDate = d);
                },
                child: Text(l10n.change),
              ),
            ),
          ],
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
            final actual = double.parse(
              _amountCtrl.text.replaceAll(',', '').trim(),
            );
            Navigator.pop(context, (amount: actual, paidDate: _paidDate));
          },
          child: Text(l10n.confirmPaid),
        ),
      ],
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
    final l10n = context.l10n;
    final isIncome = item.type == 'income';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      item.nextDueDate.year,
      item.nextDueDate.month,
      item.nextDueDate.day,
    );
    final daysUntil = due.difference(today).inDays;

    final (Color badgeBg, Color badgeFg, String badgeText) = switch (daysUntil) {
      < 0 => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
          l10n.overdueByDays(-daysUntil),
        ),
      0 => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
          l10n.dueToday,
        ),
      1 => (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          l10n.dueTomorrow,
        ),
      <= 3 => (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          l10n.dueInDays(daysUntil),
        ),
      _ => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
          DateFormat('d MMM').format(item.nextDueDate)
        ),
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
                      color: isIncome
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward_rounded : Icons.repeat,
                      color: isIncome
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
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
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          RecurrenceEngine.localizedFrequencyLabel(
                            l10n,
                            item.frequency,
                            item.intervalCount,
                          ),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline),
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
                          color: isIncome
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeFg,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      switch (val) {
                        case 'edit':
                          onEdit();
                        case 'toggle':
                          onToggleActive(!item.isActive);
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(item.isActive ? l10n.pause : l10n.resume),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          l10n.delete,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (item.categoryName != null ||
                  item.accountName != null ||
                  item.notes.isNotEmpty) ...[
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
                        avatar: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 14,
                        ),
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
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onSkip,
                      icon: const Icon(Icons.skip_next, size: 16),
                      label: Text(l10n.skip),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onMarkPaid,
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(l10n.markAsPaid),
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
