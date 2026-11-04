// Run: dart lib/features/transactions/services/mpesa_parser_test.dart
// ignore_for_file: avoid_print
import 'mpesa_parser.dart';
import '../models/mpesa_parse_result.dart';

void main() {
  int passed = 0;
  int failed = 0;

  void check(String label, bool condition) {
    if (!condition) {
      print('FAIL: $label');
      failed++;
    } else {
      print('PASS: $label');
      passed++;
    }
  }

  // ── Send Money with phone ──
  final send = MpesaParser.parse(
    'UK3QX11WX8 Confirmed. Ksh220.00 sent to JOSEPHAT  RORI 0703701764 on 3/11/26 at 10:29 PM. New M-PESA balance is Ksh0.00. Transaction cost, Ksh7.00.');
  check('send isValid', send.isValid);
  check('send ref', send.mpesaRef == 'UK3QX11WX8');
  check('send amount', send.amount == 220.00);
  check('send cost', send.transactionCost == 7.00);
  check('send type', send.type == MpesaTransactionType.sendMoney);
  check('send counterparty', send.counterpartyName.contains('JOSEPHAT'));
  check('send account', send.counterpartyAccount == '0703701764');
  check('send date day=3', send.transactionDate.day == 3);
  check('send date month=11', send.transactionDate.month == 11);
  check('send time 22:29', send.transactionDate.hour == 22 && send.transactionDate.minute == 29);

  // ── Send Money no phone ──
  final sendNoPhone = MpesaParser.parse(
    'UK3QX0YHOV Confirmed. Ksh100.00 sent to Gideon  Mwangi 0745811254 on 3/11/26 at 11:23 AM. New M-PESA balance is Ksh14,041.34. Transaction cost, Ksh0.00.');
  check('sendPhone isValid', sendNoPhone.isValid);
  check('sendPhone ref', sendNoPhone.mpesaRef == 'UK3QX0YHOV');
  check('sendPhone counterparty', sendNoPhone.counterpartyName.contains('Gideon'));

  // ── Paybill (paid to) ──
  final paybill = MpesaParser.parse(
    'UK2QX0UQCW Confirmed. Ksh5,650.00 paid to REMTAK LIMITED. on 2/11/26 at 2:40 PM.New M-PESA balance is Ksh416.46. Transaction cost, Ksh0.00.');
  check('paybill isValid', paybill.isValid);
  check('paybill ref', paybill.mpesaRef == 'UK2QX0UQCW');
  check('paybill amount', paybill.amount == 5650.00);
  check('paybill type', paybill.type == MpesaTransactionType.paybill);
  check('paybill counterparty', paybill.counterpartyName.toUpperCase().contains('REMTAK'));
  check('paybill hour=14', paybill.transactionDate.hour == 14);

  // ── Paybill with account (sent to ... for account) ──
  final paybillAcct = MpesaParser.parse(
    'UK3QX0YQW4 Confirmed. Ksh35,485.00 sent to Equity Paybill Account for account 497456#Loresho_44 on 3/11/26 at 11:57 AM New M-PESA balance is Ksh722.34. Transaction cost, Ksh99.00.');
  check('paybillAcct isValid', paybillAcct.isValid);
  check('paybillAcct amount', paybillAcct.amount == 35485.00);
  check('paybillAcct type', paybillAcct.type == MpesaTransactionType.paybill);
  check('paybillAcct account', paybillAcct.counterpartyAccount.contains('497456'));
  check('paybillAcct cost', paybillAcct.transactionCost == 99.00);

  // ── Receive Money (masked phone) ──
  final receive = MpesaParser.parse(
    'UK1140IRT2 Confirmed.You have received Ksh1,000.00 from TORY  RUKWARO 0758***343 on 1/11/26 at 6:52 PM  New M-PESA balance is Ksh1,336.46.');
  check('receive isValid', receive.isValid);
  check('receive ref', receive.mpesaRef == 'UK1140IRT2');
  check('receive amount', receive.amount == 1000.00);
  check('receive type income', receive.type == MpesaTransactionType.receiveMoney);
  check('receive counterparty', receive.counterpartyName.contains('TORY'));

  // ── Agent Cashout (Give Ksh cash to) ──
  final cashout = MpesaParser.parse(
    'UK3QX0YLCB Confirmed. On 3/11/26 at 11:54 AM Give Ksh7,165.00 cash to Leemax Investment Ltd CHINI YA MWAMBA FASHION DESIGNS BUSIA AGG New M-PESA balance is Ksh36,306.34. You can now access M-PESA via *334#');
  check('cashout isValid', cashout.isValid);
  check('cashout ref', cashout.mpesaRef == 'UK3QX0YLCB');
  check('cashout amount', cashout.amount == 7165.00);
  check('cashout type', cashout.type == MpesaTransactionType.agentCashout);
  check('cashout counterparty not empty', cashout.counterpartyName.isNotEmpty);

  // ── Fuliza Drawdown — parsed with Fuliza fields ──
  final fulizaDown = MpesaParser.parse(
    'UK3QX11U87 Confirmed. Fuliza M-PESA amount is Ksh 70.00. Access Fee charged Ksh 0.70. Total Fuliza M-PESA outstanding amount is Ksh102.68 due on 03/12/26.');
  check('fulizaDown isValid', fulizaDown.isValid);
  check('fulizaDown ref', fulizaDown.mpesaRef == 'UK3QX11U87');
  check('fulizaDown amount', fulizaDown.fulizaAmount == 70.00);
  check('fulizaDown fee', fulizaDown.fulizaAccessFee == 0.70);
  check('fulizaDown outstanding', fulizaDown.outstandingTotal == 102.68);
  check('fulizaDown dueDate', fulizaDown.fulizaDueDate == DateTime(2026, 12, 3));

  // ── Fuliza Repayment — IS a real transaction ──
  final fulizaRep = MpesaParser.parse(
    'UK3QX0Y7E6 Confirmed. Ksh 718.66 from your M-PESA has been used to fully pay your outstanding Fuliza M-PESA. Available Fuliza M-PESA limit is Ksh 800.00. Your M-PESA balance is 14281.34.');
  check('fulizaRep isValid', fulizaRep.isValid);
  check('fulizaRep ref', fulizaRep.mpesaRef == 'UK3QX0Y7E6');
  check('fulizaRep amount', fulizaRep.amount == 718.66);
  check('fulizaRep type', fulizaRep.type == MpesaTransactionType.fulizaRepayment);

  // ── Failed message — must be invalid ──
  final failed_ = MpesaParser.parse(
    'Failed. Insufficient funds in your M-PESA account as well as Fuliza M-PESA to send KSH100.00.');
  check('failed NOT valid', !failed_.isValid);

  // ── Amount with space: "Ksh 70.00" ──
  final spaceAmt = MpesaParser.parse(
    'UK3QX11U87 Confirmed. Ksh70.00 sent to CASCADE INDUSTRIES LTD for account 254715485059 on 3/11/26 at 10:41 PM New M-PESA balance is Ksh0.00. Transaction cost, Ksh0.00.');
  check('spaceAmt isValid', spaceAmt.isValid);
  check('spaceAmt amount', spaceAmt.amount == 70.00);
  check('spaceAmt ref', spaceAmt.mpesaRef == 'UK3QX11U87');

  print('\n${passed + failed} checks: $passed passed, $failed failed');
  if (failed > 0) throw Exception('$failed tests FAILED');
  print('✅ All parser tests passed');
}
