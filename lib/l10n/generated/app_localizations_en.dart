// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tiet Kiem';

  @override
  String get homeTab => 'Home';

  @override
  String get transactionsTab => 'Transactions';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get walletsTab => 'Wallets';

  @override
  String get quickAdd => 'Quick add';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get trackCashflowOneTap => 'Track cashflow in just one tap';

  @override
  String get addIncome => 'Add income';

  @override
  String get addExpense => 'Add expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get myWallets => 'My wallets';

  @override
  String get swipeBalances => 'Swipe through your available balances';

  @override
  String get viewAll => 'View all';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get latestMoneyMovements =>
      'Latest money movements across your wallets';

  @override
  String get seeAll => 'See all';

  @override
  String get noWalletsYet => 'No wallets yet';

  @override
  String get createWalletStart =>
      'Create a wallet to start tracking your finances.';

  @override
  String get createWallet => 'Create wallet';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get transactionsWillAppear =>
      'Your income, expenses, and transfers will show up here.';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String walletCount(int count) {
    return '$count wallets';
  }

  @override
  String get totalBalance => 'Total balance';

  @override
  String get spendingPulse =>
      'Your spending pulse and cashflow, all in one place.';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get allWallets => 'All wallets';

  @override
  String walletsTotal(int count, String total) {
    return '$count wallets • Total $total';
  }

  @override
  String get add => 'Add';

  @override
  String get noWalletsCreated => 'No wallets created';

  @override
  String get addCashBankSavingWallet =>
      'Add a cash, bank, or saving wallet to begin.';

  @override
  String get walletDeleted => 'Wallet deleted.';

  @override
  String get createWalletTitle => 'Create wallet';

  @override
  String get editWalletTitle => 'Edit wallet';

  @override
  String get walletName => 'Wallet name';

  @override
  String get openingBalance => 'Opening balance';

  @override
  String get walletType => 'Wallet type';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get enterValidOpeningBalance => 'Enter a valid opening balance.';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeBank => 'Bank';

  @override
  String get walletTypeSaving => 'Saving';

  @override
  String get iconWallet => 'Wallet';

  @override
  String get iconBank => 'Bank';

  @override
  String get iconSavings => 'Savings';

  @override
  String get availableBalance => 'Available balance';

  @override
  String get primaryAccount => 'Primary account';

  @override
  String get securedWallet => 'Secured wallet';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get activityFeed => 'Activity feed';

  @override
  String get searchFilterManage =>
      'Search, filter and manage your money movements';

  @override
  String get searchNoteOrCategory => 'Search note or category';

  @override
  String get all => 'All';

  @override
  String get noMatchingTransactions => 'No matching transactions';

  @override
  String get tryDifferentSearch =>
      'Try a different search or add a new transaction.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String resultsCount(int count) {
    return '$count results';
  }

  @override
  String get reset => 'Reset';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get noDataToChart => 'No data to chart';

  @override
  String get addIncomeExpenseToReports =>
      'Add income or expense transactions to see reports.';

  @override
  String get insights => 'Insights';

  @override
  String get quickVisualOverview =>
      'A quick visual overview of your spending behaviour';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get net => 'Net';

  @override
  String get expenseBreakdown => 'Expense breakdown';

  @override
  String get incomeVsExpense => 'Income vs expense';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get createWalletContinue => 'Create wallet and continue';

  @override
  String get quickAddTitle => 'Quick add';

  @override
  String get quickEditTitle => 'Quick edit';

  @override
  String get coreFieldsFirst => 'Core fields first. Extra details when needed.';

  @override
  String get wallet => 'Wallet';

  @override
  String get lastUsedWalletPreselected => 'Last used wallet is preselected';

  @override
  String get targetWallet => 'Target wallet';

  @override
  String get tapOnceSwitchDestination => 'Tap once to switch destination';

  @override
  String get noTargetWallet => 'No target wallet';

  @override
  String get category => 'Category';

  @override
  String get tapIconChangeInstantly => 'Tap icon to change instantly';

  @override
  String get status => 'Status';

  @override
  String get note => 'Note';

  @override
  String get addNoteIfNeeded => 'Add note if needed';

  @override
  String get noReceiptAttached => 'No receipt attached';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get remove => 'Remove';

  @override
  String get saving => 'Saving...';

  @override
  String get moreDetails => 'More details';

  @override
  String get optionalFieldsOutWay => 'Optional fields stay out of the way';

  @override
  String get noteAdded => 'Note added';

  @override
  String get receiptAttached => 'Receipt attached';

  @override
  String get pending => 'Pending';

  @override
  String get verified => 'Verified';

  @override
  String get review => 'Review';

  @override
  String get headlineIncome => 'How much came in?';

  @override
  String get headlineExpense => 'How much went out?';

  @override
  String get headlineTransfer => 'How much do you want to move?';

  @override
  String get calculator => 'Calculator';

  @override
  String get saveIncome => 'Save income';

  @override
  String get saveExpense => 'Save expense';

  @override
  String get saveTransfer => 'Save transfer';

  @override
  String get updateIncome => 'Update income';

  @override
  String get updateExpense => 'Update expense';

  @override
  String get updateTransfer => 'Update transfer';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownWallet => 'Unknown wallet';

  @override
  String get walletNameRequired => 'Wallet name is required.';

  @override
  String get walletHasTransactionsCannotDelete =>
      'This wallet has transactions and cannot be deleted.';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than zero.';

  @override
  String get selectTargetWallet => 'Select a target wallet for transfer.';

  @override
  String get transferWalletsDifferent => 'Transfer wallets must be different.';

  @override
  String get sourceWalletNotFound => 'Source wallet not found.';

  @override
  String get targetWalletNotFound => 'Target wallet not found.';

  @override
  String get enterValidAmountGreaterThanZero =>
      'Enter a valid amount greater than zero.';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryGift => 'Gift';

  @override
  String get categoryBonus => 'Bonus';

  @override
  String get categoryTransfer => 'Transfer';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryHealth => 'Health';

  @override
  String get loading => 'Loading...';

  @override
  String get transactionNotFound => 'Transaction not found';

  @override
  String get transactionInformation => 'Transaction information';

  @override
  String get dateTime => 'Date & time';

  @override
  String get receiptImage => 'Receipt image';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String get deleteTransactionPrompt =>
      'This transaction will be removed permanently. Do you want to continue?';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusUnconfirmed => 'Unconfirmed';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get helloUser => 'Hello, Alex';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profilePlaceholder =>
      'Your profile area is ready for account details, identity, and preferences.';

  @override
  String get settingsPlaceholder =>
      'This settings area is ready for language, notifications, and app preferences.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get quickOverview => 'Quick overview';

  @override
  String get financeSnapshot => 'A fast snapshot of your account activity';

  @override
  String get totalTransactions => 'Total transactions';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameRequired => 'Please enter your name.';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get notUpdatedYet => 'Not updated yet';

  @override
  String get removeAvatar => 'Remove avatar';

  @override
  String get save => 'Save';

  @override
  String get generalSection => 'General';

  @override
  String get generalSectionSubtitle => 'Language and display preferences';

  @override
  String get appSettingsSection => 'App settings';

  @override
  String get appSettingsSubtitle => 'Control how the app behaves every day';

  @override
  String get dataSection => 'Data';

  @override
  String get dataSectionSubtitle => 'Export or reset your local finance data';

  @override
  String get securitySection => 'Security';

  @override
  String get securitySectionSubtitle => 'Extra protection for your finances';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutSectionSubtitle => 'App details and development information';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get currency => 'Currency';

  @override
  String get vndCurrency => 'Vietnamese dong (VND)';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkModeSubtitle =>
      'Reduce glare and keep the app comfortable at night';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle =>
      'Stay up to date with reminders and finance updates';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataSubtitle =>
      'Preview and copy your finance data as JSON or CSV';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get resetData => 'Reset data';

  @override
  String get resetDataSubtitle =>
      'Delete wallets and transactions on this device';

  @override
  String get resetDataPrompt =>
      'All wallets and transactions on this device will be deleted. Do you want to continue?';

  @override
  String get dataResetSuccess => 'Data reset successfully';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockSubtitle => 'Require an extra lock before opening the app';

  @override
  String get pinSetup => 'PIN setup';

  @override
  String get pinSetupSubtitle =>
      'Prepare a quick access PIN for future releases';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get appVersion => 'App version';

  @override
  String get developer => 'Developer';

  @override
  String get settingsHeroTitle => 'Control your experience';

  @override
  String get editTransactionSubtitle =>
      'Review details, adjust values, and save instantly.';

  @override
  String get confirmTransaction => 'Confirm transaction';

  @override
  String get transactionConfirmed => 'Transaction confirmed';

  @override
  String get pinConfigured => 'PIN is configured and ready to use';

  @override
  String get setPin => 'Set PIN';

  @override
  String get createPinSubtitle =>
      'Create a 4-digit PIN to protect your finance app.';

  @override
  String get changePinSubtitle => 'Update your 4-digit PIN for app lock.';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinMustBe4Digits => 'PIN must contain exactly 4 digits.';

  @override
  String get pinDoesNotMatch => 'PIN confirmation does not match.';

  @override
  String get unlockApp => 'Unlock app';

  @override
  String get enterPinContinue => 'Enter your PIN to continue to Tiet Kiem.';

  @override
  String get unlock => 'Unlock';

  @override
  String get invalidPin => 'Incorrect PIN. Try again.';

  @override
  String get smartSuggestions => 'Smart suggestions';

  @override
  String get smartSuggestionsSubtitle => 'Based on your amount and note';

  @override
  String get noSmartSuggestions => 'Add a note or amount to get suggestions.';

  @override
  String get recurring => 'Recurring';

  @override
  String get recurringHint => 'Create repeating transactions automatically';

  @override
  String get enableRecurring => 'Enable recurring';

  @override
  String get repeatEvery => 'Repeat every';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get recurringTitle => 'Recurring';

  @override
  String get recurringSubtitle => 'Automate repeating transactions';

  @override
  String get noRecurringYet => 'No recurring rules yet';

  @override
  String get createRecurringHint => 'Create one from a new transaction';

  @override
  String get nextRunLabel => 'Next run';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsSubtitle => 'Stay on track with category limits';

  @override
  String get setBudget => 'Set budget';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get monthlyBudgetHint => 'Monthly limit for this category';

  @override
  String get spentLabel => 'Spent';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get budgetExceeded => 'Exceeded budget';

  @override
  String get createBudgetHint => 'Set budgets to see progress';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get spendingInsightsTitle => 'Spending insights';

  @override
  String get topCategory => 'Top category';

  @override
  String get comparedToLastPeriod => 'Compared to last month';

  @override
  String get noPreviousPeriod => 'No previous period data';

  @override
  String get increase => 'Up';

  @override
  String get decrease => 'Down';

  @override
  String get same => 'No change';

  @override
  String get aiAssistantSection => 'AI assistant';

  @override
  String get aiAssistantSectionSubtitle =>
      'AI-powered categorization, summaries, and natural input';

  @override
  String get aiFeatures => 'Enable AI features';

  @override
  String get aiFeaturesSubtitle =>
      'Use Gemini 2.5 Flash when a Google AI Studio API key is configured. Local fallback stays available.';

  @override
  String get openAiApiKey => 'Google AI Studio API key';

  @override
  String get openAiApiKeySubtitle =>
      'Used for Gemini 2.5 Flash. Stored only on this device. Recommended for personal use or testing.';

  @override
  String get configureApiKey => 'Configure API key';

  @override
  String get apiKeyConfigured => 'API key configured';

  @override
  String get apiKeyNotConfigured => 'API key not configured';

  @override
  String get aiNaturalEntry => 'Natural input';

  @override
  String get aiNaturalEntrySubtitle =>
      'Describe the transaction in one sentence';

  @override
  String get parseTransaction => 'Parse transaction';

  @override
  String get describeTransactionHint => 'Example: lunch 45k from cash wallet';

  @override
  String get aiClassifyTransaction => 'AI classify';

  @override
  String get aiCategoryApplied => 'AI suggestion applied';

  @override
  String get aiSuggestionFailed => 'Could not extract a useful suggestion.';

  @override
  String get aiSummaryTitle => 'Monthly summary';

  @override
  String get aiSummarySubtitle =>
      'Get a concise spending recap for the selected month';

  @override
  String get generateSummary => 'Generate summary';

  @override
  String get aiPowered => 'AI powered';

  @override
  String get localFallback => 'Local fallback';

  @override
  String get authHeroTitle => 'Sign in to sync your finance data';

  @override
  String get authHeroSubtitle =>
      'Use Supabase email login first, then create a wallet or join one by invitation to start syncing across devices.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Sign up';

  @override
  String get signInSubtitle => 'Continue with your existing account';

  @override
  String get signUpSubtitle => 'Create a new account to access shared wallets';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signUpAction => 'Create account';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get signUpSuccess => 'Account created. Sign in to continue.';

  @override
  String get signedOut => 'Signed out';

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authEmailNotConfirmed => 'Confirm your email before signing in.';

  @override
  String get authUserExists => 'This email is already registered.';

  @override
  String get authNetworkError =>
      'Network error. Check your connection and try again.';

  @override
  String get authGenericError => 'Authentication failed. Try again.';
}
