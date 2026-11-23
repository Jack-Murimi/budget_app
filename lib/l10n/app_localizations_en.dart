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
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get continueLabel => 'Continue';

  @override
  String get apply => 'Apply';

  @override
  String get filters => 'Filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get search => 'Search';

  @override
  String get view => 'View';

  @override
  String get record => 'Record';

  @override
  String get parse => 'Parse';

  @override
  String get skip => 'Skip';

  @override
  String get change => 'Change';

  @override
  String get history => 'History';

  @override
  String get addMoney => 'Add money';

  @override
  String get useThis => 'Use this';

  @override
  String get all => 'All';

  @override
  String get allTime => 'All time';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisWeekTitle => 'This Week';

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String get thisYear => 'This year';

  @override
  String get custom => 'Custom';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get total => 'Total';

  @override
  String get otherLabel => 'Other';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get active => 'Active';

  @override
  String get archived => 'Archived';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get settled => 'Settled';

  @override
  String get defaultLabel => 'Default';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get errorRequired => 'Required';

  @override
  String get errorInvalidNumber => 'Enter a valid number';

  @override
  String get errorPositiveAmount => 'Enter a positive amount';

  @override
  String get errorValidPositiveAmount => 'Enter a valid positive amount';

  @override
  String get errorValidAmount => 'Enter a valid amount';

  @override
  String get errorValidNumberShort => 'Enter a valid balance';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Name *';

  @override
  String get type => 'Type';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get date => 'Date';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get time => 'Time';

  @override
  String get header => 'Header';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get amountKES => 'Amount (KES)';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSwahili => 'Kiswahili';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'M-Pesa budget tracker';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemePureDark => 'Pure Dark (OLED)';

  @override
  String get settingsOledSubtitle => 'True black background in dark mode';

  @override
  String get settingsDynamicColor => 'Dynamic color';

  @override
  String get settingsDynamicColorDesc => 'Use wallpaper colors (Android 12+)';

  @override
  String get settingsBiometric => 'Biometric lock';

  @override
  String get settingsBiometricDesc => 'Fingerprint or face to open app';

  @override
  String get settingsBiometricUnavailable =>
      'Screen lock or biometrics not available on this device';

  @override
  String get settingsBiometricRequired =>
      'Authentication required to enable lock';

  @override
  String get settingsAutoLock => 'Auto-lock after';

  @override
  String get settingsAutoLockImmediate => 'Immediately';

  @override
  String get settingsAutoLock1min => 'After 1 minute';

  @override
  String get settingsAutoLock5min => 'After 5 minutes';

  @override
  String get biometricPrompt => 'Authenticate to open Budget KE';

  @override
  String get biometricLockedTitle => 'App Locked';

  @override
  String get biometricUnlock => 'Unlock';

  @override
  String get overallBudget => 'Overall Budget';

  @override
  String budgetProgressSummary(String spent, String total, String percent) {
    return 'KES $spent / KES $total ($percent%)';
  }

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See all';

  @override
  String get couldNotLoadTransactions => 'Could not load your transactions.';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get pasteOrAddHint => 'Paste an M-Pesa SMS or add manually';

  @override
  String billsOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills overdue!',
      one: '1 bill overdue!',
    );
    return '$_temp0';
  }

  @override
  String billsDueSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills due soon',
      one: '1 bill due soon',
    );
    return '$_temp0';
  }

  @override
  String get spentThisMonth => 'spent this month';

  @override
  String get expensesLabel => 'Expenses';

  @override
  String get spendingBreakdown => 'Spending Breakdown';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get noExpensesInPeriod => 'No expenses in this period';

  @override
  String spendingBreakdownSemantic(String details) {
    return 'Spending breakdown: $details';
  }

  @override
  String get pasteMpesaSmsTooltip => 'Paste M-Pesa SMS';

  @override
  String get addManuallyTooltip => 'Add Manually';

  @override
  String get clipboardEmpty => 'Clipboard is empty. Copy an M-Pesa SMS first.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get fulizaAlreadyRecorded =>
      'Already recorded — this Fuliza was saved before.';

  @override
  String get fulizaLinkedToast =>
      'Fuliza linked ✓  Transaction updated with Fuliza details.';

  @override
  String get fulizaRecordedToast =>
      'Fuliza recorded ✓  Paste the paired M-Pesa send message next.';

  @override
  String get fulizaRepayAlreadyRecorded =>
      'Already recorded — this Fuliza repayment was saved before.';

  @override
  String fulizaRepaidToast(String amount) {
    return 'Fuliza repaid: $amount  •  Recorded ✓';
  }

  @override
  String alreadyRecordedWithDate(String ref, String date) {
    return 'Already recorded — $ref was saved on $date.';
  }

  @override
  String get pasteMpesaSmsTitle => 'Paste M-Pesa SMS';

  @override
  String get pasteMpesaHint => 'Paste your M-Pesa message here...';

  @override
  String get pasteMpesaFirstError => 'Paste an M-Pesa message first.';

  @override
  String couldNotParseError(String error) {
    return 'Could not parse: $error';
  }

  @override
  String get deleteTransactionTooltip => 'Delete transaction';

  @override
  String feeBadge(String fee) {
    return '+$fee fee';
  }

  @override
  String get fulizaBadge => 'Fuliza';

  @override
  String transactionSemantics(String kind, String amount, String header,
      String categoryPart, String date) {
    return '$kind of $amount, $header$categoryPart, $date';
  }

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get searchTransactionsHint => 'Search transactions...';

  @override
  String get closeSearch => 'Close search';

  @override
  String get filterByAccount => 'Filter by Account';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get deleteTransactionTitle => 'Delete Transaction';

  @override
  String deleteItemQuestion(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String deletedItemToast(String name) {
    return 'Deleted \"$name\"';
  }

  @override
  String transactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get pickCategory => 'Pick category';

  @override
  String get pickAccount => 'Pick account';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get completeTransaction => 'Complete Transaction';

  @override
  String get updateTransaction => 'Update Transaction';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get titleRequired => 'Title *';

  @override
  String get titleHint => 'e.g. Groceries at Naivas';

  @override
  String get titleValidation => 'Give this transaction a title';

  @override
  String get paidTo => 'Paid to';

  @override
  String get receivedFrom => 'Received from';

  @override
  String get note => 'Note';

  @override
  String get paidToHint => 'Person, shop or paybill';

  @override
  String get receivedFromHint => 'Sender or source';

  @override
  String get noteHint => 'Optional note';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get suggestedFromPast => 'Suggested from past entries';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get addTransactionFee => 'Add transaction fee';

  @override
  String get transactionFeeKes => 'Transaction fee (KES)';

  @override
  String get mpesaOrBankCharge => 'M-Pesa or bank charge';

  @override
  String amountPlusFee(String total) {
    return 'Amount + fee: $total';
  }

  @override
  String get accountWalletRequired => 'Account / Wallet *';

  @override
  String get accountWallet => 'Account / Wallet';

  @override
  String get selectAccount => 'Select account';

  @override
  String get fromAccount => 'From Account';

  @override
  String get fromAccountRequired => 'From Account *';

  @override
  String get selectSourceAccount => 'Select source account';

  @override
  String get toAccount => 'To Account';

  @override
  String get toAccountRequired => 'To Account *';

  @override
  String get selectDestAccount => 'Select destination account';

  @override
  String get selectDifferentDestAccount =>
      'Select a destination account different from the source';

  @override
  String get accountsMustDiffer => 'Accounts must be different';

  @override
  String get couldNotLoadAccounts => 'Could not load accounts';

  @override
  String get noAccountsAvailable => 'No accounts available';

  @override
  String get moreOptions => 'More options';

  @override
  String get excludeFromBudget => 'Exclude from budget';

  @override
  String get excludeFromBudgetDesc => 'Does not count against spending limits';

  @override
  String get autoFilledMpesa => 'Auto-filled from M-Pesa';

  @override
  String autoFilledMpesaRef(String ref) {
    return 'Auto-filled from M-Pesa · $ref';
  }

  @override
  String fulizaUsedBanner(String amount, String fee) {
    return 'Fuliza used: $amount (fee: $fee)';
  }

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesBody =>
      'You have unsaved changes on this transaction.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get amountGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get enterValidCost => 'Enter a valid cost';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionSaved => 'Transaction saved!';

  @override
  String get alreadySavedMpesa =>
      'Already saved — this M-Pesa transaction was recorded before.';

  @override
  String get couldNotUpdateTransaction =>
      'Could not update the transaction. Try again.';

  @override
  String get couldNotSaveTransaction =>
      'Could not save the transaction. Try again.';

  @override
  String get addBorrowerInDesc => 'Add who you lent to in Description';

  @override
  String get addLenderInDesc => 'Add lender name in Description / Payee';

  @override
  String get selectWhoRepaying => 'Select who is repaying';

  @override
  String get borrowerNoOutstanding =>
      'Selected borrower no longer has an outstanding balance. Please re-select.';

  @override
  String amountExceedsOutstanding(String amount) {
    return 'Amount exceeds outstanding balance of $amount';
  }

  @override
  String get borrower => 'Borrower';

  @override
  String get borrowerRequired => 'Borrower *';

  @override
  String get noOutstandingLoans => 'No outstanding loans to repay';

  @override
  String get couldNotLoadBorrowers => 'Could not load borrowers';

  @override
  String get lender => 'Lender';

  @override
  String get lenderRepaidRequired => 'Lender being repaid *';

  @override
  String get selectLoanToRepay => 'Select loan to repay';

  @override
  String get noOpenBorrowedLoans => 'No open borrowed loans to link';

  @override
  String get couldNotLoadLenders => 'Could not load lenders';

  @override
  String get actualCreditedOptional => 'Actual amount credited (optional)';

  @override
  String get actualCreditedHint => 'e.g. 570 if 600 was borrowed';

  @override
  String get actualCreditedHelper =>
      'Deductions (shortfall) will be tracked under Bridge charges';

  @override
  String get cannotExceedBorrowed => 'Cannot exceed borrowed amount';

  @override
  String get evaluateExpressionTooltip => 'Evaluate expression';

  @override
  String get enterValidExpression => 'Enter a valid expression';

  @override
  String get evaluateExpressionFirst => 'Tap ✓ to evaluate expression first';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get showActive => 'Show active';

  @override
  String get showArchived => 'Show archived';

  @override
  String get noArchivedBudgets => 'No archived budgets';

  @override
  String get noBudgetsSetYet => 'No budgets set yet';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudgetTitle => 'Delete Budget';

  @override
  String deleteBudgetConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get budgetCreated => 'Budget created';

  @override
  String get budgetUpdated => 'Budget updated';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get budgetArchived => 'Budget archived';

  @override
  String get budgetUnarchived => 'Budget unarchived';

  @override
  String get archiveBudgetTooltip => 'Archive budget';

  @override
  String get unarchiveBudgetTooltip => 'Unarchive budget';

  @override
  String get editBudgetTooltip => 'Edit budget';

  @override
  String get deleteBudgetTooltip => 'Delete budget';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekly => 'Weekly';

  @override
  String get daily => 'Daily';

  @override
  String get yearly => 'Yearly';

  @override
  String get period => 'Period';

  @override
  String startWithDate(String date) {
    return 'Start: $date';
  }

  @override
  String endWithDate(String date) {
    return 'End: $date';
  }

  @override
  String get overallBudgetAllExpenses => 'Overall Budget (All Expenses)';

  @override
  String get useOverallBudget => 'Use Overall Budget';

  @override
  String get rolloverRemainingBudget => 'Rollover remaining budget';

  @override
  String get rolloverSubtitle => 'Carry over unused amount to next period';

  @override
  String rolloverPlusBadge(String amount) {
    return '+$amount rollover';
  }

  @override
  String rolloverIncludes(String amount) {
    return 'Includes $amount rollover from previous period';
  }

  @override
  String overBudgetBy(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String amountLeft(String amount) {
    return '$amount left';
  }

  @override
  String amountRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get noRemainingBudget => 'No remaining budget';

  @override
  String get periodEnded => 'Period ended';

  @override
  String recommendedDaily(String daily, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$daily / day for the remaining $_temp0';
  }

  @override
  String get contributingTransactions => 'Contributing Transactions';

  @override
  String get noExpensesInPeriodYet => 'No expenses in this period yet';

  @override
  String get budgetAmountRequired => 'Amount (KES) *';

  @override
  String get budgetNameRequiredError => 'Name is required';

  @override
  String get accountsTitle => 'Accounts & Wallets';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get noAccountsYet => 'No accounts yet. Tap + to add one.';

  @override
  String get errorLoadingAccounts => 'Error loading accounts';

  @override
  String get addAccount => 'Add Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get enterAccountName => 'Enter account name';

  @override
  String get openingBalance => 'Opening Balance';

  @override
  String get colorLabel => 'Color';

  @override
  String get transferBetweenAccounts => 'Transfer Between Accounts';

  @override
  String get feeKes => 'Fee (KES)';

  @override
  String get feeCannotBeNegative => 'Fee cannot be negative';

  @override
  String get needTwoAccountsToTransfer =>
      'Need at least 2 active accounts to transfer';

  @override
  String get transferRecorded => 'Transfer recorded';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String deleteAccountConfirm(String name) {
    return 'Delete \"$name\"? All linked transactions will lose their account reference.';
  }

  @override
  String accountSetAsDefault(String name) {
    return '$name set as default';
  }

  @override
  String accountArchived(String name) {
    return '$name archived';
  }

  @override
  String accountUnarchived(String name) {
    return '$name unarchived';
  }

  @override
  String get balanceLabel => 'Balance';

  @override
  String get adjustBalance => 'Adjust Balance';

  @override
  String get newBalance => 'New Balance';

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get noCategories => 'No categories';

  @override
  String get noArchivedCategories => 'No archived categories';

  @override
  String get addSubcategory => 'Add subcategory';

  @override
  String get newCategory => 'New Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get parentCategory => 'Parent Category';

  @override
  String get noneTopLevel => 'None (Top-level)';

  @override
  String get iconLabel => 'Icon';

  @override
  String get selectCategory => 'Select Category';

  @override
  String noTypeCategoriesFound(String type) {
    return 'No $type categories found';
  }

  @override
  String get debtsTitle => 'Loans & Debts';

  @override
  String get lendMoney => 'Lend money';

  @override
  String get addDebt => 'Add debt';

  @override
  String get theyOweMe => 'They owe me';

  @override
  String get iOweThem => 'I owe them';

  @override
  String get noLoansGiven => 'No loans given';

  @override
  String get noLoansGivenDesc => 'Track money you have lent to others.';

  @override
  String get noDebtsOwed => 'No debts owed';

  @override
  String get noDebtsOwedDesc => 'Track money you have borrowed from others.';

  @override
  String unableToLoadDebts(String error) {
    return 'Unable to load debts: $error';
  }

  @override
  String get noRepaymentsYet => 'No repayments yet';

  @override
  String repaymentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repayments',
      one: '1 repayment',
    );
    return '$_temp0';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get outstanding => 'Outstanding';

  @override
  String dueDateLabel(String date) {
    return 'Due $date';
  }

  @override
  String dueColonDate(String date) {
    return 'Due: $date';
  }

  @override
  String get repay => 'Repay';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get recordRepayment => 'Record repayment';

  @override
  String get editDebt => 'Edit debt';

  @override
  String get addLoanGiven => 'Add loan given';

  @override
  String get personBorrower => 'Person (borrower)';

  @override
  String get personOrLender => 'Person or lender';

  @override
  String get enterAName => 'Please enter a name';

  @override
  String get direction => 'Direction';

  @override
  String get iBorrowed => 'I borrowed';

  @override
  String get iLent => 'I lent';

  @override
  String get personal => 'Personal';

  @override
  String get mshwari => 'M-Shwari';

  @override
  String get hustlerFund => 'Hustler Fund';

  @override
  String get bridge => 'Bridge';

  @override
  String get principalKes => 'Principal (KES)';

  @override
  String get enterPositivePrincipal => 'Enter a positive principal';

  @override
  String get actualCreditedKes => 'Actual amount credited (KES)';

  @override
  String get actualCreditedBridgeExample =>
      'e.g. borrow 600 but only 570 hits your M-Pesa';

  @override
  String get totalInterestExtraKes => 'Total interest/repayment extra (KES)';

  @override
  String get enterZeroOrMore => 'Enter 0 or more';

  @override
  String get noAccountTrackOnly => 'No account (track only)';

  @override
  String get addDueDate => 'Add due date';

  @override
  String get clearDueDate => 'Clear due date';

  @override
  String unableToSaveDebt(String error) {
    return 'Unable to save debt: $error';
  }

  @override
  String repayTarget(String name) {
    return 'Repay $name';
  }

  @override
  String amountMaxOutstanding(String amount) {
    return 'Amount, max $amount';
  }

  @override
  String get amountUpToOutstanding =>
      'Enter an amount up to the outstanding balance';

  @override
  String get payFromAccount => 'Pay from account';

  @override
  String get receiveIntoAccount => 'Receive into account';

  @override
  String get alsoDeleteLinkedTxns => 'Also delete linked ledger transactions';

  @override
  String get alsoDeleteLinkedTxn => 'Also delete linked ledger transaction';

  @override
  String get loanReceivedLabel => 'Loan received';

  @override
  String get loanDisbursedLabel => 'Loan disbursed';

  @override
  String get repaymentLabel => 'Repayment';

  @override
  String get editDebtTooltip => 'Edit debt';

  @override
  String get deleteDebtTooltip => 'Delete debt';

  @override
  String get totalBorrowed => 'Total borrowed';

  @override
  String get totalLent => 'Total lent';

  @override
  String get repaid => 'Repaid';

  @override
  String interestFeesLabel(String amount) {
    return 'Interest/Fees: $amount';
  }

  @override
  String get timeline => 'Timeline';

  @override
  String get noTransactionHistory => 'No transaction history';

  @override
  String get debtUpdated => 'Debt updated';

  @override
  String get deleteDebtTitle => 'Delete debt';

  @override
  String deleteDebtConfirm(String name) {
    return 'Delete \"$name\" and all its repayment records?';
  }

  @override
  String get deleteRepaymentTitle => 'Delete repayment';

  @override
  String deleteRepaymentConfirm(String amount) {
    return 'Remove repayment of $amount and restore outstanding balance?';
  }

  @override
  String get repaymentDeleted => 'Repayment deleted';

  @override
  String get deleteRepaymentTooltip => 'Delete repayment';

  @override
  String get bridgeChargesTitle => 'Bridge Loan Charges';

  @override
  String get totalBridgeCharges => 'Total Bridge charges';

  @override
  String get upfrontDeductionsShortfall => 'Upfront deductions (shortfall)';

  @override
  String get upfrontDeductionsTooltip =>
      'Difference between borrowed principal and credited cash';

  @override
  String get repaymentInterest => 'Repayment interest';

  @override
  String get repaymentInterestTooltip => 'Extra paid back on top of principal';

  @override
  String get totalPrincipalBorrowed => 'Total principal borrowed';

  @override
  String get totalLoans => 'Total loans';

  @override
  String get loansHeader => 'Loans';

  @override
  String borrowedAmount(String amount) {
    return 'Borrowed $amount';
  }

  @override
  String upfrontDeductionRow(String shortfall, String received) {
    return 'Upfront deduction: $shortfall (received $received)';
  }

  @override
  String repaymentInterestRow(String amount) {
    return 'Repayment interest: $amount';
  }

  @override
  String outstandingRow(String amount) {
    return 'Outstanding: $amount';
  }

  @override
  String settledOnDate(String date) {
    return 'Settled: $date';
  }

  @override
  String lastPaymentOnDate(String date) {
    return 'Last payment: $date';
  }

  @override
  String get totalChargesLabel => 'total charges';

  @override
  String get noBridgeLoansInPeriod => 'No Bridge loans found in this period';

  @override
  String get noBridgeLoansRecorded => 'No Bridge loans recorded yet';

  @override
  String get bridgeEmptyHint =>
      'Record a loan received from Bridge under Income with category \"Loan Received\"';

  @override
  String get fulizaTitle => 'Fuliza M-PESA';

  @override
  String get fulizaUsageHistory => 'Fuliza Usage History';

  @override
  String get fulizaBalanceCleared => 'Fuliza balance cleared.';

  @override
  String fulizaRepaymentRecorded(String amount) {
    return 'Fuliza repayment of $amount recorded.';
  }

  @override
  String get recordFulizaRepayment => 'Record Fuliza Repayment';

  @override
  String outstandingHelper(String amount) {
    return 'Outstanding: $amount';
  }

  @override
  String get fulizaOutstanding => 'Fuliza Outstanding';

  @override
  String get noFulizaBalance => 'No Fuliza Balance';

  @override
  String dueDateOverdue(String date) {
    return 'Due $date — OVERDUE';
  }

  @override
  String get recordRepaymentButton => 'Record Repayment';

  @override
  String totalFeesPaid(String amount) {
    return 'Total fees paid: $amount';
  }

  @override
  String repaidAmount(String amount) {
    return 'Repaid $amount';
  }

  @override
  String refPrefix(String ref) {
    return 'Ref: $ref';
  }

  @override
  String accessFeeRow(String amount) {
    return 'Access fee: $amount';
  }

  @override
  String get noFulizaUsageRecorded => 'No Fuliza usage recorded';

  @override
  String get pasteFulizaHint =>
      'Paste Fuliza M-PESA SMS messages to track your Fuliza usage';

  @override
  String get goalsTitle => 'Savings goals';

  @override
  String get addGoal => 'Add goal';

  @override
  String unableToLoadGoals(String error) {
    return 'Unable to load goals: $error';
  }

  @override
  String get savingsGoalSaved => 'Savings goal saved';

  @override
  String get editSavingsGoal => 'Edit savings goal';

  @override
  String get addSavingsGoal => 'Add savings goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get enterGoalName => 'Enter a goal name';

  @override
  String get targetKes => 'Target (KES)';

  @override
  String get enterPositiveTarget => 'Enter a positive target amount';

  @override
  String get addTargetDate => 'Add target date';

  @override
  String targetDateLabel(String date) {
    return 'Target $date';
  }

  @override
  String get clearTargetDate => 'Clear target date';

  @override
  String unableToSaveGoal(String error) {
    return 'Unable to save goal: $error';
  }

  @override
  String addToGoal(String name) {
    return 'Add to $name';
  }

  @override
  String get fromAccountLower => 'From account';

  @override
  String unableToRecordContribution(String error) {
    return 'Unable to record contribution: $error';
  }

  @override
  String get contributionHistory => 'Contribution history';

  @override
  String goalAmountProgress(String current, String target) {
    return '$current of $target';
  }

  @override
  String remainingTarget(String amount, String targetPart) {
    return 'Remaining $amount$targetPart';
  }

  @override
  String addedContributionTo(String name) {
    return 'Added contribution to $name';
  }

  @override
  String get goalUpdated => 'Goal updated';

  @override
  String get deleteGoalTitle => 'Delete goal';

  @override
  String deleteGoalConfirm(String name) {
    return 'Delete \"$name\" and its contribution history?';
  }

  @override
  String goalContributionsHeader(String name) {
    return '$name · Contributions';
  }

  @override
  String unableToLoadContributions(String error) {
    return 'Unable to load contributions: $error';
  }

  @override
  String get noContributionsYet => 'No contributions recorded yet.';

  @override
  String get deleteContributionTitle => 'Delete contribution';

  @override
  String get deleteContributionConfirm =>
      'Remove this contribution from the goal total?';

  @override
  String get deleteContributionTooltip => 'Delete contribution';

  @override
  String get noSavingsGoals => 'No savings goals';

  @override
  String get noSavingsGoalsDesc =>
      'Set a target, then allocate money from an account.';

  @override
  String get recurringTitle => 'Recurring & Bills';

  @override
  String get addRecurringTooltip => 'Add Recurring Bill';

  @override
  String get monthlyCommitments => 'Monthly Commitments';

  @override
  String overdueCountBadge(int count) {
    return '$count Overdue';
  }

  @override
  String activeCountBadge(int count) {
    return '$count Active';
  }

  @override
  String get upcomingAndDue => 'Upcoming & Due';

  @override
  String get allSubscriptions => 'All Subscriptions';

  @override
  String get noUpcomingBillsDue => 'No upcoming bills due';

  @override
  String get noUpcomingBillsDueDesc =>
      'Bills due or overdue within the next 30 days appear here.';

  @override
  String get noRecurringTransactions => 'No recurring transactions';

  @override
  String get noRecurringTransactionsDesc =>
      'Set up recurring bills, salaries, rent, and subscriptions.';

  @override
  String recordedPaymentToast(String name) {
    return 'Recorded \"$name\" payment ✓';
  }

  @override
  String get skipOccurrenceTitle => 'Skip this occurrence?';

  @override
  String skipOccurrenceBody(String name) {
    return 'Skip payment for \"$name\"? Next due date will advance to the following cycle without creating a ledger transaction.';
  }

  @override
  String skippedOccurrenceToast(String name) {
    return 'Skipped \"$name\" occurrence';
  }

  @override
  String get deleteRecurringTitle => 'Delete Recurring Item?';

  @override
  String deleteRecurringBody(String name) {
    return 'Delete \"$name\"? Past recorded transactions will remain in your ledger.';
  }

  @override
  String recordPaidTitle(String name) {
    return 'Record \"$name\" as Paid?';
  }

  @override
  String get recordPaidBody =>
      'This will log a transaction in your ledger and advance the due date to the next cycle.';

  @override
  String get amountPaidKes => 'Amount Paid (KES)';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get confirmPaid => 'Confirm Paid';

  @override
  String overdueByDays(int days) {
    return 'Overdue by ${days}d';
  }

  @override
  String get dueToday => 'Due Today';

  @override
  String get dueTomorrow => 'Due Tomorrow';

  @override
  String dueInDays(int days) {
    return 'Due in ${days}d';
  }

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get editRecurring => 'Edit Recurring';

  @override
  String get newRecurringAndBill => 'New Recurring & Bill';

  @override
  String get payeeSubscriptionRequired => 'Payee / Subscription Name *';

  @override
  String get payeeSubscriptionHint =>
      'e.g., Netflix, Home Internet, Rent, Salary';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get frequency => 'Frequency';

  @override
  String get interval => 'Interval';

  @override
  String get mustBeAtLeastOne => 'Must be >= 1';

  @override
  String get intervalAtLeastOne => 'Interval must be at least 1';

  @override
  String get nextDueDate => 'Next Due Date';

  @override
  String get endDateOptional => 'End Date (Optional)';

  @override
  String get runsIndefinitely => 'Runs indefinitely';

  @override
  String get setEnd => 'Set End';

  @override
  String get defaultAccount => 'Default Account';

  @override
  String categoryWithName(String name) {
    return 'Category: $name';
  }

  @override
  String get autoRecordWhenDue => 'Auto-record when due';

  @override
  String get autoRecordWhenDueDesc =>
      'Automatically log transactions when the app opens on or after the due date';

  @override
  String get notesBillingHint => 'Account number, billing notes, etc.';

  @override
  String repeatsSummary(String freq, String date) {
    return 'Repeats $freq, starting $date.';
  }

  @override
  String get createRecurringItem => 'Create Recurring Item';

  @override
  String get subscriptionUpdated => 'Subscription updated';

  @override
  String get recurringBillSaved => 'Recurring bill saved';

  @override
  String everyNDays(int count) {
    return 'Every $count days';
  }

  @override
  String everyNWeeks(int count) {
    return 'Every $count weeks';
  }

  @override
  String everyNMonths(int count) {
    return 'Every $count months';
  }

  @override
  String everyNYears(int count) {
    return 'Every $count years';
  }

  @override
  String get insightsTitle => 'Insights';

  @override
  String unableToLoadInsights(String error) {
    return 'Unable to load insights: $error';
  }

  @override
  String get cashflowSummary => 'Cashflow summary';

  @override
  String get spent => 'Spent';

  @override
  String get net => 'Net';

  @override
  String avgDailySpend(String amount) {
    return 'Avg daily spend: $amount/day';
  }

  @override
  String upPercentFromPrevious(String percent) {
    return 'Up $percent% from previous period';
  }

  @override
  String downPercentFromPrevious(String percent) {
    return 'Down $percent% from previous period';
  }

  @override
  String get dailyCashflow => 'Daily cashflow';

  @override
  String get weeklyCashflow => 'Weekly cashflow';

  @override
  String get monthlyCashflow => 'Monthly cashflow';

  @override
  String get noCashflowInPeriod => 'No cashflow in this period';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get netWorthTrend => 'Net worth trend';

  @override
  String get moreTitle => 'More';

  @override
  String get searchFeaturesHint => 'Search features...';

  @override
  String get noMatchingFeatures => 'No matching features found';

  @override
  String get sectionMoney => 'Money';

  @override
  String get sectionAutomation => 'Automation';

  @override
  String get sectionOrganize => 'Organize';

  @override
  String get sectionApp => 'App';

  @override
  String get moreAccounts => 'Accounts';

  @override
  String get moreLoansAndDebts => 'Loans & Debts';

  @override
  String get moreBridgeCharges => 'Bridge Charges';

  @override
  String get moreBridgeChargesSub => 'Track costs from Bridge loans';

  @override
  String get moreFulizaOverdraft => 'Fuliza Overdraft';

  @override
  String get moreRecurringBills => 'Recurring & Bills';

  @override
  String get moreScanSms => 'Scan SMS Inbox';

  @override
  String get moreScanSmsSub => 'Import M-Pesa SMS from your inbox';

  @override
  String get moreCategories => 'Categories';

  @override
  String get moreSavingsGoals => 'Savings Goals';

  @override
  String get moreInsights => 'Insights & Analytics';

  @override
  String get moreSettings => 'Settings';

  @override
  String get moreExportBackup => 'Export & Backup';

  @override
  String get portabilityTitle => 'Export & backup';

  @override
  String get csvHeading => 'CSV';

  @override
  String get csvDescription =>
      'Export tables or import standard transaction CSVs.';

  @override
  String get exportCsvFiles => 'Export CSV files';

  @override
  String get importTransactionsCsv => 'Import transactions CSV';

  @override
  String get encryptedBackupHeading => 'Encrypted backup';

  @override
  String get encryptedBackupDesc =>
      'Backups use authenticated encryption and a passphrase.';

  @override
  String get createEncryptedBackup => 'Create encrypted backup';

  @override
  String get restoreEncryptedBackup => 'Restore encrypted backup';

  @override
  String get exportCsvTitle => 'Export CSV';

  @override
  String get exportAllToFolder => 'Export all to folder';

  @override
  String get exportAllCsvSub =>
      'transactions.csv, accounts.csv, categories.csv';

  @override
  String get transactionsCsv => 'Transactions CSV';

  @override
  String get accountsCsv => 'Accounts CSV';

  @override
  String get categoriesCsv => 'Categories CSV';

  @override
  String get folderPickerUnavailable =>
      'Folder selection is unavailable here. Choose a single CSV file instead.';

  @override
  String get exportingCsvFiles => 'Exporting CSV files...';

  @override
  String get exported3CsvFiles => 'Exported 3 CSV files.';

  @override
  String get couldNotWriteCsvFiles => 'Could not write CSV files.';

  @override
  String get preparingCsvExport => 'Preparing CSV export...';

  @override
  String get csvExportSaved => 'CSV export saved.';

  @override
  String get couldNotExportCsv => 'Could not export CSV.';

  @override
  String couldNotOpenFile(String error) {
    return 'Could not open file: $error';
  }

  @override
  String get importingCsv => 'Importing CSV...';

  @override
  String importedCsvResult(int imported, int skipped) {
    return 'Imported $imported; skipped $skipped duplicates.';
  }

  @override
  String get couldNotImportCsv => 'Could not import CSV file.';

  @override
  String get createBackupTitle => 'Create backup';

  @override
  String get encryptingBackup => 'Encrypting backup...';

  @override
  String get encryptedBackupSaved => 'Encrypted backup saved.';

  @override
  String get couldNotCreateBackup => 'Could not create encrypted backup.';

  @override
  String couldNotOpenBackupFile(String error) {
    return 'Could not open backup file: $error';
  }

  @override
  String get restoreBackupTitle => 'Restore backup';

  @override
  String get decryptingRestoringBackup => 'Decrypting and restoring backup...';

  @override
  String get backupRestored => 'Backup restored.';

  @override
  String get couldNotRestoreBackup =>
      'Could not restore backup. Check the passphrase and file.';

  @override
  String get passphrase => 'Passphrase';

  @override
  String get passphraseRequired => 'Passphrase is required';

  @override
  String get passphraseMinLength => 'Use at least 8 characters';

  @override
  String get confirmPassphrase => 'Confirm passphrase';

  @override
  String get passphrasesDoNotMatch => 'Passphrases do not match';

  @override
  String operationFailed(String error) {
    return 'Operation failed: $error';
  }

  @override
  String get restoreConfirmTitle => 'Replace current data?';

  @override
  String get restoreConfirmBody =>
      'Restoring permanently replaces all current app data.';

  @override
  String get restore => 'Restore';

  @override
  String get scanSmsTitle => 'Scan M-Pesa SMS';

  @override
  String get rescan => 'Rescan';

  @override
  String get smsPermissionDenied =>
      'SMS permission denied. Grant it in device Settings.';

  @override
  String couldNotReadSmsInbox(String detail) {
    return 'Could not read SMS inbox: $detail';
  }

  @override
  String failedToScanSmsInbox(String error) {
    return 'Failed to scan SMS inbox: $error';
  }

  @override
  String alreadyRecordedRef(String ref) {
    return 'Already recorded — $ref';
  }

  @override
  String get fulizaRecordedAndLinked =>
      'Fuliza recorded & linked to existing transaction.';

  @override
  String get fulizaDrawdownRecorded => 'Fuliza drawdown recorded.';

  @override
  String bulkImportSummary(int transactions, int fuliza, String skippedPart) {
    return 'Imported $transactions transactions, $fuliza Fuliza records$skippedPart.';
  }

  @override
  String bulkImportSkippedPart(int count) {
    return ' ($count duplicates skipped)';
  }

  @override
  String get openSettings => 'Open Settings';

  @override
  String allMpesaAlreadyImported(int count) {
    return 'All M-Pesa messages already imported ($count).';
  }

  @override
  String get noMpesaInInbox => 'No M-Pesa messages found in inbox.';

  @override
  String skippedAlreadyRecorded(int count) {
    return 'Skipped $count already recorded or dismissed messages';
  }

  @override
  String readyToAddCount(int count) {
    return 'Ready to Add ($count)';
  }

  @override
  String importAllCount(int count) {
    return 'Import all ($count)';
  }

  @override
  String needsReviewCount(int count) {
    return 'Needs Review ($count)';
  }

  @override
  String get unrecognised => 'Unrecognised';

  @override
  String get dismiss => 'Dismiss';
}
