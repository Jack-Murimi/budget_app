import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);
  static String formatTime(DateTime dt) => DateFormat('hh:mm a').format(dt);
  static String formatDateTime(DateTime dt) => DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd MMM').format(dt);
  }
}
