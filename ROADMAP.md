# Budget KE — Feature & Engineering Roadmap

Offline-first personal finance & M-Pesa budget tracker for Kenya (`com.budgetke.app`).

---

## Phase 1 — Frictionless M-Pesa Entry (Play Protect–Safe)

Because `READ_SMS` triggers Google Play Protect's Enhanced Fraud Protection sideloading block, automatic SMS importing should rely on zero-permission OS entry points.

### 1.1 Android Share-to-Budget KE (`ACTION_SEND`)
- **Android Manifest** ([AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)):
  - Add an `<intent-filter>` on `MainActivity` for `android.intent.action.SEND` (`DEFAULT` category, `mimeType="text/plain"`).
- **Native Bridge** ([MainActivity.kt](android/app/src/main/kotlin/com/budgetapp/budget_app/MainActivity.kt)):
  - Extract `Intent.EXTRA_TEXT` in `configureFlutterEngine` (cold launch) and `onNewIntent` (warm launch) and emit an encoded `budgetke://share_text?text=...` (or dedicated `MethodChannel` / `EventChannel`) event to Flutter.
- **Flutter Routing** ([main.dart](lib/main.dart), [mpesa_result_handler.dart](lib/features/transactions/services/mpesa_result_handler.dart)):
  - Queue incoming shared text behind `AuthGate` if the app is locked.
  - Parse via `MpesaParser.parse(sharedText)` and route directly to `AddTransactionScreen(parseResult: ...)` (or handle Fuliza drawdown/repayment & duplicate checks cleanly).

### 1.2 Batch M-Pesa Paste Importer
- **Multi-Message Splitter** (`lib/features/transactions/services/mpesa_parser.dart`):
  - Add `MpesaParser.parseBatch(String rawBlock)` splitting multi-message clipboard blocks on M-Pesa transaction code headers (e.g. `^[A-Z0-9]{10}\s+Confirmed\.`).
- **Batch Review Sheet** (`lib/features/transactions/widgets/batch_mpesa_paste_sheet.dart`):
  - Deduplicate parsed items against `transactions.mpesa_ref` and `fuliza_records.mpesa_ref`.
  - Allow per-item category override, payee memory matching via `PayeeCategoryRepository`, and one-tap bulk import inside a single DB transaction.

---

## Phase 2 — Multi-Category Budget Upgrades & Proactive Alerts

### 2.1 Per-Category Breakdown on Combined Budgets
- **Model & Repository** ([budget_model.dart](lib/features/budgets/models/budget_model.dart), [budget_repository.dart](lib/features/budgets/repositories/budget_repository.dart)):
  - Compute per-category spent totals (rolling child subcategories up to their selected parent or keeping individual subcategory slices) inside `BudgetRepository`.
- **Detail UI** ([budget_detail_screen.dart](lib/features/budgets/screens/budget_detail_screen.dart)):
  - Render a stacked/per-category progress breakdown card below the main budget progress bar whenever `liveBudget.isMultiCategory` is true.

### 2.2 Pinned Key Budgets on HomeScreen
- **Schema / Preferences**:
  - Add `isPinned` boolean column on `Budgets` (next DB migration) or persist pinned budget IDs via `SharedPreferences`.
- **Home Dashboard** ([home_screen.dart](lib/features/home/screens/home_screen.dart)):
  - Show up to 3 pinned category/combined budgets right beneath the Overall Budget card with tap-through to `BudgetDetailScreen`.

### 2.3 Budget Threshold Warnings & Bill/Debt Reminders
- **On-Save Budget Check** (`lib/features/add_transaction/widgets/transaction_form.dart`):
  - After saving an expense, evaluate matching active budgets and show a contextual banner/snackbar if spending crosses `80%` or `100%`.
- **Local Notifications** (`flutter_local_notifications` + Android `POST_NOTIFICATIONS` runtime prompt):
  - Wire up the existing `recurring_transactions.notify` flag (`lib/features/recurring/`) and upcoming `debts.due_date` / Fuliza due reminders on app start & when recurring rules are edited.

---

## Phase 3 — Split Transactions

### 3.1 Schema & Backup Support
- **Table** (`lib/core/database/tables/transaction_splits_table.dart`):
  - `id`, `transactionId` (`REFERENCES transactions(id) ON DELETE CASCADE`), `categoryId` (`REFERENCES categories(id)`), `amount` (`CentsConverter` integer cents), `note`.
- **Backup & Restore** ([database_backup_service.dart](lib/features/portability/services/database_backup_service.dart)):
  - Add `transaction_splits` to `_tables` and `_moneyColumnsByTable`.

### 3.2 Split Editor & Split-Aware Aggregation
- **Editor UI** (`lib/features/add_transaction/`):
  - Toggle "Split across categories" to divide one receipt/M-Pesa payment across multiple categories with live integer-cents remainder validation (must sum to `transaction.amount`).
- **Analytics & Budgets** ([budget_repository.dart](lib/features/budgets/repositories/budget_repository.dart), [insights_providers.dart](lib/features/insights/providers/insights_providers.dart), [category_pie_chart.dart](lib/features/home/widgets/category_pie_chart.dart)):
  - Attribute split amounts (plus proportional or primary fee allocation) to each split's `categoryId` instead of double-counting the parent transaction.

---

## Phase 4 — Release Automation & Backup Safety Net

### 4.1 GitHub Actions Release Pipeline
- **Workflow** (`.github/workflows/release.yml`):
  - Trigger on `v*` tags (`push: tags: ['v*']`).
  - Run `flutter gen-l10n`, `flutter analyze`, and `flutter test` as a release gate.
  - Decode the base64 PKCS12 release keystore and credentials from GitHub Repository Secrets (`RELEASE_KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`).
  - Build universal + split-per-ABI release APKs, generate `SHA256SUMS.txt`, and publish the GitHub Release via `softprops/action-gh-release` or `gh release create`.

### 4.2 Periodic Encrypted Backup Reminder
- **Tracking** (`lib/features/portability/services/encrypted_backup_service.dart`):
  - Record `last_backup_at` timestamp in `SharedPreferences` whenever an encrypted backup or full export succeeds.
- **UI Nudge** ([home_screen.dart](lib/features/home/screens/home_screen.dart), [more_screen.dart](lib/features/more/screens/more_screen.dart)):
  - Show a dismissible monthly reminder banner if transactions exist and no backup has been created in the past 30 days.

---

## Phase 5 — Maintenance & Optional Encrypted Cloud Sync

### 5.1 Drift / Analyzer Upgrade & Foreign Key Audit
- Upgrade `drift`, `drift_dev`, `sqlite3_flutter_libs`, and `analyzer` in [pubspec.yaml](pubspec.yaml) so `.references(..., onDelete: ...)` codegen completes cleanly without analyzer language-version warnings.
- Audit older tables (`transactions`, `budgets`, `recurring_transactions`, `payee_category_rules`) to ensure explicit foreign-key cascade/restrict behavior matches repository expectations.

### 5.2 Optional End-to-End Encrypted Cloud Sync
- Reuse the existing PBKDF2 + AES-GCM encrypted snapshot format ([encrypted_backup_service.dart](lib/features/portability/services/encrypted_backup_service.dart)) for user-controlled opt-in cloud backup/restore (e.g., Google Drive AppData or Firebase Storage), keeping zero plaintext financial data off-device.
