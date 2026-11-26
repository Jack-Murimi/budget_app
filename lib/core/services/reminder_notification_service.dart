import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/budgets/services/budget_alert_evaluator.dart';
import '../../features/debts/models/debt_model.dart';
import '../../features/recurring/models/recurring_model.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/utils/currency_formatter.dart';
import '../database/app_database.dart';

enum ReminderKind { recurringBill, debtDue, fulizaDue }

class ReminderItem {
  final int notificationId;
  final ReminderKind kind;
  final String title;
  final String body;
  final DateTime dueDate;
  final bool isOverdue;

  const ReminderItem({
    required this.notificationId,
    required this.kind,
    required this.title,
    required this.body,
    required this.dueDate,
    required this.isOverdue,
  });
}

class ReminderNotificationService {
  static const _remindersChannelId = 'budgetke_reminders';
  static const _remindersChannelName = 'Bill & Debt Reminders';
  static const _budgetChannelId = 'budgetke_budget_alerts';
  static const _budgetChannelName = 'Budget Alerts';
  static const _notifiedPrefix = 'notified_day_';

  final FlutterLocalNotificationsPlugin _plugin;
  final SharedPreferences? _prefs;
  bool _initialized = false;
  bool _tzInitialized = false;

  ReminderNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    SharedPreferences? prefs,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _prefs = prefs;

  /// Pure builder for recurring bills (with [notify] enabled), unsettled
  /// debts with due dates, and active Fuliza balances due within [windowDays].
  static List<ReminderItem> buildDueReminders({
    required List<RecurringModel> recurring,
    required List<DebtWithRepayments> debts,
    required FulizaRecord? latestFuliza,
    DateTime? now,
    int windowDays = 3,
  }) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final cutoff = today.add(Duration(days: windowDays));
    final items = <ReminderItem>[];

    for (final r in recurring) {
      if (!r.isActive || !r.notify) continue;
      final overdue = r.isOverdueAt(today);
      final dueSoon = r.isDueSoonAt(today, days: windowDays);
      if (!overdue && !dueSoon) continue;
      final dueDay = DateTime(
        r.nextDueDate.year,
        r.nextDueDate.month,
        r.nextDueDate.day,
      );
      items.add(
        ReminderItem(
          notificationId: 10000 + r.id,
          kind: ReminderKind.recurringBill,
          title: overdue ? 'Bill overdue: ${r.payee}' : 'Bill due: ${r.payee}',
          body: '${CurrencyFormatter.format(r.amount)} (${r.frequency})',
          dueDate: dueDay,
          isOverdue: overdue,
        ),
      );
    }

    for (final entry in debts) {
      final d = entry.debt;
      if (entry.isSettled || d.dueDate == null) continue;
      final dueDay = DateTime(d.dueDate!.year, d.dueDate!.month, d.dueDate!.day);
      final overdue = dueDay.isBefore(today);
      final dueSoon = !dueDay.isAfter(cutoff);
      if (!overdue && !dueSoon) continue;
      final verb = d.direction == 'borrowed' ? 'owe' : 'owed by';
      items.add(
        ReminderItem(
          notificationId: 20000 + d.id,
          kind: ReminderKind.debtDue,
          title: overdue
              ? 'Debt overdue: ${d.counterparty}'
              : 'Debt due: ${d.counterparty}',
          body:
              '${CurrencyFormatter.format(d.outstanding)} $verb ${d.counterparty}',
          dueDate: dueDay,
          isOverdue: overdue,
        ),
      );
    }

    if (latestFuliza != null &&
        latestFuliza.outstandingTotal > 0 &&
        latestFuliza.dueDate != null) {
      final fDue = latestFuliza.dueDate!;
      final dueDay = DateTime(fDue.year, fDue.month, fDue.day);
      final overdue = dueDay.isBefore(today);
      final dueSoon = !dueDay.isAfter(cutoff);
      if (overdue || dueSoon) {
        items.add(
          ReminderItem(
            notificationId: 30001,
            kind: ReminderKind.fulizaDue,
            title: overdue ? 'Fuliza M-PESA overdue' : 'Fuliza M-PESA due soon',
            body:
                'Outstanding: ${CurrencyFormatter.format(latestFuliza.outstandingTotal)}',
            dueDate: dueDay,
            isOverdue: overdue,
          ),
        );
      }
    }

    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    if (kIsWeb) return false;
    try {
      if (!_tzInitialized) {
        tz_data.initializeTimeZones();
        _tzInitialized = true;
      }
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        ),
      );
      await _plugin.initialize(settings: settings);
      _initialized = true;
      return true;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugPrint('Notification init skipped: $e');
      return false;
    }
  }

  Future<void> requestPermissionIfNeeded() async {
    if (kIsWeb) return;
    if (!await _ensureInitialized()) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } on MissingPluginException {
      // No-op in headless/test environments.
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  Future<void> syncReminders({
    required List<RecurringModel> recurring,
    required List<DebtWithRepayments> debts,
    required FulizaRecord? latestFuliza,
    bool requestPermission = false,
  }) async {
    final items = buildDueReminders(
      recurring: recurring,
      debts: debts,
      latestFuliza: latestFuliza,
    );
    if (items.isEmpty) return;
    if (!await _ensureInitialized()) return;
    if (requestPermission) {
      await requestPermissionIfNeeded();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _remindersChannelId,
        _remindersChannelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final item in items) {
      try {
        if (!item.dueDate.isAfter(today)) {
          final prefKey = '$_notifiedPrefix${item.notificationId}';
          if (_prefs?.getString(prefKey) == todayKey) continue;
          await _plugin.show(
            id: item.notificationId,
            title: item.title,
            body: item.body,
            notificationDetails: details,
          );
          await _prefs?.setString(prefKey, todayKey);
        } else {
          final scheduled = tz.TZDateTime(
            tz.local,
            item.dueDate.year,
            item.dueDate.month,
            item.dueDate.day,
            9,
            0,
          );
          if (scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
            await _plugin.zonedSchedule(
              id: item.notificationId,
              title: item.title,
              body: item.body,
              scheduledDate: scheduled,
              notificationDetails: details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          }
        }
      } on MissingPluginException {
        return;
      } catch (e) {
        debugPrint('Reminder notification skipped: $e');
      }
    }
  }

  Future<void> showBudgetAlert(BudgetThresholdAlert alert) async {
    if (!await _ensureInitialized()) return;
    final pct = alert.budget.percentage.round();
    final isExceeded = alert.level == BudgetAlertLevel.exceeded100;
    final title = isExceeded
        ? 'Over budget: ${alert.budget.name}'
        : 'Budget warning: ${alert.budget.name}';
    final body = isExceeded
        ? '${alert.budget.name} reached $pct% (${CurrencyFormatter.format(alert.budget.spent)} / ${CurrencyFormatter.format(alert.budget.amount)})'
        : '${alert.budget.name} reached $pct% of your limit';

    try {
      await _plugin.show(
        id: 40000 + alert.budget.id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _budgetChannelId,
            _budgetChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } on MissingPluginException {
      // No-op in tests.
    } catch (e) {
      debugPrint('Budget alert notification skipped: $e');
    }
  }
}

final reminderNotificationServiceProvider =
    Provider<ReminderNotificationService>((ref) {
  return ReminderNotificationService(
    prefs: ref.watch(sharedPreferencesProvider),
  );
});
