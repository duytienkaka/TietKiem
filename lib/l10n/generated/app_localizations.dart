import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tiết Kiệm'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @transactionsTab.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTab;

  /// No description provided for @statisticsTab.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTab;

  /// No description provided for @walletsTab.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsTab;

  /// No description provided for @moreTab.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTab;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @trackCashflowOneTap.
  ///
  /// In en, this message translates to:
  /// **'Track cashflow in just one tap'**
  String get trackCashflowOneTap;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get addIncome;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @myWallets.
  ///
  /// In en, this message translates to:
  /// **'My wallets'**
  String get myWallets;

  /// No description provided for @swipeBalances.
  ///
  /// In en, this message translates to:
  /// **'Swipe through your available balances'**
  String get swipeBalances;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @latestMoneyMovements.
  ///
  /// In en, this message translates to:
  /// **'Latest money movements across your wallets'**
  String get latestMoneyMovements;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noWalletsYet.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet'**
  String get noWalletsYet;

  /// No description provided for @createWalletStart.
  ///
  /// In en, this message translates to:
  /// **'Create a wallet to start tracking your finances.'**
  String get createWalletStart;

  /// No description provided for @createWallet.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get createWallet;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @transactionsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your income, expenses, and transfers will show up here.'**
  String get transactionsWillAppear;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @walletCount.
  ///
  /// In en, this message translates to:
  /// **'{count} wallets'**
  String walletCount(int count);

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @spendingPulse.
  ///
  /// In en, this message translates to:
  /// **'Your spending pulse and cashflow, all in one place.'**
  String get spendingPulse;

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsTitle;

  /// No description provided for @allWallets.
  ///
  /// In en, this message translates to:
  /// **'All wallets'**
  String get allWallets;

  /// No description provided for @walletsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} wallets • Total {total}'**
  String walletsTotal(int count, String total);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noWalletsCreated.
  ///
  /// In en, this message translates to:
  /// **'No wallets created'**
  String get noWalletsCreated;

  /// No description provided for @addCashBankSavingWallet.
  ///
  /// In en, this message translates to:
  /// **'Add a cash, bank, or saving wallet to begin.'**
  String get addCashBankSavingWallet;

  /// No description provided for @walletDeleted.
  ///
  /// In en, this message translates to:
  /// **'Wallet deleted.'**
  String get walletDeleted;

  /// No description provided for @createWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get createWalletTitle;

  /// No description provided for @editWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit wallet'**
  String get editWalletTitle;

  /// No description provided for @walletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get walletName;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalance;

  /// No description provided for @walletType.
  ///
  /// In en, this message translates to:
  /// **'Wallet type'**
  String get walletType;

  /// No description provided for @transactionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get transactionTypeLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @enterValidOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid opening balance.'**
  String get enterValidOpeningBalance;

  /// No description provided for @walletTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get walletTypeCash;

  /// No description provided for @walletTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get walletTypeBank;

  /// No description provided for @walletTypeSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get walletTypeSaving;

  /// No description provided for @iconWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get iconWallet;

  /// No description provided for @iconBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get iconBank;

  /// No description provided for @iconSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get iconSavings;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @primaryAccount.
  ///
  /// In en, this message translates to:
  /// **'Primary account'**
  String get primaryAccount;

  /// No description provided for @securedWallet.
  ///
  /// In en, this message translates to:
  /// **'Secured wallet'**
  String get securedWallet;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @activityFeed.
  ///
  /// In en, this message translates to:
  /// **'Activity feed'**
  String get activityFeed;

  /// No description provided for @searchFilterManage.
  ///
  /// In en, this message translates to:
  /// **'Search, filter and manage your money movements'**
  String get searchFilterManage;

  /// No description provided for @searchNoteOrCategory.
  ///
  /// In en, this message translates to:
  /// **'Search note or category'**
  String get searchNoteOrCategory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get noMatchingTransactions;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or add a new transaction.'**
  String get tryDifferentSearch;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tools and automation in one place'**
  String get moreSubtitle;

  /// No description provided for @savingsGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsGoalsTitle;

  /// No description provided for @savingsGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track progress toward your next money milestone'**
  String get savingsGoalsSubtitle;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addGoal;

  /// No description provided for @noSavingsGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get noSavingsGoalsYet;

  /// No description provided for @createSavingsGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Create a target and tie it to a wallet to follow progress automatically'**
  String get createSavingsGoalHint;

  /// No description provided for @createSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Create savings goal'**
  String get createSavingsGoal;

  /// No description provided for @editSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit savings goal'**
  String get editSavingsGoal;

  /// No description provided for @savingsGoalEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Set a target amount, choose a wallet, and give yourself a realistic deadline.'**
  String get savingsGoalEditorHint;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmount;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get targetDate;

  /// No description provided for @savedAmount.
  ///
  /// In en, this message translates to:
  /// **'Saved so far'**
  String get savedAmount;

  /// No description provided for @deadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineLabel;

  /// No description provided for @dailyNeeded.
  ///
  /// In en, this message translates to:
  /// **'Need per day'**
  String get dailyNeeded;

  /// No description provided for @goalOverdue.
  ///
  /// In en, this message translates to:
  /// **'Past deadline'**
  String get goalOverdue;

  /// No description provided for @createGoalAction.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get createGoalAction;

  /// No description provided for @toolsSection.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsSection;

  /// No description provided for @toolsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculator, recurring rules, and budgets'**
  String get toolsSectionSubtitle;

  /// No description provided for @openCalculator.
  ///
  /// In en, this message translates to:
  /// **'Open calculator'**
  String get openCalculator;

  /// No description provided for @calculatorHint.
  ///
  /// In en, this message translates to:
  /// **'Quick calculations for amounts before saving'**
  String get calculatorHint;

  /// No description provided for @automationSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage repeating transactions'**
  String get automationSectionSubtitle;

  /// No description provided for @planningSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set limits by category and month'**
  String get planningSectionSubtitle;

  /// No description provided for @noDataToChart.
  ///
  /// In en, this message translates to:
  /// **'No data to chart'**
  String get noDataToChart;

  /// No description provided for @addIncomeExpenseToReports.
  ///
  /// In en, this message translates to:
  /// **'Add income or expense transactions to see reports.'**
  String get addIncomeExpenseToReports;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @quickVisualOverview.
  ///
  /// In en, this message translates to:
  /// **'A quick visual overview of your spending behaviour'**
  String get quickVisualOverview;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense breakdown'**
  String get expenseBreakdown;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs expense'**
  String get incomeVsExpense;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get newTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @createWalletContinue.
  ///
  /// In en, this message translates to:
  /// **'Create wallet and continue'**
  String get createWalletContinue;

  /// No description provided for @coreFieldsFirst.
  ///
  /// In en, this message translates to:
  /// **'Core fields first. Extra details when needed.'**
  String get coreFieldsFirst;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @lastUsedWalletPreselected.
  ///
  /// In en, this message translates to:
  /// **'Last used wallet is preselected'**
  String get lastUsedWalletPreselected;

  /// No description provided for @targetWallet.
  ///
  /// In en, this message translates to:
  /// **'Target wallet'**
  String get targetWallet;

  /// No description provided for @tapOnceSwitchDestination.
  ///
  /// In en, this message translates to:
  /// **'Tap once to switch destination'**
  String get tapOnceSwitchDestination;

  /// No description provided for @noTargetWallet.
  ///
  /// In en, this message translates to:
  /// **'No target wallet'**
  String get noTargetWallet;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @tapIconChangeInstantly.
  ///
  /// In en, this message translates to:
  /// **'Tap icon to change instantly'**
  String get tapIconChangeInstantly;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @addNoteIfNeeded.
  ///
  /// In en, this message translates to:
  /// **'Add note if needed'**
  String get addNoteIfNeeded;

  /// No description provided for @noReceiptAttached.
  ///
  /// In en, this message translates to:
  /// **'No receipt attached'**
  String get noReceiptAttached;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetails;

  /// No description provided for @optionalFieldsOutWay.
  ///
  /// In en, this message translates to:
  /// **'Optional fields stay out of the way'**
  String get optionalFieldsOutWay;

  /// No description provided for @noteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get noteAdded;

  /// No description provided for @receiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Receipt attached'**
  String get receiptAttached;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @headlineIncome.
  ///
  /// In en, this message translates to:
  /// **'How much came in?'**
  String get headlineIncome;

  /// No description provided for @headlineExpense.
  ///
  /// In en, this message translates to:
  /// **'How much went out?'**
  String get headlineExpense;

  /// No description provided for @headlineTransfer.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to move?'**
  String get headlineTransfer;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save income'**
  String get saveIncome;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpense;

  /// No description provided for @saveTransfer.
  ///
  /// In en, this message translates to:
  /// **'Save transfer'**
  String get saveTransfer;

  /// No description provided for @updateIncome.
  ///
  /// In en, this message translates to:
  /// **'Update income'**
  String get updateIncome;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update expense'**
  String get updateExpense;

  /// No description provided for @updateTransfer.
  ///
  /// In en, this message translates to:
  /// **'Update transfer'**
  String get updateTransfer;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownWallet.
  ///
  /// In en, this message translates to:
  /// **'Unknown wallet'**
  String get unknownWallet;

  /// No description provided for @walletNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Wallet name is required.'**
  String get walletNameRequired;

  /// No description provided for @walletHasTransactionsCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'This wallet has transactions and cannot be deleted.'**
  String get walletHasTransactionsCannotDelete;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero.'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @selectTargetWallet.
  ///
  /// In en, this message translates to:
  /// **'Select a target wallet for transfer.'**
  String get selectTargetWallet;

  /// No description provided for @transferWalletsDifferent.
  ///
  /// In en, this message translates to:
  /// **'Transfer wallets must be different.'**
  String get transferWalletsDifferent;

  /// No description provided for @sourceWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Source wallet not found.'**
  String get sourceWalletNotFound;

  /// No description provided for @targetWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Target wallet not found.'**
  String get targetWalletNotFound;

  /// No description provided for @enterValidAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero.'**
  String get enterValidAmountGreaterThanZero;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get categoryGift;

  /// No description provided for @categoryBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get categoryBonus;

  /// No description provided for @categoryTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get categoryTransfer;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @transactionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Transaction not found'**
  String get transactionNotFound;

  /// No description provided for @transactionInformation.
  ///
  /// In en, this message translates to:
  /// **'Transaction information'**
  String get transactionInformation;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateTime;

  /// No description provided for @receiptImage.
  ///
  /// In en, this message translates to:
  /// **'Receipt image'**
  String get receiptImage;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed'**
  String get statusUnconfirmed;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, Alex'**
  String get helloUser;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @quickOverview.
  ///
  /// In en, this message translates to:
  /// **'Quick overview'**
  String get quickOverview;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total transactions'**
  String get totalTransactions;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get fullNameRequired;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @notUpdatedYet.
  ///
  /// In en, this message translates to:
  /// **'Not updated yet'**
  String get notUpdatedYet;

  /// No description provided for @removeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Remove avatar'**
  String get removeAvatar;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @generalSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language and display preferences'**
  String get generalSectionSubtitle;

  /// No description provided for @appSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettingsSection;

  /// No description provided for @appSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control how the app behaves every day'**
  String get appSettingsSubtitle;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @dataSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export or reset your local finance data'**
  String get dataSectionSubtitle;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @securitySectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra protection for your finances'**
  String get securitySectionSubtitle;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @aboutSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App details and development information'**
  String get aboutSectionSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @vndCurrency.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese dong (VND)'**
  String get vndCurrency;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce glare and keep the app comfortable at night'**
  String get darkModeSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay up to date with reminders and finance updates'**
  String get notificationsSubtitle;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted.'**
  String get notificationPermissionDenied;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview and copy your finance data as JSON or CSV'**
  String get exportDataSubtitle;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a full offline JSON backup of your finance data'**
  String get exportBackupSubtitle;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a backup file and replace current local data'**
  String get restoreBackupSubtitle;

  /// No description provided for @backupSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {location}'**
  String backupSavedMessage(String location);

  /// No description provided for @backupRestoredMessage.
  ///
  /// In en, this message translates to:
  /// **'Restored {walletCount} wallets and {transactionCount} transactions'**
  String backupRestoredMessage(int walletCount, int transactionCount);

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'The backup file is invalid or unreadable.'**
  String get invalidBackupFile;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset data'**
  String get resetData;

  /// No description provided for @resetDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete wallets and transactions on this device'**
  String get resetDataSubtitle;

  /// No description provided for @resetDataPrompt.
  ///
  /// In en, this message translates to:
  /// **'All wallets and transactions on this device will be deleted. Do you want to continue?'**
  String get resetDataPrompt;

  /// No description provided for @dataResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data reset successfully'**
  String get dataResetSuccess;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require an extra lock before opening the app'**
  String get appLockSubtitle;

  /// No description provided for @pinSetup.
  ///
  /// In en, this message translates to:
  /// **'PIN setup'**
  String get pinSetup;

  /// No description provided for @pinSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare a quick access PIN for future releases'**
  String get pinSetupSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @settingsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Control your experience'**
  String get settingsHeroTitle;

  /// No description provided for @editTransactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review details, adjust values, and save instantly.'**
  String get editTransactionSubtitle;

  /// No description provided for @confirmTransaction.
  ///
  /// In en, this message translates to:
  /// **'Confirm transaction'**
  String get confirmTransaction;

  /// No description provided for @transactionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Transaction confirmed'**
  String get transactionConfirmed;

  /// No description provided for @pinConfigured.
  ///
  /// In en, this message translates to:
  /// **'PIN is configured and ready to use'**
  String get pinConfigured;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// No description provided for @createPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN to protect your finance app.'**
  String get createPinSubtitle;

  /// No description provided for @changePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your 4-digit PIN for app lock.'**
  String get changePinSubtitle;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @pinMustBe4Digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain exactly 4 digits.'**
  String get pinMustBe4Digits;

  /// No description provided for @pinDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PIN confirmation does not match.'**
  String get pinDoesNotMatch;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock app'**
  String get unlockApp;

  /// No description provided for @enterPinContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue to PocketLedger.'**
  String get enterPinContinue;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @invalidPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get invalidPin;

  /// No description provided for @smartSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Smart suggestions'**
  String get smartSuggestions;

  /// No description provided for @smartSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your amount and note'**
  String get smartSuggestionsSubtitle;

  /// No description provided for @enableRecurring.
  ///
  /// In en, this message translates to:
  /// **'Enable recurring'**
  String get enableRecurring;

  /// No description provided for @repeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get repeatEvery;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringTitle;

  /// No description provided for @noRecurringYet.
  ///
  /// In en, this message translates to:
  /// **'No recurring rules yet'**
  String get noRecurringYet;

  /// No description provided for @createRecurringHint.
  ///
  /// In en, this message translates to:
  /// **'Create one from a new transaction'**
  String get createRecurringHint;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get setBudget;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// No description provided for @monthlyBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit for this category'**
  String get monthlyBudgetHint;

  /// No description provided for @spentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingLabel;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded budget'**
  String get budgetExceeded;

  /// No description provided for @createBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Set budgets to see progress'**
  String get createBudgetHint;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// No description provided for @spendingInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending insights'**
  String get spendingInsightsTitle;

  /// No description provided for @monthlyInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rule-based highlights generated from your local transactions'**
  String get monthlyInsightsSubtitle;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get topCategory;

  /// No description provided for @comparedToLastPeriod.
  ///
  /// In en, this message translates to:
  /// **'Compared to last month'**
  String get comparedToLastPeriod;

  /// No description provided for @noPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'No previous period data'**
  String get noPreviousPeriod;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get decrease;

  /// No description provided for @same.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get same;

  /// No description provided for @averageDailySpend.
  ///
  /// In en, this message translates to:
  /// **'Average daily spend'**
  String get averageDailySpend;

  /// No description provided for @biggestExpense.
  ///
  /// In en, this message translates to:
  /// **'Biggest expense'**
  String get biggestExpense;

  /// No description provided for @spendingDays.
  ///
  /// In en, this message translates to:
  /// **'{count} spending days'**
  String spendingDays(int count);

  /// No description provided for @categoryShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch this category'**
  String get categoryShiftTitle;

  /// No description provided for @categoryShiftMessage.
  ///
  /// In en, this message translates to:
  /// **'{category} increased by {amount} compared to last month'**
  String categoryShiftMessage(String category, String amount);

  /// No description provided for @monthEndForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Month-end forecast'**
  String get monthEndForecastTitle;

  /// No description provided for @monthEndForecastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate how this month may close based on your current pace'**
  String get monthEndForecastSubtitle;

  /// No description provided for @projectedExpense.
  ///
  /// In en, this message translates to:
  /// **'Projected expense'**
  String get projectedExpense;

  /// No description provided for @projectedNet.
  ///
  /// In en, this message translates to:
  /// **'Projected net'**
  String get projectedNet;

  /// No description provided for @remainingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String remainingDaysLabel(int count);

  /// No description provided for @stayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Still on track'**
  String get stayOnTrack;

  /// No description provided for @watchBudgetPressure.
  ///
  /// In en, this message translates to:
  /// **'Budget pressure ahead'**
  String get watchBudgetPressure;

  /// No description provided for @spendingPaceHighTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending pace is high'**
  String get spendingPaceHighTitle;

  /// No description provided for @spendingPaceHighMessage.
  ///
  /// In en, this message translates to:
  /// **'You are spending about {percent} faster than last month'**
  String spendingPaceHighMessage(String percent);

  /// No description provided for @spendingPaceStableTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending pace is stable'**
  String get spendingPaceStableTitle;

  /// No description provided for @spendingPaceStableMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current spending pace is close to a healthy monthly rhythm'**
  String get spendingPaceStableMessage;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required.'**
  String get categoryNameRequired;

  /// No description provided for @categoryIconRequired.
  ///
  /// In en, this message translates to:
  /// **'Category icon is required.'**
  String get categoryIconRequired;

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This category already exists in the wallet.'**
  String get categoryAlreadyExists;

  /// No description provided for @categoryInUseCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'This category is in use and cannot be deleted.'**
  String get categoryInUseCannotDelete;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category management'**
  String get categoryManagement;

  /// No description provided for @categoryManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add or remove categories for each wallet.'**
  String get categoryManagementSubtitle;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @addCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use a name and an emoji icon from your keyboard.'**
  String get addCategorySubtitle;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryEmojiIcon.
  ///
  /// In en, this message translates to:
  /// **'Emoji icon'**
  String get categoryEmojiIcon;

  /// No description provided for @categoryEmojiHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 🍜'**
  String get categoryEmojiHint;

  /// No description provided for @deleteCategoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Delete category \"{name}\"?'**
  String deleteCategoryPrompt(String name);

  /// No description provided for @categoryScopeWallet.
  ///
  /// In en, this message translates to:
  /// **'Categories for wallet: {walletName}'**
  String categoryScopeWallet(String walletName);

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @addCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first category for this wallet.'**
  String get addCategoryHint;

  /// No description provided for @noCategoriesForWallet.
  ///
  /// In en, this message translates to:
  /// **'This wallet does not have categories for the selected type yet.'**
  String get noCategoriesForWallet;

  /// No description provided for @selectCategoryToContinue.
  ///
  /// In en, this message translates to:
  /// **'Select a category to continue.'**
  String get selectCategoryToContinue;

  /// No description provided for @accountWallets.
  ///
  /// In en, this message translates to:
  /// **'Account wallets'**
  String get accountWallets;

  /// No description provided for @cashWallets.
  ///
  /// In en, this message translates to:
  /// **'Cash wallets'**
  String get cashWallets;

  /// No description provided for @walletPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Wallet portfolio'**
  String get walletPortfolio;

  /// No description provided for @walletPortfolioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a wallet to review details and manage it.'**
  String get walletPortfolioSubtitle;

  /// No description provided for @walletDetails.
  ///
  /// In en, this message translates to:
  /// **'Wallet details'**
  String get walletDetails;

  /// No description provided for @editWalletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change wallet name, balance, color, or type.'**
  String get editWalletSubtitle;

  /// No description provided for @deleteWalletAction.
  ///
  /// In en, this message translates to:
  /// **'Delete wallet'**
  String get deleteWalletAction;

  /// No description provided for @deleteWalletActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this wallet when it has no linked transactions.'**
  String get deleteWalletActionSubtitle;

  /// No description provided for @deleteWalletPrompt.
  ///
  /// In en, this message translates to:
  /// **'This wallet will be removed if it has no linked transactions. Continue?'**
  String get deleteWalletPrompt;

  /// No description provided for @addTransactionFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Add a new transaction for {walletName}'**
  String addTransactionFromWallet(String walletName);

  /// No description provided for @walletRecentTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest activity related to this wallet.'**
  String get walletRecentTransactionsSubtitle;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get accountInfo;

  /// No description provided for @accountInfoReady.
  ///
  /// In en, this message translates to:
  /// **'This wallet is ready to receive transfers by QR.'**
  String get accountInfoReady;

  /// No description provided for @accountInfoIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Add account details to generate a transaction QR.'**
  String get accountInfoIncomplete;

  /// No description provided for @updateAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Update account info'**
  String get updateAccountInfo;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank name'**
  String get bankName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @accountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get accountHolder;

  /// No description provided for @paymentNote.
  ///
  /// In en, this message translates to:
  /// **'Payment note'**
  String get paymentNote;

  /// No description provided for @transactionQr.
  ///
  /// In en, this message translates to:
  /// **'Transaction QR'**
  String get transactionQr;

  /// No description provided for @notConfiguredYet.
  ///
  /// In en, this message translates to:
  /// **'Not configured yet'**
  String get notConfiguredYet;

  /// No description provided for @bankNotificationAccess.
  ///
  /// In en, this message translates to:
  /// **'Read bank notifications'**
  String get bankNotificationAccess;

  /// No description provided for @bankNotificationAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detect new transactions from Android banking app notifications.'**
  String get bankNotificationAccessSubtitle;

  /// No description provided for @bankNotificationAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Access granted'**
  String get bankNotificationAccessGranted;

  /// No description provided for @bankNotificationAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get bankNotificationAccessRequired;

  /// No description provided for @bankNotificationUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This feature is currently available on Android only.'**
  String get bankNotificationUnsupported;

  /// No description provided for @detectedTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'New transaction detected'**
  String get detectedTransactionTitle;

  /// No description provided for @detectedTransactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A banking notification matched one of your wallets. Please confirm before saving it.'**
  String get detectedTransactionSubtitle;

  /// No description provided for @dismissDetectedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissDetectedTransaction;

  /// No description provided for @confirmDetectedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get confirmDetectedTransaction;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
