# Budget KE (M-Pesa Budget Tracker)

Offline-first personal finance tracker tailored for Kenya, featuring automated M-Pesa SMS parsing, local SQLite persistence, and category-level spending insights.

## Features

- **M-Pesa SMS Parsing**: Extracts transaction codes, amounts, recipients, and timestamps from standard M-Pesa notifications.
- **Offline-First Storage**: Local persistence powered by Drift (SQLite). No external cloud sync required.
- **Spending Analytics**: Category breakdown and interactive pie charts via `fl_chart`.
- **Reactive State**: Riverpod for state management and decoupled repository architecture.
- **Modern UI**: Material 3 light/dark theme support.

## Tech Stack

- **Framework**: Flutter (Dart SDK `>=3.0.0 <4.0.0`)
- **State Management**: `flutter_riverpod`
- **Database**: `drift` & `drift_flutter`
- **Charts**: `fl_chart`
- **Formatting**: `intl` (KES currency & timestamps)

## Getting Started

### Prerequisites

- Flutter SDK (3.x+)
- Android Studio / VS Code with Flutter extension
- Android device or emulator

### Setup

```bash
# Clone the repository
git clone https://github.com/<your-username>/budget_app.git
cd budget_app

# Install dependencies
flutter pub get

# Generate Drift database code (if modifying schema)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Running Tests

```bash
flutter test
```

## Automated Releases (GitHub Actions)

Pushing a `v*` tag triggers [`.github/workflows/release.yml`](.github/workflows/release.yml) to verify Play Protect safety (no `READ_SMS`/`RECEIVE_SMS`), run `flutter gen-l10n`, `flutter analyze`, and `flutter test`, build all 4 signed APKs + `SHA256SUMS.txt`, and publish the GitHub Release.

### Required GitHub Repository Secrets

Configure these 4 secrets under **Settings → Secrets and variables → Actions**:

- `RELEASE_KEYSTORE_BASE64`: Base64-encoded release `.jks` file:
  ```bash
  base64 -w 0 android/release-keystore.jks
  ```
- `KEYSTORE_PASSWORD`: Release keystore store password
- `KEY_ALIAS`: Release key alias (e.g., `budgetke`)
- `KEY_PASSWORD`: Release key password

### Cutting a Release

```bash
# 1. Bump version in pubspec.yaml (e.g., version: 1.0.3+4) and commit
# 2. Tag and push to trigger the release workflow
git tag -a v1.0.3 -m "Budget KE v1.0.3"
git push origin v1.0.3
```

## Project Structure

```text
lib/
├── core/database/         # Drift database schema & DAOs
├── features/
│   ├── add_transaction/  # Manual entry & SMS paste parser UI
│   ├── categories/       # Category models, providers, picker
│   ├── home/             # Dashboard, charts, spending cards
│   └── transactions/     # M-Pesa parser service & repo
└── shared/               # Theme and currency/date formatters
```

## License

MIT
