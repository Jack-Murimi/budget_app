import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _fmt = NumberFormat('#,##0.00', 'en_KE');

  static String format(double amount) => 'KES ${_fmt.format(amount)}';
  static String formatCompact(double amount) {
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();
    if (abs >= 1000000) return '${sign}KES ${(abs / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${sign}KES ${(abs / 1000).toStringAsFixed(1)}K';
    return '${sign}KES ${_fmt.format(abs)}';
  }
}
