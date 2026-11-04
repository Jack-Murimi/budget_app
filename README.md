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
