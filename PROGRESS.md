---
type: note
status: active
project: Budget KE
created: 2026-11-26
tags:
  - progress
  - budget
  - flutter
---

# Budget KE — Engineering Progress & Status

Authoritative engineering status for **Budget KE** (`com.budgetke.app`). See [ROADMAP.md](./ROADMAP.md) for detailed technical designs for upcoming phases.

## Current Snapshot (2026-11-26)

- **App ID:** `com.budgetke.app` (debug builds: `com.budgetke.app.debug`)
- **Version:** `1.0.3+4`
- **Latest Git Tag:** `v1.0.3`
- **Database Schema:** Drift SQLite **v22** (`PRAGMA foreign_keys = ON`, integer-cents `CentsConverter`)
- **Working Tree State:** Clean release `v1.0.3`

---

## Completed Work

### Shipped Releases & Audit Remediation
- [x] **Audit & Remediation Phases 1–4 (`4934791`, `a7d62a9`, `3b6d0eb`, `d27a941`, `afe3a91`):** Unified `CashflowCalculator` integer-cents math, biometric `AuthGate` & queued `budgetke://` deep links, Drift schema v18 + FK enforcement + 12-table encrypted/CSV backup hardening, M-Pesa parser & Fuliza lifecycle hardening, archived budgets/accounts, custom rollover budgets, `RecurrenceEngine` `autoRecord`, and dark/OLED theme polish.
- [x] **Audit & Remediation Phase 5 (`544f961`):** Complete `en` + `sw` l10n wiring across the app, SQLite-level balance/summary perf optimizations, `TransactionForm` refactor, release build config, and widget/repository test suite.
- [x] **`v1.0.0` (`01978cf`, `6e61ef0`):** Redesigned UI typography (bundled local `Poppins`), cards, and Material 3 motion; added R8 `dontwarn` rule for unused Play Core deferred components.
- [x] **`v1.0.1` (`5f1010c`):** Cold-start performance optimizations.
- [x] **`v1.0.2` (`7b0d404`):** Removed `READ_SMS` permission for Google Play Protect sideloading safety, added release signing configuration, and enabled side-by-side debug builds (`com.budgetke.app.debug`).

### Uncommitted Working Tree (Targeting `v1.0.3`)
- [x] **Multi-Category Budgets (DB v20):** Added `budget_categories` join table (`lib/core/database/tables/budget_categories_table.dart`), `MultiCategoryPicker` (`lib/features/categories/widgets/multi_category_picker.dart`), and updated `BudgetModel`, `BudgetRepository`, `BudgetsScreen`, `BudgetDetailScreen`, `DatabaseBackupService`, `en`/`sw` l10n, and budget/backup/migration tests.
- [x] **Branded Kenyan Banks & Wallets (DB v21):** Added `PaymentProvider` / `PaymentProviders` (`lib/features/accounts/models/payment_provider.dart`), `AccountBrandBadge` supporting SVG + raster logos and `fullBleedBadge` (`lib/features/accounts/widgets/account_brand_badge.dart`), `ProviderPickerSheet`, `AddAccountDialog`, and updated `AccountsScreen`, `AccountDetailScreen`, `HomeScreen`, and `TransactionAccountSection`.
- [x] **Official Brand Logos (`assets/brands/`):** Bundled and verified all 15 static logos (`mpesa.png`, `airtel.svg`, `tkash.jpg`, `cash.svg`, `equity.png`, `kcb.png`, `coop.webp`, `ncba.png`, `absa.svg`, `scb.svg`, `im.png`, `stanbic.png`, `dtb.jpg`, `family.jpg`, `sidian.jpg`) with widget test coverage rendering all 15 `PaymentProviders.all` badges.
- [x] **Splash & Home FAB Polish:** Added `android/app/src/main/res/drawable/splash_logo.xml`, updated launch backgrounds / Android 12+ splash styles, and updated `HomeFloatingActionButtons`.

---

## Known Open Issues

- [x] Fix pre-existing test assertion mismatch in `test/account_detail_screen_test.dart:186` (`'Bank archived'` → `'KCB Bank archived'`).
- [x] Run full `flutter test` suite and commit the current working tree (`v1.0.3`).

---

## Unfinished / Upcoming Work

Detailed technical specs for each item live in [ROADMAP.md](./ROADMAP.md).

