import '../models/mpesa_parse_result.dart';

/// Parses M-Pesa SMS messages into structured data.
/// Auto-fills: ref, amount, cost, date/time, counterparty, type, balance.
/// Never fills: header, category — user must set those.
class MpesaParser {
  // Ref: 10-12 alphanumeric chars at message start (before first space)
  // e.g. UK3QX11U87, UJVQX0LSN2, UK1140IRT2
  static final _refRe = RegExp(r'^([A-Z0-9]{8,12})\s+Confirmed', multiLine: false);

  // Amount: "Ksh 70.00" or "Ksh1000" or "KSH100.00"
  static final _amountRe = RegExp(r'[Kk][Ss][Hh]\s*([\d,]+\.?\d*)');

  // Date: d/m/yy or d/m/yyyy
  static final _dateRe = RegExp(r'\b(\d{1,2})/(\d{1,2})/(\d{2,4})\b');

  // Time: 10:41 PM or 10:41PM
  static final _timeRe = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);

  // Transaction cost
  static final _costRe = RegExp(r'[Tt]ransaction cost,\s*[Kk][Ss][Hh]\s*([\d,]+\.?\d*)');

  // New balance — two formats
  static final _balRe = RegExp(r'(?:New M-PESA balance is [Kk][Ss][Hh]\s*([\d,]+\.?\d*)|M-PESA balance is ([\d,]+\.?\d*))');

  static final _fulizaAmountRe = RegExp(r'Fuliza M-PESA amount is [Kk][Ss][Hh]\s*([\d,]+\.?\d*)');
  static final _fulizaFeeRe = RegExp(r'Access Fee charged [Kk][Ss][Hh]\s*([\d,]+\.?\d*)');
  static final _fulizaOutstandingRe = RegExp(r'Total Fuliza M-PESA outstanding amount is [Kk][Ss][Hh]\s*([\d,]+\.?\d*)');
  static final _fulizaDueDateRe = RegExp(r'due on (\d{1,2})/(\d{1,2})/(\d{2,4})');

  static MpesaParseResult parse(String message) {
    final msg = message.trim();
    if (msg.isEmpty) return MpesaParseResult.invalid('Empty message');

    // Must contain "Confirmed" — reject Failed/other messages
    if (!msg.contains('Confirmed')) return MpesaParseResult.invalid('Not a confirmed transaction');

    // Extract ref
    final refMatch = _refRe.firstMatch(msg);
    final ref = refMatch?.group(1) ?? '';

    // Detect type first (drives amount extraction)
    final type = _detectType(msg);

    // Fuliza drawdown — parse its fields (caller decides what to do with it)
    if (type == MpesaTransactionType.fulizaDrawdown) {
      return _parseFulizaDrawdown(msg, ref);
    }

    // Extract amounts
    final allAmounts = _amountRe.allMatches(msg)
        .map((m) => _parseAmount(m.group(1)!))
        .where((a) => a > 0)
        .toList();

    if (allAmounts.isEmpty) return MpesaParseResult.invalid('No amount found');

    // The transaction amount is the FIRST Ksh amount in the message
    // Exception: Fuliza repayment — first amount is the repayment amount
    final amount = allAmounts.first;

    // Balance
    final balMatch = _balRe.firstMatch(msg);
    final balance = balMatch != null
        ? _parseAmount(balMatch.group(1) ?? balMatch.group(2) ?? '0')
        : (allAmounts.length > 1 ? allAmounts.last : 0.0);

    // Cost
    final costMatch = _costRe.firstMatch(msg);
    final cost = costMatch != null ? _parseAmount(costMatch.group(1)!) : 0.0;

    // Date + time
    final dateMatch = _dateRe.firstMatch(msg);
    final timeMatch = _timeRe.firstMatch(msg);
    final transactionDate = _buildDateTime(dateMatch, timeMatch);

    // Counterparty
    final (counterpartyName, counterpartyAccount) = _extractCounterparty(msg, type);

    return MpesaParseResult(
      mpesaRef: ref,
      amount: amount,
      transactionCost: cost,
      transactionDate: transactionDate,
      counterpartyName: counterpartyName,
      counterpartyAccount: counterpartyAccount,
      type: type,
      newBalance: balance,
      isValid: true,
    );
  }

  static MpesaTransactionType _detectType(String msg) {
    final lower = msg.toLowerCase();

    // Order matters — most specific first
    if (lower.contains('fuliza m-pesa amount is')) return MpesaTransactionType.fulizaDrawdown;
    if (lower.contains('used to fully pay your outstanding fuliza')) return MpesaTransactionType.fulizaRepayment;
    if (lower.contains('you have received') || lower.contains('confirmed.you have received')) return MpesaTransactionType.receiveMoney;
    if (lower.contains('airtime purchase')) return MpesaTransactionType.airtime;
    if (lower.contains('withdrawn from agent')) return MpesaTransactionType.withdraw;
    if (lower.contains('give') && lower.contains('cash to')) return MpesaTransactionType.agentCashout;
    if (lower.contains('sent to') && lower.contains('for account')) return MpesaTransactionType.paybill; // paybill with account
    if (lower.contains('sent to')) return MpesaTransactionType.sendMoney;
    if (lower.contains('paid to')) return MpesaTransactionType.paybill;

    return MpesaTransactionType.unknown;
  }

  static (String name, String account) _extractCounterparty(
      String msg, MpesaTransactionType type) {
    switch (type) {
      case MpesaTransactionType.sendMoney:
        // "sent to NAME 0712345678 on" or "sent to NAME on" (no phone)
        // Also handles double spaces in names: "JOSEPHAT  RORI"
        var m = RegExp(
          r'sent to ([A-Za-z][A-Za-z\s]+?)\s+(\d{10,12})\s+on',
          caseSensitive: false,
        ).firstMatch(msg);
        if (m != null) return (_cleanName(m.group(1)!), m.group(2)!);
        // No phone number
        m = RegExp(
          r'sent to ([A-Za-z][A-Za-z\s]+?)\s+on\s+\d',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m?.group(1) ?? ''), '');

      case MpesaTransactionType.paybill:
        // "sent to NAME for account ACCOUNT on"
        var m2 = RegExp(
          r'sent to ([A-Za-z][A-Za-z\s]+?)\s+for account\s+([^\s]+)\s+on',
          caseSensitive: false,
        ).firstMatch(msg);
        if (m2 != null) return (_cleanName(m2.group(1)!), m2.group(2) ?? '');
        // "paid to NAME. on" or "paid to NAME on"
        m2 = RegExp(
          r'paid to ([A-Za-z][A-Za-z\s\-]+?)[\.\s]+on\s',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m2?.group(1) ?? ''), '');

      case MpesaTransactionType.receiveMoney:
        // "received Ksh... from NAME 0758***343 on"
        // masked phone: 0758***343
        final m3 = RegExp(
          r'from ([A-Za-z][A-Za-z\s]+?)\s+([\d*]{10,12})\s+on',
          caseSensitive: false,
        ).firstMatch(msg);
        if (m3 != null) return (_cleanName(m3.group(1)!), m3.group(2)!);
        final m4 = RegExp(
          r'from ([A-Za-z][A-Za-z\s]+?)\s+on\s+\d',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m4?.group(1) ?? ''), '');

      case MpesaTransactionType.agentCashout:
        // "Give Ksh... cash to NAME ... New M-PESA"
        final m5 = RegExp(
          r'cash to ([A-Za-z][A-Za-z\s&]+?)(?:\s+New M-PESA|\s+You can)',
          caseSensitive: false,
        ).firstMatch(msg);
        // Name may include location suffix — take first 3 words
        final raw = m5?.group(1)?.trim() ?? '';
        return (_firstWords(raw, 4), '');

      case MpesaTransactionType.withdraw:
        final m6 = RegExp(
          r'agent\s+(\d+)\s+([A-Za-z][A-Za-z\s]+?)(?:\s+on\s|\s+\d)',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m6?.group(2) ?? ''), m6?.group(1) ?? '');

      case MpesaTransactionType.fulizaRepayment:
        return ('Fuliza M-PESA Repayment', '');

      case MpesaTransactionType.airtime:
        return ('Safaricom Airtime', '');

      default:
        return ('', '');
    }
  }

  static String _cleanName(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');
  static String _firstWords(String s, int n) =>
      s.trim().split(RegExp(r'\s+')).take(n).join(' ');

  static double _parseAmount(String s) =>
      double.tryParse(s.replaceAll(',', '')) ?? 0.0;

  static DateTime _buildDateTime(RegExpMatch? dateMatch, RegExpMatch? timeMatch) {
    final now = DateTime.now();
    int day = now.day, month = now.month, year = now.year;
    int hour = 0, minute = 0;

    if (dateMatch != null) {
      day = int.parse(dateMatch.group(1)!);
      month = int.parse(dateMatch.group(2)!);
      final rawYear = int.parse(dateMatch.group(3)!);
      year = rawYear < 100 ? 2000 + rawYear : rawYear;
    }

    if (timeMatch != null) {
      hour = int.parse(timeMatch.group(1)!);
      minute = int.parse(timeMatch.group(2)!);
      final ampm = timeMatch.group(3)!.toUpperCase();
      if (ampm == 'PM' && hour != 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
    }

    return DateTime(year, month, day, hour, minute);
  }

  static MpesaParseResult _parseFulizaDrawdown(String msg, String ref) {
    final amountMatch = _fulizaAmountRe.firstMatch(msg);
    final feeMatch = _fulizaFeeRe.firstMatch(msg);
    final outstandingMatch = _fulizaOutstandingRe.firstMatch(msg);
    final dueDateMatch = _fulizaDueDateRe.firstMatch(msg);

    final fulizaAmount = amountMatch != null ? _parseAmount(amountMatch.group(1)!) : 0.0;
    final accessFee = feeMatch != null ? _parseAmount(feeMatch.group(1)!) : 0.0;
    final outstanding = outstandingMatch != null ? _parseAmount(outstandingMatch.group(1)!) : 0.0;

    DateTime? dueDate;
    if (dueDateMatch != null) {
      final d = int.parse(dueDateMatch.group(1)!);
      final mo = int.parse(dueDateMatch.group(2)!);
      final rawY = int.parse(dueDateMatch.group(3)!);
      final y = rawY < 100 ? 2000 + rawY : rawY;
      dueDate = DateTime(y, mo, d);
    }

    return MpesaParseResult(
      mpesaRef: ref,
      amount: fulizaAmount, // the Fuliza amount used
      transactionCost: 0,
      transactionDate: DateTime.now(),
      counterpartyName: '',
      counterpartyAccount: '',
      type: MpesaTransactionType.fulizaDrawdown,
      newBalance: 0,
      isValid: true,
      fulizaAmount: fulizaAmount,
      fulizaAccessFee: accessFee,
      outstandingTotal: outstanding,
      fulizaDueDate: dueDate,
    );
  }
}
