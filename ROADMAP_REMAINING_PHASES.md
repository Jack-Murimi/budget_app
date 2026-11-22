
# Budget KE — Audit & Remediation Plan

Related: [[Budget KE/context|context]] · [[Budget KE/decisions|decisions]] · [[Budget KE/ideas|ideas]]

**Baseline (2026-11-22):**
- Repo: `~/projects/flutter_projects/budget_app/` (`HEAD` `969e93b`, plus uncommitted v15–v17 integer-cents / Bridge / `CentsConverter` work across 29 modified and 6 untracked files).
- Tests: `flutter test` — 127/127 passing.
- Static analysis: `flutter analyze` — 0 errors/warnings, 27 info diagnostics.

---

## Pre-Phase 0 — Git Housekeeping
- [x] Commit or stash the current uncommitted v15–v17 (`CentsConverter`, Bridge charges, `LoanDetailScreen`, backup v2, `allowBackup="false"`) working tree cleanly before starting Phase 1 so remediation fixes land on clean git history.

---

## Phase 1 — Financial Math, Crashes & Security

### Accounting & Insights Math
- [x] Create a single integer-cents cashflow helper (`lib/shared/utils/cashflow_calculator.dart`) to unify expense/income/transfer calculations across the app.
- [x] Exclude `transfer` transactions from expenses and include `transactionCost + fulizaFee` in `monthSummaryProvider` (`lib/features/transactions/providers/transaction_providers.dart:36-42`), so Home summary and Android widget totals are accurate (e.g., Savings Goal contributions no longer inflate monthly spend).
- [x] Exclude `transfer` transactions from the top summary bar in `TransactionsScreen` (`lib/features/transactions/screens/transactions_screen.dart:268-275`) so it matches the daily net cashflow headers below it (`transactions_screen.dart:315-323`).
- [x] Include `transactionCost + fulizaFee` consistently in `buildInsightsSummary` (`lib/features/insights/providers/insights_providers.dart:150-157`), `CategoryPieChartSection` (`lib/features/home/widgets/category_pie_chart.dart:74`), and `InsightsScreen._CategoryChart` (`lib/features/insights/screens/insights_screen.dart:237`).
- [x] Fix 100× spending delta bug in `InsightsSummary.expenseDelta` / `_SummaryCard` (`lib/features/insights/providers/insights_providers.dart:67-69`, `lib/features/insights/screens/insights_screen.dart:139`) by multiplying the fractional ratio by `100` (or storing percentage points).
- [x] Clamp `initialDateRange.end` in `InsightsScreen._pickRange` (`lib/features/insights/screens/insights_screen.dart:13-21`) to `DateTime.now()` to prevent `showDateRangePicker` `AssertionError` crashes when tapping **Custom** from **This month** or **This year**.
- [x] Fix previous-period calculation in `buildInsightsSummary` (`lib/features/insights/providers/insights_providers.dart:141`) to compare calendar month boundaries instead of subtracting a fixed `Duration` (`Mar 1 - 31d = Jan 29`).
- [x] Fix `netWorthTrendProvider` (`lib/features/insights/providers/insights_providers.dart:85-110`) so archived accounts' `initialBalance` matches the historical transactions included in the trend (or filter both consistently).

### Biometrics, `AuthGate` & Deep-Link Security
- [x] Change `MainActivity` (`android/app/src/main/kotlin/com/budgetapp/budget_app/MainActivity.kt:14`) from `FlutterActivity` to `FlutterFragmentActivity` so `local_auth` `BiometricPrompt` works on Android.
- [x] Add `NSFaceIDUsageDescription` to `ios/Runner/Info.plist` for iOS Face ID support.
- [x] Initialize `appLockedProvider` synchronously from `biometricEnabledProvider` (`lib/features/settings/auth_gate.dart:22-26`) to eliminate the first-frame flash of financial balances on cold start.
- [x] Track background lock timestamps only on `AppLifecycleState.paused` / `hidden` (not `inactive`) and add an `_authenticating` guard in `AuthGate` (`lib/features/settings/auth_gate.dart:40-53`) so system dialogs (biometric prompt, file picker, permission prompt) do not immediately re-lock the app under "Immediately" mode.
- [x] Require `authenticate()` confirmation before enabling biometric lock in `SettingsScreen` (`lib/features/settings/settings_screen.dart`).
- [x] Queue incoming `budgetke://` deep links in `lib/main.dart:48-64` until `AuthGate` is unlocked so external intents cannot push screens above the lock screen.

