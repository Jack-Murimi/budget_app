import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../shared/providers/theme_provider.dart';

const kLastBackupAtKey = 'last_backup_at';
const kBackupReminderDismissedAtKey = 'backup_reminder_dismissed_at';
const kBackupReminderInterval = Duration(days: 30);

class BackupReminderState {
  final DateTime? lastBackupAt;
  final DateTime? dismissedAt;
  final bool isTrackingEnabled;

  const BackupReminderState({
    this.lastBackupAt,
    this.dismissedAt,
    this.isTrackingEnabled = true,
  });

  int? daysSinceLastBackup({DateTime? now}) {
    if (lastBackupAt == null) return null;
    final diff = (now ?? DateTime.now()).difference(lastBackupAt!).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool shouldShow({required bool hasTransactions, DateTime? now}) {
    if (!isTrackingEnabled || !hasTransactions) return false;
    final current = now ?? DateTime.now();
    if (lastBackupAt != null &&
        current.difference(lastBackupAt!) < kBackupReminderInterval) {
      return false;
    }
    if (dismissedAt != null &&
        current.difference(dismissedAt!) < kBackupReminderInterval) {
      return false;
    }
    return true;
  }
}

class BackupReminderNotifier extends Notifier<BackupReminderState> {
  @override
  BackupReminderState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    if (prefs == null) {
      return const BackupReminderState(isTrackingEnabled: false);
    }
    final lastMs = prefs.getInt(kLastBackupAtKey);
    final dismissedMs = prefs.getInt(kBackupReminderDismissedAtKey);
    return BackupReminderState(
      lastBackupAt: lastMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastMs)
          : null,
      dismissedAt: dismissedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(dismissedMs)
          : null,
      isTrackingEnabled: true,
    );
  }

  Future<void> markBackedUp([DateTime? when]) async {
    final timestamp = when ?? DateTime.now();
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs != null) {
      await prefs.setInt(kLastBackupAtKey, timestamp.millisecondsSinceEpoch);
      await prefs.remove(kBackupReminderDismissedAtKey);
    }
    state = BackupReminderState(
      lastBackupAt: timestamp,
      dismissedAt: null,
      isTrackingEnabled: state.isTrackingEnabled || prefs != null,
    );
  }

  Future<void> dismiss([DateTime? when]) async {
    final timestamp = when ?? DateTime.now();
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs != null) {
      await prefs.setInt(
        kBackupReminderDismissedAtKey,
        timestamp.millisecondsSinceEpoch,
      );
    }
    state = BackupReminderState(
      lastBackupAt: state.lastBackupAt,
      dismissedAt: timestamp,
      isTrackingEnabled: state.isTrackingEnabled || prefs != null,
    );
  }
}

final backupReminderProvider =
    NotifierProvider<BackupReminderNotifier, BackupReminderState>(
  BackupReminderNotifier.new,
);

final hasAnyTransactionsProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.transactions)..limit(1))
      .watch()
      .map((rows) => rows.isNotEmpty);
});
