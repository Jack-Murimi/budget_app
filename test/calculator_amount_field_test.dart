import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/add_transaction/widgets/calculator_amount_field.dart';

void main() {
  group('CalculatorAmountField', () {
    testWidgets('shows check icon for expressions, evaluates on tap', (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorAmountField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ),
        ),
      );

      // Plain number — no calc icon
      await tester.enterText(find.byType(TextFormField), '150.00');
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);

      // Expression — icon appears
      await tester.enterText(find.byType(TextFormField), '100+50');
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      // Tap evaluate
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pump();
      expect(ctrl.text, '150.00');
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    });

    testWidgets('evaluates subtraction', (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorAmountField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '200-75');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pump();
      expect(ctrl.text, '125.00');
    });

    test('handles comma-formatted operands and operator precedence', () {
      expect(CalculatorAmountField.evaluateExpression('1,000+500'), '1500.00');
      expect(CalculatorAmountField.evaluateExpression('100+50*2'), '200.00');
      expect(CalculatorAmountField.evaluateExpression('200-100/4'), '175.00');
      expect(CalculatorAmountField.evaluateExpression('50+'), isNull);
      expect(CalculatorAmountField.evaluateExpression('10/0'), isNull);
    });

    testWidgets('rejects trailing operator in validation and does not evaluate it',
        (tester) async {
      final ctrl = TextEditingController();
      final formKey = GlobalKey<FormState>();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CalculatorAmountField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '50+');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pump();
      expect(ctrl.text, '50+');
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a valid expression'), findsOneWidget);
    });

    testWidgets('shows inline operator chips on focus and evaluates via =',
        (tester) async {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorAmountField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ),
        ),
      );

      expect(find.text('+'), findsNothing);

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(find.text('+'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '50');
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      expect(ctrl.text, '50+');

      await tester.enterText(find.byType(TextFormField), '50+25');
      await tester.pump();
      expect(find.text('='), findsOneWidget);
      await tester.tap(find.text('='));
      await tester.pump();
      expect(ctrl.text, '75.00');
    });
  });
}
