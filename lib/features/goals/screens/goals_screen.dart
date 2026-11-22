import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../../debts/widgets/debt_dialogs.dart';
import '../providers/goal_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Savings goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add goal'),
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load goals: $error')),
        data: (items) => items.isEmpty
            ? const _EmptyGoals()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (_, index) => _GoalCard(goal: items[index]),
              ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateEditGoalDialog(),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings goal saved')),
      );
    }
  }
}

class _CreateEditGoalDialog extends ConsumerStatefulWidget {
  final SavingsGoal? existing;

  const _CreateEditGoalDialog({this.existing});

  @override
  ConsumerState<_CreateEditGoalDialog> createState() =>
      _CreateEditGoalDialogState();
}

class _CreateEditGoalDialogState extends ConsumerState<_CreateEditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _targetCtrl = TextEditingController(
    text: widget.existing != null
        ? widget.existing!.targetAmount.toStringAsFixed(2)
        : '',
  );
  late DateTime? _targetDate = widget.existing?.targetDate;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return AlertDialog(
      title: Text(_isEditing ? 'Edit savings goal' : 'Add savings goal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Goal name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a goal name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target (KES)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive target amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _targetDate ?? today,
                          firstDate: today,
                          lastDate: DateTime(today.year + 50),
                        );
                        if (picked != null && mounted) {
                          setState(() => _targetDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        _targetDate == null
                            ? 'Add target date'
                            : 'Target ${MaterialLocalizations.of(context).formatMediumDate(_targetDate!)}',
                      ),
                    ),
                  ),
                  if (_targetDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Clear target date',
                      onPressed: () => setState(() => _targetDate = null),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.parse(_targetCtrl.text.replaceAll(',', '').trim());
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(goalRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          id: widget.existing!.id,
          name: _nameCtrl.text,
          targetAmount: amount,
          targetDate: _targetDate,
          clearTargetDate: _targetDate == null,
        );
      } else {
        await repo.create(
          name: _nameCtrl.text,
          targetAmount: amount,
          targetDate: _targetDate,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save goal: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ContributeGoalDialog extends ConsumerStatefulWidget {
  final SavingsGoal goal;

  const _ContributeGoalDialog({required this.goal});

  @override
  ConsumerState<_ContributeGoalDialog> createState() =>
      _ContributeGoalDialogState();
}

class _ContributeGoalDialogState extends ConsumerState<_ContributeGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  int? _selectedAccountId;
  bool _accountInitialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsWithBalanceProvider).asData?.value ?? [];
    if (!_accountInitialized && accounts.isNotEmpty) {
      _selectedAccountId =
          accounts.where((a) => a.isDefault).firstOrNull?.id ?? accounts.first.id;
      _accountInitialized = true;
    }
    final validAccountValue =
        accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null;

    return AlertDialog(
      title: Text('Add to ${widget.goal.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (KES)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: validAccountValue,
                decoration: const InputDecoration(
                  labelText: 'From account',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No account (track only)'),
                  ),
                  ...accounts.map(
                    (a) => DropdownMenuItem<int?>(
                      value: a.id,
                      child: Text(a.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedAccountId = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final value = double.parse(_amountCtrl.text.replaceAll(',', '').trim());
    setState(() => _isSaving = true);
    try {
      await ref.read(goalRepositoryProvider).contribute(
            goalId: widget.goal.id,
            amount: value,
            accountId: _selectedAccountId,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to record contribution: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});
  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining =
        (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showHistory(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(goal.name, style: theme.textTheme.titleMedium),
                  ),
                  Text('${(progress * 100).round()}%'),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'history':
                          _showHistory(context);
                        case 'edit':
                          _edit(context);
                        case 'delete':
                          _delete(context, ref);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'history',
                        child: Text('Contribution history'),
                      ),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text(
                '${CurrencyFormatter.format(goal.currentAmount)} of ${CurrencyFormatter.format(goal.targetAmount)}',
              ),
              Text(
                'Remaining ${CurrencyFormatter.format(remaining)}${goal.targetDate == null ? '' : ' · Target ${MaterialLocalizations.of(context).formatMediumDate(goal.targetDate!)}'}',
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showHistory(context),
                    child: const Text('History'),
                  ),
                  TextButton(
                    onPressed: () => _contribute(context),
                    child: const Text('Add money'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _contribute(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ContributeGoalDialog(goal: goal),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added contribution to ${goal.name}')),
      );
    }
  }

  Future<void> _edit(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _CreateEditGoalDialog(existing: goal),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal updated')),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final res = await showDialog<({bool confirmed, bool deleteLinked})>(
      context: context,
      builder: (_) => ConfirmDeleteWithLinkedTxnsDialog(
        title: 'Delete goal',
        message: 'Delete "${goal.name}" and its contribution history?',
      ),
    );
    if (res?.confirmed != true) return;
    await ref.read(goalRepositoryProvider).delete(
          goal.id,
          deleteLinkedTransactions: res!.deleteLinked,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${goal.name}"')),
      );
    }
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GoalContributionsSheet(goal: goal),
    );
  }
}

class _GoalContributionsSheet extends ConsumerWidget {
  final SavingsGoal goal;

  const _GoalContributionsSheet({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final contributionsAsync = ref.watch(goalContributionsProvider(goal.id));
    final accounts = ref.watch(allAccountsWithBalanceProvider).valueOrNull ?? [];
    final accountNames = {for (final a in accounts) a.id: a.name};

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${goal.name} · Contributions',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            contributionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Unable to load contributions: $e'),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No contributions recorded yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 340),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final c = items[index];
                      final acctName = c.accountId != null
                          ? accountNames[c.accountId]
                          : null;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.savings_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 18,
                          ),
                        ),
                        title: Text(CurrencyFormatter.format(c.amount)),
                        subtitle: Text(
                          [
                            DateFormatter.formatDate(c.contributionDate),
                            if (acctName != null) acctName,
                          ].join(' · '),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.outline,
                          ),
                          tooltip: 'Delete contribution',
                          onPressed: () async {
                            final res = await showDialog<
                                ({bool confirmed, bool deleteLinked})>(
                              context: context,
                              builder: (_) =>
                                  const ConfirmDeleteWithLinkedTxnsDialog(
                                title: 'Delete contribution',
                                message:
                                    'Remove this contribution from the goal total?',
                                checkboxLabel:
                                    'Also delete linked ledger transaction',
                              ),
                            );
                            if (res?.confirmed != true) return;
                            await ref
                                .read(goalRepositoryProvider)
                                .deleteContribution(
                                  c.id,
                                  deleteLinkedTransaction: res!.deleteLinked,
                                );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.savings_outlined, size: 56),
              SizedBox(height: 12),
              Text('No savings goals'),
              SizedBox(height: 4),
              Text(
                'Set a target, then allocate money from an account.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
