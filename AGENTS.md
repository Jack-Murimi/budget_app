# Agent Guide — Budget KE (`budget_app`)

Offline-first personal finance & M-Pesa budget tracker for Kenya (`com.budgetke.app`).

## Source of Truth (Read First)

1. Read **`PROGRESS.md`** for current version, DB schema, completed work, known issues, and unchecked tasks.
2. Read **`ROADMAP.md`** for implementation details of upcoming phases.
3. **Update `PROGRESS.md`** whenever you finish a feature, bump the DB schema, fix a known issue, or cut a release. Do not create duplicate status files.

## Architecture & Guardrails

- **Stack:** Flutter (`>=3.0.0 <4.0.0`), Riverpod, Drift (SQLite, schema **v22**, `PRAGMA foreign_keys = ON`), `fl_chart`, `intl`, `flutter_svg`, `local_auth`, `cryptography`.
- **Money math:** Monetary columns use integer cents via `CentsConverter` and `CashflowCalculator` — never introduce floating-point rounding drift.
- **Localization:** User-facing strings must be localized in both `lib/l10n/app_en.arb` and `lib/l10n/app_sw.arb` (`flutter gen-l10n`).
- **Play Protect safety:** Never re-add `READ_SMS` or `RECEIVE_SMS` permissions to `AndroidManifest.xml`.
- **Brand assets:** Bank and mobile-money logos live statically in `assets/brands/` and are wired through `PaymentProviders` (`lib/features/accounts/models/payment_provider.dart`) and `AccountBrandBadge` (`lib/features/accounts/widgets/account_brand_badge.dart`).
- **Secrets:** Never commit API keys, `.env` files, keystores, or signing passwords.

## Key Commands

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Obsidian Vault Integration

Jack's personal Obsidian project folder lives at:
`/home/jack/Documents/Obsidian/Obsidian/10-Projects/Budget KE/`

- `Progress.md` and `Roadmap.md` inside that folder are **symlinks** to `./PROGRESS.md` and `./ROADMAP.md` in this repository — updating the repo files keeps Obsidian up to date automatically.
- `context.md`, `decisions.md`, and `ideas.md` in Obsidian hold high-level project context, ADRs, and cross-project notes (e.g., overlap with SmartPesa).
- If your agent session has access outside the workspace and a major architectural decision or release lands, offer to log the ADR in Obsidian's `decisions.md` and refresh `context.md` (following `/home/jack/Documents/Obsidian/Obsidian/AGENTS.md` write rules). Never block on Obsidian if it is outside your sandbox — this repo's `PROGRESS.md` and `ROADMAP.md` are authoritative.
