import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Writes summary data to SharedPreferences and triggers an Android
/// home-screen widget refresh. No-ops gracefully on non-Android.
class WidgetUpdateService {
  static const _channel = MethodChannel('budget_app/widget');

  // Keys must match BudgetWidget.kt constants (without 'flutter.' prefix —
  // shared_preferences adds that automatically).
  static const _keySpend = 'widget_month_spend';
  static const _keyBalance = 'widget_total_balance';

  static Future<void> update({
    required double monthSpend,
    required double totalBalance,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySpend, 'KES ${monthSpend.toStringAsFixed(0)}');
      await prefs.setString(
          _keyBalance, 'KES ${totalBalance.toStringAsFixed(0)}');
      await _channel.invokeMethod('updateWidgetData');
    } on MissingPluginException {
      // Not on Android / widget not installed
    } on PlatformException {
      // ignore
    }
  }
}
