import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _fmt = NumberFormat('#,##0.00', 'en_KE');

  static String format(double amount) => 'KES ${_fmt.format(amount)}';
  static String formatCompact(double amount) {
    if (amount >= 1000000) return 'KES ${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return 'KES ${(amount / 1000).toStringAsFixed(1)}K';
    return format(amount);
  }
}
