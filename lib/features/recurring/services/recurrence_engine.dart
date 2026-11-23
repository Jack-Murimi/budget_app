import '../../../l10n/l10n.dart';
import '../models/recurring_model.dart';

class RecurrenceEngine {
  /// Compute the next due date given a RecurringModel or frequency + interval.
  static DateTime nextDue(RecurringModel r, {DateTime? from}) {
    final base = from ?? r.nextDueDate;
    return calculateNextDate(
      base,
      r.frequency,
      r.intervalCount,
      anchorDay: r.startDate.day,
    );
  }

  static DateTime calculateNextDate(
    DateTime from,
    String frequency,
    int count, {
    int? anchorDay,
  }) {
    final effectiveCount = count > 0 ? count : 1;
    final targetDay = anchorDay ?? from.day;
    return switch (frequency.toLowerCase()) {
      'daily' => DateTime(
          from.year,
          from.month,
          from.day + effectiveCount,
          from.hour,
          from.minute,
        ),
      'weekly' => DateTime(
          from.year,
          from.month,
          from.day + 7 * effectiveCount,
          from.hour,
          from.minute,
        ),
      'yearly' => () {
          final y = from.year + effectiveCount;
          final day = targetDay.clamp(1, _daysInMonth(y, from.month));
          return DateTime(y, from.month, day, from.hour, from.minute);
        }(),
      _ => _addMonths(
          from,
          effectiveCount,
          anchorDay: targetDay,
        ), // monthly and custom
    };
  }

  static DateTime _addMonths(DateTime d, int months, {int? anchorDay}) {
    final y = d.year + (d.month - 1 + months) ~/ 12;
    final m = (d.month - 1 + months) % 12 + 1;
    final day = (anchorDay ?? d.day).clamp(1, _daysInMonth(y, m));
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

  /// Localized human-readable label for frequency.
  static String localizedFrequencyLabel(
    AppLocalizations l10n,
    String frequency,
    int count,
  ) {
    final effectiveCount = count > 0 ? count : 1;
    if (effectiveCount == 1) {
      return switch (frequency.toLowerCase()) {
        'daily' => l10n.daily,
        'weekly' => l10n.weekly,
        'yearly' => l10n.yearly,
        _ => l10n.monthly,
      };
    }
    return switch (frequency.toLowerCase()) {
      'daily' => l10n.everyNDays(effectiveCount),
      'weekly' => l10n.everyNWeeks(effectiveCount),
      'yearly' => l10n.everyNYears(effectiveCount),
      _ => l10n.everyNMonths(effectiveCount),
    };
  }
}
