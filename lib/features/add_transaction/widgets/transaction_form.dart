import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../core/services/reminder_notification_service.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../accounts/providers/account_providers.dart';
import '../../budgets/models/budget_model.dart';
import '../../budgets/providers/budget_providers.dart';
import '../../budgets/services/budget_alert_evaluator.dart';
import '../../categories/models/category_system_keys.dart';
import '../../categories/providers/category_providers.dart';
import '../../categories/widgets/category_picker.dart';
import '../../debts/providers/debt_providers.dart';
import '../../transactions/models/header_suggestion.dart';
import '../../transactions/models/mpesa_parse_result.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/payee_category_providers.dart';
import '../../transactions/providers/transaction_providers.dart';
import 'transaction_account_section.dart';
import 'transaction_amount_section.dart';
import 'transaction_header_autocomplete.dart';
import 'transaction_loan_fields.dart';
import 'transaction_split_section.dart';
import 'transaction_when_section.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final MpesaParseResult? parseResult;
  final TransactionModel? transactionToEdit;

  const TransactionForm({
    super.key,
    this.parseResult,
    this.transactionToEdit,
  });

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  static const _gap = SizedBox(height: 12);
  static const _groupGap = SizedBox(height: 24);

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

  bool _saving = false;
  bool _showFee = false;
  bool _dirty = false;
  bool _isSplitMode = false;
  final List<SplitDraftRow> _splitRows = [];

  bool get _isEdit => widget.transactionToEdit != null;
  double get _fee =>
      _type == 'income' ? 0.0 : (_parseMoney(_costCtrl.text) ?? 0.0);
  bool get _isLoanSpecialCategory =>
      _hasSystemKey(CategorySystemKeys.loanGiven, 'loan given') ||
      _hasSystemKey(CategorySystemKeys.loanReceived, 'loan received') ||
      _hasSystemKey(CategorySystemKeys.loanRepayment, 'loan repayment') ||
      _hasSystemKey(
        CategorySystemKeys.loanRepaymentReceived,
        'loan repayment received',
      );

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
      if (edit.isSplit) {
        _isSplitMode = true;
        for (final s in edit.splits) {
          _splitRows.add(
            SplitDraftRow(
              initialAmount: s.amount.toStringAsFixed(2),
              initialNote: s.note,
            ),
          );
        }
        _loadSplitCategories(edit.splits);
      }
    } else {
      _headerCtrl = TextEditingController();
      _descCtrl = TextEditingController(text: p?.counterpartyName ?? '');
      _amountCtrl = TextEditingController(
        text: p != null ? p.amount.toStringAsFixed(2) : '',
      );
      _costCtrl = TextEditingController(
        text: p != null && p.transactionCost > 0
            ? p.transactionCost.toStringAsFixed(2)
            : '',
      );
      _date = p?.transactionDate ?? DateTime.now();
      _type = p?.resolvedTransactionType ?? 'expense';
      _excludeFromBudget = p?.type == MpesaTransactionType.reversal;
      if (p != null && p.counterpartyName.isNotEmpty) {
        _loadSuggestedCategory(p.counterpartyName);
      }
    }
    _actualCreditedCtrl = TextEditingController();
    _descCtrl.addListener(_onDescChanged);
    _amountCtrl.addListener(_onAmountChanged);
    _showFee = p != null || (edit != null && edit.transactionCost > 0);

    if (p != null && edit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _headerFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _descDebounce?.cancel();
    _amountCtrl.removeListener(_onAmountChanged);
    for (final row in _splitRows) {
      row.dispose();
    }
    _headerFocusNode.dispose();
    _headerCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _costCtrl.dispose();
    _actualCreditedCtrl.dispose();
    super.dispose();
  }

  void _edit(VoidCallback fn) => setState(() {
        fn();
        _dirty = true;
      });

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  double? _parseMoney(String? s) =>
      double.tryParse((s ?? '').replaceAll(',', '').trim());

  InputDecoration _dec(
    String label,
    IconData? icon, {
    String? hint,
    String? helper,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      );

  Future<Category?> _fetchCategory(int id) =>
      ref.read(categoryRepositoryProvider).getCategoryById(id);

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

  String _categoryDisplayLabel(
    Category? cat,
    Map<int, Category> byId,
    AppLocalizations l10n,
  ) {
    if (cat == null) return l10n.tapToSelect;
    if (cat.parentId != null) {
      final parent = byId[cat.parentId!];
      if (parent != null) return '${parent.name} > ${cat.name}';
    }
    return cat.name;
  }

  Future<void> _pickDate() async {
    final last = DateTime.now().add(const Duration(days: 1));
    final d = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(last) ? last : _date,
      firstDate: DateTime(2000),
      lastDate: last,
    );
    if (d == null || !mounted) return;
    _edit(
      () => _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute),
    );
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (t == null || !mounted) return;
    _edit(
      () => _date =
          DateTime(_date.year, _date.month, _date.day, t.hour, t.minute),
    );
  }

  void _setDaysAgo(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    _edit(
      () => _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute),
    );
  }

  void _onAmountChanged() {
    if (_isSplitMode && mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSplitCategories(List<TransactionSplitModel> splits) async {
    for (var i = 0; i < splits.length; i++) {
      final cat = await _fetchCategory(splits[i].categoryId);
      if (!mounted || i >= _splitRows.length) return;
      if (cat != null) {
        setState(() => _splitRows[i].category = cat);
      }
    }
  }

  void _toggleSplitMode(bool enable) {
    _edit(() {
      _isSplitMode = enable;
      if (enable && _splitRows.isEmpty) {
        final compatible = _selectedCategory != null &&
                _selectedCategory!.transactionType == _type
            ? _selectedCategory
            : null;
        _splitRows.add(SplitDraftRow(category: compatible));
        _splitRows.add(SplitDraftRow());
      }
    });
  }

  Future<void> _pickSplitCategory(int index) async {
    final cat = await showCategoryPicker(context, initialType: _type);
    if (cat == null || !mounted || index >= _splitRows.length) return;
    _edit(() => _splitRows[index].category = cat);
  }

  void _addSplitRow() {
    _edit(() => _splitRows.add(SplitDraftRow()));
  }

  void _removeSplitRow(int index) {
    if (_splitRows.length <= 2 || index >= _splitRows.length) return;
    _edit(() {
      final removed = _splitRows.removeAt(index);
      removed.dispose();
    });
  }

  void _fillRemainingSplit(int index) {
    if (index < 0 || index >= _splitRows.length) return;
    final total = _parseMoney(_amountCtrl.text);
    if (total == null || total <= 0) return;
    final totalCents = CentsConverter.toCents(total);
    var otherCents = 0;
    for (var i = 0; i < _splitRows.length; i++) {
      if (i == index) continue;
      otherCents += TransactionSplitSection.parseCents(
        _splitRows[i].amountCtrl.text,
      );
    }
    final remCents = totalCents - otherCents;
    if (remCents <= 0) return;
    _edit(() {
      _splitRows[index].amountCtrl.text =
          CentsConverter.fromCents(remCents).toStringAsFixed(2);
    });
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

  bool _hasSystemKey(String key, String legacyName) =>
      _selectedCategory?.systemKey == key ||
      (_selectedCategory?.systemKey == null &&
          _selectedCategory?.name.toLowerCase() == legacyName);

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;

    final accounts = ref.read(accountsWithBalanceProvider).value ?? [];
    final defaultId =
        (accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull)
            ?.id;
    final acc = resolveSelectedAccounts(
      type: _type,
      selectedAccountId: _selectedAccountId,
      selectedToAccountId: _selectedToAccountId,
      availableIds: [for (final a in accounts) a.id],
      defaultId: defaultId,
    );

    if (acc.from == null) {
      _toast(
        _type == 'transfer' ? l10n.selectSourceAccount : l10n.selectAccount,
      );
      return;
    }
    if (_type == 'transfer' && acc.to == null) {
      _toast(l10n.selectDifferentDestAccount);
      return;
    }

    List<TransactionSplitModel> splitsToSave = const [];
    if (_isSplitMode && _type != 'transfer') {
      if (_splitRows.length < 2) {
        _toast(l10n.splitRequiresTwoRows);
        return;
      }
      final totalCents = CentsConverter.toCents(_parseMoney(_amountCtrl.text)!);
      var sumCents = 0;
      final built = <TransactionSplitModel>[];
      for (final row in _splitRows) {
        final cat = row.category;
        if (cat == null) {
          _toast(l10n.splitSelectAllCategories);
          return;
        }
        final rowCents = TransactionSplitSection.parseCents(row.amountCtrl.text);
        if (rowCents <= 0) {
          _toast(l10n.splitAmountsMustMatch);
          return;
        }
        sumCents += rowCents;
        built.add(
          TransactionSplitModel(
            categoryId: cat.id,
            amount: CentsConverter.fromCents(rowCents),
            note: row.noteCtrl.text.trim(),
          ),
        );
      }
      if (sumCents != totalCents) {
        _toast(l10n.splitAmountsMustMatch);
        return;
      }
      splitsToSave = built;
    }

    setState(() => _saving = true);
    try {
      final shouldCheckBudgets = _type == 'expense' && !_excludeFromBudget;
      final beforeBudgets = shouldCheckBudgets
          ? (ref.read(budgetsWithProgressProvider).valueOrNull ??
              const <BudgetWithProgress>[])
          : const <BudgetWithProgress>[];

      if (_isEdit) {
        await _saveEdit(
          widget.transactionToEdit!,
          acc.from!,
          acc.to,
          splits: splitsToSave,
          beforeBudgets: beforeBudgets,
          checkBudgets: shouldCheckBudgets,
        );
      } else {
        await _saveNew(
          acc.from!,
          acc.to,
          splits: splitsToSave,
          beforeBudgets: beforeBudgets,
          checkBudgets: shouldCheckBudgets,
        );
      }
    } catch (e, st) {
      debugPrint('Save error: $e\n$st');
      if (mounted) {
        _toast(
          _isEdit
              ? l10n.couldNotUpdateTransaction
              : l10n.couldNotSaveTransaction,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveEdit(
    TransactionModel edit,
    int from,
    int? to, {
    required List<TransactionSplitModel> splits,
    required List<BudgetWithProgress> beforeBudgets,
    required bool checkBudgets,
  }) async {
    final payee = _descCtrl.text.trim();
    await ref.read(transactionRepositoryProvider).updateWithSplits(
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
            toAccountId: Value(to),
            excludeFromBudget: Value(_excludeFromBudget),
          ),
          splits,
        );
    _learnPayee();
    if (!mounted) return;
    HapticFeedback.lightImpact();
    await _showPostSaveFeedback(
      beforeBudgets: beforeBudgets,
      checkBudgets: checkBudgets,
      fallbackToast: context.l10n.transactionUpdated,
    );
    if (!mounted) return;
    _finish(true);
  }

  Future<void> _saveNew(
    int from,
    int? to, {
    required List<TransactionSplitModel> splits,
    required List<BudgetWithProgress> beforeBudgets,
    required bool checkBudgets,
  }) async {
    final l10n = context.l10n;
    final payee = _descCtrl.text.trim();
    final isLoanGiven =
        !_isSplitMode && _hasSystemKey(CategorySystemKeys.loanGiven, 'loan given');

    if (isLoanGiven && payee.isEmpty) {
      _toast(l10n.addBorrowerInDesc);
      return;
    }

    final isLoanReceived = !_isSplitMode &&
        _hasSystemKey(CategorySystemKeys.loanReceived, 'loan received');
    if (isLoanReceived && payee.isEmpty) {
      _toast(l10n.addLenderInDesc);
      return;
    }

    final isLoanRepayment = !_isSplitMode &&
        _hasSystemKey(CategorySystemKeys.loanRepayment, 'loan repayment');
    Debt? matchedBorrowedDebt;
    if (isLoanRepayment && _selectedRepayDebtId != null) {
      final borrowedDebts = ref.read(borrowedDebtsProvider).value ?? [];
      matchedBorrowedDebt = borrowedDebts
          .where((d) => d.debt.id == _selectedRepayDebtId)
          .firstOrNull
          ?.debt;
    }

    final isLoanRepaymentReceived = !_isSplitMode &&
        _hasSystemKey(
          CategorySystemKeys.loanRepaymentReceived,
          'loan repayment received',
        );
    if (isLoanRepaymentReceived && _selectedLoanDebtId == null) {
      _toast(l10n.selectWhoRepaying);
      return;
    }

    Debt? matchedDebt;
    if (isLoanRepaymentReceived) {
      final lentDebts = ref.read(lentDebtsProvider).value ?? [];
      final match = lentDebts
          .where((d) => d.debt.id == _selectedLoanDebtId)
          .firstOrNull;
      if (match == null) {
        _toast(l10n.borrowerNoOutstanding);
        return;
      }
      final amount = _parseMoney(_amountCtrl.text)!;
      if (amount > match.debt.outstanding + 0.005) {
        _toast(
          l10n.amountExceedsOutstanding(
            CurrencyFormatter.format(match.debt.outstanding),
          ),
        );
        return;
      }
      matchedDebt = match.debt;
    }

    final rawRef = widget.parseResult?.mpesaRef.trim();
    final normalizedRef = (rawRef == null || rawRef.isEmpty) ? null : rawRef;

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
      toAccountId: Value(to),
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
      id = await ref
          .read(debtRepositoryProvider)
          .recordRepaymentWithTransaction(
            debtId: matchedDebt.id,
            transaction: companion,
          );
    } else if (isLoanRepayment && matchedBorrowedDebt != null) {
      id = await ref
          .read(debtRepositoryProvider)
          .recordRepaymentWithTransaction(
            debtId: matchedBorrowedDebt.id,
            transaction: companion,
          );
    } else if (widget.parseResult?.type == MpesaTransactionType.reversal) {
      id = await ref
          .read(transactionRepositoryProvider)
          .insertReversalAndMarkOriginal(
            companion,
            widget.parseResult!.counterpartyAccount,
          );
    } else {
      id = await ref
          .read(transactionRepositoryProvider)
          .insertWithSplits(companion, splits);
    }

    if (!mounted) return;
    if (id == null) {
      _toast(l10n.alreadySavedMpesa);
      _finish(false);
      return;
    }

    if (!_isSplitMode) {
      _learnPayee();
    }
    HapticFeedback.lightImpact();
    await _showPostSaveFeedback(
      beforeBudgets: beforeBudgets,
      checkBudgets: checkBudgets,
      fallbackToast: l10n.transactionSaved,
    );
    if (!mounted) return;
    _finish(true);
  }

  Future<void> _showPostSaveFeedback({
    required List<BudgetWithProgress> beforeBudgets,
    required bool checkBudgets,
    required String fallbackToast,
  }) async {
    if (checkBudgets) {
      try {
        final afterBudgets = await ref
            .read(budgetRepositoryProvider)
            .watchBudgetsWithProgress()
            .first;
        final alerts = BudgetAlertEvaluator.evaluateCrossedThresholds(
          before: beforeBudgets,
          after: afterBudgets,
        );
        if (alerts.isNotEmpty && mounted) {
          final top = alerts.first;
          final pct = top.budget.percentage.round();
          final l10n = context.l10n;
          final theme = Theme.of(context);
          final isExceeded = top.level == BudgetAlertLevel.exceeded100;
          final msg = isExceeded
              ? l10n.budgetExceededAlert(top.budget.name, pct)
              : l10n.budgetWarning80Alert(top.budget.name, pct);
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                backgroundColor: isExceeded
                    ? theme.colorScheme.error
                    : theme.colorScheme.tertiary,
              ),
            );
          unawaited(
            ref.read(reminderNotificationServiceProvider).showBudgetAlert(top),
          );
          return;
        }
      } catch (e) {
        debugPrint('Budget threshold check failed: $e');
      }
    }
    _toast(fallbackToast);
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
    final l10n = context.l10n;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  String? _validateAmount(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.amountRequired;
    final n = _parseMoney(v);
    if (n == null) return l10n.errorInvalidNumber;
    if (n <= 0) return l10n.amountGreaterThanZero;
    return null;
  }

  String? _validateCost(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return null;
    final n = _parseMoney(v);
    if (n == null || n < 0) return l10n.enterValidCost;
    return null;
  }

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

  String _payeeLabel(AppLocalizations l10n) => switch (_type) {
        'income' => l10n.receivedFrom,
        'transfer' => l10n.note,
        _ => l10n.paidTo,
      };

  String _payeeHint(AppLocalizations l10n) => switch (_type) {
        'income' => l10n.receivedFromHint,
        'transfer' => l10n.noteHint,
        _ => l10n.paidToHint,
      };

  Widget _buildSourceChip(ThemeData theme, AppLocalizations l10n) {
    final p = widget.parseResult;
    if (p == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          visualDensity: VisualDensity.compact,
          avatar: Icon(
            Icons.auto_awesome,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          label: Text(
            p.mpesaRef.isEmpty
                ? l10n.autoFilledMpesa
                : l10n.autoFilledMpesaRef(p.mpesaRef),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildFulizaBanner(ThemeData theme, AppLocalizations l10n) {
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
            Icon(
              Icons.info_outline,
              size: 18,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.fulizaUsedBanner(
                  CurrencyFormatter.format(p.fulizaAmount),
                  CurrencyFormatter.format(p.fulizaAccessFee),
                ),
                style: TextStyle(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField(ThemeData theme, AppLocalizations l10n) {
    final categoriesById = ref.watch(categoriesByIdProvider);
    final cat = _selectedCategory;
    final dotColor = cat == null
        ? theme.colorScheme.outline
        : (tryParseHexColor(cat.colorHex) ?? theme.colorScheme.primary);

    return InkWell(
      onTap: _pickCategory,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _dec(
          l10n.category,
          null,
          helper: _categorySuggested ? l10n.suggestedFromPast : null,
          suffix: const Icon(Icons.chevron_right),
        ).copyWith(
          prefixIcon: Icon(
            cat == null ? Icons.category_outlined : Icons.circle,
            size: cat == null ? 24 : 14,
            color: dotColor,
          ),
        ),
        child: Text(
          cat == null
              ? l10n.chooseCategory
              : _categoryDisplayLabel(cat, categoriesById, l10n),
          style:
              cat == null ? TextStyle(color: theme.colorScheme.primary) : null,
        ),
      ),
    );
  }

  Widget _buildMoreOptions(AppLocalizations l10n) {
    if (_type == 'transfer') return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      initiallyExpanded: _excludeFromBudget,
      title: Text(l10n.moreOptions),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.excludeFromBudget),
          subtitle: Text(l10n.excludeFromBudgetDesc),
          value: _excludeFromBudget,
          onChanged: (v) => _edit(() => _excludeFromBudget = v),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final accent = _accentFor(theme);

    return PopScope(
      canPop: !_dirty,
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
            _buildSourceChip(theme, l10n),
            _buildFulizaBanner(theme, l10n),
            TransactionTypeToggle(
              type: _type,
              accent: accent,
              expenseLabel: l10n.expense,
              incomeLabel: l10n.income,
              transferLabel: l10n.transfer,
              onChanged: (nextType) => _edit(() {
                _type = nextType;
                _selectedLoanDebtId = null;
                if (_type == 'transfer') {
                  _isSplitMode = false;
                }
                if (_selectedCategory != null &&
                    _selectedCategory!.transactionType != _type) {
                  _selectedCategory = null;
                  _categorySuggested = false;
                }
                for (final row in _splitRows) {
                  if (row.category != null &&
                      row.category!.transactionType != _type) {
                    row.category = null;
                  }
                }
              }),
            ),
            _gap,
            TransactionAmountHero(
              type: _type,
              accent: accent,
              amountCtrl: _amountCtrl,
              costCtrl: _costCtrl,
              showFee: _showFee,
              onShowFee: () => setState(() => _showFee = true),
              validateAmount: (v) => _validateAmount(v, l10n),
              validateCost: (v) => _validateCost(v, l10n),
              parseMoney: _parseMoney,
              decorationBuilder: (label, icon, {helper}) =>
                  _dec(label, icon, helper: helper),
              amountLabel: l10n.amount,
              addFeeLabel: l10n.addTransactionFee,
              feeLabel: l10n.transactionFeeKes,
              feeHelper: l10n.mpesaOrBankCharge,
              amountPlusFeeBuilder: l10n.amountPlusFee,
            ),
            _groupGap,
            TransactionHeaderAutocomplete(
              controller: _headerCtrl,
              focusNode: _headerFocusNode,
              decoration:
                  _dec(l10n.titleRequired, Icons.title, hint: l10n.titleHint),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.titleValidation
                  : null,
              onSelected: _onHeaderSuggestionSelected,
            ),
            _gap,
            TextFormField(
              controller: _descCtrl,
              decoration: _dec(
                _payeeLabel(l10n),
                _type == 'transfer' ? Icons.notes : Icons.person_outline,
                hint: _payeeHint(l10n),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            _gap,
            if (!_isSplitMode || _type == 'transfer')
              _buildCategoryField(theme, l10n)
            else
              TransactionSplitSection(
                totalAmountCents: () {
                  final amt = _parseMoney(_amountCtrl.text);
                  return (amt != null && amt > 0)
                      ? CentsConverter.toCents(amt)
                      : 0;
                }(),
                rows: _splitRows,
                categoriesById: ref.watch(categoriesByIdProvider),
                onPickCategory: _pickSplitCategory,
                onAddRow: _addSplitRow,
                onRemoveRow: _removeSplitRow,
                onFillRemaining: _fillRemainingSplit,
                onChanged: () => _edit(() {}),
              ),
            if (_type != 'transfer' && !_isLoanSpecialCategory) ...[
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.splitAcrossCategories),
                subtitle: Text(l10n.splitAcrossCategoriesDesc),
                value: _isSplitMode,
                onChanged: _toggleSplitMode,
              ),
            ],
            if (!_isSplitMode &&
                _hasSystemKey(
                  CategorySystemKeys.loanRepaymentReceived,
                  'loan repayment received',
                )) ...[
              _gap,
              BorrowerDropdownField(
                selectedDebtId: _selectedLoanDebtId,
                onChanged: (v) => _edit(() => _selectedLoanDebtId = v),
              ),
            ],
            if (!_isSplitMode &&
                _hasSystemKey(
                  CategorySystemKeys.loanReceived,
                  'loan received',
                )) ...[
              _gap,
              LoanReceivedCreditedField(
                controller: _actualCreditedCtrl,
                principalCtrl: _amountCtrl,
                parseMoney: _parseMoney,
              ),
            ],
            if (!_isSplitMode &&
                _hasSystemKey(
                  CategorySystemKeys.loanRepayment,
                  'loan repayment',
                )) ...[
              _gap,
              LenderRepayDropdownField(
                selectedDebtId: _selectedRepayDebtId,
                onChanged: (v) => _edit(() => _selectedRepayDebtId = v),
              ),
            ],
            _groupGap,
            TransactionWhenSection(
              date: _date,
              showQuickChips: widget.parseResult == null,
              onPickDate: _pickDate,
              onPickTime: _pickTime,
              onSelectDaysAgo: _setDaysAgo,
              decorationBuilder: (label, icon) => _dec(label, icon),
            ),
            _gap,
            TransactionAccountSection(
              type: _type,
              selectedAccountId: _selectedAccountId,
              selectedToAccountId: _selectedToAccountId,
              onFromChanged: (v) => _edit(() {
                _selectedAccountId = v;
                if (_selectedToAccountId == v) _selectedToAccountId = null;
              }),
              onToChanged: (v) => _edit(() => _selectedToAccountId = v),
              decorationBuilder: (label, icon) => _dec(label, icon),
            ),
            _gap,
            _buildMoreOptions(l10n),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _isEdit ? l10n.updateTransaction : l10n.saveTransaction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
