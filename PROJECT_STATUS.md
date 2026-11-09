# Project Status

Last updated: 2026-11-09

## Current Work
- All roadmap phases complete (Firestore sync deferred — needs Firebase project)
- Next: awaiting new requirements or Firestore config

## Verified Completion
- [x] Phase 0 — Baseline & regression gate
- [x] Phase 1 — Core data
- [x] Phase 2 — Budgets & spending limits
- [x] Phase 3 — Recurring money & subscriptions
- [x] Phase 4 — Insights & analytics
- [x] Phase 5 — debt/loan tracking, repayments, savings goals, contribution allocation
- [x] Phase 6 — CSV export/import, duplicate detection, encrypted backup/restore, file picker UI
- [x] Phase 7 — Biometric lock + auto-lock, privacy screen (FLAG_SECURE), inline calculator, l10n en+sw, Material 3 dynamic color, OLED dark mode
- [~] Phase 8 — Android widget, launcher shortcuts, deep links; Firestore sync deferred
- [x] Parallel Track — Payee memory (learn/suggest on save + manual entry debounce), specialized parsers (Pochi, Till, M-Shwari, Reversals + zero-sum linking), bulk SMS scanner

## Evidence
- `45490e2`: savings goals.
- Phase 6: CSV exports; AES-GCM backup/restore.
- Phase 7: local_auth v3; FLAG_SECURE; CalculatorAmountField; l10n en+sw; DynamicColorBuilder; OLED dark.
- Phase 8 (partial): BudgetWidget; shortcuts.xml; deep link EventChannel.
- Parallel Track: payee_category_rules v12; PayeeCategoryRepository; parser + 5 new types; reversal zero-sum linking; desc debounce suggestion; SmsInboxScanner + SmsInboxScreen.
- Build: `flutter build apk --debug` → ✓ app-debug.apk
- Tests: `flutter test` passed 104 tests. `flutter analyze` 35 info, 0 errors/warnings.

## Update Rules
1. Update Current Work before each deliverable.
2. Mark a phase complete only after every roadmap item and verification.
3. Add real command/result under Evidence after verification.
4. `[~]` means active, partial, or unverified.
