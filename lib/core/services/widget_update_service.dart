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
    SharedPreferences? prefs,
  }) async {
    try {
      final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
      final spendStr = 'KES ${monthSpend.toStringAsFixed(0)}';
      final balanceStr = 'KES ${totalBalance.toStringAsFixed(0)}';
      if (resolvedPrefs.getString(_keySpend) == spendStr &&
          resolvedPrefs.getString(_keyBalance) == balanceStr) {
        return;
      }
      await resolvedPrefs.setString(_keySpend, spendStr);
      await resolvedPrefs.setString(_keyBalance, balanceStr);
      await _channel.invokeMethod('updateWidgetData');
    } on MissingPluginException {
      // Not on Android / widget not installed
    } on PlatformException {
      // ignore
    }
  }
}
