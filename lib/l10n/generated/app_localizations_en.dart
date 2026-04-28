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
}