### Category Corruption & Reordering
- [x] Change `CategoryRepository.updateCategory` (`lib/features/categories/repositories/category_repository.dart:59-60`) from `.replace(...)` to `.write(...)` so partial edits do not reset `isDefault`, `sortOrder`, `isArchived`, or `createdAt`.
- [x] Pass/load existing `parentId` when editing subcategories in `CategoriesScreen` (`lib/features/categories/screens/categories_screen.dart:170, 266`) so editing a subcategory does not silently detach it into a top-level category.
- [x] Pass the real item index `i` (instead of hardcoded `index: 0`) to `ReorderableDragStartListener` (`lib/features/categories/screens/categories_screen.dart:132-135`).
- [x] Add a `transactionType` selector (`expense` / `income` / `transfer`) and type grouping in `CategoriesScreen`, and replace its local `_iconMap` with `CategoryIconHelper`.

### Inline Calculator & System Entry Points
- [x] Update `CalculatorAmountField` (`lib/features/add_transaction/widgets/calculator_amount_field.dart`) to expose inline operator chips (`+`, `−`, `×`, `÷`, `=`) alongside the numeric keyboard, strip commas before tokenizing, respect `*`/`/` operator precedence, reject malformed trailing operators cleanly, and handle `didUpdateWidget` controller swaps.
- [x] Add `android:id="@+id/widget_root"` to `android/app/src/main/res/layout/widget_budget.xml` and update `BudgetWidget.kt:47` to bind the tap `PendingIntent` to `R.id.widget_root` instead of `android.R.id.content`.
- [x] Wire `budgetke://scan_sms` in `lib/main.dart:55-63, 100-122` to open `SmsInboxScreen` (removing the no-op `_ScanSmsPage`).

### Phase 1 Verification
- [x] Add/update unit and widget tests for cashflow/transfer/fee totals, Insights delta/date-range/net-worth math, `AuthGate` cold-start lock & deep-link queueing, category update/reorder preservation, and `CalculatorAmountField` precedence + commas.
- [x] Run `flutter analyze && flutter test`.

---

## Phase 2 — Database Integrity, Atomicity & Backup/Portability

### SQLite Foreign Keys, Indexes & Migrations
- [x] Enable `PRAGMA foreign_keys = ON` in `AppDatabase.beforeOpen` (`lib/core/database/app_database.dart:339`).
- [x] Add schema migration `v18` creating indexes on `transactions(transaction_date)`, `transactions(account_id)`, `transactions(to_account_id)`, `transactions(category_id)`, `transactions(debt_id)`, `debt_repayments(debt_id)`, and `goal_contributions(goal_id)`.
- [x] Move one-time legacy category deduplication out of `beforeOpen` (`lib/core/database/app_database.dart:349-433`) into an explicit migration/pref flag, and stop using `'Food & Groceries'` presence as a re-seed trigger.

### Encrypted Backup & Restore
- [x] Update `DatabaseBackupService` (`lib/features/portability/services/database_backup_service.dart:10-93`):
  - Include `payee_category_rules` and `sms_inbox_items` in `_tables`.
  - Order parent tables before dependents (`transactions` before `goal_contributions` and `debt_repayments`; top-level `categories` before child categories) so restore succeeds with `PRAGMA foreign_keys = ON`.
  - Replace raw string-interpolated SQL inserts with bound `Variable` parameters.
  - Call `_db.markTablesUpdated(_db.allTables)` after restore so active Drift/Riverpod streams refresh immediately without an app restart.
- [x] Harden `EncryptedBackupService` & `DataPortabilityScreen` (`lib/features/portability/services/encrypted_backup_service.dart`, `lib/features/portability/screens/data_portability_screen.dart`):
  - Offload PBKDF2 key derivation to `Isolate.run` to keep the UI responsive.
  - Increase PBKDF2 iterations for new backups (e.g., 600,000, stored in envelope metadata while staying backward-compatible with `v1` 100,000-iteration backups).
  - Add passphrase confirmation + minimum validation when creating a backup.
  - Return `bool` from `_save()` so cancelled OS save dialogs do not show a false `"saved"` snackbar.
  - Add loading indicators and error handling across all 4 export/import/backup/restore actions, and bundle CSV exports (or use folder picker / single archive) instead of 3 consecutive OS save dialogs.

