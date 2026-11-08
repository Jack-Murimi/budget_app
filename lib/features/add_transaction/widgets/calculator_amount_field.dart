import 'package:flutter/material.dart';

/// A TextFormField for numeric amounts that also supports inline math expressions.
/// Typing "50+25" and tapping the ✓ icon evaluates to "75.00".
class CalculatorAmountField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final String? Function(String?)? validator;

  const CalculatorAmountField({
    super.key,
    required this.controller,
    required this.decoration,
    this.validator,
  });

  @override
  State<CalculatorAmountField> createState() => _CalculatorAmountFieldState();
}

class _CalculatorAmountFieldState extends State<CalculatorAmountField> {
  bool _hasExpr = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    final isExpr = _looksLikeExpr(widget.controller.text);
    if (isExpr != _hasExpr) setState(() => _hasExpr = isExpr);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  /// Returns true when text contains +, -, *, / (not just a leading minus).
  bool _looksLikeExpr(String text) {
    final t = text.trim();
    if (t.length < 3) return false;
    // Allow leading minus for negative: skip first char
    return RegExp(r'[+\-*/]').hasMatch(t.substring(1));
  }

  /// Evaluates simple arithmetic: +, -, *, / with decimal support.
  /// ponytail: no operator precedence — left-to-right only; for full precedence add math_expressions pkg.
  String? _evaluate(String input) {
    final expr = input.trim();
    // tokenise: split on operators, keeping them
    final tokens = RegExp(r'(\d+\.?\d*)|([+\-*/])').allMatches(expr).toList();
    if (tokens.isEmpty) return null;

    double result;
    try {
      result = double.parse(tokens.first.group(0)!);
    } catch (_) {
      return null;
    }

    for (int i = 1; i < tokens.length - 1; i += 2) {
      final op = tokens[i].group(0);
      final operand = double.tryParse(tokens[i + 1].group(0) ?? '');
      if (operand == null) return null;
      switch (op) {
        case '+':
          result += operand;
        case '-':
          result -= operand;
        case '*':
          result *= operand;
        case '/':
          if (operand == 0) return null;
          result /= operand;
      }
    }

    if (result < 0) return null; // amounts must be positive
    return result.toStringAsFixed(2);
  }

  void _applyCalc() {
    final result = _evaluate(widget.controller.text);
    if (result != null) {
      widget.controller.text = result;
      widget.controller.selection =
          TextSelection.collapsed(offset: result.length);
      setState(() => _hasExpr = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _hasExpr
        ? widget.decoration.copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Evaluate expression',
              onPressed: _applyCalc,
            ),
          )
        : widget.decoration;

    return TextFormField(
      controller: widget.controller,
      decoration: decoration,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (widget.validator != null) {
          final raw = widget.validator!(v);
          if (raw != null) return raw;
        }
        if (v != null && _looksLikeExpr(v)) {
          return 'Tap ✓ to evaluate expression first';
        }
        return null;
      },
    );
  }
}
