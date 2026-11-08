// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Budget KE';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navMore => 'More';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemePureDark => 'Pure Dark (OLED)';

  @override
  String get settingsDynamicColor => 'Dynamic color';

  @override
  String get settingsDynamicColorDesc => 'Use wallpaper colors (Android 12+)';

  @override
  String get settingsBiometric => 'Biometric lock';

  @override
  String get settingsBiometricDesc => 'Require fingerprint or face to open app';

  @override
  String get settingsAutoLock => 'Auto-lock';

  @override
  String get settingsAutoLockImmediate => 'Immediately';

  @override
  String get settingsAutoLock1min => 'After 1 minute';

  @override
  String get settingsAutoLock5min => 'After 5 minutes';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get amount => 'Amount';

  @override
  String get amountKES => 'Amount (KES)';

  @override
  String get header => 'Header';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date & Time';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get biometricPrompt => 'Authenticate to open Budget KE';

  @override
  String get biometricLockedTitle => 'App Locked';

  @override
  String get biometricUnlock => 'Unlock';

  @override
  String get restoreConfirmTitle => 'Replace current data?';

  @override
  String get restoreConfirmBody =>
      'Restoring permanently replaces all current app data.';

  @override
  String get restore => 'Restore';

  @override
  String get errorRequired => 'Required';

  @override
  String get errorInvalidNumber => 'Enter a valid number';
}
