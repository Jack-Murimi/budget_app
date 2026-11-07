import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';
import '../models/recurring_model.dart';
import '../providers/recurring_providers.dart';
import '../services/recurrence_engine.dart';

class AddEditRecurringScreen extends ConsumerStatefulWidget {
  final RecurringModel? recurringToEdit;

  const AddEditRecurringScreen({super.key, this.recurringToEdit});

  @override
  ConsumerState<AddEditRecurringScreen> createState() => _AddEditRecurringScreenState();
}

class _AddEditRecurringScreenState extends ConsumerState<AddEditRecurringScreen> {
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
  bool _autoRecord = false;
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

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _nextDueDate = picked);
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

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final interval = int.tryParse(_intervalCtrl.text) ?? 1;

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
          accountId: _selectedAccountId,
          categoryId: _selectedCategory?.id ?? current.categoryId,
          notes: _notesCtrl.text.trim(),
          autoRecord: _autoRecord,
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
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.insert(newRecurring);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Subscription updated' : 'Recurring bill saved'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsWithBalanceProvider).asData?.value ?? [];
    final categories = ref.watch(categoriesStreamProvider).asData?.value ?? [];

    // Resolve category if editing and not selected yet
    if (_selectedCategory == null && widget.recurringToEdit?.categoryId != null) {
      _selectedCategory = categories.where((c) => c.id == widget.recurringToEdit!.categoryId).firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recurring' : 'New Recurring & Bill'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_upward_rounded)),
                ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_downward_rounded)),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 16),

            // Payee / Name Field
            TextFormField(
              controller: _payeeCtrl,
              decoration: const InputDecoration(
                labelText: 'Payee / Subscription Name *',
                hintText: 'e.g., Netflix, Home Internet, Rent, Salary',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (KES) *',
                prefixText: 'KES ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter amount';
                if (double.tryParse(v.replaceAll(',', '')) == null) return 'Invalid number';
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
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    value: _frequency,
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
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
                    decoration: const InputDecoration(
                      labelText: 'Interval',
                      hintText: '1',
                      border: OutlineInputBorder(),
                    ),
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
                      title: const Text('Next Due Date'),
                      subtitle: Text(DateFormat('EEE, d MMM yyyy').format(_nextDueDate)),
                      trailing: TextButton(
                        onPressed: _pickDueDate,
                        child: const Text('Change'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_busy_outlined),
                      title: const Text('End Date (Optional)'),
                      subtitle: Text(_endDate != null
                          ? DateFormat('EEE, d MMM yyyy').format(_endDate!)
                          : 'Runs indefinitely'),
                      trailing: _endDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => setState(() => _endDate = null),
                            )
                          : TextButton(
                              onPressed: _pickEndDate,
                              child: const Text('Set End'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account and Category Selectors
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Account / Wallet',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              value: accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
              hint: const Text('Default Account'),
              items: accounts.map((a) => DropdownMenuItem(
                value: a.id,
                child: Text('${a.name} (${a.type.toUpperCase()})'),
              )).toList(),
              onChanged: (v) => setState(() => _selectedAccountId = v),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.category_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedCategory != null ? 'Category: ${_selectedCategory!.name}' : 'Select Category',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              onPressed: () async {
                final cat = await showCategoryPicker(context);
                if (cat != null) setState(() => _selectedCategory = cat);
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Account number, billing notes, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Summary description badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Repeats ${RecurrenceEngine.frequencyLabel(_frequency, int.tryParse(_intervalCtrl.text) ?? 1).toLowerCase()}, starting ${DateFormat('d MMM yyyy').format(_nextDueDate)}.',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(_isEditing ? 'Save Changes' : 'Create Recurring Item'),
            ),
          ],
        ),
      ),
    );
  }
}