### CSV Portability
- [x] Expand `CsvPortabilityService` (`lib/features/portability/services/csv_portability_service.dart`) to export/import category, account, transfer `to_account_id`, fees (`transaction_cost`, `fuliza_amount`, `fuliza_fee`), and `exclude_from_budget`.
- [x] Sanitize CSV cells starting with `=`, `+`, `-`, `@`, `\t`, or `\r` against spreadsheet formula injection.
- [x] Wrap `importTransactionsCsv` (`csv_portability_service.dart:69-121`) in `_db.transaction(...)`, check `mpesaRef` duplicates before inserting, and assign the default `accountId` when omitted.

### Atomic Multi-Step Writes & Cross-Table Consistency
- [x] In `TransactionForm._saveNew` (`lib/features/add_transaction/widgets/transaction_form.dart:517-568`): convert empty `mpesaRef` (`""`) to `null`, enforce `mpesaRef` duplicate checks on `recordLoanGiven` / `recordLoanReceived`, wrap Loan Repayment transaction insert + `debtRepository.repay(...)` in one DB transaction, and validate `_actualCreditedCtrl` via `TextFormField`.
- [x] Reconcile linked `Debts`, `DebtRepayments`, and `GoalContributions` when linked transactions are edited or deleted.
- [x] Wrap `RecurringRepository.markAsPaid` (`lib/features/recurring/repositories/recurring_repository.dart:170-214`) in `_db.transaction(...)` and populate `recurrenceId` and `isRecurring: Value(true)` on the generated transaction.
- [x] Wrap `AccountRepository.setDefault` (`lib/features/accounts/repositories/account_repository.dart:91-95`) in a transaction, set `excludeFromBudget: Value(true)` in `correctBalance` (`account_repository.dart:101-133`), and guard `deleteAccount` against deleting the last/default account or leaving orphaned FK rows.
- [x] Fix `DebtRepository` (`lib/features/debts/repositories/debt_repository.dart`) & `GoalRepository` (`lib/features/goals/repositories/goal_repository.dart`):
  - Watch `debt_repayments` and `transactions` in `DebtRepository.watchAll` and fix its non-antisymmetric `dueDate` comparator (`?? 1` when both are `null`).
  - Set `debtId` on the transaction created in `DebtRepository.create()` and record `principal - disbursementShortfall` as the credited cash amount for Bridge loans.
  - Re-read `debt` inside `DebtRepository.repay()` transaction instead of trusting stale `debt.outstanding`, and convert arithmetic in `DebtRepository` & `GoalRepository` to integer cents via `CentsConverter`.
- [x] Fix `PayeeCategoryRepository.learn` (`lib/features/transactions/repositories/payee_category_repository.dart:11-30`) so `insertOnConflictUpdate` does not reset `hitCount` to `1` before incrementing (use atomic upsert increment), and check bidirectional containment in `suggest()`.

### Phase 2 Verification
- [x] Add/update tests covering `PRAGMA foreign_keys = ON`, full-table backup/restore with stream refresh, CSV `mpesaRef` dedupe + formula escaping, atomic debt/goal/recurring transactions, and `PayeeCategoryRepository` `hitCount` increments.
- [x] Run `flutter analyze && flutter test`.

---

## Phase 3 — M-Pesa Parser, Fuliza Lifecycle & SMS Inbox Scanner

### `MpesaParser` & `MpesaParseResult`
- [x] Differentiate `pochiLaBiashara` inflow (`income`) vs outflow (`expense`) and `mShwariSavings` deposit vs withdrawal/transfer in `MpesaParseResult` / `MpesaParser` (`lib/features/transactions/models/mpesa_parse_result.dart:114-120`, `lib/features/transactions/services/mpesa_parser.dart`).
- [x] Match both full and partial Fuliza repayments (`used to (?:fully|partially) pay your outstanding Fuliza`) in `MpesaParser._detectType` (`mpesa_parser.dart:103`).
- [x] Add optional `DateTime? fallbackDate` to `MpesaParser.parse` (passing `sms.date` from `SmsInboxScanner`) and parse SMS dates in `_parseFulizaDrawdown` instead of hardcoding `DateTime.now()` (`mpesa_parser.dart:312`).
- [x] Expand counterparty extraction regexes (`mpesa_parser.dart:146-256`) to handle Kenyan names and payees with hyphens, apostrophes, dots, ampersands, digits, and `+254` phone numbers (e.g., `CO-OP BANK`, `I&M BANK`, `O'CONNOR`).
- [x] Remove the unsafe `allAmounts.last` balance fallback (`mpesa_parser.dart:71`) so daily transaction limits (e.g. `499,500.00`) are never parsed as the M-Pesa balance.

