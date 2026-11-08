import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/add_transaction/widgets/calculator_amount_field.dart';

void main() {
  group('CalculatorAmountField', () {
    testWidgets('shows check icon for expressions, evaluates on tap', (tester) async {
      final ctrl = TextEditingController();
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
  });
}
