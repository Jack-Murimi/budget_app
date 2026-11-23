import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../../debts/widgets/debt_dialogs.dart';
import '../providers/goal_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final goals = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addGoal),
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l10n.unableToLoadGoals('$error'))),
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
        SnackBar(content: Text(context.l10n.savingsGoalSaved)),
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
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return AlertDialog(
      title: Text(_isEditing ? l10n.editSavingsGoal : l10n.addSavingsGoal),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.goalName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.enterGoalName
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.targetKes,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return l10n.enterPositiveTarget;
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
                            ? l10n.addTargetDate
                            : l10n.targetDateLabel(
                                MaterialLocalizations.of(context)
                                    .formatMediumDate(_targetDate!),
                              ),
                      ),
                    ),
                  ),
                  if (_targetDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: l10n.clearTargetDate,
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.save),
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
          SnackBar(content: Text(context.l10n.unableToSaveGoal('$e'))),
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
    final l10n = context.l10n;
    final accounts = ref.watch(accountsWithBalanceProvider).asData?.value ?? [];
    if (!_accountInitialized && accounts.isNotEmpty) {
      _selectedAccountId =
          accounts.where((a) => a.isDefault).firstOrNull?.id ?? accounts.first.id;
      _accountInitialized = true;
    }
    final validAccountValue =
        accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null;

    return AlertDialog(
      title: Text(l10n.addToGoal(widget.goal.name)),
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
                decoration: InputDecoration(
                  labelText: l10n.amountKES,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return l10n.errorPositiveAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: validAccountValue,
                decoration: InputDecoration(
                  labelText: l10n.fromAccountLower,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.noAccountTrackOnly),
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(l10n.add),
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
          SnackBar(
            content: Text(context.l10n.unableToRecordContribution('$e')),
          ),
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
    final l10n = context.l10n;
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining =
        (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    final targetPart = goal.targetDate == null
        ? ''
        : ' · ${l10n.targetDateLabel(MaterialLocalizations.of(context).formatMediumDate(goal.targetDate!))}';

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
                      PopupMenuItem(
                        value: 'history',
                        child: Text(l10n.contributionHistory),
                      ),
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
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
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text(
                l10n.goalAmountProgress(
                  CurrencyFormatter.format(goal.currentAmount),
                  CurrencyFormatter.format(goal.targetAmount),
                ),
              ),
              Text(
                l10n.remainingTarget(
                  CurrencyFormatter.format(remaining),
                  targetPart,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showHistory(context),
                    child: Text(l10n.history),
                  ),
                  TextButton(
                    onPressed: () => _contribute(context),
                    child: Text(l10n.addMoney),
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
        SnackBar(content: Text(context.l10n.addedContributionTo(goal.name))),
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
        SnackBar(content: Text(context.l10n.goalUpdated)),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final res = await showDialog<({bool confirmed, bool deleteLinked})>(
      context: context,
      builder: (_) => ConfirmDeleteWithLinkedTxnsDialog(
        title: l10n.deleteGoalTitle,
        message: l10n.deleteGoalConfirm(goal.name),
      ),
    );
    if (res?.confirmed != true) return;
    await ref.read(goalRepositoryProvider).delete(
          goal.id,
          deleteLinkedTransactions: res!.deleteLinked,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deletedItemToast(goal.name))),
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
    final l10n = context.l10n;
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
              l10n.goalContributionsHeader(goal.name),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            contributionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.unableToLoadContributions('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        l10n.noContributionsYet,
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
                          tooltip: l10n.deleteContributionTooltip,
                          onPressed: () async {
                            final res = await showDialog<
                                ({bool confirmed, bool deleteLinked})>(
                              context: context,
                              builder: (_) =>
                                  ConfirmDeleteWithLinkedTxnsDialog(
                                title: l10n.deleteContributionTitle,
                                message: l10n.deleteContributionConfirm,
                                checkboxLabel: l10n.alsoDeleteLinkedTxn,
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.savings_outlined, size: 56),
            const SizedBox(height: 12),
            Text(l10n.noSavingsGoals),
            const SizedBox(height: 4),
            Text(
              l10n.noSavingsGoalsDesc,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
