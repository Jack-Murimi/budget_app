import '../models/mpesa_parse_result.dart';

/// Result of splitting and parsing a multi-message M-Pesa text block.
class MpesaBatchSplit {
  final List<MpesaParseResult> valid;
  final List<String> unparsedSegments;

  const MpesaBatchSplit({
    required this.valid,
    required this.unparsedSegments,
  });
}

/// Parses M-Pesa SMS messages into structured data.
/// Auto-fills: ref, amount, cost, date/time, counterparty, type, balance.
/// Never fills: header, category — user must set those.
class MpesaParser {
  // Ref: 8-12 alphanumeric chars at message start (before first space)
  static final _refRe = RegExp(r'^([A-Z0-9]{8,12})\s+Confirmed', multiLine: false);

  // Batch anchor: transaction reference followed by "Confirmed"
  static final _batchAnchorRe = RegExp(
    r'(?:^|[\s\n])([A-Z0-9]{8,12}\s+Confirmed\b)',
    multiLine: true,
  );

  // Pure sender/timestamp prefix lines like "[12/11, 14:30] MPESA:" or "M-PESA:"
  static final _senderPrefixLineRe = RegExp(
    r'^\s*(?:\[?\d{1,2}/\d{1,2}(?:/\d{2,4})?(?:[,\s]+\d{1,2}:\d{2}(?:\s*(?:AM|PM))?)?\]?\s*)?M-?PESA\s*:?\s*$',
    caseSensitive: false,
  );
  static final _trailingSenderPrefixRe = RegExp(
    r'(?:^|\n)\s*(?:\[?\d{1,2}/\d{1,2}(?:/\d{2,4})?(?:[,\s]+\d{1,2}:\d{2}(?:\s*(?:AM|PM))?)?\]?\s*)?M-?PESA\s*:?\s*$',
    caseSensitive: false,
  );
  static final _inlineSenderPrefixRe = RegExp(
    r'^\s*(?:\[?\d{1,2}/\d{1,2}(?:/\d{2,4})?(?:[,\s]+\d{1,2}:\d{2}(?:\s*(?:AM|PM))?)?\]?\s*)?M-?PESA\s*:?\s*$',
    caseSensitive: false,
  );

  // Amount: "Ksh 70.00" or "Ksh1000" or "KSH100.00"
  static final _amountRe = RegExp(r'[Kk][Ss][Hh]\s*([\d,]+\.?\d*)');

  // Date: d/m/yy or d/m/yyyy
  static final _dateRe = RegExp(r'\b(\d{1,2})/(\d{1,2})/(\d{2,4})\b');

