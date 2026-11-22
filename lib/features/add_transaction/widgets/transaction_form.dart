import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../accounts/providers/account_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';
import '../../transactions/models/header_suggestion.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/payee_category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../debts/providers/debt_providers.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../main.dart';
import 'calculator_amount_field.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final MpesaParseResult? parseResult;
  final TransactionModel? transactionToEdit;
  const TransactionForm({super.key, this.parseResult, this.transactionToEdit});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  static const _gap = SizedBox(height: 12);
  static const _groupGap = SizedBox(height: 24);
  // TODO: replace name matching with a system-category flag/key on Category.
  static const _loanGivenCategory = 'loan given';
  static const _loanRepaymentReceivedCategory = 'loan repayment received';
  static const _loanReceivedCategory = 'loan received';
  static const _loanRepaymentCategory = 'loan repayment';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _headerCtrl;
  late final FocusNode _headerFocusNode;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _actualCreditedCtrl;
  late DateTime _date;
  Category? _selectedCategory;
  int? _selectedLoanDebtId;
  int? _selectedRepayDebtId;
  bool _categorySuggested = false;
  String _type = 'expense';
  int? _selectedAccountId;
  int? _selectedToAccountId;
  bool _excludeFromBudget = false;
  Timer? _descDebounce;

  bool _saving =
      false; // blocks double-tap Save (manual entries have no ref to dedupe on)
  bool _showFee =
      false; // fee is always visible for M-Pesa entries, on-demand for manual ones
  bool _dirty = false; // drives the "discard changes?" prompt on back

  bool get _isEdit => widget.transactionToEdit != null;
  // Hidden field (income) never contributes a fee.
  double get _fee =>
      _type == 'income' ? 0.0 : (_parseMoney(_costCtrl.text) ?? 0.0);

  @override
  void initState() {
    super.initState();
    final p = widget.parseResult;
    final edit = widget.transactionToEdit;

    _headerFocusNode = FocusNode();
    if (edit != null) {
      _headerCtrl = TextEditingController(text: edit.header);
      _descCtrl = TextEditingController(text: edit.description);
      _amountCtrl = TextEditingController(text: edit.amount.toStringAsFixed(2));
      _costCtrl = TextEditingController(
        text: edit.transactionCost > 0
            ? edit.transactionCost.toStringAsFixed(2)
            : '',
      );
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
          text: p != null ? p.amount.toStringAsFixed(2) : '');
      _costCtrl = TextEditingController(
        text: p != null && p.transactionCost > 0
            ? p.transactionCost.toStringAsFixed(2)
            : '',
      );
      _date = p?.transactionDate ?? DateTime.now();
      _type = p?.type.transactionType ?? 'expense';
      if (p != null && p.counterpartyName.isNotEmpty) {
        _loadSuggestedCategory(p.counterpartyName);
      }
    }
    _actualCreditedCtrl = TextEditingController();
    _descCtrl.addListener(_onDescChanged);

    _showFee = p != null || (edit != null && edit.transactionCost > 0);

    // M-Pesa flow: amount/date/payee are already filled, so Title is the first thing to type.
    if (p != null && edit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _headerFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _descDebounce?.cancel();
    _headerFocusNode.dispose();
    _headerCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _costCtrl.dispose();
    _actualCreditedCtrl.dispose();
    super.dispose();
  }

  // ── Small helpers ──────────────────────────────────────────────────────

  /// setState + mark the form as having unsaved changes.
  void _edit(VoidCallback fn) => setState(() {
        fn();
        _dirty = true;
      });

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text(message), behavior: SnackBarBehavior.floating));
  }

  /// Accepts "1,500" as well as "1500".
  double? _parseMoney(String? s) =>
      double.tryParse((s ?? '').replaceAll(',', '').trim());

  InputDecoration _dec(String label, IconData? icon,
          {String? hint, String? helper, Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      );

  // ── Category loading / suggestions ─────────────────────────────────────

  // TODO: move into the category repository (UI shouldn't query the DB).
  Future<Category?> _fetchCategory(int id) {
    final db = ref.read(dbProvider);
    return (db.select(db.categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  void _onDescChanged() {
    _descDebounce?.cancel();
    _descDebounce = Timer(const Duration(milliseconds: 600), () {
      final text = _descCtrl.text.trim();
      if (text.length >= 3 && _selectedCategory == null) {
        _loadSuggestedCategory(text);
      }
    });
  }

  Future<void> _loadSuggestedCategory(String payee) async {
    final catId =
        await ref.read(payeeCategoryRepositoryProvider).suggest(payee);
    if (catId == null || !mounted) return;
    _applySuggestedCategory(await _fetchCategory(catId));
  }

  Future<void> _loadCategoryForEdit(int? id) async {
    if (id == null) return;
    final cat = await _fetchCategory(id);
    if (cat != null && mounted) {
      setState(() {
        _selectedCategory = cat;
        _selectedLoanDebtId = null;
      });
    }
  }

  Future<void> _onHeaderSuggestionSelected(HeaderSuggestion option) async {
    final id = option.categoryId;
    if (id == null) return;
    _applySuggestedCategory(await _fetchCategory(id), overwrite: true);
  }

  /// Only applies a suggestion that matches the current type, so an
  /// expense payee can't drop an expense category onto an income entry.
  void _applySuggestedCategory(Category? cat, {bool overwrite = false}) {
    if (cat == null || !mounted) return;
    if (!overwrite && _selectedCategory != null) return;
    if (cat.transactionType != _type) return;
    setState(() {
      _selectedCategory = cat;
      _categorySuggested = true;
      _selectedLoanDebtId = null;
    });
  }

  String _categoryDisplayLabel(Category? cat, List<Category> allCats) {
    if (cat == null) return 'Tap to select';
    if (cat.parentId != null) {
      final parent = allCats.where((c) => c.id == cat.parentId).firstOrNull;
      if (parent != null) return '${parent.name} > ${cat.name}';
    }
    return cat.name;
  }

  // ── Pickers ────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final last = DateTime.now().add(const Duration(days: 1));
    final d = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(last) ? last : _date,
      firstDate: DateTime(2000),
      lastDate: last,
    );
    if (d == null || !mounted) return;
    _edit(() =>
        _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (t == null || !mounted) return;
    _edit(() =>
        _date = DateTime(_date.year, _date.month, _date.day, t.hour, t.minute));
  }

  bool _isDaysAgo(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return d.year == _date.year && d.month == _date.month && d.day == _date.day;
  }

  void _setDaysAgo(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    _edit(() =>
        _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute));
  }

  Future<void> _pickCategory() async {
    final cat = await showCategoryPicker(context, initialType: _type);
    if (cat == null || !mounted) return;
    _edit(() {
      _selectedCategory = cat;
      _categorySuggested = false;
      _selectedLoanDebtId = null;
    });
  }

  // ── Accounts ───────────────────────────────────────────────────────────

  /// Single source of truth for which accounts are really selected.
  /// - nothing picked yet → default account
  /// - picked account no longer exists → null (force a re-pick, never save a stale id)
  /// - "to" only counts for transfers, and can't equal "from"
  ({int? from, int? to}) _resolveAccounts(List<int> ids, int? defaultId) {
    final from = _selectedAccountId == null
        ? defaultId
        : (ids.contains(_selectedAccountId) ? _selectedAccountId : null);
    final to = (_type == 'transfer' &&
            _selectedToAccountId != from &&
            ids.contains(_selectedToAccountId))
        ? _selectedToAccountId
        : null;
    return (from: from, to: to);
  }

  Widget _accountDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      isExpanded: true, // long account names ellipsize instead of overflowing
      decoration: _dec(label, icon),
      // ignore: deprecated_member_use
      value: value,
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildAccountSelector(ThemeData theme) {
    final async = ref.watch(accountsWithBalanceProvider);
    final accounts = async.value;

    if (accounts == null) {
      return async.hasError
          ? Text('Could not load accounts',
              style: TextStyle(color: theme.colorScheme.error))
          : const SizedBox(
              height: 56, child: Center(child: LinearProgressIndicator()));
    }
    if (accounts.isEmpty) {
      return Text('No accounts available',
          style: TextStyle(color: theme.colorScheme.error));
    }

    final defaultId =
        (accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull)
            ?.id;
    final res = _resolveAccounts([for (final a in accounts) a.id], defaultId);

    // One wallet and not a transfer: nothing to choose, so don't make it a field.
    if (accounts.length == 1 &&
        _type != 'transfer' &&
        res.from == accounts.first.id) {
      return InputDecorator(
        decoration: _dec('Account', Icons.account_balance_wallet_outlined),
        child: Text(accounts.first.name, overflow: TextOverflow.ellipsis),
      );
    }

    List<DropdownMenuItem<int>> items({int? except}) => [
          for (final a in accounts)
            if (a.id != except)
              DropdownMenuItem<int>(
                value: a.id,
                child: Text(
                  '${a.name} (${CurrencyFormatter.format(a.balance)})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        ];

    if (_type != 'transfer') {
      return _accountDropdown(
        label: 'Account / Wallet *',
        icon: Icons.account_balance_wallet_outlined,
        hint: 'Select account',
        value: res.from,
        items: items(),
        onChanged: (v) => _edit(() => _selectedAccountId = v),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _accountDropdown(
          label: 'From Account *',
          icon: Icons.arrow_left,
          hint: 'Select source account',
          value: res.from,
          items: items(),
          onChanged: (v) => _edit(() {
            _selectedAccountId = v;
            if (_selectedToAccountId == v) _selectedToAccountId = null;
          }),
        ),
        const SizedBox(height: 12),
        _accountDropdown(
          label: 'To Account *',
          icon: Icons.arrow_right,
          hint: 'Select destination account',
          value: res.to,
          items: items(except: res.from), // can't transfer to the same account
          onChanged: (v) => _edit(() => _selectedToAccountId = v),
        ),
      ],
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final accounts = ref.read(accountsWithBalanceProvider).value ?? [];
    final defaultId =
        (accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull)
            ?.id;
    final acc = _resolveAccounts([for (final a in accounts) a.id], defaultId);

    if (acc.from == null) {
      _toast(_type == 'transfer' ? 'Select source account' : 'Select account');
      return;
    }
    if (_type == 'transfer' && acc.to == null) {
      _toast('Select a destination account different from the source');
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _saveEdit(widget.transactionToEdit!, acc.from!, acc.to);
      } else {
        await _saveNew(acc.from!, acc.to);
      }
    } catch (e, st) {
      debugPrint('Save error: $e\n$st'); // details to the log, not the user
      _toast(_isEdit
          ? 'Could not update the transaction. Try again.'
          : 'Could not save the transaction. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveEdit(TransactionModel edit, int from, int? to) async {
    final payee = _descCtrl.text.trim();
    await ref.read(transactionRepositoryProvider).updateTransaction(
          TransactionsCompanion(
            id: Value(edit.id),
            header: Value(_headerCtrl.text.trim()),
            description: Value(payee),
            amount: Value(_parseMoney(_amountCtrl.text)!),
            transactionCost: Value(_fee),
            type: Value(_type),
            categoryId: Value(_selectedCategory?.id),
            transactionDate: Value(_date),
            counterpartyName: Value(payee),
            accountId: Value(from),
            toAccountId: Value(to), // null unless this is a transfer
            excludeFromBudget: Value(_excludeFromBudget),
          ),
        );
    _learnPayee();
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _toast('Transaction updated');
    _finish(true);
  }

  Future<void> _saveNew(int from, int? to) async {
    final payee = _descCtrl.text.trim();
    final isLoanGiven =
        _selectedCategory?.name.toLowerCase() == _loanGivenCategory;

    if (isLoanGiven && payee.isEmpty) {
      _toast('Add who you lent to in Description');
      return;
    }

    final isLoanReceived =
        _selectedCategory?.name.toLowerCase() == _loanReceivedCategory;
    if (isLoanReceived && payee.isEmpty) {
      _toast('Add lender name in Description / Payee');
      return;
    }

    final isLoanRepayment =
        _selectedCategory?.name.toLowerCase() == _loanRepaymentCategory;
    Debt? matchedBorrowedDebt;
    if (isLoanRepayment && _selectedRepayDebtId != null) {
      final borrowedDebts = ref.read(borrowedDebtsProvider).value ?? [];
      matchedBorrowedDebt = borrowedDebts
          .where((d) => d.debt.id == _selectedRepayDebtId)
          .firstOrNull
          ?.debt;
    }

    final isLoanRepaymentReceived =
        _selectedCategory?.name.toLowerCase() == _loanRepaymentReceivedCategory;
    if (isLoanRepaymentReceived && _selectedLoanDebtId == null) {
      _toast('Select who is repaying');
      return;
    }

    Debt? matchedDebt;
    if (isLoanRepaymentReceived) {
      final lentDebts = ref.read(lentDebtsProvider).value ?? [];
      final match = lentDebts
          .where((d) => d.debt.id == _selectedLoanDebtId)
          .firstOrNull;
      if (match == null) {
        _toast(
            'Selected borrower no longer has an outstanding balance. Please re-select.');
        return;
      }
      final amount = _parseMoney(_amountCtrl.text)!;
      if (amount > match.debt.outstanding + 0.005) {
        _toast(
            'Amount exceeds outstanding balance of ${CurrencyFormatter.format(match.debt.outstanding)}');
        return;
      }
      matchedDebt = match.debt;
    }

    final rawRef = widget.parseResult?.mpesaRef.trim();
    final normalizedRef =
        (rawRef == null || rawRef.isEmpty) ? null : rawRef;

    final companion = TransactionsCompanion.insert(
      header: _headerCtrl.text.trim(),
      description: Value(payee),
      amount: _parseMoney(_amountCtrl.text)!,
      transactionCost: Value(_fee),
      fulizaAmount: Value(widget.parseResult?.fulizaAmount ?? 0.0),
      fulizaFee: Value(widget.parseResult?.fulizaAccessFee ?? 0.0),
      type: Value(_type),
      categoryId: Value(_selectedCategory?.id),
      transactionDate: _date,
      mpesaRef: Value(normalizedRef),
      counterpartyName: Value(payee),
      counterpartyAccount: Value(widget.parseResult?.counterpartyAccount ?? ''),
      isParsed: Value(widget.parseResult != null),
      accountId: Value(from),
      toAccountId: Value(to), // null unless this is a transfer
      excludeFromBudget: Value(_excludeFromBudget),
    );

    int? id;
    if (isLoanGiven) {
      id = await ref.read(debtRepositoryProvider).recordLoanGiven(
            transaction: companion,
            counterparty: payee,
          );
    } else if (isLoanReceived) {
      final credited = _parseMoney(_actualCreditedCtrl.text);
      id = await ref.read(debtRepositoryProvider).recordLoanReceived(
            transaction: companion,
            counterparty: payee,
            actualReceived: credited,
          );
    } else if (isLoanRepaymentReceived && matchedDebt != null) {
      id = await ref.read(debtRepositoryProvider).recordRepaymentWithTransaction(
            debtId: matchedDebt.id,
            transaction: companion,
          );
    } else if (isLoanRepayment && matchedBorrowedDebt != null) {
      id = await ref.read(debtRepositoryProvider).recordRepaymentWithTransaction(
            debtId: matchedBorrowedDebt.id,
            transaction: companion,
          );
    } else {
      id = await ref
          .read(transactionRepositoryProvider)
          .insertOrIgnoreDuplicate(companion);
    }

    if (!mounted) return;
    if (id == null) {
      _toast('Already saved — this M-Pesa transaction was recorded before.');
      _finish();
      return;
    }

    _learnPayee();
    HapticFeedback.lightImpact();
    _toast('Transaction saved!');
    _finish();
  }

  void _learnPayee() {
    final catId = _selectedCategory?.id;
    final payee = _descCtrl.text.trim();
    if (catId != null && payee.isNotEmpty) {
      ref.read(payeeCategoryRepositoryProvider).learn(payee, catId);
    }
  }

  void _finish([bool? result]) {
    _dirty = false;
    Navigator.of(context).pop(result);
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes on this transaction.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep editing')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard')),
        ],
      ),
    );
    return discard ?? false;
  }

  // ── Validators ─────────────────────────────────────────────────────────

  String? _validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Amount is required';
    final n = _parseMoney(v);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Amount must be greater than 0';
    return null;
  }

  String? _validateCost(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    final n = _parseMoney(v);
    if (n == null || n < 0) return 'Enter a valid cost';
    return null;
  }

  // ── UI pieces ──────────────────────────────────────────────────────────
  // Layout follows the job: money first, then what/who, then when/where.
  // Rarely used controls stay out of the way.

  Color _accentFor(ThemeData theme) {
    final dark = theme.brightness == Brightness.dark;
    switch (_type) {
      case 'income':
        return dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      case 'transfer':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.error;
    }
  }

  // The same field means different things per type, so say so.
  String get _payeeLabel => switch (_type) {
        'income' => 'Received from',
        'transfer' => 'Note',
        _ => 'Paid to',
      };

  String get _payeeHint => switch (_type) {
        'income' => 'Sender or source',
        'transfer' => 'Optional note',
        _ => 'Person, shop or paybill',
      };

  Widget _buildSourceChip(ThemeData theme) {
    final p = widget.parseResult;
    if (p == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          visualDensity: VisualDensity.compact,
          avatar: Icon(Icons.auto_awesome,
              size: 16, color: theme.colorScheme.primary),
          label: Text(
            p.mpesaRef.isEmpty
                ? 'Auto-filled from M-Pesa'
                : 'Auto-filled from M-Pesa · ${p.mpesaRef}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildFulizaBanner(ThemeData theme) {
    final p = widget.parseResult;
    if (p == null || p.fulizaAmount <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 18, color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Fuliza used: ${CurrencyFormatter.format(p.fulizaAmount)} '
                '(fee: ${CurrencyFormatter.format(p.fulizaAccessFee)})',
                style: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(Color accent) {
    return SegmentedButton<String>(
      showSelectedIcon: false, // keeps 3 labelled segments readable at 360dp
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: accent.withValues(alpha: 0.14),
        selectedForegroundColor: accent,
      ),
      segments: const [
        ButtonSegment(
            value: 'expense',
            label: Text('Expense'),
            icon: Icon(Icons.arrow_upward_rounded)),
        ButtonSegment(
            value: 'income',
            label: Text('Income'),
            icon: Icon(Icons.arrow_downward_rounded)),
        ButtonSegment(
            value: 'transfer',
            label: Text('Transfer'),
            icon: Icon(Icons.swap_horiz)),
      ],
      selected: {_type},
      onSelectionChanged: (s) {
        HapticFeedback.selectionClick();
        _edit(() {
          _type = s.first;
          _selectedLoanDebtId = null;
          if (_selectedCategory != null &&
              _selectedCategory!.transactionType != _type) {
            _selectedCategory = null;
            _categorySuggested = false;
          }
        });
      },
    );
  }

  /// The money block: the one tinted area on the screen, so the eye lands here first.
  Widget _buildAmountHero(ThemeData theme, Color accent) {
    final amountStyle = theme.textTheme.headlineMedium
        ?.copyWith(fontWeight: FontWeight.w700, color: accent);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Enlarge the inner field via the theme so this doesn't depend on
          // CalculatorAmountField exposing a style parameter.
          Theme(
            data: theme.copyWith(
                textTheme: theme.textTheme.copyWith(bodyLarge: amountStyle)),
            child: CalculatorAmountField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixText: 'KES ',
                prefixStyle: amountStyle,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              validator: _validateAmount,
            ),
          ),
          _buildFee(theme),
        ],
      ),
    );
  }

  Widget _buildFee(ThemeData theme) {
    if (_type == 'income') return const SizedBox.shrink();

    if (!_showFee) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => _showFee = true),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add transaction fee'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        TextFormField(
          controller: _costCtrl,
          decoration: _dec('Transaction fee (KES)', null,
                  helper: 'M-Pesa or bank charge')
              .copyWith(filled: true, fillColor: theme.colorScheme.surface),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: _validateCost,
        ),
        // Live total so the fee's effect is visible, not implied.
        ListenableBuilder(
          listenable: Listenable.merge([_amountCtrl, _costCtrl]),
          builder: (context, _) {
            final amount = _parseMoney(_amountCtrl.text) ?? 0;
            final fee = _parseMoney(_costCtrl.text) ?? 0;
            if (amount <= 0 || fee <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Amount + fee: ${CurrencyFormatter.format(amount + fee)}',
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.end,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderField() {
    // LayoutBuilder so the suggestion list matches the field's width.
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<HeaderSuggestion>(
        textEditingController: _headerCtrl,
        focusNode: _headerFocusNode,
        displayStringForOption: (option) => option.header,
        optionsBuilder: (value) {
          final query = value.text.trim();
          if (query.isEmpty) return const Iterable<HeaderSuggestion>.empty();
          return ref
              .read(transactionRepositoryProvider)
              .getHeaderSuggestions(query);
        },
        onSelected: _onHeaderSuggestionSelected,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration:
                _dec('Title *', Icons.title, hint: 'e.g. Groceries at Naivas'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Give this transaction a title'
                : null,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              onFieldSubmitted();
              FocusScope.of(context).nextFocus();
            },
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          final theme = Theme.of(context);
          return Align(
            alignment: AlignmentDirectional.topStart,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth, maxHeight: 220),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 20),
                      title: Text(option.header,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: option.categoryDisplay.isNotEmpty
                          ? Text(
                              option.categoryDisplay,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary),
                            )
                          : null,
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayeeField() {
    return TextFormField(
      controller: _descCtrl,
      decoration: _dec(
        _payeeLabel,
        _type == 'transfer' ? Icons.notes : Icons.person_outline,
        hint: _payeeHint,
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildCategoryField(ThemeData theme) {
    final allCats = ref.watch(categoriesStreamProvider).value ?? [];
    final cat = _selectedCategory;
    final dotColor = cat == null
        ? theme.colorScheme.outline
        : (_tryParseColor(cat.colorHex) ?? theme.colorScheme.primary);

    return InkWell(
      onTap: _pickCategory,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _dec(
          'Category',
          null,
          helper: _categorySuggested ? 'Suggested from past entries' : null,
          suffix: const Icon(Icons.chevron_right),
        ).copyWith(
          // The category's own color, so a pick is recognisable at a glance.
          prefixIcon: Icon(cat == null ? Icons.category_outlined : Icons.circle,
              size: cat == null ? 24 : 14, color: dotColor),
        ),
        child: Text(
          cat == null
              ? 'Choose a category'
              : _categoryDisplayLabel(cat, allCats),
          style:
              cat == null ? TextStyle(color: theme.colorScheme.primary) : null,
        ),
      ),
    );
  }

  Widget _buildBorrowerField() {
    final lentAsync = ref.watch(lentDebtsProvider);

    return lentAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (e, _) => Text(
        'Could not load borrowers',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (lentDebts) {
        if (lentDebts.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Borrower',
              prefixIcon: const Icon(Icons.person_outline),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('No outstanding loans to repay'),
          );
        }
        return DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Borrower *',
            prefixIcon: const Icon(Icons.person_outline),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          // ignore: deprecated_member_use
          value: lentDebts.any((d) => d.debt.id == _selectedLoanDebtId)
              ? _selectedLoanDebtId
              : null,
          hint: const Text('Select who is repaying'),
          items: lentDebts
              .map((d) => DropdownMenuItem<int>(
                    value: d.debt.id,
                    child: Text(
                      '${d.debt.counterparty} (${CurrencyFormatter.format(d.debt.outstanding)})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (v) => _edit(() => _selectedLoanDebtId = v),
        );
      },
    );
  }

  Widget _buildLoanReceivedExtraFields() {
    return TextFormField(
      controller: _actualCreditedCtrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Actual amount credited (optional)',
        hintText: 'e.g. 570 if 600 was borrowed',
        helperText:
            'Deductions (shortfall) will be tracked under Bridge charges',
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        final credited = _parseMoney(v);
        if (credited == null || !credited.isFinite || credited <= 0) {
          return 'Enter a valid positive amount';
        }
        final principal = _parseMoney(_amountCtrl.text);
        if (principal != null && principal > 0 && credited > principal) {
          return 'Cannot exceed borrowed amount';
        }
        return null;
      },
    );
  }

  Widget _buildLenderRepayField() {
    final borrowedAsync = ref.watch(borrowedDebtsProvider);

    return borrowedAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (e, _) => Text(
        'Could not load lenders',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (borrowedDebts) {
        if (borrowedDebts.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Lender',
              prefixIcon: const Icon(Icons.account_balance_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('No open borrowed loans to link'),
          );
        }
        return DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Lender being repaid *',
            prefixIcon: const Icon(Icons.account_balance_outlined),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          initialValue:
              borrowedDebts.any((d) => d.debt.id == _selectedRepayDebtId)
                  ? _selectedRepayDebtId
                  : null,
          hint: const Text('Select loan to repay'),
          items: borrowedDebts
              .map((d) => DropdownMenuItem<int>(
                    value: d.debt.id,
                    child: Text(
                      '${d.debt.counterparty} (${CurrencyFormatter.format(d.debt.outstanding)})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (v) => _edit(() => _selectedRepayDebtId = v),
        );
      },
    );
  }

  Widget _tapField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _dec(label, null),
        child: Text(value, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  /// Date and time are separate controls (one tap each), grouped in one row.
  Widget _buildWhen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
                flex: 3,
                child: _tapField(
                    'Date', DateFormatter.formatDate(_date), _pickDate)),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _tapField('Time',
                  TimeOfDay.fromDateTime(_date).format(context), _pickTime),
            ),
          ],
        ),
        // Manual entries are almost always today or yesterday.
        if (widget.parseResult == null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                  label: const Text('Today'),
                  selected: _isDaysAgo(0),
                  onSelected: (_) => _setDaysAgo(0)),
              ChoiceChip(
                  label: const Text('Yesterday'),
                  selected: _isDaysAgo(1),
                  onSelected: (_) => _setDaysAgo(1)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMoreOptions() {
    if (_type == 'transfer') return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      initiallyExpanded:
          _excludeFromBudget, // never hide an option that's switched on
      title: const Text('More options'),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Exclude from budget'),
          subtitle: const Text('Does not count against spending limits'),
          value: _excludeFromBudget,
          onChanged: (v) => _edit(() => _excludeFromBudget = v),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentFor(theme);

    return PopScope(
      canPop: !_dirty, // Android back / gesture asks before throwing work away
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) _finish();
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () {
          if (!_dirty) setState(() => _dirty = true);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSourceChip(theme),
            _buildFulizaBanner(theme),
            _buildTypeToggle(accent),
            _gap,
            _buildAmountHero(theme, accent),
            _groupGap,
            _buildHeaderField(),
            _gap,
            _buildPayeeField(),
            _gap,
            _buildCategoryField(theme),
            if (_selectedCategory?.name.toLowerCase() ==
                _loanRepaymentReceivedCategory) ...[
              _gap,
              _buildBorrowerField(),
            ],
            if (_selectedCategory?.name.toLowerCase() ==
                _loanReceivedCategory) ...[
              _gap,
              _buildLoanReceivedExtraFields(),
            ],
            if (_selectedCategory?.name.toLowerCase() ==
                _loanRepaymentCategory) ...[
              _gap,
              _buildLenderRepayField(),
            ],
            _groupGap,
            _buildWhen(),
            _gap,
            _buildAccountSelector(theme),
            _gap,
            _buildMoreOptions(),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_isEdit ? 'Update Transaction' : 'Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

Color? _tryParseColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    var v = hex.replaceFirst('#', '');
    if (v.length == 6) v = 'FF$v';
    return Color(int.parse(v, radix: 16));
  } catch (_) {
    return null;
  }
}
