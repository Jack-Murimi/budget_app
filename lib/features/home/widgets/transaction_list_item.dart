import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/category_icon_helper.dart';
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

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final category = transaction.categoryId != null
        ? categories.where((c) => c.id == transaction.categoryId).firstOrNull
        : null;

    final type = transaction.type;
    final isIncome = type == 'income';
    final isTransfer = type == 'transfer';

    final Color categoryColor = _parseColor(
      category?.colorHex,
      isIncome
          ? theme.colorScheme.primary
          : (isTransfer ? theme.colorScheme.tertiary : theme.colorScheme.secondary),
    );

    final IconData icon = (category != null && category.icon == 'category')
        ? CategoryIconHelper.getIcon(CategoryIconHelper.defaultIconForName(category.name), type: type)
        : CategoryIconHelper.getIcon(category?.icon, type: type);

    final fee = transaction.transactionCost + transaction.fulizaFee;
    final totalAmount = isIncome ? transaction.amount : transaction.amount + fee;

    final sign = isIncome ? '+' : (isTransfer ? '⇄ ' : '-');
    final amountColor = isIncome
        ? theme.colorScheme.primary
        : (isTransfer ? theme.colorScheme.tertiary : theme.colorScheme.error);

    String? categoryLabel;
    if (category != null) {
      if (category.parentId != null) {
        final parent = categories.where((c) => c.id == category.parentId).firstOrNull;
        categoryLabel = parent != null ? '${parent.name} > ${category.name}' : category.name;
      } else {
        categoryLabel = category.name;
      }
    }

    final relativeDate = DateFormatter.formatRelative(transaction.transactionDate);

    final semanticLabel =
        '${isIncome ? "Income" : (isTransfer ? "Transfer" : "Expense")} of ${CurrencyFormatter.format(totalAmount)}, '
        '${transaction.header}${categoryLabel != null ? ", $categoryLabel" : ""}, $relativeDate';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            Text(
              '$sign${CurrencyFormatter.format(totalAmount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
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
                    '+${CurrencyFormatter.format(fee)} fee',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 10,
                    ),
                  ),
                )
              else if (transaction.fulizaAmount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Fuliza',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
