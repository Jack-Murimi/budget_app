import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';

/// A TextFormField for numeric amounts that also supports inline math expressions.
/// Typing "50+25" (or tapping the inline operator chips) and tapping ✓ or = evaluates to "75.00".
class CalculatorAmountField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CalculatorAmountField({
    super.key,
    required this.controller,
    required this.decoration,
    this.validator,
    this.focusNode,
  });

  static String _normalize(String input) => input
      .replaceAll(',', '')
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('−', '-')
      .replaceAll('×', '*')
      .replaceAll('÷', '/');

  /// Returns true when [text] contains an arithmetic operator after the leading sign.
  static bool looksLikeExpression(String text) {
    final normalized = _normalize(text);
    if (normalized.length < 2) return false;
    final tail = normalized.startsWith('-') ? normalized.substring(1) : normalized;
    return RegExp(r'[+\-*/]').hasMatch(tail);
  }

  /// Evaluates arithmetic expressions with *, / precedence before +, -.
  /// Strips commas in operands and returns null on malformed/trailing operators,
  /// division by zero, or negative results.
  static String? evaluateExpression(String input) {
    final expr = _normalize(input);
    if (expr.isEmpty) return null;

    final validPattern = RegExp(
      r'^-?(?:\d+(?:\.\d*)?|\.\d+)(?:[+\-*/](?:\d+(?:\.\d*)?|\.\d+))+$',
    );
    if (!validPattern.hasMatch(expr)) return null;

    final rawTokens =
        RegExp(r'(\d+(?:\.\d*)?|\.\d+)|([+\-*/])').allMatches(expr).toList();
    if (rawTokens.isEmpty) return null;

    final numbers = <double>[];
    final ops = <String>[];
    var idx = 0;
    var firstSign = 1.0;
    if (rawTokens.first.group(0) == '-') {
      firstSign = -1.0;
      idx = 1;
    }

    if (idx >= rawTokens.length) return null;
    final firstNum = double.tryParse(rawTokens[idx].group(0)!);
    if (firstNum == null || !firstNum.isFinite) return null;
    numbers.add(firstSign * firstNum);
    idx++;

    while (idx + 1 < rawTokens.length) {
      final op = rawTokens[idx].group(0)!;
      final val = double.tryParse(rawTokens[idx + 1].group(0)!);
      if (val == null || !val.isFinite) return null;
      ops.add(op);
      numbers.add(val);
      idx += 2;
    }

    if (idx != rawTokens.length || ops.isEmpty) return null;

    // Pass 1: multiplication and division left-to-right.
    final addNums = <double>[numbers.first];
    final addOps = <String>[];
    for (var i = 0; i < ops.length; i++) {
      final op = ops[i];
      final rhs = numbers[i + 1];
      if (op == '*') {
        addNums[addNums.length - 1] = addNums.last * rhs;
      } else if (op == '/') {
        if (rhs == 0) return null;
        addNums[addNums.length - 1] = addNums.last / rhs;
      } else {
        addOps.add(op);
        addNums.add(rhs);
      }
    }

    // Pass 2: addition and subtraction left-to-right.
    var result = addNums.first;
    for (var i = 0; i < addOps.length; i++) {
      if (addOps[i] == '+') {
        result += addNums[i + 1];
      } else {
        result -= addNums[i + 1];
      }
    }

    if (!result.isFinite || result < 0) return null;
    return result.toStringAsFixed(2);
  }

  @override
  State<CalculatorAmountField> createState() => _CalculatorAmountFieldState();
}

class _CalculatorAmountFieldState extends State<CalculatorAmountField> {
  FocusNode? _ownedFocusNode;
  bool _hasExpr = false;
  bool _isFocused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _hasExpr = CalculatorAmountField.looksLikeExpression(widget.controller.text);
    widget.controller.addListener(_onChanged);
    _focusNode.addListener(_onFocusChanged);
    _isFocused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(covariant CalculatorAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
      _hasExpr = CalculatorAmountField.looksLikeExpression(widget.controller.text);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
      if (widget.focusNode != null) {
        _ownedFocusNode?.dispose();
        _ownedFocusNode = null;
      }
      _focusNode.addListener(_onFocusChanged);
      _isFocused = _focusNode.hasFocus;
    }
  }

  void _onChanged() {
    final isExpr = CalculatorAmountField.looksLikeExpression(widget.controller.text);
    if (isExpr != _hasExpr) setState(() => _hasExpr = isExpr);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    (widget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _insertOperator(String op) {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    final start = sel.isValid && sel.start >= 0 ? sel.start : text.length;
    final end = sel.isValid && sel.end >= 0 ? sel.end : text.length;
    final updated = text.replaceRange(start, end, op);
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + op.length),
    );
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  void _applyCalc() {
    final result = CalculatorAmountField.evaluateExpression(widget.controller.text);
    if (result != null) {
      widget.controller.value = TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
      setState(() => _hasExpr = false);
    }
  }

  Widget _buildOpChip(
    BuildContext context, {
    required String label,
    required String op,
    bool isApply = false,
  }) {
    final theme = Theme.of(context);
    final bg = isApply
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isApply
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(8),
        onTap: isApply ? _applyCalc : () => _insertOperator(op),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final decoration = _hasExpr
        ? widget.decoration.copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: l10n.evaluateExpressionTooltip,
              onPressed: _applyCalc,
            ),
          )
        : widget.decoration;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: decoration,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v != null && CalculatorAmountField.looksLikeExpression(v)) {
              if (CalculatorAmountField.evaluateExpression(v) == null) {
                return l10n.enterValidExpression;
              }
              return l10n.evaluateExpressionFirst;
            }
            if (widget.validator != null) {
              return widget.validator!(v);
            }
            return null;
          },
        ),
        if (_isFocused)
          Focus(
            canRequestFocus: false,
            descendantsAreFocusable: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildOpChip(context, label: '+', op: '+'),
                  _buildOpChip(context, label: '−', op: '-'),
                  _buildOpChip(context, label: '×', op: '*'),
                  _buildOpChip(context, label: '÷', op: '/'),
                  if (_hasExpr)
                    _buildOpChip(context, label: '=', op: '=', isApply: true),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
