import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/date_formatter.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == 'income';
    final total = transaction.amount + transaction.transactionCost + transaction.fulizaFee;
    final displayAmount = total > transaction.amount ? total : transaction.amount;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isIncome
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: isIncome
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
          size: 20,
        ),
      ),
      title: Text(
        transaction.header,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (transaction.description.isNotEmpty)
            Text(
              transaction.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            DateFormatter.formatRelative(transaction.transactionDate),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          if (transaction.fulizaAmount > 0)
            Text(
              'incl. Fuliza KES ${transaction.fulizaAmount.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange.shade600, fontSize: 11),
            ),
        ],
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${CurrencyFormatter.format(displayAmount)}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isIncome ? theme.colorScheme.primary : theme.colorScheme.error,
        ),
      ),
    );
  }
}