### Fuliza & Reversal Lifecycles
- [x] Update `FulizaRepository` and `_handleFulizaRepayment` (`lib/features/home/widgets/floating_action_buttons.dart:174-181`) to record Fuliza repayments (reducing/clearing `outstandingTotal` instead of only showing a toast), add manual settle/repay support and total fees display on `FulizaScreen` (`lib/features/fuliza/screens/fuliza_screen.dart`).
- [x] Fix M-Pesa wallet balance calculation in `AccountRepository` (`lib/features/accounts/repositories/account_repository.dart:29-31`) when `fulizaAmount > 0` so Fuliza-covered portions of an expense are not double-deducted from the M-Pesa wallet balance.
- [x] Defer `_markOriginalReversed` (`floating_action_buttons.dart:117-120`) until the reversal transaction is actually saved, and mark the reversed pair `excludeFromBudget: true`.

### SMS Inbox Scanner
- [x] Move `readMpesaSmsMessages()` in `MainActivity.kt` (`android/app/src/main/kotlin/com/budgetapp/budget_app/MainActivity.kt:86-111`) onto a background coroutine/executor so large SMS inboxes never cause Android ANRs, and tighten the SQLite `selection` filter.
- [x] Remove unused `RECEIVE_SMS` permission from `android/app/src/main/AndroidManifest.xml:5` (Play Store policy compliance).
- [x] Upgrade `SmsInboxScreen` (`lib/features/sms/screens/sms_inbox_screen.dart`) & `SmsInboxScanner`:
  - Deduplicate scanned messages against saved `transactions.mpesaRef` and `fuliza_records.mpesaRef`.
  - Route item actions through the shared M-Pesa result handler (supporting Fuliza drawdowns/repayments and reversal linking).
  - Add batch/bulk import for high-confidence items and surface `PlatformException` errors cleanly instead of swallowing them.
  - Either persist `pending` / `approved` / `dismissed` state in `sms_inbox_items` or remove the dead table cleanly in a migration.

### Phase 3 Verification
- [x] Expand `test/mpesa_parser_test.dart` for Pochi inflow/outflow, M-Shwari deposit/withdraw, partial Fuliza repayment, Fuliza drawdown dates, hyphenated/apostrophe/ampersand counterparties, and daily-limit non-balance messages.
- [x] Add Fuliza settlement, reversal-on-save, and `SmsInboxScreen` widget tests.
- [x] Run `flutter analyze && flutter test`.

---

## Phase 4 — Unfinished Features, Broken UI Controls & Dark Mode Polish

### Archived Views & Budget Logic
- [ ] Add `includeArchived: true` providers in `budget_providers.dart` and `account_providers.dart` so `BudgetsScreen` (`budgets_screen.dart:38-40`) and `AccountsScreen` (`accounts_screen.dart:194`) can actually view and unarchive archived items.
- [ ] Fix invisible category icons on Budget cards (`lib/features/budgets/screens/budgets_screen.dart:144-154`) by using `color.withValues(alpha: 0.15)` background and contrasting foreground icon color.
- [ ] Make `BudgetDetailScreen` (`lib/features/budgets/screens/budget_detail_screen.dart`) reactive: watch the budget by ID from `budgetsWithProgressProvider` and switch `budgetTransactionsAsyncProvider` from `.first` `FutureProvider` to a `StreamProvider`.
- [ ] Fix `BudgetDetailScreen._getPeriodInfo` (`budget_detail_screen.dart:164-168`) `'Period ended'` bug on the final day of a period (use calendar day/hour remainder with `>= 1` day left), and fix the red text on filled primary Delete button (`budget_detail_screen.dart:333`).
- [ ] Support `custom` budget periods (`startDate`–`endDate`) in `BudgetRepository._getPeriodWindow` (`lib/features/budgets/repositories/budget_repository.dart:158-163`), and either implement `rollover` carry-over math or remove the placebo `rollover` switch from the budget dialogs (`budgets_screen.dart:326-363`).

