import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../main.dart';
import '../providers/backup_reminder_provider.dart';
import '../screens/data_portability_screen.dart';

class BackupReminderBanner extends ConsumerWidget {
  final EdgeInsetsGeometry padding;

  const BackupReminderBanner({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(backupReminderProvider);
    final hasTxns = ref.watch(hasAnyTransactionsProvider).valueOrNull ?? false;

    if (!reminder.shouldShow(hasTransactions: hasTxns)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final days = reminder.daysSinceLastBackup();
    final subtitle = days == null
        ? l10n.backupReminderNever
        : l10n.backupReminderDaysAgo(days);

    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: cs.secondaryContainer.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.secondary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                color: cs.onSecondaryContainer,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.backupReminderTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DataPortabilityScreen(
                    db: ref.read(dbProvider),
                    onBackupCompleted: () => ref
                        .read(backupReminderProvider.notifier)
                        .markBackedUp(),
                  ),
                ),
              ),
              child: Text(l10n.backupNow),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: cs.onSecondaryContainer,
              ),
              tooltip: l10n.dismissBackupReminder,
              visualDensity: VisualDensity.compact,
              onPressed: () =>
                  ref.read(backupReminderProvider.notifier).dismiss(),
            ),
          ],
        ),
      ),
    );
  }
}
