// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tiết Kiệm';

  @override
  String get homeTab => 'Home';

  @override
  String get transactionsTab => 'Transactions';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get walletsTab => 'Wallets';

  @override
  String get moreTab => 'More';

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
  String get transactionTypeLabel => 'Transaction type';

  @override
  String get amountLabel => 'Amount';

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
  String get moreTitle => 'More';

  @override
  String get moreSubtitle => 'Tools and automation in one place';

  @override
  String get savingsGoalsTitle => 'Savings goals';

  @override
  String get savingsGoalsSubtitle =>
      'Track progress toward your next money milestone';

  @override
  String get addGoal => 'Add goal';

  @override
  String get noSavingsGoalsYet => 'No savings goals yet';

  @override
  String get createSavingsGoalHint =>
      'Create a target and tie it to a wallet to follow progress automatically';

  @override
  String get createSavingsGoal => 'Create savings goal';

  @override
  String get editSavingsGoal => 'Edit savings goal';

  @override
  String get savingsGoalEditorHint =>
      'Set a target amount, choose a wallet, and give yourself a realistic deadline.';

  @override
  String get goalName => 'Goal name';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get targetDate => 'Target date';

  @override
  String get savedAmount => 'Saved so far';

  @override
  String get deadlineLabel => 'Deadline';

  @override
  String get dailyNeeded => 'Need per day';

  @override
  String get goalOverdue => 'Past deadline';

  @override
  String get createGoalAction => 'Create goal';

  @override
  String get toolsSection => 'Tools';

  @override
  String get toolsSectionSubtitle => 'Calculator, recurring rules, and budgets';

  @override
  String get openCalculator => 'Open calculator';

  @override
  String get calculatorHint => 'Quick calculations for amounts before saving';

  @override
  String get automationSectionSubtitle => 'Manage repeating transactions';

  @override
  String get planningSectionSubtitle => 'Set limits by category and month';

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
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusUnconfirmed => 'Unconfirmed';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get helloUser => 'Hello, Alex';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get quickOverview => 'Quick overview';

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
  String get notificationPermissionDenied =>
      'Notification permission was not granted.';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataSubtitle =>
      'Preview and copy your finance data as JSON or CSV';

  @override
  String get exportBackup => 'Create backup';

  @override
  String get exportBackupSubtitle =>
      'Save a full offline JSON backup of your finance data';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get restoreBackupSubtitle =>
      'Import a backup file and replace current local data';

  @override
  String backupSavedMessage(String location) {
    return 'Backup saved: $location';
  }

  @override
  String backupRestoredMessage(int walletCount, int transactionCount) {
    return 'Restored $walletCount wallets and $transactionCount transactions';
  }

  @override
  String get invalidBackupFile => 'The backup file is invalid or unreadable.';

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
  String get enterPinContinue => 'Enter your PIN to continue to PocketLedger.';

  @override
  String get unlock => 'Unlock';

  @override
  String get invalidPin => 'Incorrect PIN. Try again.';

  @override
  String get smartSuggestions => 'Smart suggestions';

  @override
  String get smartSuggestionsSubtitle => 'Based on your amount and note';

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
  String get noRecurringYet => 'No recurring rules yet';

  @override
  String get createRecurringHint => 'Create one from a new transaction';

  @override
  String get budgetsTitle => 'Budgets';

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
  String get monthlyInsightsSubtitle =>
      'Rule-based highlights generated from your local transactions';

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
  String get averageDailySpend => 'Average daily spend';

  @override
  String get biggestExpense => 'Biggest expense';

  @override
  String spendingDays(int count) {
    return '$count spending days';
  }

  @override
  String get categoryShiftTitle => 'Watch this category';

  @override
  String categoryShiftMessage(String category, String amount) {
    return '$category increased by $amount compared to last month';
  }

  @override
  String get monthEndForecastTitle => 'Month-end forecast';

  @override
  String get monthEndForecastSubtitle =>
      'Estimate how this month may close based on your current pace';

  @override
  String get projectedExpense => 'Projected expense';

  @override
  String get projectedNet => 'Projected net';

  @override
  String remainingDaysLabel(int count) {
    return '$count days left';
  }

  @override
  String get stayOnTrack => 'Still on track';

  @override
  String get watchBudgetPressure => 'Budget pressure ahead';

  @override
  String get spendingPaceHighTitle => 'Spending pace is high';

  @override
  String spendingPaceHighMessage(String percent) {
    return 'You are spending about $percent faster than last month';
  }

  @override
  String get spendingPaceStableTitle => 'Spending pace is stable';

  @override
  String get spendingPaceStableMessage =>
      'Your current spending pace is close to a healthy monthly rhythm';

  @override
  String get categoryNameRequired => 'Category name is required.';

  @override
  String get categoryIconRequired => 'Category icon is required.';

  @override
  String get categoryAlreadyExists =>
      'This category already exists in the wallet.';

  @override
  String get categoryInUseCannotDelete =>
      'This category is in use and cannot be deleted.';

  @override
  String get categoryManagement => 'Category management';

  @override
  String get categoryManagementSubtitle =>
      'Add or remove categories for each wallet.';

  @override
  String get addCategory => 'Add category';

  @override
  String get addCategorySubtitle =>
      'Use a name and an emoji icon from your keyboard.';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryEmojiIcon => 'Emoji icon';

  @override
  String get categoryEmojiHint => 'Example: 🍜';

  @override
  String deleteCategoryPrompt(String name) {
    return 'Delete category \"$name\"?';
  }

  @override
  String categoryScopeWallet(String walletName) {
    return 'Categories for wallet: $walletName';
  }

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get addCategoryHint => 'Create your first category for this wallet.';

  @override
  String get noCategoriesForWallet =>
      'This wallet does not have categories for the selected type yet.';

  @override
  String get selectCategoryToContinue => 'Select a category to continue.';

  @override
  String get accountWallets => 'Account wallets';

  @override
  String get cashWallets => 'Cash wallets';

  @override
  String get walletPortfolio => 'Wallet portfolio';

  @override
  String get walletPortfolioSubtitle =>
      'Open a wallet to review details and manage it.';

  @override
  String get walletDetails => 'Wallet details';

  @override
  String get editWalletSubtitle =>
      'Change wallet name, balance, color, or type.';

  @override
  String get deleteWalletAction => 'Delete wallet';

  @override
  String get deleteWalletActionSubtitle =>
      'Remove this wallet when it has no linked transactions.';

  @override
  String get deleteWalletPrompt =>
      'This wallet will be removed if it has no linked transactions. Continue?';

  @override
  String addTransactionFromWallet(String walletName) {
    return 'Add a new transaction for $walletName';
  }

  @override
  String get walletRecentTransactionsSubtitle =>
      'Latest activity related to this wallet.';

  @override
  String get accountInfo => 'Account information';

  @override
  String get accountInfoReady =>
      'This wallet is ready to receive transfers by QR.';

  @override
  String get accountInfoIncomplete =>
      'Add account details to generate a transaction QR.';

  @override
  String get updateAccountInfo => 'Update account info';

  @override
  String get bankName => 'Bank name';

  @override
  String get accountNumber => 'Account number';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get paymentNote => 'Payment note';

  @override
  String get transactionQr => 'Transaction QR';

  @override
  String get notConfiguredYet => 'Not configured yet';
}
