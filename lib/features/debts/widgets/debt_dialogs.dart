import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../providers/debt_providers.dart';

class CreateEditDebtDialog extends ConsumerStatefulWidget {
  final Debt? debtToEdit;
  final String? initialDirection;

  const CreateEditDebtDialog({
    super.key,
    this.debtToEdit,
    this.initialDirection,
  });

  @override
  ConsumerState<CreateEditDebtDialog> createState() =>
      _CreateEditDebtDialogState();
}

class _CreateEditDebtDialogState extends ConsumerState<CreateEditDebtDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.debtToEdit?.counterparty ?? '',
  );
  late final TextEditingController _principalCtrl = TextEditingController(
    text: widget.debtToEdit != null
        ? widget.debtToEdit!.principal.toStringAsFixed(2)
        : '',
  );
  late final TextEditingController _interestCtrl = TextEditingController(
    text: widget.debtToEdit != null
        ? widget.debtToEdit!.interest.toStringAsFixed(2)
        : '0',
  );
  late final TextEditingController _actualCreditedCtrl = TextEditingController(
    text: widget.debtToEdit != null && widget.debtToEdit!.disbursementShortfall > 0
        ? (widget.debtToEdit!.principal -
                widget.debtToEdit!.disbursementShortfall)
            .toStringAsFixed(2)
        : '',
  );
  late final TextEditingController _notesCtrl = TextEditingController(
    text: widget.debtToEdit?.notes ?? '',
  );

  late String _selectedDirection =
      widget.debtToEdit?.direction ?? widget.initialDirection ?? 'borrowed';
  late String _product = widget.debtToEdit?.product ?? 'personal';
  late DateTime? _dueDate = widget.debtToEdit?.dueDate;
  int? _selectedAccountId;
  bool _accountInitialized = false;
  bool _isSaving = false;

  bool get _isEditing => widget.debtToEdit != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _principalCtrl.dispose();
    _interestCtrl.dispose();
    _actualCreditedCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsWithBalanceProvider).asData?.value ?? [];
    if (!_isEditing && !_accountInitialized && accounts.isNotEmpty) {
      _selectedAccountId =
          accounts.where((a) => a.isDefault).firstOrNull?.id ?? accounts.first.id;
      _accountInitialized = true;
    }
    final validAccountValue =
        accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null;

    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Edit debt'
            : (_selectedDirection == 'lent' ? 'Add loan given' : 'Add debt'),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: _selectedDirection == 'lent'
                      ? 'Person (borrower)'
                      : 'Person or lender',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 12),
              if (!_isEditing && widget.initialDirection == null) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedDirection,
                  decoration: const InputDecoration(
                    labelText: 'Direction',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'borrowed',
                      child: Text('I borrowed'),
                    ),
                    DropdownMenuItem(value: 'lent', child: Text('I lent')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedDirection = value);
                  },
                ),
                const SizedBox(height: 12),
              ],
              DropdownButtonFormField<String>(
                initialValue: const [
                  'personal',
                  'mshwari',
                  'fuliza',
                  'hustler_fund',
                  'bridge',
                ].contains(_product)
                    ? _product
                    : 'personal',
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'personal', child: Text('Personal')),
                  DropdownMenuItem(value: 'mshwari', child: Text('M-Shwari')),
                  DropdownMenuItem(value: 'fuliza', child: Text('Fuliza')),
                  DropdownMenuItem(
                    value: 'hustler_fund',
                    child: Text('Hustler Fund'),
                  ),
                  DropdownMenuItem(value: 'bridge', child: Text('Bridge')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _product = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _principalCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Principal (KES)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive principal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (_product == 'bridge') ...[
                TextFormField(
                  controller: _actualCreditedCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Actual amount credited (KES)',
                    helperText:
                        'e.g. borrow 600 but only 570 hits your M-Pesa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _interestCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total interest/repayment extra (KES)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final parsed = double.tryParse(v.replaceAll(',', '').trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter 0 or more';
                  }
                  return null;
                },
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: validAccountValue,
                  decoration: const InputDecoration(
                    labelText: 'Account',
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: _dueDate ?? DateTime.now(),
                        );
                        if (picked != null && mounted) {
                          setState(() => _dueDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        _dueDate == null
                            ? 'Add due date'
                            : 'Due ${_dueDate!.toLocal().toString().split(' ').first}',
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Clear due date',
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
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
        double.parse(_principalCtrl.text.replaceAll(',', '').trim());
    final fee =
        double.tryParse(_interestCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final credited =
        double.tryParse(_actualCreditedCtrl.text.replaceAll(',', '').trim());
    final shortfall =
        (_product == 'bridge' && credited != null && credited < amount)
            ? amount - credited
            : 0.0;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(debtRepositoryProvider);
      if (_isEditing) {
        await repo.updateDebt(
          id: widget.debtToEdit!.id,
          counterparty: _nameCtrl.text.trim(),
          product: _product,
          principal: amount,
          interest: fee,
          disbursementShortfall: shortfall,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          notes: _notesCtrl.text.trim(),
        );
      } else {
        await repo.create(
          direction: _selectedDirection,
          counterparty: _nameCtrl.text.trim(),
          principal: amount,
          interest: fee,
          product: _product,
          disbursementShortfall: shortfall,
          accountId: _selectedAccountId,
          dueDate: _dueDate,
          notes: _notesCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save debt: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}

class RecordRepaymentDialog extends ConsumerStatefulWidget {
  final Debt debt;

  const RecordRepaymentDialog({super.key, required this.debt});

  @override
  ConsumerState<RecordRepaymentDialog> createState() =>
      _RecordRepaymentDialogState();
}

class _RecordRepaymentDialogState extends ConsumerState<RecordRepaymentDialog> {
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
    final isBorrowed = widget.debt.direction == 'borrowed';

    return AlertDialog(
      title: Text('Repay ${widget.debt.counterparty}'),
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
                  labelText:
                      'Amount, max ${CurrencyFormatter.format(widget.debt.outstanding)}',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse((v ?? '').replaceAll(',', '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid positive amount';
                  }
                  if (!isBorrowed &&
                      CentsConverter.toCents(parsed) >
                          CentsConverter.toCents(widget.debt.outstanding)) {
                    return 'Enter an amount up to the outstanding balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: validAccountValue,
                decoration: InputDecoration(
                  labelText: isBorrowed ? 'Pay from account' : 'Receive into account',
                  border: const OutlineInputBorder(),
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
          child: const Text('Record'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final value = double.parse(_amountCtrl.text.replaceAll(',', '').trim());

    setState(() => _isSaving = true);
    try {
      await ref.read(debtRepositoryProvider).repay(
            debt: widget.debt,
            amount: value,
            accountId: _selectedAccountId,
          );
      if (mounted) Navigator.pop(context, true);
    } on ArgumentError {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter an amount up to the outstanding balance'),
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}

class ConfirmDeleteWithLinkedTxnsDialog extends StatefulWidget {
  final String title;
  final String message;
  final String checkboxLabel;

  const ConfirmDeleteWithLinkedTxnsDialog({
    super.key,
    required this.title,
    required this.message,
    this.checkboxLabel = 'Also delete linked ledger transactions',
  });

  @override
  State<ConfirmDeleteWithLinkedTxnsDialog> createState() =>
      _ConfirmDeleteWithLinkedTxnsDialogState();
}

class _ConfirmDeleteWithLinkedTxnsDialogState
    extends State<ConfirmDeleteWithLinkedTxnsDialog> {
  bool _deleteLinked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _deleteLinked,
            onChanged: (v) => setState(() => _deleteLinked = v ?? false),
            title: Text(
              widget.checkboxLabel,
              style: theme.textTheme.bodyMedium,
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(
            context,
            (confirmed: true, deleteLinked: _deleteLinked),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
