// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Budget KE';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navTransactions => 'Miamala';

  @override
  String get navBudgets => 'Bajeti';

  @override
  String get navMore => 'Zaidi';

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String get settingsAppearance => 'Muonekano';

  @override
  String get settingsAbout => 'Kuhusu';

  @override
  String get settingsThemeSystem => 'Mfumo (otomatiki)';

  @override
  String get settingsThemeLight => 'Mwanga';

  @override
  String get settingsThemeDark => 'Giza';

  @override
  String get settingsThemePureDark => 'Giza Kamili (OLED)';

  @override
  String get settingsDynamicColor => 'Rangi zinazobadilika';

  @override
  String get settingsDynamicColorDesc =>
      'Tumia rangi za picha ya skrini (Android 12+)';

  @override
  String get settingsBiometric => 'Kufunga kwa biometriki';

  @override
  String get settingsBiometricDesc =>
      'Hitaji alama ya kidole au uso kufungua programu';

  @override
  String get settingsAutoLock => 'Kufunga otomatiki';

  @override
  String get settingsAutoLockImmediate => 'Mara moja';

  @override
  String get settingsAutoLock1min => 'Baada ya dakika 1';

  @override
  String get settingsAutoLock5min => 'Baada ya dakika 5';

  @override
  String get transactionsTitle => 'Miamala';

  @override
  String get addTransaction => 'Ongeza muamala';

  @override
  String get amount => 'Kiasi';

  @override
  String get amountKES => 'Kiasi (KES)';

  @override
  String get header => 'Kichwa';

  @override
  String get description => 'Maelezo';

  @override
  String get date => 'Tarehe & Saa';

  @override
  String get category => 'Kategoria';

  @override
  String get account => 'Akaunti';

  @override
  String get expense => 'Matumizi';

  @override
  String get income => 'Mapato';

  @override
  String get transfer => 'Uhamisho';

  @override
  String get save => 'Hifadhi';

  @override
  String get cancel => 'Ghairi';

  @override
  String get delete => 'Futa';

  @override
  String get edit => 'Hariri';

  @override
  String get budgetsTitle => 'Bajeti';

  @override
  String get accountsTitle => 'Akaunti';

  @override
  String get categoriesTitle => 'Kategoria';

  @override
  String get biometricPrompt => 'Thibitisha ili ufungue Budget KE';

  @override
  String get biometricLockedTitle => 'Programu Imefungwa';

  @override
  String get biometricUnlock => 'Fungua';

  @override
  String get restoreConfirmTitle => 'Badilisha data ya sasa?';

  @override
  String get restoreConfirmBody =>
      'Kurejesha itabadilisha data yote ya sasa kabisa.';

  @override
  String get restore => 'Rejesha';

  @override
  String get errorRequired => 'Inahitajika';

  @override
  String get errorInvalidNumber => 'Ingiza nambari sahihi';
}
