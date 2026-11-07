import '../models/recurring_model.dart';

class RecurrenceEngine {
  /// Compute the next due date given a RecurringModel or frequency + interval.
  static DateTime nextDue(RecurringModel r, {DateTime? from}) {
    final base = from ?? r.nextDueDate;
    return calculateNextDate(base, r.frequency, r.intervalCount);
  }

  static DateTime calculateNextDate(DateTime from, String frequency, int count) {
    final effectiveCount = count > 0 ? count : 1;
    return switch (frequency.toLowerCase()) {
      'daily' => from.add(Duration(days: effectiveCount)),
      'weekly' => from.add(Duration(days: 7 * effectiveCount)),
      'yearly' => DateTime(from.year + effectiveCount, from.month, from.day, from.hour, from.minute),
      _ => _addMonths(from, effectiveCount), // monthly and custom
    };
  }

  static DateTime _addMonths(DateTime d, int months) {
    int y = d.year + (d.month - 1 + months) ~/ 12;
    int m = (d.month - 1 + months) % 12 + 1;
    int day = d.day.clamp(1, _daysInMonth(y, m));
    return DateTime(y, m, day, d.hour, d.minute);
  }

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// Human-readable label for frequency.
  static String frequencyLabel(String frequency, int count) {
    final effectiveCount = count > 0 ? count : 1;
    if (effectiveCount == 1) {
      return switch (frequency.toLowerCase()) {
        'daily' => 'Daily',
        'weekly' => 'Weekly',
        'yearly' => 'Yearly',
        _ => 'Monthly',
      };
    }
    return switch (frequency.toLowerCase()) {
      'daily' => 'Every $effectiveCount days',
      'weekly' => 'Every $effectiveCount weeks',
      'yearly' => 'Every $effectiveCount years',
      _ => 'Every $effectiveCount months',
    };
  }
}
