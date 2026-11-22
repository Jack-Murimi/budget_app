import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);
  static String formatTime(DateTime dt) => DateFormat('hh:mm a').format(dt);
  static String formatDateTime(DateTime dt) => DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  static String formatRelative(DateTime dt, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(target).inDays;
    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (diffDays == -1) return 'Tomorrow';
    if (diffDays < -1 && diffDays > -7) return 'In ${-diffDays} days';
    if (diffDays > 1 && diffDays < 7) return '$diffDays days ago';
    return DateFormat('dd MMM').format(dt);
  }
}
