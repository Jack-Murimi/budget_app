import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/category_icon_helper.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../categories/providers/category_providers.dart';
import '../../transactions/models/transaction_model.dart';

class TransactionListItem extends ConsumerWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final categoriesById = ref.watch(categoriesByIdProvider);
    final category = transaction.categoryId != null
        ? categoriesById[transaction.categoryId!]
        : null;

    final type = transaction.type;
    final isIncome = type == 'income';
    final isTransfer = type == 'transfer';

    final Color categoryColor = parseHexColor(
      category?.colorHex,
      fallback: isIncome
          ? theme.colorScheme.primary
          : (isTransfer ? theme.colorScheme.tertiary : theme.colorScheme.secondary),
    );

    final IconData icon = CategoryIconHelper.resolveCategoryIcon(
      iconName: category?.icon,
      categoryName: category?.name,
      type: type,
    );

    final fee = transaction.transactionCost + transaction.fulizaFee;
    final totalAmount = isIncome ? transaction.amount : transaction.amount + fee;

    final sign = isIncome ? '+' : (isTransfer ? '⇄ ' : '-');
    final amountColor = isIncome
        ? theme.colorScheme.primary
        : (isTransfer ? theme.colorScheme.tertiary : theme.colorScheme.error);

    String? categoryLabel;
    if (category != null) {
      if (category.parentId != null) {
        final parent = categoriesById[category.parentId!];
        categoryLabel = parent != null ? '${parent.name} > ${category.name}' : category.name;
      } else {
        categoryLabel = category.name;
      }
    }

    final relativeDate = DateFormatter.formatRelative(transaction.transactionDate);

    final semanticLabel = l10n.transactionSemantics(
      isIncome ? l10n.income : (isTransfer ? l10n.transfer : l10n.expense),
      CurrencyFormatter.format(totalAmount),
      transaction.header,
      categoryLabel != null ? ', $categoryLabel' : '',
      relativeDate,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(
          16,
          4,
          onDelete != null ? 4 : 16,
          4,
        ),
        horizontalTitleGap: 12,
        onTap: onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    transactionToEdit: transaction,
                  ),
                ),
              );
            },
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: categoryColor,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.header,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '$sign${CurrencyFormatter.format(totalAmount)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: l10n.deleteTransactionTooltip,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: onDelete,
              )
            : null,
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  [
                    if (transaction.description.isNotEmpty)
                      transaction.description
                    else if (categoryLabel != null)
                      categoryLabel
                    else if (transaction.mpesaRef != null && transaction.mpesaRef!.isNotEmpty)
                      transaction.mpesaRef!,
                    relativeDate,
                  ].join(' • '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (fee > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    l10n.feeBadge(CurrencyFormatter.format(fee)),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 10,
                    ),
                  ),
                ),
              if (transaction.fulizaAmount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.fulizaBadge,
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
