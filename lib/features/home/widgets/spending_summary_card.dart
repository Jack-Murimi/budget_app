import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/motion.dart';

/// Hero card: gradient surface, oversized animated total, glass pills.
class SpendingSummaryCard extends StatelessWidget {
  final double totalSpent;
  final double totalIncome;
  final String month;

  const SpendingSummaryCard({
    super.key,
    required this.totalSpent,
    required this.totalIncome,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final net = totalIncome - totalSpent;
    final isPositive = net >= 0;
    final onHero = scheme.onPrimaryContainer;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            Color.lerp(scheme.primaryContainer, scheme.tertiaryContainer, 0.7)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onHero.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      month.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: onHero.withValues(alpha: 0.75),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: Motion.medium,
                      curve: Motion.emphasized,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? scheme.primary.withValues(alpha: 0.16)
                            : scheme.error.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: isPositive ? scheme.primary : scheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${CurrencyFormatter.format(net)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isPositive ? scheme.primary : scheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedAmount(
                    value: totalSpent,
                    format: CurrencyFormatter.format,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 40,
                      color: onHero,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.spentThisMonth,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onHero.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
                        icon: Icons.south_west_rounded,
                        label: l10n.income,
                        amount: totalIncome,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryPill(
                        icon: Icons.north_east_rounded,
                        label: l10n.expensesLabel,
                        amount: totalSpent,
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis),
                AnimatedAmount(
                  value: amount,
                  format: CurrencyFormatter.formatCompact,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
