import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/transactions/services/mpesa_parser.dart';
import 'package:budget_app/features/transactions/models/mpesa_parse_result.dart';

void main() {
  group('sendMoney', () {
    test('with phone number', () {
      const msg = 'UK3QX11U87 Confirmed. Ksh70.00 sent to JOHN DOE 0712345678 on 3/12/26 at 10:41 PM. New M-PESA balance is Ksh500.00. Transaction cost, Ksh0.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'UK3QX11U87');
      expect(result.amount, 70.00);
      expect(result.transactionCost, 0.00);
      expect(result.counterpartyName, 'JOHN DOE');
      expect(result.counterpartyAccount, '0712345678');
      expect(result.type, MpesaTransactionType.sendMoney);
      expect(result.newBalance, 500.00);
      expect(result.transactionDate.day, 3);
      expect(result.transactionDate.month, 12);
      expect(result.transactionDate.year, 2026);
      expect(result.transactionDate.hour, 22);
      expect(result.transactionDate.minute, 41);
    });

    test('without phone number', () {
      const msg = 'UJVQX0LSN2 Confirmed. Ksh100.00 sent to JANE SMITH on 4/11/26 at 2:15 PM. New M-PESA balance is Ksh1,200.50. Transaction cost, Ksh5.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'UJVQX0LSN2');
      expect(result.amount, 100.00);
      expect(result.transactionCost, 5.00);
      expect(result.counterpartyName, 'JANE SMITH');
      expect(result.counterpartyAccount, '');
      expect(result.type, MpesaTransactionType.sendMoney);
      expect(result.newBalance, 1200.50);
    });

    test('name with multiple spaces', () {
      const msg = 'UK1140IRT2 Confirmed. Ksh250.00 sent to JOSEPHAT  RORI 0722111222 on 1/11/26 at 9:30 AM. New M-PESA balance is Ksh800.00. Transaction cost, Ksh10.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.counterpartyName, 'JOSEPHAT RORI'); // cleaned up
      expect(result.counterpartyAccount, '0722111222');
      expect(result.type, MpesaTransactionType.sendMoney);
    });
  });

  group('paybill', () {
    test('paid to MERCHANT format', () {
      const msg = 'VK4QX22V99 Confirmed. Ksh500.00 paid to KPLC PREPAID. on 15/10/26 at 8:00 PM. New M-PESA balance is Ksh2,000.00. Transaction cost, Ksh0.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'VK4QX22V99');
      expect(result.amount, 500.00);
      expect(result.counterpartyName, 'KPLC PREPAID');
      expect(result.counterpartyAccount, '');
      expect(result.type, MpesaTransactionType.paybill);
      expect(result.newBalance, 2000.00);
    });

    test('sent to PAYBILL for account format', () {
      const msg = 'WL5RY33W88 Confirmed. Ksh1,200.00 sent to EQUITY BANK for account 1234567890 on 20/9/26 at 3:45 PM. New M-PESA balance is Ksh5,500.00. Transaction cost, Ksh30.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'WL5RY33W88');
      expect(result.amount, 1200.00);
      expect(result.counterpartyName, 'EQUITY BANK');
      expect(result.counterpartyAccount, '1234567890');
      expect(result.type, MpesaTransactionType.paybill);
      expect(result.newBalance, 5500.00);
      expect(result.transactionCost, 30.00);
    });
  });

  group('receiveMoney', () {
    test('standard receive', () {
      const msg = 'XM6SZ44X77 Confirmed. You have received Ksh1,500.00 from ALICE MWANGI 0733222333 on 5/11/26 at 11:20 AM. New M-PESA balance is Ksh3,200.00. Transaction cost, Ksh0.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'XM6SZ44X77');
      expect(result.amount, 1500.00);
      expect(result.counterpartyName, 'ALICE MWANGI');
      expect(result.counterpartyAccount, '0733222333');
      expect(result.type, MpesaTransactionType.receiveMoney);
      expect(result.newBalance, 3200.00);
    });

    test('with masked phone number', () {
      const msg = 'YN7TZ55Y66 Confirmed.You have received Ksh800.00 from BOB KIMANI 0758***343 on 6/11/26 at 4:10 PM. New M-PESA balance is Ksh2,100.00. Transaction cost, Ksh0.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'YN7TZ55Y66');
      expect(result.amount, 800.00);
      expect(result.counterpartyName, 'BOB KIMANI');
      expect(result.counterpartyAccount, '0758***343');
      expect(result.type, MpesaTransactionType.receiveMoney);
    });
  });

  group('agentCashout', () {
    test('give cash to agent', () {
      const msg = 'ZO8UZ66Z55 Confirmed. Give Ksh2,000.00 cash to JOHN KARIUKI NAIROBI New M-PESA balance is Ksh100.00. Transaction cost, Ksh30.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'ZO8UZ66Z55');
      expect(result.amount, 2000.00);
      expect(result.counterpartyName, 'JOHN KARIUKI NAIROBI');
      expect(result.type, MpesaTransactionType.agentCashout);
      expect(result.newBalance, 100.00);
      expect(result.transactionCost, 30.00);
    });
  });

  group('withdraw', () {
    test('withdrawn from agent', () {
      const msg = 'AP9VZ77A44 Confirmed. Ksh3,000.00 withdrawn from agent 12345 MARY KAMAU on 7/11/26 at 1:30 PM. New M-PESA balance is Ksh500.00. Transaction cost, Ksh33.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'AP9VZ77A44');
      expect(result.amount, 3000.00);
      expect(result.counterpartyName, 'MARY KAMAU');
      expect(result.counterpartyAccount, '12345');
      expect(result.type, MpesaTransactionType.withdraw);
      expect(result.newBalance, 500.00);
      expect(result.transactionCost, 33.00);
    });
  });

  group('fulizaDrawdown', () {
    test('complete fuliza message', () {
      const msg = 'BQ0WZ88B33 Confirmed. Fuliza M-PESA amount is Ksh70.00. Access Fee charged Ksh0.70. Total Fuliza M-PESA outstanding amount is Ksh102.68 due on 3/12/26.';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'BQ0WZ88B33');
      expect(result.type, MpesaTransactionType.fulizaDrawdown);
      expect(result.fulizaAmount, 70.00);
      expect(result.fulizaAccessFee, 0.70);
      expect(result.outstandingTotal, 102.68);
      expect(result.fulizaDueDate, isNotNull);
      expect(result.fulizaDueDate!.day, 3);
      expect(result.fulizaDueDate!.month, 12);
      expect(result.fulizaDueDate!.year, 2026);
    });

    test('fuliza without due date', () {
      const msg = 'CR1XZ99C22 Confirmed. Fuliza M-PESA amount is Ksh150.00. Access Fee charged Ksh1.50. Total Fuliza M-PESA outstanding amount is Ksh200.00.';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.type, MpesaTransactionType.fulizaDrawdown);
      expect(result.fulizaAmount, 150.00);
      expect(result.fulizaAccessFee, 1.50);
      expect(result.outstandingTotal, 200.00);
      expect(result.fulizaDueDate, isNull);
    });
  });

  group('fulizaRepayment', () {
    test('full repayment', () {
      const msg = 'DS2YZ00D11 Confirmed. Ksh102.68 used to fully pay your outstanding fuliza M-PESA balance on 10/11/26 at 5:00 PM. New M-PESA balance is Ksh500.00. Transaction cost, Ksh0.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'DS2YZ00D11');
      expect(result.amount, 102.68);
      expect(result.type, MpesaTransactionType.fulizaRepayment);
      expect(result.counterpartyName, 'Fuliza M-PESA Repayment');
      expect(result.newBalance, 500.00);
    });
  });

  group('airtime', () {
    test('airtime purchase', () {
      const msg = 'ET3ZA11E00 Confirmed. Ksh50.00 Airtime purchase on 8/11/26 at 6:45 PM. New M-PESA balance is Ksh450.00. Transaction cost, Ksh0.00';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, true);
      expect(result.mpesaRef, 'ET3ZA11E00');
      expect(result.amount, 50.00);
      expect(result.type, MpesaTransactionType.airtime);
      expect(result.counterpartyName, 'Safaricom Airtime');
      expect(result.newBalance, 450.00);
    });
  });

  group('invalid messages', () {
    test('empty string', () {
      final result = MpesaParser.parse('');
      
      expect(result.isValid, false);
      expect(result.errorMessage, 'Empty message');
    });

    test('failed transaction', () {
      const msg = 'Failed. Ksh100.00 sent to JOHN DOE 0712345678';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, false);
      expect(result.errorMessage, 'Not a confirmed transaction');
    });

    test('non-confirmed message', () {
      const msg = 'Pending. Ksh200.00 to MERCHANT';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, false);
      expect(result.errorMessage, 'Not a confirmed transaction');
    });

    test('confirmed but missing amount', () {
      const msg = 'FU4AB22F99 Confirmed. Sent to JOHN DOE on 1/11/26';
      final result = MpesaParser.parse(msg);
      
      expect(result.isValid, false);
      expect(result.errorMessage, 'No amount found');
    });
  });
}