### Recurring Transactions
- [ ] Fix `RecurringModel.copyWith` (`lib/features/recurring/models/recurring_model.dart:92`) using a sentinel/clear flag so `endDate` can be cleared back to `null`.
- [ ] Fix `RecurrenceEngine` (`lib/features/recurring/services/recurrence_engine.dart`) month-end drift (`Jan 31 -> Feb 28 -> Mar 28`, `Feb 29 + 1yr -> Mar 1`) by anchoring day-of-month to `startDate.day`.
- [ ] Fix `RecurringModel.isOverdue` (`recurring_model.dart:50`) to compare calendar dates instead of `DateTime.now()` (avoiding false overdue badges on bills due today).
- [ ] In `AddEditRecurringScreen` (`lib/features/recurring/screens/add_edit_recurring_screen.dart`): pass `initialType: _type` to `showCategoryPicker`, clear `_selectedCategory` if type changes to a mismatched type, and validate `intervalCount >= 1`.
- [ ] Validate `actualAmount > 0` in `RecurringScreen._confirmMarkPaid`, filter the `Upcoming & Due` tab by the upcoming horizon (e.g., 30 days) or due/overdue status, and either implement `autoRecord` startup execution + `notify` local notifications (`flutter_local_notifications`) or hide the unimplemented toggles.

### Debts, Loans & Goals UX
- [ ] Add edit and delete actions for Debts, Debt Repayments, and Savings Goals (with linked transaction cleanup options).
- [ ] Add an account picker dropdown to Debt creation, Repayment, and Goal contribution dialogs instead of silently defaulting to `getDefaultAccount()`.
- [ ] Allow tapping Borrowed debts on `DebtsScreen` to open `LoanDetailScreen` (`lib/features/debts/screens/loan_detail_screen.dart`), generalize hardcoded `'Total lent'` / sign strings for both `lent` and `borrowed`, and fix `_DebtCard._repay` button wording for borrowed vs lent items.
- [ ] Fix `BridgeChargesScreen` (`lib/features/debts/screens/bridge_charges_screen.dart:360-362`) labeling partial repayments on active loans as `'Settled: <date>'`.
- [ ] Add validation snackbars/errors, `targetAmount > 0` guard (`goals_screen.dart:110`), `NULLS LAST` sorting (`goal_repository.dart:9-11`), and contribution history view to `GoalsScreen`.

### Home, Navigation, Transactions, Accounts & Insights UI
- [ ] Show `HomeFloatingActionButtons` (`lib/features/home/screens/main_navigation_screen.dart:56`) only on Home (`0`) and Transactions (`1`) tabs so it stops overlapping `BudgetsScreen`'s FAB and floating over `MoreScreen`.
- [ ] Feed `CategoryPieChartSection` on `HomeScreen` (`lib/features/home/screens/home_screen.dart:300-301`) from current-month transactions instead of `recentTransactionsProvider` (last 50 all-time).
- [ ] Tap Home account chips (`home_screen.dart:236-241`) directly into `AccountDetailScreen` for that account; switch Home app bar logo to `assets/logo_dark.svg` when `Theme.of(context).brightness == Brightness.dark`.
- [ ] Fix `TransactionsScreen` (`lib/features/transactions/screens/transactions_screen.dart`): show `'This Week'` in the active date filter chip (`transactions_screen.dart:234`), include subcategories when filtering by a parent category (`transaction_providers.dart:91`), and make the summary bar responsive (`Wrap` / `FittedBox`) so it never overflows on narrow devices.
- [ ] Fix `TransactionListItem` (`lib/features/home/widgets/transaction_list_item.dart:128-134, 161-187`) so the `Fuliza` badge renders alongside `fee > 0`, and restore a 48×48dp tap target on the delete `IconButton`.
- [ ] Fix `AccountDetailScreen` (`lib/features/accounts/screens/account_detail_screen.dart:252-254, 366-371`) so incoming transfers (`txn.toAccountId == _account.id`) render with `+` and primary color, and edit/default state reads reactively from `accountsWithBalanceProvider`; add validation (`fromId != toId`, `amount > 0`, `fee >= 0`, error feedback) to `AccountsScreen._showTransferDialog`.
- [ ] Improve `InsightsScreen` (`lib/features/insights/screens/insights_screen.dart`): aggregate `_CashflowChart` weekly/monthly when the selected range exceeds 31 days (instead of cramming 365 daily bars), roll categories #6+ into `"Other"` with KES values in `_CategoryChart`, and display average daily burn rate on `_SummaryCard`.
- [ ] Replace hardcoded light-only pastel colors (`Colors.amber.shade100`, `Colors.orange.shade50`, `Colors.green.shade50`, `Colors.grey.shade200`, etc.) with theme `ColorScheme` tokens across `HomeScreen`, `FulizaScreen`, `RecurringScreen`, `DebtsScreen`, and `BridgeChargesScreen`.
- [ ] Fix `CurrencyFormatter.formatCompact` (`lib/shared/utils/currency_formatter.dart:7-11`) for negative values and `DateFormatter.formatRelative` (`lib/shared/utils/date_formatter.dart:7-14`) for calendar-day boundaries and future dates.

