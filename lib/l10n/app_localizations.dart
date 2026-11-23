import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Budget KE'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @parse.
  ///
  /// In en, this message translates to:
  /// **'Parse'**
  String get parse;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get addMoney;

  /// No description provided for @useThis.
  ///
  /// In en, this message translates to:
  /// **'Use this'**
  String get useThis;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekTitle;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @otherLabel.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherLabel;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(String error);

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get errorRequired;

  /// No description provided for @errorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get errorInvalidNumber;

  /// No description provided for @errorPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount'**
  String get errorPositiveAmount;

  /// No description provided for @errorValidPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount'**
  String get errorValidPositiveAmount;

  /// No description provided for @errorValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get errorValidAmount;

  /// No description provided for @errorValidNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid balance'**
  String get errorValidNumberShort;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameRequired;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @header.
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get header;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountKES.
  ///
  /// In en, this message translates to:
  /// **'Amount (KES)'**
  String get amountKES;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get settingsLanguageSwahili;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa budget tracker'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemePureDark.
  ///
  /// In en, this message translates to:
  /// **'Pure Dark (OLED)'**
  String get settingsThemePureDark;

  /// No description provided for @settingsOledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'True black background in dark mode'**
  String get settingsOledSubtitle;

  /// No description provided for @settingsDynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Dynamic color'**
  String get settingsDynamicColor;

  /// No description provided for @settingsDynamicColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Use wallpaper colors (Android 12+)'**
  String get settingsDynamicColorDesc;

  /// No description provided for @settingsBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock'**
  String get settingsBiometric;

  /// No description provided for @settingsBiometricDesc.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or face to open app'**
  String get settingsBiometricDesc;

  /// No description provided for @settingsBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Screen lock or biometrics not available on this device'**
  String get settingsBiometricUnavailable;

  /// No description provided for @settingsBiometricRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to enable lock'**
  String get settingsBiometricRequired;

  /// No description provided for @settingsAutoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock after'**
  String get settingsAutoLock;

  /// No description provided for @settingsAutoLockImmediate.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get settingsAutoLockImmediate;

  /// No description provided for @settingsAutoLock1min.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get settingsAutoLock1min;

  /// No description provided for @settingsAutoLock5min.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get settingsAutoLock5min;

  /// No description provided for @biometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to open Budget KE'**
  String get biometricPrompt;

  /// No description provided for @biometricLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'App Locked'**
  String get biometricLockedTitle;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get biometricUnlock;

  /// No description provided for @overallBudget.
  ///
  /// In en, this message translates to:
  /// **'Overall Budget'**
  String get overallBudget;

  /// No description provided for @budgetProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'KES {spent} / KES {total} ({percent}%)'**
  String budgetProgressSummary(String spent, String total, String percent);

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @couldNotLoadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Could not load your transactions.'**
  String get couldNotLoadTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @pasteOrAddHint.
  ///
  /// In en, this message translates to:
  /// **'Paste an M-Pesa SMS or add manually'**
  String get pasteOrAddHint;

  /// No description provided for @billsOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill overdue!} other{{count} bills overdue!}}'**
  String billsOverdueCount(int count);

  /// No description provided for @billsDueSoonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill due soon} other{{count} bills due soon}}'**
  String billsDueSoonCount(int count);

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'spent this month'**
  String get spentThisMonth;

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesLabel;

  /// No description provided for @spendingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Spending Breakdown'**
  String get spendingBreakdown;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @noExpensesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get noExpensesInPeriod;

  /// No description provided for @spendingBreakdownSemantic.
  ///
  /// In en, this message translates to:
  /// **'Spending breakdown: {details}'**
  String spendingBreakdownSemantic(String details);

  /// No description provided for @pasteMpesaSmsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Paste M-Pesa SMS'**
  String get pasteMpesaSmsTooltip;

  /// No description provided for @addManuallyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManuallyTooltip;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty. Copy an M-Pesa SMS first.'**
  String get clipboardEmpty;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @fulizaAlreadyRecorded.
  ///
  /// In en, this message translates to:
  /// **'Already recorded — this Fuliza was saved before.'**
  String get fulizaAlreadyRecorded;

  /// No description provided for @fulizaLinkedToast.
  ///
  /// In en, this message translates to:
  /// **'Fuliza linked ✓  Transaction updated with Fuliza details.'**
  String get fulizaLinkedToast;

  /// No description provided for @fulizaRecordedToast.
  ///
  /// In en, this message translates to:
  /// **'Fuliza recorded ✓  Paste the paired M-Pesa send message next.'**
  String get fulizaRecordedToast;

  /// No description provided for @fulizaRepayAlreadyRecorded.
  ///
  /// In en, this message translates to:
  /// **'Already recorded — this Fuliza repayment was saved before.'**
  String get fulizaRepayAlreadyRecorded;

  /// No description provided for @fulizaRepaidToast.
  ///
  /// In en, this message translates to:
  /// **'Fuliza repaid: {amount}  •  Recorded ✓'**
  String fulizaRepaidToast(String amount);

  /// No description provided for @alreadyRecordedWithDate.
  ///
  /// In en, this message translates to:
  /// **'Already recorded — {ref} was saved on {date}.'**
  String alreadyRecordedWithDate(String ref, String date);

  /// No description provided for @pasteMpesaSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste M-Pesa SMS'**
  String get pasteMpesaSmsTitle;

  /// No description provided for @pasteMpesaHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your M-Pesa message here...'**
  String get pasteMpesaHint;

  /// No description provided for @pasteMpesaFirstError.
  ///
  /// In en, this message translates to:
  /// **'Paste an M-Pesa message first.'**
  String get pasteMpesaFirstError;

  /// No description provided for @couldNotParseError.
  ///
  /// In en, this message translates to:
  /// **'Could not parse: {error}'**
  String couldNotParseError(String error);

  /// No description provided for @deleteTransactionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get deleteTransactionTooltip;

  /// No description provided for @feeBadge.
  ///
  /// In en, this message translates to:
  /// **'+{fee} fee'**
  String feeBadge(String fee);

  /// No description provided for @fulizaBadge.
  ///
  /// In en, this message translates to:
  /// **'Fuliza'**
  String get fulizaBadge;

  /// No description provided for @transactionSemantics.
  ///
  /// In en, this message translates to:
  /// **'{kind} of {amount}, {header}{categoryPart}, {date}'**
  String transactionSemantics(String kind, String amount, String header,
      String categoryPart, String date);

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @searchTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactionsHint;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @filterByAccount.
  ///
  /// In en, this message translates to:
  /// **'Filter by Account'**
  String get filterByAccount;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteItemQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteItemQuestion(String name);

  /// No description provided for @deletedItemToast.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String deletedItemToast(String name);

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String transactionCount(int count);

  /// No description provided for @pickCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick category'**
  String get pickCategory;

  /// No description provided for @pickAccount.
  ///
  /// In en, this message translates to:
  /// **'Pick account'**
  String get pickAccount;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @completeTransaction.
  ///
  /// In en, this message translates to:
  /// **'Complete Transaction'**
  String get completeTransaction;

  /// No description provided for @updateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransaction;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get titleRequired;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries at Naivas'**
  String get titleHint;

  /// No description provided for @titleValidation.
  ///
  /// In en, this message translates to:
  /// **'Give this transaction a title'**
  String get titleValidation;

  /// No description provided for @paidTo.
  ///
  /// In en, this message translates to:
  /// **'Paid to'**
  String get paidTo;

  /// No description provided for @receivedFrom.
  ///
  /// In en, this message translates to:
  /// **'Received from'**
  String get receivedFrom;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @paidToHint.
  ///
  /// In en, this message translates to:
  /// **'Person, shop or paybill'**
  String get paidToHint;

  /// No description provided for @receivedFromHint.
  ///
  /// In en, this message translates to:
  /// **'Sender or source'**
  String get receivedFromHint;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get noteHint;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @suggestedFromPast.
  ///
  /// In en, this message translates to:
  /// **'Suggested from past entries'**
  String get suggestedFromPast;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @addTransactionFee.
  ///
  /// In en, this message translates to:
  /// **'Add transaction fee'**
  String get addTransactionFee;

  /// No description provided for @transactionFeeKes.
  ///
  /// In en, this message translates to:
  /// **'Transaction fee (KES)'**
  String get transactionFeeKes;

  /// No description provided for @mpesaOrBankCharge.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa or bank charge'**
  String get mpesaOrBankCharge;

  /// No description provided for @amountPlusFee.
  ///
  /// In en, this message translates to:
  /// **'Amount + fee: {total}'**
  String amountPlusFee(String total);

  /// No description provided for @accountWalletRequired.
  ///
  /// In en, this message translates to:
  /// **'Account / Wallet *'**
  String get accountWalletRequired;

  /// No description provided for @accountWallet.
  ///
  /// In en, this message translates to:
  /// **'Account / Wallet'**
  String get accountWallet;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get selectAccount;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccount;

  /// No description provided for @fromAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'From Account *'**
  String get fromAccountRequired;

  /// No description provided for @selectSourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Select source account'**
  String get selectSourceAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccount;

  /// No description provided for @toAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'To Account *'**
  String get toAccountRequired;

  /// No description provided for @selectDestAccount.
  ///
  /// In en, this message translates to:
  /// **'Select destination account'**
  String get selectDestAccount;

  /// No description provided for @selectDifferentDestAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a destination account different from the source'**
  String get selectDifferentDestAccount;

  /// No description provided for @accountsMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Accounts must be different'**
  String get accountsMustDiffer;

  /// No description provided for @couldNotLoadAccounts.
  ///
  /// In en, this message translates to:
  /// **'Could not load accounts'**
  String get couldNotLoadAccounts;

  /// No description provided for @noAccountsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No accounts available'**
  String get noAccountsAvailable;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @excludeFromBudget.
  ///
  /// In en, this message translates to:
  /// **'Exclude from budget'**
  String get excludeFromBudget;

  /// No description provided for @excludeFromBudgetDesc.
  ///
  /// In en, this message translates to:
  /// **'Does not count against spending limits'**
  String get excludeFromBudgetDesc;

  /// No description provided for @autoFilledMpesa.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled from M-Pesa'**
  String get autoFilledMpesa;

  /// No description provided for @autoFilledMpesaRef.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled from M-Pesa · {ref}'**
  String autoFilledMpesaRef(String ref);

  /// No description provided for @fulizaUsedBanner.
  ///
  /// In en, this message translates to:
  /// **'Fuliza used: {amount} (fee: {fee})'**
  String fulizaUsedBanner(String amount, String fee);

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes on this transaction.'**
  String get discardChangesBody;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @amountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountGreaterThanZero;

  /// No description provided for @enterValidCost.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid cost'**
  String get enterValidCost;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionUpdated;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved!'**
  String get transactionSaved;

  /// No description provided for @alreadySavedMpesa.
  ///
  /// In en, this message translates to:
  /// **'Already saved — this M-Pesa transaction was recorded before.'**
  String get alreadySavedMpesa;

  /// No description provided for @couldNotUpdateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Could not update the transaction. Try again.'**
  String get couldNotUpdateTransaction;

  /// No description provided for @couldNotSaveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Could not save the transaction. Try again.'**
  String get couldNotSaveTransaction;

  /// No description provided for @addBorrowerInDesc.
  ///
  /// In en, this message translates to:
  /// **'Add who you lent to in Description'**
  String get addBorrowerInDesc;

  /// No description provided for @addLenderInDesc.
  ///
  /// In en, this message translates to:
  /// **'Add lender name in Description / Payee'**
  String get addLenderInDesc;

  /// No description provided for @selectWhoRepaying.
  ///
  /// In en, this message translates to:
  /// **'Select who is repaying'**
  String get selectWhoRepaying;

  /// No description provided for @borrowerNoOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Selected borrower no longer has an outstanding balance. Please re-select.'**
  String get borrowerNoOutstanding;

  /// No description provided for @amountExceedsOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds outstanding balance of {amount}'**
  String amountExceedsOutstanding(String amount);

  /// No description provided for @borrower.
  ///
  /// In en, this message translates to:
  /// **'Borrower'**
  String get borrower;

  /// No description provided for @borrowerRequired.
  ///
  /// In en, this message translates to:
  /// **'Borrower *'**
  String get borrowerRequired;

  /// No description provided for @noOutstandingLoans.
  ///
  /// In en, this message translates to:
  /// **'No outstanding loans to repay'**
  String get noOutstandingLoans;

  /// No description provided for @couldNotLoadBorrowers.
  ///
  /// In en, this message translates to:
  /// **'Could not load borrowers'**
  String get couldNotLoadBorrowers;

  /// No description provided for @lender.
  ///
  /// In en, this message translates to:
  /// **'Lender'**
  String get lender;

  /// No description provided for @lenderRepaidRequired.
  ///
  /// In en, this message translates to:
  /// **'Lender being repaid *'**
  String get lenderRepaidRequired;

  /// No description provided for @selectLoanToRepay.
  ///
  /// In en, this message translates to:
  /// **'Select loan to repay'**
  String get selectLoanToRepay;

  /// No description provided for @noOpenBorrowedLoans.
  ///
  /// In en, this message translates to:
  /// **'No open borrowed loans to link'**
  String get noOpenBorrowedLoans;

  /// No description provided for @couldNotLoadLenders.
  ///
  /// In en, this message translates to:
  /// **'Could not load lenders'**
  String get couldNotLoadLenders;

  /// No description provided for @actualCreditedOptional.
  ///
  /// In en, this message translates to:
  /// **'Actual amount credited (optional)'**
  String get actualCreditedOptional;

  /// No description provided for @actualCreditedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 570 if 600 was borrowed'**
  String get actualCreditedHint;

  /// No description provided for @actualCreditedHelper.
  ///
  /// In en, this message translates to:
  /// **'Deductions (shortfall) will be tracked under Bridge charges'**
  String get actualCreditedHelper;

  /// No description provided for @cannotExceedBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed borrowed amount'**
  String get cannotExceedBorrowed;

  /// No description provided for @evaluateExpressionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Evaluate expression'**
  String get evaluateExpressionTooltip;

  /// No description provided for @enterValidExpression.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid expression'**
  String get enterValidExpression;

  /// No description provided for @evaluateExpressionFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap ✓ to evaluate expression first'**
  String get evaluateExpressionFirst;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @showActive.
  ///
  /// In en, this message translates to:
  /// **'Show active'**
  String get showActive;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @noArchivedBudgets.
  ///
  /// In en, this message translates to:
  /// **'No archived budgets'**
  String get noArchivedBudgets;

  /// No description provided for @noBudgetsSetYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets set yet'**
  String get noBudgetsSetYet;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteBudgetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteBudgetConfirm(String name);

  /// No description provided for @budgetCreated.
  ///
  /// In en, this message translates to:
  /// **'Budget created'**
  String get budgetCreated;

  /// No description provided for @budgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated'**
  String get budgetUpdated;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @budgetArchived.
  ///
  /// In en, this message translates to:
  /// **'Budget archived'**
  String get budgetArchived;

  /// No description provided for @budgetUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Budget unarchived'**
  String get budgetUnarchived;

  /// No description provided for @archiveBudgetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive budget'**
  String get archiveBudgetTooltip;

  /// No description provided for @unarchiveBudgetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unarchive budget'**
  String get unarchiveBudgetTooltip;

  /// No description provided for @editBudgetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudgetTooltip;

  /// No description provided for @deleteBudgetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete budget'**
  String get deleteBudgetTooltip;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @startWithDate.
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String startWithDate(String date);

  /// No description provided for @endWithDate.
  ///
  /// In en, this message translates to:
  /// **'End: {date}'**
  String endWithDate(String date);

  /// No description provided for @overallBudgetAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'Overall Budget (All Expenses)'**
  String get overallBudgetAllExpenses;

  /// No description provided for @useOverallBudget.
  ///
  /// In en, this message translates to:
  /// **'Use Overall Budget'**
  String get useOverallBudget;

  /// No description provided for @rolloverRemainingBudget.
  ///
  /// In en, this message translates to:
  /// **'Rollover remaining budget'**
  String get rolloverRemainingBudget;

  /// No description provided for @rolloverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Carry over unused amount to next period'**
  String get rolloverSubtitle;

  /// No description provided for @rolloverPlusBadge.
  ///
  /// In en, this message translates to:
  /// **'+{amount} rollover'**
  String rolloverPlusBadge(String amount);

  /// No description provided for @rolloverIncludes.
  ///
  /// In en, this message translates to:
  /// **'Includes {amount} rollover from previous period'**
  String rolloverIncludes(String amount);

  /// No description provided for @overBudgetBy.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String overBudgetBy(String amount);

  /// No description provided for @amountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String amountLeft(String amount);

  /// No description provided for @amountRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String amountRemaining(String amount);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @noRemainingBudget.
  ///
  /// In en, this message translates to:
  /// **'No remaining budget'**
  String get noRemainingBudget;

  /// No description provided for @periodEnded.
  ///
  /// In en, this message translates to:
  /// **'Period ended'**
  String get periodEnded;

  /// No description provided for @recommendedDaily.
  ///
  /// In en, this message translates to:
  /// **'{daily} / day for the remaining {days, plural, =1{1 day} other{{days} days}}'**
  String recommendedDaily(String daily, int days);

  /// No description provided for @contributingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Contributing Transactions'**
  String get contributingTransactions;

  /// No description provided for @noExpensesInPeriodYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period yet'**
  String get noExpensesInPeriodYet;

  /// No description provided for @budgetAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount (KES) *'**
  String get budgetAmountRequired;

  /// No description provided for @budgetNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get budgetNameRequiredError;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts & Wallets'**
  String get accountsTitle;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet. Tap + to add one.'**
  String get noAccountsYet;

  /// No description provided for @errorLoadingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts'**
  String get errorLoadingAccounts;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @enterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Enter account name'**
  String get enterAccountName;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @transferBetweenAccounts.
  ///
  /// In en, this message translates to:
  /// **'Transfer Between Accounts'**
  String get transferBetweenAccounts;

  /// No description provided for @feeKes.
  ///
  /// In en, this message translates to:
  /// **'Fee (KES)'**
  String get feeKes;

  /// No description provided for @feeCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Fee cannot be negative'**
  String get feeCannotBeNegative;

  /// No description provided for @needTwoAccountsToTransfer.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 active accounts to transfer'**
  String get needTwoAccountsToTransfer;

  /// No description provided for @transferRecorded.
  ///
  /// In en, this message translates to:
  /// **'Transfer recorded'**
  String get transferRecorded;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? All linked transactions will lose their account reference.'**
  String deleteAccountConfirm(String name);

  /// No description provided for @accountSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'{name} set as default'**
  String accountSetAsDefault(String name);

  /// No description provided for @accountArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String accountArchived(String name);

  /// No description provided for @accountUnarchived.
  ///
  /// In en, this message translates to:
  /// **'{name} unarchived'**
  String accountUnarchived(String name);

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @adjustBalance.
  ///
  /// In en, this message translates to:
  /// **'Adjust Balance'**
  String get adjustBalance;

  /// No description provided for @newBalance.
  ///
  /// In en, this message translates to:
  /// **'New Balance'**
  String get newBalance;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @noArchivedCategories.
  ///
  /// In en, this message translates to:
  /// **'No archived categories'**
  String get noArchivedCategories;

  /// No description provided for @addSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Add subcategory'**
  String get addSubcategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @parentCategory.
  ///
  /// In en, this message translates to:
  /// **'Parent Category'**
  String get parentCategory;

  /// No description provided for @noneTopLevel.
  ///
  /// In en, this message translates to:
  /// **'None (Top-level)'**
  String get noneTopLevel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @noTypeCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No {type} categories found'**
  String noTypeCategoriesFound(String type);

  /// No description provided for @debtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loans & Debts'**
  String get debtsTitle;

  /// No description provided for @lendMoney.
  ///
  /// In en, this message translates to:
  /// **'Lend money'**
  String get lendMoney;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get addDebt;

  /// No description provided for @theyOweMe.
  ///
  /// In en, this message translates to:
  /// **'They owe me'**
  String get theyOweMe;

  /// No description provided for @iOweThem.
  ///
  /// In en, this message translates to:
  /// **'I owe them'**
  String get iOweThem;

  /// No description provided for @noLoansGiven.
  ///
  /// In en, this message translates to:
  /// **'No loans given'**
  String get noLoansGiven;

  /// No description provided for @noLoansGivenDesc.
  ///
  /// In en, this message translates to:
  /// **'Track money you have lent to others.'**
  String get noLoansGivenDesc;

  /// No description provided for @noDebtsOwed.
  ///
  /// In en, this message translates to:
  /// **'No debts owed'**
  String get noDebtsOwed;

  /// No description provided for @noDebtsOwedDesc.
  ///
  /// In en, this message translates to:
  /// **'Track money you have borrowed from others.'**
  String get noDebtsOwedDesc;

  /// No description provided for @unableToLoadDebts.
  ///
  /// In en, this message translates to:
  /// **'Unable to load debts: {error}'**
  String unableToLoadDebts(String error);

  /// No description provided for @noRepaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No repayments yet'**
  String get noRepaymentsYet;

  /// No description provided for @repaymentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 repayment} other{{count} repayments}}'**
  String repaymentCount(int count);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueDateLabel(String date);

  /// No description provided for @dueColonDate.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueColonDate(String date);

  /// No description provided for @repay.
  ///
  /// In en, this message translates to:
  /// **'Repay'**
  String get repay;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// No description provided for @recordRepayment.
  ///
  /// In en, this message translates to:
  /// **'Record repayment'**
  String get recordRepayment;

  /// No description provided for @editDebt.
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get editDebt;

  /// No description provided for @addLoanGiven.
  ///
  /// In en, this message translates to:
  /// **'Add loan given'**
  String get addLoanGiven;

  /// No description provided for @personBorrower.
  ///
  /// In en, this message translates to:
  /// **'Person (borrower)'**
  String get personBorrower;

  /// No description provided for @personOrLender.
  ///
  /// In en, this message translates to:
  /// **'Person or lender'**
  String get personOrLender;

  /// No description provided for @enterAName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get enterAName;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @iBorrowed.
  ///
  /// In en, this message translates to:
  /// **'I borrowed'**
  String get iBorrowed;

  /// No description provided for @iLent.
  ///
  /// In en, this message translates to:
  /// **'I lent'**
  String get iLent;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @mshwari.
  ///
  /// In en, this message translates to:
  /// **'M-Shwari'**
  String get mshwari;

  /// No description provided for @hustlerFund.
  ///
  /// In en, this message translates to:
  /// **'Hustler Fund'**
  String get hustlerFund;

  /// No description provided for @bridge.
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get bridge;

  /// No description provided for @principalKes.
  ///
  /// In en, this message translates to:
  /// **'Principal (KES)'**
  String get principalKes;

  /// No description provided for @enterPositivePrincipal.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive principal'**
  String get enterPositivePrincipal;

  /// No description provided for @actualCreditedKes.
  ///
  /// In en, this message translates to:
  /// **'Actual amount credited (KES)'**
  String get actualCreditedKes;

  /// No description provided for @actualCreditedBridgeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. borrow 600 but only 570 hits your M-Pesa'**
  String get actualCreditedBridgeExample;

  /// No description provided for @totalInterestExtraKes.
  ///
  /// In en, this message translates to:
  /// **'Total interest/repayment extra (KES)'**
  String get totalInterestExtraKes;

  /// No description provided for @enterZeroOrMore.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 or more'**
  String get enterZeroOrMore;

  /// No description provided for @noAccountTrackOnly.
  ///
  /// In en, this message translates to:
  /// **'No account (track only)'**
  String get noAccountTrackOnly;

  /// No description provided for @addDueDate.
  ///
  /// In en, this message translates to:
  /// **'Add due date'**
  String get addDueDate;

  /// No description provided for @clearDueDate.
  ///
  /// In en, this message translates to:
  /// **'Clear due date'**
  String get clearDueDate;

  /// No description provided for @unableToSaveDebt.
  ///
  /// In en, this message translates to:
  /// **'Unable to save debt: {error}'**
  String unableToSaveDebt(String error);

  /// No description provided for @repayTarget.
  ///
  /// In en, this message translates to:
  /// **'Repay {name}'**
  String repayTarget(String name);

  /// No description provided for @amountMaxOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Amount, max {amount}'**
  String amountMaxOutstanding(String amount);

  /// No description provided for @amountUpToOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount up to the outstanding balance'**
  String get amountUpToOutstanding;

  /// No description provided for @payFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Pay from account'**
  String get payFromAccount;

  /// No description provided for @receiveIntoAccount.
  ///
  /// In en, this message translates to:
  /// **'Receive into account'**
  String get receiveIntoAccount;

  /// No description provided for @alsoDeleteLinkedTxns.
  ///
  /// In en, this message translates to:
  /// **'Also delete linked ledger transactions'**
  String get alsoDeleteLinkedTxns;

  /// No description provided for @alsoDeleteLinkedTxn.
  ///
  /// In en, this message translates to:
  /// **'Also delete linked ledger transaction'**
  String get alsoDeleteLinkedTxn;

  /// No description provided for @loanReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Loan received'**
  String get loanReceivedLabel;

  /// No description provided for @loanDisbursedLabel.
  ///
  /// In en, this message translates to:
  /// **'Loan disbursed'**
  String get loanDisbursedLabel;

  /// No description provided for @repaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Repayment'**
  String get repaymentLabel;

  /// No description provided for @editDebtTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get editDebtTooltip;

  /// No description provided for @deleteDebtTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete debt'**
  String get deleteDebtTooltip;

  /// No description provided for @totalBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total borrowed'**
  String get totalBorrowed;

  /// No description provided for @totalLent.
  ///
  /// In en, this message translates to:
  /// **'Total lent'**
  String get totalLent;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get repaid;

  /// No description provided for @interestFeesLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest/Fees: {amount}'**
  String interestFeesLabel(String amount);

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @noTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'No transaction history'**
  String get noTransactionHistory;

  /// No description provided for @debtUpdated.
  ///
  /// In en, this message translates to:
  /// **'Debt updated'**
  String get debtUpdated;

  /// No description provided for @deleteDebtTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete debt'**
  String get deleteDebtTitle;

  /// No description provided for @deleteDebtConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and all its repayment records?'**
  String deleteDebtConfirm(String name);

  /// No description provided for @deleteRepaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete repayment'**
  String get deleteRepaymentTitle;

  /// No description provided for @deleteRepaymentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove repayment of {amount} and restore outstanding balance?'**
  String deleteRepaymentConfirm(String amount);

  /// No description provided for @repaymentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Repayment deleted'**
  String get repaymentDeleted;

  /// No description provided for @deleteRepaymentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete repayment'**
  String get deleteRepaymentTooltip;

  /// No description provided for @bridgeChargesTitle.
  ///
  /// In en, this message translates to:
  /// **'Bridge Loan Charges'**
  String get bridgeChargesTitle;

  /// No description provided for @totalBridgeCharges.
  ///
  /// In en, this message translates to:
  /// **'Total Bridge charges'**
  String get totalBridgeCharges;

  /// No description provided for @upfrontDeductionsShortfall.
  ///
  /// In en, this message translates to:
  /// **'Upfront deductions (shortfall)'**
  String get upfrontDeductionsShortfall;

  /// No description provided for @upfrontDeductionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Difference between borrowed principal and credited cash'**
  String get upfrontDeductionsTooltip;

  /// No description provided for @repaymentInterest.
  ///
  /// In en, this message translates to:
  /// **'Repayment interest'**
  String get repaymentInterest;

  /// No description provided for @repaymentInterestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Extra paid back on top of principal'**
  String get repaymentInterestTooltip;

  /// No description provided for @totalPrincipalBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total principal borrowed'**
  String get totalPrincipalBorrowed;

  /// No description provided for @totalLoans.
  ///
  /// In en, this message translates to:
  /// **'Total loans'**
  String get totalLoans;

  /// No description provided for @loansHeader.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loansHeader;

  /// No description provided for @borrowedAmount.
  ///
  /// In en, this message translates to:
  /// **'Borrowed {amount}'**
  String borrowedAmount(String amount);

  /// No description provided for @upfrontDeductionRow.
  ///
  /// In en, this message translates to:
  /// **'Upfront deduction: {shortfall} (received {received})'**
  String upfrontDeductionRow(String shortfall, String received);

  /// No description provided for @repaymentInterestRow.
  ///
  /// In en, this message translates to:
  /// **'Repayment interest: {amount}'**
  String repaymentInterestRow(String amount);

  /// No description provided for @outstandingRow.
  ///
  /// In en, this message translates to:
  /// **'Outstanding: {amount}'**
  String outstandingRow(String amount);

  /// No description provided for @settledOnDate.
  ///
  /// In en, this message translates to:
  /// **'Settled: {date}'**
  String settledOnDate(String date);

  /// No description provided for @lastPaymentOnDate.
  ///
  /// In en, this message translates to:
  /// **'Last payment: {date}'**
  String lastPaymentOnDate(String date);

  /// No description provided for @totalChargesLabel.
  ///
  /// In en, this message translates to:
  /// **'total charges'**
  String get totalChargesLabel;

  /// No description provided for @noBridgeLoansInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No Bridge loans found in this period'**
  String get noBridgeLoansInPeriod;

  /// No description provided for @noBridgeLoansRecorded.
  ///
  /// In en, this message translates to:
  /// **'No Bridge loans recorded yet'**
  String get noBridgeLoansRecorded;

  /// No description provided for @bridgeEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Record a loan received from Bridge under Income with category \"Loan Received\"'**
  String get bridgeEmptyHint;

  /// No description provided for @fulizaTitle.
  ///
  /// In en, this message translates to:
  /// **'Fuliza M-PESA'**
  String get fulizaTitle;

  /// No description provided for @fulizaUsageHistory.
  ///
  /// In en, this message translates to:
  /// **'Fuliza Usage History'**
  String get fulizaUsageHistory;

  /// No description provided for @fulizaBalanceCleared.
  ///
  /// In en, this message translates to:
  /// **'Fuliza balance cleared.'**
  String get fulizaBalanceCleared;

  /// No description provided for @fulizaRepaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Fuliza repayment of {amount} recorded.'**
  String fulizaRepaymentRecorded(String amount);

  /// No description provided for @recordFulizaRepayment.
  ///
  /// In en, this message translates to:
  /// **'Record Fuliza Repayment'**
  String get recordFulizaRepayment;

  /// No description provided for @outstandingHelper.
  ///
  /// In en, this message translates to:
  /// **'Outstanding: {amount}'**
  String outstandingHelper(String amount);

  /// No description provided for @fulizaOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Fuliza Outstanding'**
  String get fulizaOutstanding;

  /// No description provided for @noFulizaBalance.
  ///
  /// In en, this message translates to:
  /// **'No Fuliza Balance'**
  String get noFulizaBalance;

  /// No description provided for @dueDateOverdue.
  ///
  /// In en, this message translates to:
  /// **'Due {date} — OVERDUE'**
  String dueDateOverdue(String date);

  /// No description provided for @recordRepaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Record Repayment'**
  String get recordRepaymentButton;

  /// No description provided for @totalFeesPaid.
  ///
  /// In en, this message translates to:
  /// **'Total fees paid: {amount}'**
  String totalFeesPaid(String amount);

  /// No description provided for @repaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Repaid {amount}'**
  String repaidAmount(String amount);

  /// No description provided for @refPrefix.
  ///
  /// In en, this message translates to:
  /// **'Ref: {ref}'**
  String refPrefix(String ref);

  /// No description provided for @accessFeeRow.
  ///
  /// In en, this message translates to:
  /// **'Access fee: {amount}'**
  String accessFeeRow(String amount);

  /// No description provided for @noFulizaUsageRecorded.
  ///
  /// In en, this message translates to:
  /// **'No Fuliza usage recorded'**
  String get noFulizaUsageRecorded;

  /// No description provided for @pasteFulizaHint.
  ///
  /// In en, this message translates to:
  /// **'Paste Fuliza M-PESA SMS messages to track your Fuliza usage'**
  String get pasteFulizaHint;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get goalsTitle;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addGoal;

  /// No description provided for @unableToLoadGoals.
  ///
  /// In en, this message translates to:
  /// **'Unable to load goals: {error}'**
  String unableToLoadGoals(String error);

  /// No description provided for @savingsGoalSaved.
  ///
  /// In en, this message translates to:
  /// **'Savings goal saved'**
  String get savingsGoalSaved;

  /// No description provided for @editSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit savings goal'**
  String get editSavingsGoal;

  /// No description provided for @addSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Add savings goal'**
  String get addSavingsGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @enterGoalName.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal name'**
  String get enterGoalName;

  /// No description provided for @targetKes.
  ///
  /// In en, this message translates to:
  /// **'Target (KES)'**
  String get targetKes;

  /// No description provided for @enterPositiveTarget.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive target amount'**
  String get enterPositiveTarget;

  /// No description provided for @addTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Add target date'**
  String get addTargetDate;

  /// No description provided for @targetDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Target {date}'**
  String targetDateLabel(String date);

  /// No description provided for @clearTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Clear target date'**
  String get clearTargetDate;

  /// No description provided for @unableToSaveGoal.
  ///
  /// In en, this message translates to:
  /// **'Unable to save goal: {error}'**
  String unableToSaveGoal(String error);

  /// No description provided for @addToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String addToGoal(String name);

  /// No description provided for @fromAccountLower.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccountLower;

  /// No description provided for @unableToRecordContribution.
  ///
  /// In en, this message translates to:
  /// **'Unable to record contribution: {error}'**
  String unableToRecordContribution(String error);

  /// No description provided for @contributionHistory.
  ///
  /// In en, this message translates to:
  /// **'Contribution history'**
  String get contributionHistory;

  /// No description provided for @goalAmountProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {target}'**
  String goalAmountProgress(String current, String target);

  /// No description provided for @remainingTarget.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}{targetPart}'**
  String remainingTarget(String amount, String targetPart);

  /// No description provided for @addedContributionTo.
  ///
  /// In en, this message translates to:
  /// **'Added contribution to {name}'**
  String addedContributionTo(String name);

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated'**
  String get goalUpdated;

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get deleteGoalTitle;

  /// No description provided for @deleteGoalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and its contribution history?'**
  String deleteGoalConfirm(String name);

  /// No description provided for @goalContributionsHeader.
  ///
  /// In en, this message translates to:
  /// **'{name} · Contributions'**
  String goalContributionsHeader(String name);

  /// No description provided for @unableToLoadContributions.
  ///
  /// In en, this message translates to:
  /// **'Unable to load contributions: {error}'**
  String unableToLoadContributions(String error);

  /// No description provided for @noContributionsYet.
  ///
  /// In en, this message translates to:
  /// **'No contributions recorded yet.'**
  String get noContributionsYet;

  /// No description provided for @deleteContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete contribution'**
  String get deleteContributionTitle;

  /// No description provided for @deleteContributionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this contribution from the goal total?'**
  String get deleteContributionConfirm;

  /// No description provided for @deleteContributionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete contribution'**
  String get deleteContributionTooltip;

  /// No description provided for @noSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'No savings goals'**
  String get noSavingsGoals;

  /// No description provided for @noSavingsGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a target, then allocate money from an account.'**
  String get noSavingsGoalsDesc;

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring & Bills'**
  String get recurringTitle;

  /// No description provided for @addRecurringTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Recurring Bill'**
  String get addRecurringTooltip;

  /// No description provided for @monthlyCommitments.
  ///
  /// In en, this message translates to:
  /// **'Monthly Commitments'**
  String get monthlyCommitments;

  /// No description provided for @overdueCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Overdue'**
  String overdueCountBadge(int count);

  /// No description provided for @activeCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String activeCountBadge(int count);

  /// No description provided for @upcomingAndDue.
  ///
  /// In en, this message translates to:
  /// **'Upcoming & Due'**
  String get upcomingAndDue;

  /// No description provided for @allSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'All Subscriptions'**
  String get allSubscriptions;

  /// No description provided for @noUpcomingBillsDue.
  ///
  /// In en, this message translates to:
  /// **'No upcoming bills due'**
  String get noUpcomingBillsDue;

  /// No description provided for @noUpcomingBillsDueDesc.
  ///
  /// In en, this message translates to:
  /// **'Bills due or overdue within the next 30 days appear here.'**
  String get noUpcomingBillsDueDesc;

  /// No description provided for @noRecurringTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get noRecurringTransactions;

  /// No description provided for @noRecurringTransactionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set up recurring bills, salaries, rent, and subscriptions.'**
  String get noRecurringTransactionsDesc;

  /// No description provided for @recordedPaymentToast.
  ///
  /// In en, this message translates to:
  /// **'Recorded \"{name}\" payment ✓'**
  String recordedPaymentToast(String name);

  /// No description provided for @skipOccurrenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip this occurrence?'**
  String get skipOccurrenceTitle;

  /// No description provided for @skipOccurrenceBody.
  ///
  /// In en, this message translates to:
  /// **'Skip payment for \"{name}\"? Next due date will advance to the following cycle without creating a ledger transaction.'**
  String skipOccurrenceBody(String name);

  /// No description provided for @skippedOccurrenceToast.
  ///
  /// In en, this message translates to:
  /// **'Skipped \"{name}\" occurrence'**
  String skippedOccurrenceToast(String name);

  /// No description provided for @deleteRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recurring Item?'**
  String get deleteRecurringTitle;

  /// No description provided for @deleteRecurringBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Past recorded transactions will remain in your ledger.'**
  String deleteRecurringBody(String name);

  /// No description provided for @recordPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Record \"{name}\" as Paid?'**
  String recordPaidTitle(String name);

  /// No description provided for @recordPaidBody.
  ///
  /// In en, this message translates to:
  /// **'This will log a transaction in your ledger and advance the due date to the next cycle.'**
  String get recordPaidBody;

  /// No description provided for @amountPaidKes.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid (KES)'**
  String get amountPaidKes;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @confirmPaid.
  ///
  /// In en, this message translates to:
  /// **'Confirm Paid'**
  String get confirmPaid;

  /// No description provided for @overdueByDays.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {days}d'**
  String overdueByDays(int days);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due Tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'Due in {days}d'**
  String dueInDays(int days);

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @editRecurring.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring'**
  String get editRecurring;

  /// No description provided for @newRecurringAndBill.
  ///
  /// In en, this message translates to:
  /// **'New Recurring & Bill'**
  String get newRecurringAndBill;

  /// No description provided for @payeeSubscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Payee / Subscription Name *'**
  String get payeeSubscriptionRequired;

  /// No description provided for @payeeSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Netflix, Home Internet, Rent, Salary'**
  String get payeeSubscriptionHint;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @mustBeAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Must be >= 1'**
  String get mustBeAtLeastOne;

  /// No description provided for @intervalAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Interval must be at least 1'**
  String get intervalAtLeastOne;

  /// No description provided for @nextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next Due Date'**
  String get nextDueDate;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (Optional)'**
  String get endDateOptional;

  /// No description provided for @runsIndefinitely.
  ///
  /// In en, this message translates to:
  /// **'Runs indefinitely'**
  String get runsIndefinitely;

  /// No description provided for @setEnd.
  ///
  /// In en, this message translates to:
  /// **'Set End'**
  String get setEnd;

  /// No description provided for @defaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Default Account'**
  String get defaultAccount;

  /// No description provided for @categoryWithName.
  ///
  /// In en, this message translates to:
  /// **'Category: {name}'**
  String categoryWithName(String name);

  /// No description provided for @autoRecordWhenDue.
  ///
  /// In en, this message translates to:
  /// **'Auto-record when due'**
  String get autoRecordWhenDue;

  /// No description provided for @autoRecordWhenDueDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically log transactions when the app opens on or after the due date'**
  String get autoRecordWhenDueDesc;

  /// No description provided for @notesBillingHint.
  ///
  /// In en, this message translates to:
  /// **'Account number, billing notes, etc.'**
  String get notesBillingHint;

  /// No description provided for @repeatsSummary.
  ///
  /// In en, this message translates to:
  /// **'Repeats {freq}, starting {date}.'**
  String repeatsSummary(String freq, String date);

  /// No description provided for @createRecurringItem.
  ///
  /// In en, this message translates to:
  /// **'Create Recurring Item'**
  String get createRecurringItem;

  /// No description provided for @subscriptionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated'**
  String get subscriptionUpdated;

  /// No description provided for @recurringBillSaved.
  ///
  /// In en, this message translates to:
  /// **'Recurring bill saved'**
  String get recurringBillSaved;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {count} days'**
  String everyNDays(int count);

  /// No description provided for @everyNWeeks.
  ///
  /// In en, this message translates to:
  /// **'Every {count} weeks'**
  String everyNWeeks(int count);

  /// No description provided for @everyNMonths.
  ///
  /// In en, this message translates to:
  /// **'Every {count} months'**
  String everyNMonths(int count);

  /// No description provided for @everyNYears.
  ///
  /// In en, this message translates to:
  /// **'Every {count} years'**
  String everyNYears(int count);

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @unableToLoadInsights.
  ///
  /// In en, this message translates to:
  /// **'Unable to load insights: {error}'**
  String unableToLoadInsights(String error);

  /// No description provided for @cashflowSummary.
  ///
  /// In en, this message translates to:
  /// **'Cashflow summary'**
  String get cashflowSummary;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @avgDailySpend.
  ///
  /// In en, this message translates to:
  /// **'Avg daily spend: {amount}/day'**
  String avgDailySpend(String amount);

  /// No description provided for @upPercentFromPrevious.
  ///
  /// In en, this message translates to:
  /// **'Up {percent}% from previous period'**
  String upPercentFromPrevious(String percent);

  /// No description provided for @downPercentFromPrevious.
  ///
  /// In en, this message translates to:
  /// **'Down {percent}% from previous period'**
  String downPercentFromPrevious(String percent);

  /// No description provided for @dailyCashflow.
  ///
  /// In en, this message translates to:
  /// **'Daily cashflow'**
  String get dailyCashflow;

  /// No description provided for @weeklyCashflow.
  ///
  /// In en, this message translates to:
  /// **'Weekly cashflow'**
  String get weeklyCashflow;

  /// No description provided for @monthlyCashflow.
  ///
  /// In en, this message translates to:
  /// **'Monthly cashflow'**
  String get monthlyCashflow;

  /// No description provided for @noCashflowInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No cashflow in this period'**
  String get noCashflowInPeriod;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get spendingByCategory;

  /// No description provided for @netWorthTrend.
  ///
  /// In en, this message translates to:
  /// **'Net worth trend'**
  String get netWorthTrend;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @searchFeaturesHint.
  ///
  /// In en, this message translates to:
  /// **'Search features...'**
  String get searchFeaturesHint;

  /// No description provided for @noMatchingFeatures.
  ///
  /// In en, this message translates to:
  /// **'No matching features found'**
  String get noMatchingFeatures;

  /// No description provided for @sectionMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get sectionMoney;

  /// No description provided for @sectionAutomation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get sectionAutomation;

  /// No description provided for @sectionOrganize.
  ///
  /// In en, this message translates to:
  /// **'Organize'**
  String get sectionOrganize;

  /// No description provided for @sectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sectionApp;

  /// No description provided for @moreAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get moreAccounts;

  /// No description provided for @moreLoansAndDebts.
  ///
  /// In en, this message translates to:
  /// **'Loans & Debts'**
  String get moreLoansAndDebts;

  /// No description provided for @moreBridgeCharges.
  ///
  /// In en, this message translates to:
  /// **'Bridge Charges'**
  String get moreBridgeCharges;

  /// No description provided for @moreBridgeChargesSub.
  ///
  /// In en, this message translates to:
  /// **'Track costs from Bridge loans'**
  String get moreBridgeChargesSub;

  /// No description provided for @moreFulizaOverdraft.
  ///
  /// In en, this message translates to:
  /// **'Fuliza Overdraft'**
  String get moreFulizaOverdraft;

  /// No description provided for @moreRecurringBills.
  ///
  /// In en, this message translates to:
  /// **'Recurring & Bills'**
  String get moreRecurringBills;

  /// No description provided for @moreScanSms.
  ///
  /// In en, this message translates to:
  /// **'Scan SMS Inbox'**
  String get moreScanSms;

  /// No description provided for @moreScanSmsSub.
  ///
  /// In en, this message translates to:
  /// **'Import M-Pesa SMS from your inbox'**
  String get moreScanSmsSub;

  /// No description provided for @moreCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get moreCategories;

  /// No description provided for @moreSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get moreSavingsGoals;

  /// No description provided for @moreInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights & Analytics'**
  String get moreInsights;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettings;

  /// No description provided for @moreExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export & Backup'**
  String get moreExportBackup;

  /// No description provided for @portabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Export & backup'**
  String get portabilityTitle;

  /// No description provided for @csvHeading.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csvHeading;

  /// No description provided for @csvDescription.
  ///
  /// In en, this message translates to:
  /// **'Export tables or import standard transaction CSVs.'**
  String get csvDescription;

  /// No description provided for @exportCsvFiles.
  ///
  /// In en, this message translates to:
  /// **'Export CSV files'**
  String get exportCsvFiles;

  /// No description provided for @importTransactionsCsv.
  ///
  /// In en, this message translates to:
  /// **'Import transactions CSV'**
  String get importTransactionsCsv;

  /// No description provided for @encryptedBackupHeading.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup'**
  String get encryptedBackupHeading;

  /// No description provided for @encryptedBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Backups use authenticated encryption and a passphrase.'**
  String get encryptedBackupDesc;

  /// No description provided for @createEncryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get createEncryptedBackup;

  /// No description provided for @restoreEncryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore encrypted backup'**
  String get restoreEncryptedBackup;

  /// No description provided for @exportCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvTitle;

  /// No description provided for @exportAllToFolder.
  ///
  /// In en, this message translates to:
  /// **'Export all to folder'**
  String get exportAllToFolder;

  /// No description provided for @exportAllCsvSub.
  ///
  /// In en, this message translates to:
  /// **'transactions.csv, accounts.csv, categories.csv'**
  String get exportAllCsvSub;

  /// No description provided for @transactionsCsv.
  ///
  /// In en, this message translates to:
  /// **'Transactions CSV'**
  String get transactionsCsv;

  /// No description provided for @accountsCsv.
  ///
  /// In en, this message translates to:
  /// **'Accounts CSV'**
  String get accountsCsv;

  /// No description provided for @categoriesCsv.
  ///
  /// In en, this message translates to:
  /// **'Categories CSV'**
  String get categoriesCsv;

  /// No description provided for @folderPickerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Folder selection is unavailable here. Choose a single CSV file instead.'**
  String get folderPickerUnavailable;

  /// No description provided for @exportingCsvFiles.
  ///
  /// In en, this message translates to:
  /// **'Exporting CSV files...'**
  String get exportingCsvFiles;

  /// No description provided for @exported3CsvFiles.
  ///
  /// In en, this message translates to:
  /// **'Exported 3 CSV files.'**
  String get exported3CsvFiles;

  /// No description provided for @couldNotWriteCsvFiles.
  ///
  /// In en, this message translates to:
  /// **'Could not write CSV files.'**
  String get couldNotWriteCsvFiles;

  /// No description provided for @preparingCsvExport.
  ///
  /// In en, this message translates to:
  /// **'Preparing CSV export...'**
  String get preparingCsvExport;

  /// No description provided for @csvExportSaved.
  ///
  /// In en, this message translates to:
  /// **'CSV export saved.'**
  String get csvExportSaved;

  /// No description provided for @couldNotExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Could not export CSV.'**
  String get couldNotExportCsv;

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open file: {error}'**
  String couldNotOpenFile(String error);

  /// No description provided for @importingCsv.
  ///
  /// In en, this message translates to:
  /// **'Importing CSV...'**
  String get importingCsv;

  /// No description provided for @importedCsvResult.
  ///
  /// In en, this message translates to:
  /// **'Imported {imported}; skipped {skipped} duplicates.'**
  String importedCsvResult(int imported, int skipped);

  /// No description provided for @couldNotImportCsv.
  ///
  /// In en, this message translates to:
  /// **'Could not import CSV file.'**
  String get couldNotImportCsv;

  /// No description provided for @createBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackupTitle;

  /// No description provided for @encryptingBackup.
  ///
  /// In en, this message translates to:
  /// **'Encrypting backup...'**
  String get encryptingBackup;

  /// No description provided for @encryptedBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup saved.'**
  String get encryptedBackupSaved;

  /// No description provided for @couldNotCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not create encrypted backup.'**
  String get couldNotCreateBackup;

  /// No description provided for @couldNotOpenBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open backup file: {error}'**
  String couldNotOpenBackupFile(String error);

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackupTitle;

  /// No description provided for @decryptingRestoringBackup.
  ///
  /// In en, this message translates to:
  /// **'Decrypting and restoring backup...'**
  String get decryptingRestoringBackup;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// No description provided for @couldNotRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not restore backup. Check the passphrase and file.'**
  String get couldNotRestoreBackup;

  /// No description provided for @passphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get passphrase;

  /// No description provided for @passphraseRequired.
  ///
  /// In en, this message translates to:
  /// **'Passphrase is required'**
  String get passphraseRequired;

  /// No description provided for @passphraseMinLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get passphraseMinLength;

  /// No description provided for @confirmPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Confirm passphrase'**
  String get confirmPassphrase;

  /// No description provided for @passphrasesDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passphrases do not match'**
  String get passphrasesDoNotMatch;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed: {error}'**
  String operationFailed(String error);

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current data?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Restoring permanently replaces all current app data.'**
  String get restoreConfirmBody;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @scanSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan M-Pesa SMS'**
  String get scanSmsTitle;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @smsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'SMS permission denied. Grant it in device Settings.'**
  String get smsPermissionDenied;

  /// No description provided for @couldNotReadSmsInbox.
  ///
  /// In en, this message translates to:
  /// **'Could not read SMS inbox: {detail}'**
  String couldNotReadSmsInbox(String detail);

  /// No description provided for @failedToScanSmsInbox.
  ///
  /// In en, this message translates to:
  /// **'Failed to scan SMS inbox: {error}'**
  String failedToScanSmsInbox(String error);

  /// No description provided for @alreadyRecordedRef.
  ///
  /// In en, this message translates to:
  /// **'Already recorded — {ref}'**
  String alreadyRecordedRef(String ref);

  /// No description provided for @fulizaRecordedAndLinked.
  ///
  /// In en, this message translates to:
  /// **'Fuliza recorded & linked to existing transaction.'**
  String get fulizaRecordedAndLinked;

  /// No description provided for @fulizaDrawdownRecorded.
  ///
  /// In en, this message translates to:
  /// **'Fuliza drawdown recorded.'**
  String get fulizaDrawdownRecorded;

  /// No description provided for @bulkImportSummary.
  ///
  /// In en, this message translates to:
  /// **'Imported {transactions} transactions, {fuliza} Fuliza records{skippedPart}.'**
  String bulkImportSummary(int transactions, int fuliza, String skippedPart);

  /// No description provided for @bulkImportSkippedPart.
  ///
  /// In en, this message translates to:
  /// **' ({count} duplicates skipped)'**
  String bulkImportSkippedPart(int count);

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @allMpesaAlreadyImported.
  ///
  /// In en, this message translates to:
  /// **'All M-Pesa messages already imported ({count}).'**
  String allMpesaAlreadyImported(int count);

  /// No description provided for @noMpesaInInbox.
  ///
  /// In en, this message translates to:
  /// **'No M-Pesa messages found in inbox.'**
  String get noMpesaInInbox;

  /// No description provided for @skippedAlreadyRecorded.
  ///
  /// In en, this message translates to:
  /// **'Skipped {count} already recorded or dismissed messages'**
  String skippedAlreadyRecorded(int count);

  /// No description provided for @readyToAddCount.
  ///
  /// In en, this message translates to:
  /// **'Ready to Add ({count})'**
  String readyToAddCount(int count);

  /// No description provided for @importAllCount.
  ///
  /// In en, this message translates to:
  /// **'Import all ({count})'**
  String importAllCount(int count);

  /// No description provided for @needsReviewCount.
  ///
  /// In en, this message translates to:
  /// **'Needs Review ({count})'**
  String needsReviewCount(int count);

  /// No description provided for @unrecognised.
  ///
  /// In en, this message translates to:
  /// **'Unrecognised'**
  String get unrecognised;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
