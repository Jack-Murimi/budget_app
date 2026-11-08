import 'package:flutter/services.dart';
import '../../transactions/services/mpesa_parser.dart';
import '../../transactions/models/mpesa_parse_result.dart';

class SmsInboxScanner {
  static const _channel = MethodChannel('budget_app/sms');

  /// Reads all SMS from the inbox filtered by address containing "MPESA"
  /// or body containing "Confirmed" (the M-Pesa pattern).
  static Future<List<RawSms>> readMpesaSms() async {
    try {
      final List result =
          await _channel.invokeMethod('readMpesaSms') as List;
      return result
          .map((e) => RawSms(
                id: e['id'] as String,
                address: e['address'] as String,
                body: e['body'] as String,
                date: DateTime.fromMillisecondsSinceEpoch(e['date'] as int),
              ))
          .toList();
    } on MissingPluginException {
      return []; // not on Android
    } on PlatformException {
      return [];
    }
  }

  /// Parses the inbox and returns categorised results.
  static List<SmsParseItem> scanAndParse(List<RawSms> messages) {
    return messages.map((sms) {
      final result = MpesaParser.parse(sms.body);
      return SmsParseItem(
        raw: sms,
        result: result,
        confidence: _confidence(result),
      );
    }).toList();
  }

  static SmsConfidence _confidence(MpesaParseResult r) {
    if (!r.isValid) return SmsConfidence.unrecognised;
    if (r.type == MpesaTransactionType.unknown) return SmsConfidence.low;
    if (r.amount > 0 && r.mpesaRef.isNotEmpty) return SmsConfidence.high;
    return SmsConfidence.medium;
  }
}

enum SmsConfidence { high, medium, low, unrecognised }

class RawSms {
  final String id;
  final String address;
  final String body;
  final DateTime date;
  const RawSms({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
  });
}

class SmsParseItem {
  final RawSms raw;
  final MpesaParseResult result;
  final SmsConfidence confidence;
  const SmsParseItem({
    required this.raw,
    required this.result,
    required this.confidence,
  });
}
