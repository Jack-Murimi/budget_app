import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/reminder_notification_service.dart';
import '../../../l10n/l10n.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';
import '../../debts/providers/debt_providers.dart';
import '../../fuliza/providers/fuliza_providers.dart';
import '../models/recurring_model.dart';
import '../providers/recurring_providers.dart';
import '../services/recurrence_engine.dart';

class AddEditRecurringScreen extends ConsumerStatefulWidget {
  final RecurringModel? recurringToEdit;

  const AddEditRecurringScreen({super.key, this.recurringToEdit});

  @override
  ConsumerState<AddEditRecurringScreen> createState() =>
      _AddEditRecurringScreenState();
}

class _AddEditRecurringScreenState
    extends ConsumerState<AddEditRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _payeeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _intervalCtrl = TextEditingController(text: '1');

  String _type = 'expense';
  String _frequency = 'monthly';
  DateTime _nextDueDate = DateTime.now();
  DateTime? _endDate;
  int? _selectedAccountId;
  Category? _selectedCategory;
  bool _categoryInitialized = false;
  bool _autoRecord = false;
  bool _notify = true;
  bool _isSaving = false;

  bool get _isEditing => widget.recurringToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.recurringToEdit;
    if (item != null) {
      _payeeCtrl.text = item.payee;
      _amountCtrl.text = item.amount.toStringAsFixed(2);
      _notesCtrl.text = item.notes;
      _intervalCtrl.text = item.intervalCount.toString();
      _type = item.type;
      _frequency = item.frequency;
      _nextDueDate = item.nextDueDate;
      _endDate = item.endDate;
      _selectedAccountId = item.accountId;
      _autoRecord = item.autoRecord;
      _notify = item.notify;
    }
  }

  @override
  void dispose() {
    _payeeCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  Future<void> _syncRemindersAfterSave({required bool requestPermission}) async {
    try {
      final recurring = await ref
          .read(recurringRepositoryProvider)
          .watchAll(includeInactive: true)
          .first;
      final debts = await ref.read(debtRepositoryProvider).watchAll().first;
      final latestFuliza =
          await ref.read(fulizaRepositoryProvider).watchLatest().first;
      await ref.read(reminderNotificationServiceProvider).syncReminders(
            recurring: recurring,
            debts: debts,
            latestFuliza: latestFuliza,
            requestPermission: requestPermission,
          );
    } catch (_) {
      // Non-critical background reminder sync.
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
        if (_endDate != null && _endDate!.isBefore(_nextDueDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _nextDueDate.add(const Duration(days: 365)),
      firstDate: _nextDueDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorValidAmount)),
      );
      return;
    }

    final interval = int.tryParse(_intervalCtrl.text.trim()) ?? 0;
    if (interval < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.intervalAtLeastOne)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = ref.read(recurringRepositoryProvider);

    try {
      if (_isEditing) {
        final current = widget.recurringToEdit!;
        final updated = current.copyWith(
          payee: _payeeCtrl.text.trim(),
          amount: amount,
          type: _type,
          frequency: _frequency,
          intervalCount: interval,
          nextDueDate: _nextDueDate,
          endDate: _endDate,
          clearEndDate: _endDate == null,
          accountId: _selectedAccountId,
          clearAccountId: _selectedAccountId == null,
          categoryId: _selectedCategory?.id,
          clearCategoryId: _selectedCategory == null,
          notes: _notesCtrl.text.trim(),
          autoRecord: _autoRecord,
          notify: _notify,
        );
        await repo.update(updated);
      } else {
        final newRecurring = RecurringModel(
          id: 0,
          payee: _payeeCtrl.text.trim(),
          amount: amount,
          type: _type,
          frequency: _frequency,
          intervalCount: interval,
          startDate: _nextDueDate,
          nextDueDate: _nextDueDate,
          endDate: _endDate,
          accountId: _selectedAccountId,
          categoryId: _selectedCategory?.id,
          notes: _notesCtrl.text.trim(),
          autoRecord: _autoRecord,
          notify: _notify,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.insert(newRecurring);
      }

      unawaited(_syncRemindersAfterSave(requestPermission: _notify));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? l10n.subscriptionUpdated : l10n.recurringBillSaved,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLabel('$e')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final accounts = ref.watch(accountsWithBalanceProvider).asData?.value ?? [];
    final categories = ref.watch(categoriesStreamProvider).asData?.value ?? [];

    // Hydrate category once on edit load so later clearing stays respected.
    if (!_categoryInitialized &&
        widget.recurringToEdit?.categoryId != null &&
        categories.isNotEmpty) {
      _selectedCategory = categories
          .where((c) => c.id == widget.recurringToEdit!.categoryId)
          .firstOrNull;
      _categoryInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editRecurring : l10n.newRecurringAndBill),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Type Selector
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'expense',
                  label: Text(l10n.expense),
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text(l10n.income),
                  icon: const Icon(Icons.arrow_downward_rounded),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() {
                final nextType = set.first;
                _type = nextType;
                if (_selectedCategory != null &&
                    _selectedCategory!.transactionType != nextType) {
                  _selectedCategory = null;
                }
              }),
            ),
            const SizedBox(height: 16),

            // Payee / Name Field
            TextFormField(
              controller: _payeeCtrl,
              decoration: InputDecoration(
                labelText: l10n.payeeSubscriptionRequired,
                hintText: l10n.payeeSubscriptionHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.pleaseEnterName
                  : null,
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.budgetAmountRequired,
                prefixText: 'KES ',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.pleaseEnterAmount;
                }
                final parsed = double.tryParse(v.replaceAll(',', '').trim());
                if (parsed == null || parsed <= 0) {
                  return l10n.errorPositiveAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Frequency and Interval Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.frequency,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.repeat),
                    ),
                    initialValue: _frequency,
                    items: [
                      DropdownMenuItem(value: 'daily', child: Text(l10n.daily)),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text(l10n.weekly),
                      ),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text(l10n.monthly),
                      ),
                      DropdownMenuItem(
                        value: 'yearly',
                        child: Text(l10n.yearly),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _frequency = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _intervalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.interval,
                      hintText: '1',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final parsed = int.tryParse((v ?? '').trim());
                      if (parsed == null || parsed < 1) {
                        return l10n.mustBeAtLeastOne;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Next Due Date & End Date
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(l10n.nextDueDate),
                      subtitle: Text(
                        DateFormat('EEE, d MMM yyyy').format(_nextDueDate),
                      ),
                      trailing: TextButton(
                        onPressed: _pickDueDate,
                        child: Text(l10n.change),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_busy_outlined),
                      title: Text(l10n.endDateOptional),
                      subtitle: Text(
                        _endDate != null
                            ? DateFormat('EEE, d MMM yyyy').format(_endDate!)
                            : l10n.runsIndefinitely,
                      ),
                      trailing: _endDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => setState(() => _endDate = null),
                            )
                          : TextButton(
                              onPressed: _pickEndDate,
                              child: Text(l10n.setEnd),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account and Category Selectors
            DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                labelText: l10n.accountWallet,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
              initialValue: accounts.any((a) => a.id == _selectedAccountId)
                  ? _selectedAccountId
                  : null,
              hint: Text(l10n.defaultAccount),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.defaultAccount),
                ),
                ...accounts.map(
                  (a) => DropdownMenuItem<int?>(
                    value: a.id,
                    child: Text('${a.name} (${a.type.toUpperCase()})'),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _selectedAccountId = v),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.category_outlined),
              label: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedCategory != null
                          ? l10n.categoryWithName(_selectedCategory!.name)
                          : l10n.selectCategory,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (_selectedCategory != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedCategory = null),
                      child: const Icon(Icons.clear, size: 18),
                    ),
                ],
              ),
              onPressed: () async {
                final cat =
                    await showCategoryPicker(context, initialType: _type);
                if (cat != null && mounted) {
                  setState(() => _selectedCategory = cat);
                }
              },
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(l10n.autoRecordWhenDue),
              subtitle: Text(l10n.autoRecordWhenDueDesc),
              value: _autoRecord,
              onChanged: (v) => setState(() => _autoRecord = v),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(l10n.remindBeforeDue),
              subtitle: Text(l10n.remindBeforeDueDesc),
              value: _notify,
              onChanged: (v) => setState(() => _notify = v),
            ),
            const SizedBox(height: 12),

            // Notes field
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.notesOptional,
                hintText: l10n.notesBillingHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Summary description badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.repeatsSummary(
                        RecurrenceEngine.localizedFrequencyLabel(
                          l10n,
                          _frequency,
                          int.tryParse(_intervalCtrl.text) ?? 1,
                        ).toLowerCase(),
                        DateFormat('d MMM yyyy').format(_nextDueDate),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _isEditing ? l10n.saveChanges : l10n.createRecurringItem,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