  // Time: 10:41 PM or 10:41PM
  static final _timeRe =
      RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);

  // Transaction cost
  static final _costRe =
      RegExp(r'[Tt]ransaction cost,\s*[Kk][Ss][Hh]\s*([\d,]+\.?\d*)');

  // New balance — handles "New M-PESA balance is Ksh...", "New MPESA balance is...", "M-PESA balance is..."
  static final _balRe = RegExp(
    r'(?:New\s+)?M-?PESA\s+balance\s+is\s+(?:[Kk][Ss][Hh]\s*)?([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  static final _fulizaAmountRe =
      RegExp(r'Fuliza M-PESA amount is [Kk][Ss][Hh]\s*([\d,]+\.?\d*)');
  static final _fulizaFeeRe =
      RegExp(r'Access Fee charged [Kk][Ss][Hh]\s*([\d,]+\.?\d*)');
  static final _fulizaOutstandingRe = RegExp(
    r'(?:Total\s+)?Fuliza\s+M-PESA\s+outstanding\s+amount\s+is\s+[Kk][Ss][Hh]\s*([\d,]+\.?\d*)',
    caseSensitive: false,
  );
  static final _fulizaDueDateRe =
      RegExp(r'due on (\d{1,2})/(\d{1,2})/(\d{2,4})', caseSensitive: false);
  static final _fulizaRepayRe = RegExp(
    r'used to (?:fully|partially) pay your outstanding fuliza',
    caseSensitive: false,
  );

  // Supports Kenyan names/merchants with letters, digits, spaces, hyphens,
  // apostrophes, dots, ampersands, and slashes.
  static const _nameChars = r"[A-Za-z0-9][A-Za-z0-9\s\-'.&/]+?";
  static const _phoneChars = r'\+?[\d*]{10,13}';

  /// Splits a clipboard/shared text block containing one or more M-Pesa SMS
  /// messages and parses each segment individually.
  static MpesaBatchSplit parseBatch(String rawBlock, {DateTime? fallbackDate}) {
    final normalized = rawBlock.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      return const MpesaBatchSplit(valid: [], unparsedSegments: []);
    }

    final valid = <MpesaParseResult>[];
    final unparsed = <String>[];

    final matches = _batchAnchorRe.allMatches(normalized).toList();
    if (matches.isEmpty) {
      final chunks = normalized
          .split(RegExp(r'\n\s*\n+'))
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty);
      for (final chunk in chunks) {
        final parsed = parse(chunk, fallbackDate: fallbackDate);
        if (parsed.isValid) {
          valid.add(parsed);
        } else {
          unparsed.add(chunk);
        }
      }
      return MpesaBatchSplit(valid: valid, unparsedSegments: unparsed);
    }

    int group1Start(RegExpMatch m) {
      final full = m.group(0)!;
      final g1 = m.group(1)!;
      return m.start + full.indexOf(g1);
    }

    final firstStart = group1Start(matches.first);
    if (firstStart > 0) {
      final leading = normalized.substring(0, firstStart).trim();
      if (leading.isNotEmpty &&
          !_senderPrefixLineRe.hasMatch(leading) &&
          !_inlineSenderPrefixRe.hasMatch(leading)) {
        final parsedLeading = parse(leading, fallbackDate: fallbackDate);
        if (parsedLeading.isValid) {
          valid.add(parsedLeading);
        } else {
          unparsed.add(leading);
        }
      }
    }

    for (var i = 0; i < matches.length; i++) {
      final start = group1Start(matches[i]);
      final end = (i + 1 < matches.length)
          ? group1Start(matches[i + 1])
          : normalized.length;
      var slice = normalized.substring(start, end).trim();
      if (i + 1 < matches.length) {
        slice = slice.replaceFirst(_trailingSenderPrefixRe, '').trim();
      }
      if (slice.isEmpty) continue;
      final parsed = parse(slice, fallbackDate: fallbackDate);
      if (parsed.isValid) {
        valid.add(parsed);
      } else {
        unparsed.add(slice);
      }
    }

    return MpesaBatchSplit(valid: valid, unparsedSegments: unparsed);
  }

  static MpesaParseResult parse(String message, {DateTime? fallbackDate}) {
    final msg = message.trim();
    if (msg.isEmpty) return MpesaParseResult.invalid('Empty message');

    // Must contain "Confirmed" — reject Failed/other messages
    if (!msg.contains('Confirmed')) {
      return MpesaParseResult.invalid('Not a confirmed transaction');
    }

    final refMatch = _refRe.firstMatch(msg);
    final ref = refMatch?.group(1) ?? '';

    final type = _detectType(msg);

    if (type == MpesaTransactionType.fulizaDrawdown) {
      return _parseFulizaDrawdown(msg, ref, fallbackDate: fallbackDate);
    }

    if (type == MpesaTransactionType.reversal) {
      return _parseReversal(msg, ref, fallbackDate: fallbackDate);
    }

    final allAmounts = _amountRe
        .allMatches(msg)
        .map((m) => _parseAmount(m.group(1)!))
        .where((a) => a > 0)
        .toList();

    if (allAmounts.isEmpty) return MpesaParseResult.invalid('No amount found');

    // First Ksh amount is the transaction amount (repayment amount for Fuliza repayment).
    final amount = allAmounts.first;

    // Extract balance strictly from explicit M-Pesa balance text (never guess allAmounts.last,
    // which could capture daily transaction limits like Ksh499,500.00).
    final balMatch = _balRe.firstMatch(msg);
    final balance =
        balMatch != null ? _parseAmount(balMatch.group(1) ?? '0') : 0.0;

    final costMatch = _costRe.firstMatch(msg);
    final cost = costMatch != null ? _parseAmount(costMatch.group(1)!) : 0.0;

    final dateMatch = _dateRe.firstMatch(msg);
    final timeMatch = _timeRe.firstMatch(msg);
    final transactionDate =
        _buildDateTime(dateMatch, timeMatch, fallbackDate: fallbackDate);

    final (counterpartyName, counterpartyAccount) =
        _extractCounterparty(msg, type);

    final typeOverride = _resolveDirectionOverride(msg, type);

    var isFullFulizaRepay = false;
    var hasExplicitOutstanding = false;
    var outstandingTotal = 0.0;
    if (type == MpesaTransactionType.fulizaRepayment) {
      final lower = msg.toLowerCase();
      isFullFulizaRepay = lower.contains('fully pay');
      final outMatch = _fulizaOutstandingRe.firstMatch(msg);
      if (outMatch != null) {
        outstandingTotal = _parseAmount(outMatch.group(1)!);
        hasExplicitOutstanding = true;
      } else if (isFullFulizaRepay) {
        outstandingTotal = 0.0;
        hasExplicitOutstanding = true;
      }
    }

    return MpesaParseResult(
      mpesaRef: ref,
      amount: amount,
      transactionCost: cost,
      transactionDate: transactionDate,
      counterpartyName: counterpartyName,
      counterpartyAccount: counterpartyAccount,
      type: type,
      transactionTypeOverride: typeOverride,
      newBalance: balance,
      isValid: true,
      outstandingTotal: outstandingTotal,
      isFullFulizaRepayment: isFullFulizaRepay,
      hasExplicitFulizaOutstanding: hasExplicitOutstanding,
    );
  }

  static MpesaTransactionType _detectType(String msg) {
    final lower = msg.toLowerCase();

    // Most specific first
    if (lower.contains('fuliza m-pesa amount is')) {
      return MpesaTransactionType.fulizaDrawdown;
    }
    if (_fulizaRepayRe.hasMatch(msg)) {
      return MpesaTransactionType.fulizaRepayment;
    }

    if (lower.contains('has been reversed') || lower.contains('reversal of')) {
      return MpesaTransactionType.reversal;
    }

    // Pochi la Biashara — check BEFORE receiveMoney/paid/sent
    if (lower.contains('pochi la biashara')) {
      return MpesaTransactionType.pochiLaBiashara;
    }

    if (lower.contains('you have received') ||
        lower.contains('confirmed.you have received')) {
      return MpesaTransactionType.receiveMoney;
    }
    if (lower.contains('airtime purchase')) {
      return MpesaTransactionType.airtime;
    }
    if (lower.contains('withdrawn from agent')) {
      return MpesaTransactionType.withdraw;
    }
    if (lower.contains('give') && lower.contains('cash to')) {
      return MpesaTransactionType.agentCashout;
    }

    // M-Shwari
    if (lower.contains('m-shwari loan') && lower.contains('disbursed')) {
      return MpesaTransactionType.mShwariLoan;
    }
    if (lower.contains('m-shwari loan') && lower.contains('repayment')) {
      return MpesaTransactionType.mShwariRepayment;
    }
    if (lower.contains('m-shwari lock savings') ||
        lower.contains('m-shwari savings') ||
        lower.contains('transferred to m-shwari') ||
        lower.contains('transferred from m-shwari') ||
        lower.contains('deposited to m-shwari') ||
        lower.contains('withdrawn from m-shwari')) {
      return MpesaTransactionType.mShwariSavings;
    }

    // Buy Goods (Till) — "paid to <MERCHANT>" without an account reference
    if (lower.contains('paid to') && !lower.contains('for account')) {
      return MpesaTransactionType.buyGoods;
    }

    if (lower.contains('for account')) return MpesaTransactionType.paybill;
    if (lower.contains('sent to') ||
        (lower.contains('sent ') && lower.contains(' to '))) {
      return MpesaTransactionType.sendMoney;
    }
    if (lower.contains('paid to')) return MpesaTransactionType.paybill;

    return MpesaTransactionType.unknown;
  }

  static String? _resolveDirectionOverride(
      String msg, MpesaTransactionType type) {
    final lower = msg.toLowerCase();
    if (type == MpesaTransactionType.pochiLaBiashara) {
      final isInflow = lower.contains('received') &&
          !lower.contains('paid to') &&
          !lower.contains('sent to') &&
          !lower.contains('paid ksh');
      return isInflow ? 'income' : 'expense';
    }
    if (type == MpesaTransactionType.mShwariSavings) {
      final isWithdrawal = lower.contains('from m-shwari') ||
          lower.contains('withdrawn') ||
          lower.contains('unlocked') ||
          lower.contains('received');
      return isWithdrawal ? 'income' : 'transfer';
    }
    return null;
  }

  static (String name, String account) _extractCounterparty(
      String msg, MpesaTransactionType type) {
    switch (type) {
      case MpesaTransactionType.sendMoney:
        var m = RegExp(
          'sent\\s+(?:[Kk][Ss][Hh]\\s*[\\d,]+\\.?\\d*\\s+)?to\\s+($_nameChars)\\s+($_phoneChars)\\s+on',
          caseSensitive: false,
        ).firstMatch(msg);
        if (m != null) return (_cleanName(m.group(1)!), m.group(2)!);
        m = RegExp(
          'sent\\s+(?:[Kk][Ss][Hh]\\s*[\\d,]+\\.?\\d*\\s+)?to\\s+($_nameChars)(?:\\s*\\.\\s*|\\s+)on\\s+\\d',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m?.group(1) ?? ''), '');

      case MpesaTransactionType.paybill:
        var m2 = RegExp(
          'sent\\s+to\\s+($_nameChars)\\s+for account\\s+([^\\s]+)\\s+on',
          caseSensitive: false,
        ).firstMatch(msg);
        if (m2 != null) return (_cleanName(m2.group(1)!), m2.group(2) ?? '');
        m2 = RegExp(
          'paid\\s+to\\s+($_nameChars)(?:\\s*\\.\\s*|\\s+)on\\s',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m2?.group(1) ?? ''), '');

      case MpesaTransactionType.buyGoods:
        final mg = RegExp(
          'paid\\s+to\\s+($_nameChars)(?:\\s*\\.\\s*|\\s+)on\\s',
          caseSensitive: false,
        ).firstMatch(msg);
        final till = RegExp(r'[Tt]ill\s+(\d+)').firstMatch(msg);
        return (_cleanName(mg?.group(1) ?? ''), till?.group(1) ?? '');

      case MpesaTransactionType.receiveMoney:
        final m3 = RegExp(
          'from\\s+($_nameChars)\\s+($_phoneChars)\\s+on',
          caseSensitive: false,
        ).firstMatch(msg);
        if (m3 != null) return (_cleanName(m3.group(1)!), m3.group(2)!);
        final m4 = RegExp(
          'from\\s+($_nameChars)(?:\\s*\\.\\s*|\\s+)on\\s+\\d',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m4?.group(1) ?? ''), '');

      case MpesaTransactionType.agentCashout:
        final m5 = RegExp(
          'cash\\s+to\\s+($_nameChars)(?:\\s+New\\s+M-?PESA|\\s+You\\s+can)',
          caseSensitive: false,
        ).firstMatch(msg);
        final raw = m5?.group(1)?.trim() ?? '';
        return (_firstWords(raw, 4), '');

      case MpesaTransactionType.withdraw:
        final m6 = RegExp(
          'agent\\s+(\\d+)\\s+($_nameChars)(?:\\s+on\\s|\\s+\\d)',
          caseSensitive: false,
        ).firstMatch(msg);
        return (_cleanName(m6?.group(2) ?? ''), m6?.group(1) ?? '');

      case MpesaTransactionType.pochiLaBiashara:
        final dir = _resolveDirectionOverride(msg, type);
        if (dir == 'income') {
          final inflow = RegExp(
            'received\\s+[Kk][Ss][Hh]\\s*[\\d,]+\\.?\\d*\\s+from\\s+($_nameChars)(?:\\s+($_phoneChars))?(?:\\s+via|\\s+on\\s|\\.)',
            caseSensitive: false,
          ).firstMatch(msg);
          if (inflow != null) {
            return (_cleanName(inflow.group(1)!), inflow.group(2) ?? '');
          }
        }
        final outflow = RegExp(
          '(?:sent|paid)\\s+(?:[Kk][Ss][Hh]\\s*[\\d,]+\\.?\\d*\\s+)?to\\s+($_nameChars)(?:\\s+($_phoneChars))?(?:\\s+via|\\s+on\\s|\\.)',
          caseSensitive: false,
        ).firstMatch(msg);
        if (outflow != null) {
          return (_cleanName(outflow.group(1)!), outflow.group(2) ?? '');
        }
        return ('Pochi la Biashara', '');

      case MpesaTransactionType.mShwariLoan:
        return ('M-Shwari Loan', '');

      case MpesaTransactionType.mShwariRepayment:
        return ('M-Shwari Repayment', '');

      case MpesaTransactionType.mShwariSavings:
        final dir = _resolveDirectionOverride(msg, type);
        return (
          dir == 'income'
              ? 'M-Shwari Savings Withdrawal'
              : 'M-Shwari Savings Deposit',
          '',
        );

      case MpesaTransactionType.reversal:
        final origRef =
            RegExp(r'[Tt]ransaction\s+([A-Z0-9]{8,12})\s+of').firstMatch(msg);
        return ('Reversal', origRef?.group(1) ?? '');

      case MpesaTransactionType.fulizaRepayment:
        return ('Fuliza M-PESA Repayment', '');

      case MpesaTransactionType.airtime:
        return ('Safaricom Airtime', '');

      default:
        return ('', '');
    }
  }

  static String _cleanName(String s) => s
      .trim()
      .replaceAll(RegExp(r'\.+$'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
  static String _firstWords(String s, int n) =>
      s.trim().split(RegExp(r'\s+')).take(n).join(' ');

  static double _parseAmount(String s) =>
      double.tryParse(s.replaceAll(',', '')) ?? 0.0;

  static DateTime _buildDateTime(
    RegExpMatch? dateMatch,
    RegExpMatch? timeMatch, {
    DateTime? fallbackDate,
  }) {
    if (dateMatch == null && timeMatch == null && fallbackDate != null) {
      return fallbackDate;
    }

    final base = fallbackDate ?? DateTime.now();
    int day = base.day, month = base.month, year = base.year;
    int hour = 0, minute = 0;

    if (dateMatch != null) {
      day = int.parse(dateMatch.group(1)!);
      month = int.parse(dateMatch.group(2)!);
      final rawYear = int.parse(dateMatch.group(3)!);
      year = rawYear < 100 ? 2000 + rawYear : rawYear;
    } else if (fallbackDate != null) {
      hour = fallbackDate.hour;
      minute = fallbackDate.minute;
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

  static MpesaParseResult _parseFulizaDrawdown(
    String msg,
    String ref, {
    DateTime? fallbackDate,
  }) {
    final amountMatch = _fulizaAmountRe.firstMatch(msg);
    final feeMatch = _fulizaFeeRe.firstMatch(msg);
    final outstandingMatch = _fulizaOutstandingRe.firstMatch(msg);
    final dueDateMatch = _fulizaDueDateRe.firstMatch(msg);

    final fulizaAmount =
        amountMatch != null ? _parseAmount(amountMatch.group(1)!) : 0.0;
    final accessFee =
        feeMatch != null ? _parseAmount(feeMatch.group(1)!) : 0.0;
    final outstanding = outstandingMatch != null
        ? _parseAmount(outstandingMatch.group(1)!)
        : 0.0;

    DateTime? dueDate;
    if (dueDateMatch != null) {
      final d = int.parse(dueDateMatch.group(1)!);
      final mo = int.parse(dueDateMatch.group(2)!);
      final rawY = int.parse(dueDateMatch.group(3)!);
      final y = rawY < 100 ? 2000 + rawY : rawY;
      dueDate = DateTime(y, mo, d);
    }

    // Strip the "due on dd/mm/yy" clause before scanning for transaction date
    // so the due date is never misread as the transaction date.
    final msgWithoutDue = msg.replaceAll(_fulizaDueDateRe, '');
    final dateMatch = _dateRe.firstMatch(msgWithoutDue);
    final timeMatch = _timeRe.firstMatch(msgWithoutDue);
    final transactionDate =
        _buildDateTime(dateMatch, timeMatch, fallbackDate: fallbackDate);

    return MpesaParseResult(
      mpesaRef: ref,
      amount: fulizaAmount,
      transactionCost: 0,
      transactionDate: transactionDate,
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

  static MpesaParseResult _parseReversal(
    String msg,
    String ref, {
    DateTime? fallbackDate,
  }) {
    final allAmounts = _amountRe
        .allMatches(msg)
        .map((m) => _parseAmount(m.group(1)!))
        .where((a) => a > 0)
        .toList();
    final amount = allAmounts.isNotEmpty ? allAmounts.first : 0.0;
    final dateMatch = _dateRe.firstMatch(msg);
    final timeMatch = _timeRe.firstMatch(msg);
    final origRef =
        RegExp(r'[Tt]ransaction\s+([A-Z0-9]{8,12})\s+of').firstMatch(msg);
    final balMatch = _balRe.firstMatch(msg);
    final balance =
        balMatch != null ? _parseAmount(balMatch.group(1) ?? '0') : 0.0;

    return MpesaParseResult(
      mpesaRef: ref,
      amount: amount,
      transactionCost: 0,
      transactionDate:
          _buildDateTime(dateMatch, timeMatch, fallbackDate: fallbackDate),
      counterpartyName: 'Reversal',
      counterpartyAccount: origRef?.group(1) ?? '',
      type: MpesaTransactionType.reversal,
      newBalance: balance,
      isValid: true,
    );
  }
}
