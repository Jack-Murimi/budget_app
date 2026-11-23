import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/date_formatter.dart';

/// Date and time pickers plus Today / Yesterday quick chips.
class TransactionWhenSection extends StatelessWidget {
  final DateTime date;
  final bool showQuickChips;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final ValueChanged<int> onSelectDaysAgo;
  final InputDecoration Function(String label, IconData? icon)
      decorationBuilder;

  const TransactionWhenSection({
    super.key,
    required this.date,
    required this.showQuickChips,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSelectDaysAgo,
    required this.decorationBuilder,
  });

  bool _isDaysAgo(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return d.year == date.year && d.month == date.month && d.day == date.day;
  }

  Widget _tapField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: decorationBuilder(label, null),
        child: Text(value, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _tapField(
                l10n.date,
                DateFormatter.formatDate(date),
                onPickDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _tapField(
                l10n.time,
                TimeOfDay.fromDateTime(date).format(context),
                onPickTime,
              ),
            ),
          ],
        ),
        if (showQuickChips) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.today),
                selected: _isDaysAgo(0),
                onSelected: (_) => onSelectDaysAgo(0),
              ),
              ChoiceChip(
                label: Text(l10n.yesterday),
                selected: _isDaysAgo(1),
                onSelected: (_) => onSelectDaysAgo(1),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
