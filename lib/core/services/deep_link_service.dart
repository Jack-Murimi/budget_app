import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Listens to the budgetke:// deep-link EventChannel and exposes a stream.
/// Routes:
///   budgetke://add_transaction  → open Add Transaction sheet
///   budgetke://scan_sms         → open SMS scan sheet
class DeepLinkService {
  static const _channel = EventChannel('budget_app/deep_link');

  static Stream<String> get links =>
      _channel.receiveBroadcastStream().cast<String>();

  /// Register handlers on a navigator key. Call once after app start.
  static StreamSubscription<String> listen(
    GlobalKey<NavigatorState> navigatorKey, {
    required VoidCallback onAddTransaction,
    required VoidCallback onScanSms,
    void Function(String link)? onLink,
    Stream<String>? stream,
  }) {
    return (stream ?? links).listen(
      (link) {
        if (onLink != null) {
          onLink(link);
          return;
        }
        if (link.startsWith('budgetke://add_transaction')) {
          onAddTransaction();
        } else if (link.startsWith('budgetke://scan_sms')) {
          onScanSms();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('DeepLinkService stream error: $error');
      },
    );
  }
}