### 1. Frictionless M-Pesa Entry (without `READ_SMS`)
- [x] **Share-to-Budget KE (`ACTION_SEND`):** Added `text/plain` `ACTION_SEND` intent filter in `AndroidManifest.xml`, handled cold + warm intents in `MainActivity.kt`, queued behind `AuthGate`, and routed parsed SMS text straight to pre-filled `AddTransactionScreen` (or `BatchMpesaPasteSheet` when 2+ messages are shared).
- [x] **Batch M-Pesa Paste:** Added `MpesaParser.parseBatch`, `prepareBatchPreview` / atomic `bulkImportWithOverrides` deduplicating against `transactions.mpesa_ref` and `fuliza_records.mpesa_ref`, and `BatchMpesaPasteSheet` (reachable from clipboard paste, Paste dialog, and `TransactionsScreen`).

### 2. Multi-Category Budget Upgrades & Alerts
- [x] **Per-Category Breakdown in `BudgetDetailScreen`:** Added `BudgetCategoryBreakdown` in `BudgetModel`, single-pass integer-cents per-category aggregation (with unselected subcategory roll-up) in `BudgetRepository`, and stacked bar + category progress list in `BudgetDetailScreen`.
- [x] **Pin Key Budgets to `HomeScreen`:** Added `SharedPreferences`-backed `PinnedBudgetsNotifier` (up to 3 non-overall budgets), pin toggles on `BudgetDetailScreen` & `BudgetsScreen`, and the Pinned Budgets section on `HomeScreen`.
- [x] **Budget & Bill Alerts:** Added `BudgetAlertEvaluator` (80%/100% threshold crossing snackbars + notifications on expense save in `TransactionForm`), `ReminderNotificationService` (`flutter_local_notifications` + `POST_NOTIFICATIONS` + core library desugaring), `notify` switch in `AddEditRecurringScreen`, debt/Fuliza due banner on `HomeScreen`, and startup reminder sync in `main.dart`.

### 3. Split Transactions
- [x] **Schema & Backup:** Added `transaction_splits` table (`CentsConverter`, `ON DELETE CASCADE` on `transaction_id`, indexes) in schema `v22` with `v21 -> v22` migration and `DatabaseBackupService` / `EncryptedBackupService` snapshot & restore support.
- [x] **Split Editor & Aggregation:** Added `TransactionSplitAllocator` (exact proportional integer-cents fee allocation), split-aware `TransactionRepository`, `BudgetRepository`, `CategoryPieChartSection`, `InsightsScreen`, `filteredTransactionsProvider`, `TransactionListItem`, and `TransactionSplitSection` in `TransactionForm` with live integer-cents sum validation (`en`/`sw`).

### 4. Automated GitHub Releases (CI/CD)
- [x] **Release Workflow:** Added [`.github/workflows/release.yml`](.github/workflows/release.yml) triggered on `v*` tags (and manual `workflow_dispatch`) to check Play Protect safety (`READ_SMS`/`RECEIVE_SMS`), verify tag vs `pubspec.yaml` version, run `flutter gen-l10n`, `flutter analyze`, and `flutter test`, decode keystore secrets from GitHub Secrets, build all 4 signed APKs + `SHA256SUMS.txt`, and publish the GitHub Release; documented secret setup in `README.md`.

### 5. Backup Safety Net & Quick Housekeeping
- [x] **Monthly Backup Reminder Nudge:** Added `BackupReminderNotifier` (`backup_reminder_provider.dart`), `BackupReminderBanner` (`HomeScreen` & `MoreScreen`), `last_backup_at` / `backup_reminder_dismissed_at` tracking in `SharedPreferences` via `DataPortabilityScreen`, `en`/`sw` l10n, and 30-day dismissal/reminder tests.
- [x] **Drift / Analyzer Upgrade & FK Audit:** Upgraded `drift` (`^2.35.4`), `drift_flutter` (`^0.3.1`), `drift_dev` (`^2.35.3`), `build_runner` (`^2.17.1`), and `sqlite3` (`^3.9.2`), removed obsolete Linux `open.overrideFor` test shims, copied read-only `QueryRow.data` maps in `DatabaseBackupService`, migrated `BudgetCategories` & `TransactionSplits` to native Drift `.references(..., onDelete: KeyAction.cascade)`, and verified cascade/repository FK integrity (`PRAGMA foreign_key_check`).
- [ ] **Optional Encrypted Cloud Sync:** Opt-in E2EE snapshot sync reusing `EncryptedBackupService` (deferred).
