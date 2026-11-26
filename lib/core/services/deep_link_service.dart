import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Listens to the budgetke:// (and budgetke-debug://) deep-link EventChannel and exposes a stream.
/// Routes:
///   <scheme>://add_transaction       → open Add Transaction sheet
///   <scheme>://share_text?text=...   → parse shared M-Pesa text (single or batch)
class DeepLinkService {
  static const _channel = EventChannel('budget_app/deep_link');

  static Stream<String> get links =>
      _channel.receiveBroadcastStream().cast<String>();

  static String? extractSharedText(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null || uri.host != 'share_text') return null;
    final text = uri.queryParameters['text']?.trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  /// Register handlers on a navigator key. Call once after app start.
  static StreamSubscription<String> listen(
    GlobalKey<NavigatorState> navigatorKey, {
    required VoidCallback onAddTransaction,
    void Function(String link)? onLink,
    Stream<String>? stream,
  }) {
    return (stream ?? links).listen(
      (link) {
        if (onLink != null) {
          onLink(link);
          return;
        }
        if (Uri.tryParse(link)?.host == 'add_transaction') {
          onAddTransaction();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('DeepLinkService stream error: $error');
      },
    );
  }
}
