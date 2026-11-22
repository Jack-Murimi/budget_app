import 'package:budget_app/shared/utils/currency_formatter.dart';
import 'package:budget_app/shared/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter.formatCompact', () {
    test('formats positive and negative values across scales', () {
      expect(CurrencyFormatter.formatCompact(500), 'KES 500.00');
      expect(CurrencyFormatter.formatCompact(1500), 'KES 1.5K');
      expect(CurrencyFormatter.formatCompact(2500000), 'KES 2.5M');

      expect(CurrencyFormatter.formatCompact(-450), '-KES 450.00');
      expect(CurrencyFormatter.formatCompact(-1500), '-KES 1.5K');
      expect(CurrencyFormatter.formatCompact(-2500000), '-KES 2.5M');
    });
  });

  group('DateFormatter.formatRelative', () {
    test('uses calendar-day boundaries and handles future dates', () {
      final now = DateTime(2026, 11, 22, 14, 0);

      expect(
        DateFormatter.formatRelative(DateTime(2026, 11, 22, 0, 5), now: now),
        'Today',
      );
      expect(
        DateFormatter.formatRelative(DateTime(2026, 11, 21, 23, 55), now: now),
        'Yesterday',
      );
      expect(
        DateFormatter.formatRelative(DateTime(2026, 11, 23, 9, 0), now: now),
        'Tomorrow',
      );
      expect(
        DateFormatter.formatRelative(DateTime(2026, 11, 25, 9, 0), now: now),
        'In 3 days',
      );
      expect(
        DateFormatter.formatRelative(DateTime(2026, 11, 19, 9, 0), now: now),
        '3 days ago',
      );
      expect(
        DateFormatter.formatRelative(DateTime(2026, 10, 1, 9, 0), now: now),
        '01 Oct',
      );
    });
  });
}
