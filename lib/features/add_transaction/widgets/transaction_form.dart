import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/widgets/category_picker.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../main.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final MpesaParseResult? parseResult;
  final TransactionModel? transactionToEdit;
  const TransactionForm({super.key, this.parseResult, this.transactionToEdit});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _headerCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _costCtrl;
  late DateTime _date;
  Category? _selectedCategory;
  String _type = 'expense';
  int? _selectedAccountId;
  int? _selectedToAccountId;
  bool _excludeFromBudget = false;

  @override
  void initState() {
    super.initState();
    final p = widget.parseResult;
    final edit = widget.transactionToEdit;
    
    if (edit != null) {
      _headerCtrl = TextEditingController(text: edit.header);
      _descCtrl = TextEditingController(text: edit.description);
      _amountCtrl = TextEditingController(text: edit.amount.toStringAsFixed(2));
      _costCtrl = TextEditingController(text: edit.transactionCost > 0 ? edit.transactionCost.toStringAsFixed(2) : '');
      _date = edit.transactionDate;
      _type = edit.type;
      _selectedAccountId = edit.accountId;
      _selectedToAccountId = edit.toAccountId;
      _excludeFromBudget = edit.excludeFromBudget;
      _loadCategoryForEdit(edit.categoryId);
    } else {
      _headerCtrl = TextEditingController(); // NEVER auto-filled
      _descCtrl = TextEditingController(text: p?.counterpartyName ?? '');
      _amountCtrl = TextEditingController(
        text: p != null ? p.amount.toStringAsFixed(2) : '',
      );
      _costCtrl = TextEditingController(
        text: p != null && p.transactionCost > 0 ? p.transactionCost.toStringAsFixed(2) : '',
      );
      _date = p?.transactionDate ?? DateTime.now();
      _type = p?.type.transactionType ?? 'expense';
    }
  }

  Future<void> _loadCategoryForEdit(int? categoryId) async {
    if (categoryId == null) return;
    final db = ref.read(dbProvider);
    final cat = await (db.select(db.categories)..where((c) => c.id.equals(categoryId))).getSingleOrNull();
    if (cat != null && mounted) {
      setState(() => _selectedCategory = cat);
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _date.hour, minute: _date.minute),
    );
    if (!mounted) return;
    setState(() => _date = DateTime(
      d.year, d.month, d.day,
      t?.hour ?? _date.hour,
      t?.minute ?? _date.minute,
    ));
  }

  Future<void> _pickCategory() async {
    final cat = await showCategoryPicker(context);
    if (cat != null) setState(() => _selectedCategory = cat);
  }

  Widget _buildAccountSelector(ThemeData theme) {
    final accounts = ref.watch(accountsWithBalanceProvider).value ?? [];

    if (accounts.isEmpty) {
      return const Text('No accounts available', style: TextStyle(color: Colors.red));
    }

    final defaultAccount = accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull;
    _selectedAccountId ??= defaultAccount?.id;

    final fromVal = accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null;
    final toVal = accounts.any((a) => a.id == _selectedToAccountId) ? _selectedToAccountId : null;

    if (_type == 'transfer') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'From Account *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.arrow_left),
            ),
            value: fromVal,
            hint: const Text('Select source account'),
            items: accounts.map((a) => DropdownMenuItem(
              value: a.id,
              child: Text('${a.name} (KES ${a.balance.toStringAsFixed(2)})'),
            )).toList(),
            onChanged: (v) => setState(() => _selectedAccountId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'To Account *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.arrow_right),
            ),
            value: toVal,
            hint: const Text('Select destination account'),
            items: accounts.map((a) => DropdownMenuItem(
              value: a.id,
              child: Text('${a.name} (KES ${a.balance.toStringAsFixed(2)})'),
            )).toList(),
            onChanged: (v) => setState(() => _selectedToAccountId = v),
          ),
        ],
      );
    } else {
      return DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Account / Wallet *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
        ),
        value: fromVal,
        hint: const Text('Select account'),
        items: accounts.map((a) => DropdownMenuItem(
          value: a.id,
          child: Text('${a.name} (KES ${a.balance.toStringAsFixed(2)})'),
        )).toList(),
        onChanged: (v) => setState(() => _selectedAccountId = v),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.parseResult != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Date, time, amount & description auto-filled from M-Pesa',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          if ((widget.parseResult?.fulizaAmount ?? 0) > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fuliza used: KES ${widget.parseResult!.fulizaAmount.toStringAsFixed(2)} (fee: KES ${widget.parseResult!.fulizaAccessFee.toStringAsFixed(2)})',
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Type toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_upward_rounded)),
              ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_downward_rounded)),
              ButtonSegment(value: 'transfer', label: Text('Transfer'), icon: Icon(Icons.swap_horiz)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),

          // Header — ALWAYS manual, never auto-filled
          TextFormField(
            controller: _headerCtrl,
            decoration: const InputDecoration(
              labelText: 'Header *',
              hintText: 'e.g. Groceries at Naivas',
              helperText: 'Your custom label for this transaction',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Header is required' : null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Amount
          TextFormField(
            controller: _amountCtrl,
            decoration: InputDecoration(
              labelText: 'Amount (KES) *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.payments_outlined),
              suffixIcon: widget.parseResult != null
                  ? const Tooltip(message: 'Auto-filled from M-Pesa', child: Icon(Icons.auto_awesome, size: 16))
                  : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Amount is required';
              if (double.tryParse(v) == null) return 'Enter a valid number';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descCtrl,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Counterparty or note',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: widget.parseResult != null
                  ? const Tooltip(message: 'Auto-filled from M-Pesa', child: Icon(Icons.auto_awesome, size: 16))
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Transaction cost (only shown for parsed M-Pesa)
          if (widget.parseResult != null) ...[
            TextFormField(
              controller: _costCtrl,
              decoration: const InputDecoration(
                labelText: 'Transaction Cost (KES)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off_outlined),
                helperText: 'M-Pesa charge for this transaction',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
          ],

          // Date & Time
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date & Time',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: widget.parseResult != null
                    ? const Tooltip(message: 'Auto-filled from M-Pesa', child: Icon(Icons.auto_awesome, size: 16))
                    : const Icon(Icons.edit),
              ),
              child: Text(DateFormatter.formatDateTime(_date)),
            ),
          ),
          const SizedBox(height: 16),

          // Category — always manual, never auto-filled
          InkWell(
            onTap: _pickCategory,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
                suffixIcon: Icon(Icons.chevron_right),
              ),
              child: Text(
                _selectedCategory?.name ?? 'Tap to select',
                style: _selectedCategory == null
                    ? TextStyle(color: theme.colorScheme.outline)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Exclude from budget'),
            subtitle: const Text('Does not count against spending limits'),
            value: _excludeFromBudget,
            onChanged: (v) => setState(() => _excludeFromBudget = v),
          ),
          const SizedBox(height: 8),

          // Account selection
          _buildAccountSelector(theme),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final accounts = ref.read(accountsWithBalanceProvider).value ?? [];
              final defaultAccount = accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull;
              _selectedAccountId ??= defaultAccount?.id ?? accounts.firstOrNull?.id;

              if (_type == 'transfer') {
                if (_selectedAccountId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select source account')),
                  );
                  return;
                }
                if (_selectedToAccountId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select destination account')),
                  );
                  return;
                }
              } else if (_selectedAccountId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select account')),
                );
                return;
              }

              final edit = widget.transactionToEdit;
              
              if (edit != null) {
                // Update existing transaction
                final companion = TransactionsCompanion(
                  id: Value(edit.id),
                  header: Value(_headerCtrl.text.trim()),
                  description: Value(_descCtrl.text.trim()),
                  amount: Value(double.parse(_amountCtrl.text)),
                  transactionCost: Value(double.tryParse(_costCtrl.text) ?? 0.0),
                  type: Value(_type),
                  categoryId: Value(_selectedCategory?.id),
                  transactionDate: Value(_date),
                  counterpartyName: Value(_descCtrl.text.trim()),
                  accountId: Value(_selectedAccountId),
                  toAccountId: Value(_selectedToAccountId),
                  excludeFromBudget: Value(_excludeFromBudget),
                );

                try {
                  await ref.read(transactionRepositoryProvider).updateTransaction(companion);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction updated'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop(true);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating: $e')),
                  );
                }
              } else {
                // Insert new transaction
                final companion = TransactionsCompanion.insert(
                  header: _headerCtrl.text.trim(),
                  description: Value(_descCtrl.text.trim()),
                  amount: double.parse(_amountCtrl.text),
                  transactionCost: Value(double.tryParse(_costCtrl.text) ?? 0.0),
                  fulizaAmount: Value(widget.parseResult?.fulizaAmount ?? 0.0),
                  fulizaFee: Value(widget.parseResult?.fulizaAccessFee ?? 0.0),
                  type: Value(_type),
                  categoryId: Value(_selectedCategory?.id),
                  transactionDate: _date,
                  mpesaRef: Value(widget.parseResult?.mpesaRef),
                  counterpartyName: Value(_descCtrl.text.trim()),
                  counterpartyAccount: Value(widget.parseResult?.counterpartyAccount ?? ''),
                  isParsed: Value(widget.parseResult != null),
                  accountId: Value(_selectedAccountId),
                  toAccountId: Value(_selectedToAccountId),
                  excludeFromBudget: Value(_excludeFromBudget),
                );

                try {
                  final id = await ref
                      .read(transactionRepositoryProvider)
                      .insertOrIgnoreDuplicate(companion);
                  if (!context.mounted) return;
                  if (id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Already saved — this M-Pesa transaction was recorded before.'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(bottom: 600, left: 16, right: 16),
                      ),
                    );
                    Navigator.of(context).pop();
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction saved!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.check),
            label: Text(widget.transactionToEdit != null ? 'Update Transaction' : 'Save Transaction'),
          ),
        ],
      ),
    );
  }
}
