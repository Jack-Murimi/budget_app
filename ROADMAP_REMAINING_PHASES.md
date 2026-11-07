# Project Roadmap: Remaining Phases

## Current Status Summary
- **Phase 0: Baseline & Regression Gate** — Complete (74 tests passing)
- **Phase 1: Core Data** — Complete
  - 1.1 Ledger (CRUD, list, search, filters)
  - 1.2 Categories (hierarchical tree, seeded defaults, sort ordering)
  - 1.3 Accounts & Transfers (multi-account balances, transfer mechanics)
- **Phase 2: Budgets & Spending Limits** — Complete
  - Category and overall budgets
  - Period-based budget calculation & progress tracking
- **Phase 3: Recurring Money & Subscriptions** — Complete
  - Schema migration v8 (`recurring_transactions` table, transaction linkage)
  - Recurrence engine (daily, weekly, monthly, yearly, custom interval calculations)
  - Upcoming & Due schedule UI with Mark as Paid & Skip occurrence flows
  - Subscription management with pause/resume and monthly commitment summary
- **Phase 4: Insights & Analytics** — In progress
  - Period selection, cashflow summary, category breakdown, daily cashflow chart

---

## Phase 3: Recurring Money & Subscriptions
Automate repeating inflows, bills, and subscription management.

### Key Deliverables
1. **Schema Migration v8**
   - New table `recurring_transactions`:
     - `id` (INTEGER, PK, auto-increment)
     - `account_id` (INTEGER, FK -> accounts)
     - `category_id` (INTEGER, NULLABLE, FK -> categories)
     - `amount` (REAL)
     - `type` (TEXT: income / expense / transfer)
     - `payee` (TEXT)
     - `frequency` (TEXT: daily, weekly, monthly, yearly, custom)
     - `interval_count` (INTEGER: e.g. every 2 weeks = 2)
     - `start_date` (DATETIME)
     - `end_date` (DATETIME, NULLABLE)
     - `next_due_date` (DATETIME)
     - `auto_record` (BOOLEAN: default false)
     - `notify` (BOOLEAN: default true)
     - `created_at` / `updated_at` (DATETIME)
   - Update `transactions` table:
     - Add `recurrence_id` (INTEGER, NULLABLE, FK -> recurring_transactions)
     - Add `is_recurring` (BOOLEAN, default false)
2. **Recurrence Engine**
   - Recurrence calculation service (next due date evaluation, missed occurrence detection).
   - Frequency support: Daily, Weekly, Monthly (same day of month), Yearly, and Custom intervals (`interval_count` + interval unit).
3. **Upcoming & Due Schedule UI**
   - Scheduled / upcoming bills dashboard screen.
   - Actionable "Mark as Paid" flow: generates matching transaction entry and updates `next_due_date`.
   - Skip occurrence and pause subscription options.
4. **Reminders & Local Notifications**
   - Local reminder notifications using `flutter_local_notifications` (or lightweight native channel).
   - Configurable trigger: on due date, 1 day before, 3 days before.

---

## Phase 4: Insights & Analytics
Visual spending analysis and cashflow intelligence.

### Key Deliverables
1. **Period Selection**
   - Standard presets: This Week, This Month, Last Month, This Year.
   - Custom date range picker with persistence.
2. **Visual Breakdowns**
   - Category Breakdown: Pie / Donut chart showing expense distribution with interactive drill-down.
   - Cashflow Breakdown: Income vs Expense bar charts per interval (daily/weekly/monthly).
   - Net Worth Trend: Cumulative balance over time line chart.
3. **Period Comparisons**
   - Delta metrics: Spend this month vs. spend last month (percentage & absolute change).
   - Average daily burn rate indicator.

---

## Phase 5: Debts, Loans & Goals
Lending/borrowing ledger and financial target tracking.

### Key Deliverables
1. **Unified Debt & Loan Tracking**
   - Track money lent to others (receivables) and borrowed from others/institutions (payables).
   - Kenyan credit product linkage: M-Shwari loans, Fuliza overdraft tracking, Hustler Fund records.
   - Due dates, interest calculation (optional/flat), and contact linkage.
2. **Repayments Ledger**
   - Partial and full repayment recording.
   - Automatic balance recalculation on repayment event.
   - Linked transaction generation in main ledger.
3. **Savings Goals & Objectives**
   - Target amount, current saved amount, target completion date.
   - Visual progress indicator (% funded, projected completion pace, remaining needed).
   - Manual deposit / transfer allocation from accounts into goals.

---

## Phase 6: Data Portability & Backup
Data sovereignty, external processing, and disaster recovery.

### Key Deliverables
1. **CSV Export & Import**
   - Export: Full CSV dump for transactions, accounts, and categories with configurable date filters.
   - Import: Parser for standard transaction CSVs with duplicate detection (timestamp + amount + payee hash matching).
2. **Encrypted Offline Backup & Restore**
   - Single-file JSON snapshot: all database tables, relations, and user preferences.
   - AES-GCM password-based encryption via user-supplied passkey.
   - File picker export/import integration (save to local downloads, share via intent, restore from file).

---

## Phase 7: Polish, Security & Settings
App security, usability enhancements, and localization.

### Key Deliverables
1. **App Security & Privacy**
   - Biometric authentication (fingerprint / Face Unlock via `local_auth`) with fallback device PIN.
   - Auto-lock timeout options (immediate, 1 minute, 5 minutes).
   - Privacy screen obscuring app switcher preview.
2. **Transaction Entry Enhancements**
   - In-app inline calculator on the amount entry field (+, -, *, / evaluation).
3. **Localization (l10n)**
   - Complete string extraction with Arb / intl support.
   - Primary locales: English (`en`) and Swahili (`sw`).
4. **Theming & Display**
   - Material 3 dynamic color scheme support.
   - True OLED Pure Dark Mode alongside Light and System modes.

---

## Phase 8: Ecosystem & Extras
Cloud synchronization and OS integrations.

### Key Deliverables
1. **Optional Cloud Synchronization**
   - Optional, opt-in Firestore sync backend.
   - Conflict-free offline-first architecture (last-write-wins with client timestamps or revision counters).
   - End-to-end client-side encryption before cloud sync.
2. **System Integrations**
   - Android home-screen glance widgets (current month spend, balance summary).
   - App launcher shortcuts (Quick Add Transaction, Scan SMS).

---

## Parallel Track: Parser Improvements
Heuristic expansion for automated M-Pesa transaction ingestion.

### Key Deliverables
1. **Payee & Merchant Memory**
   - Historical merchant-to-category learning table (`payee_category_rules`).
   - Auto-populate suggested category on matched payee / till / paybill during manual or SMS entry.
2. **Bulk SMS Inbox Scanner**
   - Permissions flow for SMS reading.
   - Background batch ingestion of historical M-Pesa SMS messages.
   - "Needs Review" staging queue for ambiguous or low-confidence parsing results.
3. **Specialized Kenyan SMS Parsers**
   - **Pochi la Biashara**: Inflow and outflow format patterns.
   - **Buy Goods / Till Numbers**: Store number extraction, merchant name sanitation.
   - **M-Shwari**: Loan disbursement, savings deposit, loan repayment formats.
   - **Safaricom Reversals**: Reversal transaction identification, reversal linking to original ledger entry, zero-sum balance adjustment.