### Phase 4 Verification
- [ ] Add/update widget tests for `BudgetsScreen` (archived toggle, icon contrast), `BudgetDetailScreen`, `RecurringScreen` (`endDate` clear, `isOverdue`), `DebtsScreen`, `GoalsScreen`, `TransactionsScreen` (`this_week` chip, subcategory filter), `AccountDetailScreen`, and Dark/OLED rendering.
- [ ] Run `flutter analyze && flutter test`.

---

## Phase 5 — Localization, Performance, Code Health & Release Readiness

### Localization (`en` + `sw`)
- [ ] Expand `lib/l10n/app_en.arb` and `lib/l10n/app_sw.arb` to cover all user-facing strings across screens, dialogs, errors, and empty states.
- [ ] Wire `AppLocalizations.of(context)!` across all UI screens and add a persisted locale selector (`System` / `English` / `Kiswahili`) in `SettingsScreen` + `BudgetApp`.

### Performance & Memory/Stream Hygiene
- [ ] Rewrite `AccountRepository.watchAccountsWithBalance` (`lib/features/accounts/repositories/account_repository.dart:11-57`) to compute balances in SQLite (`SUM(...) GROUP BY`) instead of loading all transactions into Dart.
- [ ] Eliminate N+1 query loops in `BudgetRepository.watchBudgetsWithProgress` and `DebtRepository.watchAll`.
- [ ] Switch `TransactionsScreen` to `ListView.builder` over a flattened header+item list and add a `categoriesByIdProvider` lookup map for `O(1)` lookup in `TransactionListItem`.
- [ ] Move `WidgetUpdateService.update(...)` out of `HomeScreen.build` (`lib/features/home/screens/home_screen.dart:48-54`) into `ref.listen`.
- [ ] Debounce `TransactionForm` header autocomplete (`transaction_form.dart:841-847`).
- [ ] Dispose every `TextEditingController` created in dialogs (`AccountsScreen`, `AccountDetailScreen`, `BudgetsScreen`, `BudgetDetailScreen`, `DebtsScreen`, `LoanDetailScreen`, `RecurringScreen`).
- [ ] Store/cancel the `StreamSubscription` in `DeepLinkService` (`lib/core/services/deep_link_service.dart:18-24`) with an `onError` handler, and add `.autoDispose` to family stream providers (`accountTransactionsProvider`, `_bridgeDebtsProvider`).

### Architecture, Analyzer Cleanup & Release Config
- [ ] Refactor 1,229-line `TransactionForm` (`lib/features/add_transaction/widgets/transaction_form.dart`) into smaller focused widgets/controllers, move `_fetchCategory` into `CategoryRepository`, and replace hardcoded English category-name matching (`'loan given'`, etc.) with a `systemKey` column on `Categories`.
- [ ] Centralize duplicated hex-color parsing (`parseHexColor` safe helper), category icon mapping (`CategoryIconHelper`), and budget period window helpers; delete dead `ParsePreviewScreen` (`lib/features/add_transaction/screens/parse_preview_screen.dart`).
- [ ] Bundle Poppins `.ttf` assets under `assets/fonts/` (`pubspec.yaml`) and set `GoogleFonts.config.allowRuntimeFetching = false` for true offline-first typography without `INTERNET` permission.
- [ ] Fix all 27 `flutter analyze` info diagnostics (`DropdownButtonFormField.initialValue`, `RadioGroup`, `mounted` checks, `const` constructors) until `flutter analyze` exits with 0 issues.
- [ ] Harden Android release config: set `android:label="@string/app_name"` and remove invalid `android:autoVerify="true"` on custom `budgetke://` scheme in `android/app/src/main/AndroidManifest.xml`, configure non-placeholder `applicationId`, release signing config, and R8 shrinking/proguard in `android/app/build.gradle.kts`.
- [ ] Add unit/widget test suites for previously uncovered screens: `AuthGate`, `SmsInboxScreen`, `InsightsScreen`, `GoalsScreen`, `FulizaScreen`, `DataPortabilityScreen`, `RecurringScreen`, `LoanDetailScreen`, `BudgetDetailScreen`, and `AccountDetailScreen`.

### Phase 5 Final Verification
- [ ] Run `flutter gen-l10n && flutter analyze && flutter test && flutter build apk --debug`.
