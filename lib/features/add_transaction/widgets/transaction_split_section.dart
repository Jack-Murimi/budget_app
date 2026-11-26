import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/converters/cents_converter.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';

class SplitDraftRow {
  Category? category;
  final TextEditingController amountCtrl;
  final TextEditingController noteCtrl;

  SplitDraftRow({
    this.category,
    String initialAmount = '',
    String initialNote = '',
  })  : amountCtrl = TextEditingController(text: initialAmount),
        noteCtrl = TextEditingController(text: initialNote);

  void dispose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
  }
}

class TransactionSplitSection extends StatelessWidget {
  final int totalAmountCents;
  final List<SplitDraftRow> rows;
  final Map<int, Category> categoriesById;
  final ValueChanged<int> onPickCategory;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;
  final ValueChanged<int> onFillRemaining;
  final VoidCallback onChanged;

  const TransactionSplitSection({
    super.key,
    required this.totalAmountCents,
    required this.rows,
    required this.categoriesById,
    required this.onPickCategory,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onFillRemaining,
    required this.onChanged,
  });

  static int parseCents(String raw) {
    final val = double.tryParse(raw.replaceAll(',', '').trim());
    if (val == null || val <= 0) return 0;
    return CentsConverter.toCents(val);
  }

  String _catLabel(Category? cat, AppLocalizations l10n) {
    if (cat == null) return l10n.chooseCategory;
    if (cat.parentId != null) {
      final parent = categoriesById[cat.parentId!];
      if (parent != null) return '${parent.name} > ${cat.name}';
    }
    return cat.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;

    var assignedCents = 0;
    for (final row in rows) {
      assignedCents += parseCents(row.amountCtrl.text);
    }
    final remainingCents = totalAmountCents - assignedCents;
    final isBalanced = totalAmountCents > 0 && remainingCents == 0;
    final isOver = remainingCents < 0;

    final bannerBg = isBalanced
        ? cs.primaryContainer.withValues(alpha: 0.65)
        : (isOver
            ? cs.errorContainer.withValues(alpha: 0.75)
            : cs.tertiaryContainer.withValues(alpha: 0.7));
    final bannerFg = isBalanced
        ? cs.onPrimaryContainer
        : (isOver ? cs.onErrorContainer : cs.onTertiaryContainer);
    final bannerText = isBalanced
        ? l10n.splitBalanced(
            CurrencyFormatter.format(CentsConverter.fromCents(totalAmountCents)),
          )
        : (isOver
            ? l10n.splitOverAllocated(
                CurrencyFormatter.format(
                    CentsConverter.fromCents(-remainingCents)),
              )
            : l10n.splitRemainingAmount(
                CurrencyFormatter.format(
                    CentsConverter.fromCents(remainingCents)),
              ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          _SplitRowCard(
            index: i,
            row: rows[i],
            categoryLabel: _catLabel(rows[i].category, l10n),
            canRemove: rows.length > 2,
            onPickCategory: () => onPickCategory(i),
            onRemove: () => onRemoveRow(i),
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddRow,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(l10n.addSplitRow),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isBalanced
                    ? Icons.check_circle_outline_rounded
                    : (isOver
                        ? Icons.error_outline_rounded
                        : Icons.pie_chart_outline_rounded),
                size: 18,
                color: bannerFg,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bannerText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: bannerFg,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (remainingCents > 0 && rows.isNotEmpty)
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(l10n.fillRemaining),
                  onPressed: () => onFillRemaining(rows.length - 1),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplitRowCard extends StatelessWidget {
  final int index;
  final SplitDraftRow row;
  final String categoryLabel;
  final bool canRemove;
  final VoidCallback onPickCategory;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _SplitRowCard({
    required this.index,
    required this.row,
    required this.categoryLabel,
    required this.canRemove,
    required this.onPickCategory,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final cat = row.category;
    final dotColor = cat == null
        ? cs.outline
        : (tryParseHexColor(cat.colorHex) ?? cs.primary);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickCategory,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          cat == null ? Icons.category_outlined : Icons.circle,
                          size: cat == null ? 20 : 12,
                          color: dotColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            categoryLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cat == null ? cs.primary : null,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.delete,
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  key: ValueKey('split_amount_$index'),
                  controller: row.amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  key: ValueKey('split_note_$index'),
                  controller: row.noteCtrl,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: l10n.splitNoteHint,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
