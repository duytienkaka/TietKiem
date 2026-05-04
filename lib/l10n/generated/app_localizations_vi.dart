// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Tiết Kiệm';

  @override
  String get homeTab => 'Trang chủ';

  @override
  String get transactionsTab => 'Giao dịch';

  @override
  String get statisticsTab => 'Thống kê';

  @override
  String get walletsTab => 'Ví';

  @override
  String get moreTab => 'Khác';

  @override
  String get quickAdd => 'Thêm nhanh';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get quickActions => 'Thao tác nhanh';

  @override
  String get trackCashflowOneTap => 'Ghi nhận dòng tiền chỉ với một chạm';

  @override
  String get addIncome => 'Thêm thu nhập';

  @override
  String get addExpense => 'Thêm chi tiêu';

  @override
  String get transfer => 'Chuyển tiền';

  @override
  String get myWallets => 'Ví của tôi';

  @override
  String get swipeBalances => 'Vuốt để xem số dư các ví';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get recentActivity => 'Hoạt động gần đây';

  @override
  String get latestMoneyMovements => 'Biến động tiền gần nhất giữa các ví';

  @override
  String get seeAll => 'Xem hết';

  @override
  String get noWalletsYet => 'Chưa có ví nào';

  @override
  String get createWalletStart =>
      'Tạo ví để bắt đầu theo dõi tài chính của bạn.';

  @override
  String get createWallet => 'Tạo ví';

  @override
  String get noTransactionsYet => 'Chưa có giao dịch';

  @override
  String get transactionsWillAppear =>
      'Các khoản thu, chi và chuyển tiền sẽ hiển thị tại đây.';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String walletCount(int count) {
    return '$count ví';
  }

  @override
  String get totalBalance => 'Tổng số dư';

  @override
  String get spendingPulse =>
      'Theo dõi nhịp chi tiêu và dòng tiền trong cùng một nơi.';

  @override
  String get walletsTitle => 'Ví';

  @override
  String get allWallets => 'Tất cả ví';

  @override
  String walletsTotal(int count, String total) {
    return '$count ví • Tổng $total';
  }

  @override
  String get add => 'Thêm';

  @override
  String get noWalletsCreated => 'Chưa tạo ví nào';

  @override
  String get addCashBankSavingWallet =>
      'Thêm ví tiền mặt, ngân hàng hoặc tiết kiệm để bắt đầu.';

  @override
  String get walletDeleted => 'Đã xóa ví.';

  @override
  String get createWalletTitle => 'Tạo ví';

  @override
  String get editWalletTitle => 'Chỉnh sửa ví';

  @override
  String get walletName => 'Tên ví';

  @override
  String get openingBalance => 'Số dư ban đầu';

  @override
  String get walletType => 'Loại ví';

  @override
  String get transactionTypeLabel => 'Loại giao dịch';

  @override
  String get amountLabel => 'Số tiền';

  @override
  String get color => 'Màu sắc';

  @override
  String get icon => 'Biểu tượng';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get enterValidOpeningBalance => 'Vui lòng nhập số dư ban đầu hợp lệ.';

  @override
  String get walletTypeCash => 'Tiền mặt';

  @override
  String get walletTypeBank => 'Ngân hàng';

  @override
  String get walletTypeSaving => 'Tiết kiệm';

  @override
  String get iconWallet => 'Ví';

  @override
  String get iconBank => 'Ngân hàng';

  @override
  String get iconSavings => 'Tiết kiệm';

  @override
  String get availableBalance => 'Số dư khả dụng';

  @override
  String get primaryAccount => 'Tài khoản chính';

  @override
  String get securedWallet => 'Ví an toàn';

  @override
  String get transactionsTitle => 'Giao dịch';

  @override
  String get activityFeed => 'Dòng giao dịch';

  @override
  String get searchFilterManage =>
      'Tìm kiếm, lọc và quản lý các biến động tiền';

  @override
  String get searchNoteOrCategory => 'Tìm theo ghi chú hoặc danh mục';

  @override
  String get all => 'Tất cả';

  @override
  String get noMatchingTransactions => 'Không có giao dịch phù hợp';

  @override
  String get tryDifferentSearch =>
      'Hãy thử bộ lọc khác hoặc thêm giao dịch mới.';

  @override
  String get clearFilters => 'Xóa bộ lọc';

  @override
  String resultsCount(int count) {
    return '$count kết quả';
  }

  @override
  String get reset => 'Đặt lại';

  @override
  String get statisticsTitle => 'Thống kê';

  @override
  String get moreTitle => 'Khác';

  @override
  String get moreSubtitle => 'Công cụ và tự động hóa ở một nơi';

  @override
  String get savingsGoalsTitle => 'Mục tiêu tiết kiệm';

  @override
  String get savingsGoalsSubtitle => 'Theo dõi tiến độ đạt mục tiêu tài chính';

  @override
  String get addGoal => 'Thêm mục tiêu';

  @override
  String get noSavingsGoalsYet => 'Chưa có mục tiêu tiết kiệm';

  @override
  String get createSavingsGoalHint =>
      'Tạo mục tiêu và gắn với một ví để theo dõi tiến độ tự động';

  @override
  String get createSavingsGoal => 'Tạo mục tiêu tiết kiệm';

  @override
  String get editSavingsGoal => 'Chỉnh sửa mục tiêu tiết kiệm';

  @override
  String get savingsGoalEditorHint =>
      'Đặt số tiền mục tiêu, chọn ví và hạn hoàn thành phù hợp.';

  @override
  String get goalName => 'Tên mục tiêu';

  @override
  String get targetAmount => 'Số tiền mục tiêu';

  @override
  String get targetDate => 'Ngày mục tiêu';

  @override
  String get savedAmount => 'Đã tiết kiệm';

  @override
  String get deadlineLabel => 'Hạn';

  @override
  String get dailyNeeded => 'Cần mỗi ngày';

  @override
  String get goalOverdue => 'Đã quá hạn';

  @override
  String get createGoalAction => 'Tạo mục tiêu';

  @override
  String get toolsSection => 'Công cụ';

  @override
  String get toolsSectionSubtitle => 'Máy tính, lịch định kỳ và ngân sách';

  @override
  String get openCalculator => 'Mở máy tính';

  @override
  String get calculatorHint => 'Tính nhanh số tiền trước khi lưu giao dịch';

  @override
  String get automationSectionSubtitle => 'Quản lý các giao dịch lặp lại';

  @override
  String get planningSectionSubtitle =>
      'Đặt giới hạn chi theo danh mục và tháng';

  @override
  String get noDataToChart => 'Chưa có dữ liệu để vẽ biểu đồ';

  @override
  String get addIncomeExpenseToReports =>
      'Thêm giao dịch thu hoặc chi để xem báo cáo.';

  @override
  String get insights => 'Phân tích';

  @override
  String get quickVisualOverview =>
      'Tổng quan nhanh về thói quen chi tiêu của bạn';

  @override
  String get income => 'Thu nhập';

  @override
  String get expense => 'Chi tiêu';

  @override
  String get net => 'Chênh lệch';

  @override
  String get expenseBreakdown => 'Cơ cấu chi tiêu';

  @override
  String get incomeVsExpense => 'Thu nhập và chi tiêu';

  @override
  String get newTransaction => 'Giao dịch mới';

  @override
  String get editTransaction => 'Chỉnh sửa giao dịch';

  @override
  String get createWalletContinue => 'Tạo ví để tiếp tục';

  @override
  String get coreFieldsFirst =>
      'Ưu tiên các trường chính. Thông tin bổ sung chỉ hiện khi cần.';

  @override
  String get wallet => 'Ví';

  @override
  String get lastUsedWalletPreselected => 'Ví dùng gần nhất đã được chọn sẵn';

  @override
  String get targetWallet => 'Ví đích';

  @override
  String get tapOnceSwitchDestination => 'Chạm một lần để đổi ví nhận';

  @override
  String get noTargetWallet => 'Không có ví đích';

  @override
  String get category => 'Danh mục';

  @override
  String get tapIconChangeInstantly => 'Chạm biểu tượng để đổi nhanh';

  @override
  String get status => 'Trạng thái';

  @override
  String get note => 'Ghi chú';

  @override
  String get addNoteIfNeeded => 'Thêm ghi chú nếu cần';

  @override
  String get noReceiptAttached => 'Chưa đính kèm hóa đơn';

  @override
  String get camera => 'Máy ảnh';

  @override
  String get gallery => 'Thư viện';

  @override
  String get remove => 'Xóa';

  @override
  String get saving => 'Đang lưu...';

  @override
  String get moreDetails => 'Thông tin thêm';

  @override
  String get optionalFieldsOutWay =>
      'Các trường tùy chọn sẽ không làm rối thao tác chính';

  @override
  String get noteAdded => 'Đã thêm ghi chú';

  @override
  String get receiptAttached => 'Đã đính kèm hóa đơn';

  @override
  String get pending => 'Chờ xử lý';

  @override
  String get verified => 'Đã xác minh';

  @override
  String get review => 'Cần xem lại';

  @override
  String get headlineIncome => 'Bạn vừa nhận bao nhiêu?';

  @override
  String get headlineExpense => 'Bạn vừa chi bao nhiêu?';

  @override
  String get headlineTransfer => 'Bạn muốn chuyển bao nhiêu?';

  @override
  String get calculator => 'Máy tính';

  @override
  String get saveIncome => 'Lưu thu nhập';

  @override
  String get saveExpense => 'Lưu chi tiêu';

  @override
  String get saveTransfer => 'Lưu chuyển tiền';

  @override
  String get updateIncome => 'Cập nhật thu nhập';

  @override
  String get updateExpense => 'Cập nhật chi tiêu';

  @override
  String get updateTransfer => 'Cập nhật chuyển tiền';

  @override
  String get unknown => 'Không xác định';

  @override
  String get unknownWallet => 'Ví không xác định';

  @override
  String get walletNameRequired => 'Tên ví là bắt buộc.';

  @override
  String get walletHasTransactionsCannotDelete =>
      'Ví này đã có giao dịch nên không thể xóa.';

  @override
  String get amountMustBeGreaterThanZero => 'Số tiền phải lớn hơn 0.';

  @override
  String get selectTargetWallet =>
      'Hãy chọn ví đích cho giao dịch chuyển tiền.';

  @override
  String get transferWalletsDifferent => 'Ví nguồn và ví đích phải khác nhau.';

  @override
  String get sourceWalletNotFound => 'Không tìm thấy ví nguồn.';

  @override
  String get targetWalletNotFound => 'Không tìm thấy ví đích.';

  @override
  String get enterValidAmountGreaterThanZero =>
      'Vui lòng nhập số tiền hợp lệ lớn hơn 0.';

  @override
  String get categorySalary => 'Lương';

  @override
  String get categoryGift => 'Quà tặng';

  @override
  String get categoryBonus => 'Thưởng';

  @override
  String get categoryTransfer => 'Chuyển tiền';

  @override
  String get categoryFood => 'Ăn uống';

  @override
  String get categoryTransport => 'Di chuyển';

  @override
  String get categoryShopping => 'Mua sắm';

  @override
  String get categoryBills => 'Hóa đơn';

  @override
  String get categoryHealth => 'Sức khỏe';

  @override
  String get loading => 'Đang tải...';

  @override
  String get transactionNotFound => 'Không tìm thấy giao dịch';

  @override
  String get transactionInformation => 'Thông tin giao dịch';

  @override
  String get dateTime => 'Ngày giờ';

  @override
  String get receiptImage => 'Ảnh hóa đơn';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get delete => 'Xóa';

  @override
  String get cancel => 'Hủy';

  @override
  String get statusConfirmed => 'Đã xác nhận';

  @override
  String get statusUnconfirmed => 'Chưa xác nhận';

  @override
  String get errorTitle => 'Đã xảy ra lỗi';

  @override
  String get helloUser => 'Xin chào, Bạn';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get quickOverview => 'Tổng quan nhanh';

  @override
  String get totalTransactions => 'Tổng giao dịch';

  @override
  String get personalInformation => 'Thông tin cá nhân';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get fullNameRequired => 'Vui lòng nhập họ tên.';

  @override
  String get emailOptional => 'Email (tùy chọn)';

  @override
  String get notUpdatedYet => 'Chưa cập nhật';

  @override
  String get removeAvatar => 'Xóa ảnh đại diện';

  @override
  String get save => 'Lưu';

  @override
  String get generalSection => 'Chung';

  @override
  String get generalSectionSubtitle => 'Ngôn ngữ và tùy chọn hiển thị';

  @override
  String get appSettingsSection => 'Tùy chọn ứng dụng';

  @override
  String get appSettingsSubtitle =>
      'Điều khiển cách ứng dụng hoạt động hằng ngày';

  @override
  String get dataSection => 'Dữ liệu';

  @override
  String get dataSectionSubtitle =>
      'Xuất hoặc đặt lại dữ liệu tài chính cục bộ';

  @override
  String get securitySection => 'Bảo mật';

  @override
  String get securitySectionSubtitle =>
      'Tăng cường bảo vệ cho dữ liệu tài chính';

  @override
  String get aboutSection => 'Giới thiệu';

  @override
  String get aboutSectionSubtitle => 'Thông tin ứng dụng và nhóm phát triển';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get chooseLanguage => 'Chọn ngôn ngữ';

  @override
  String get currency => 'Tiền tệ';

  @override
  String get vndCurrency => 'Đồng Việt Nam (VND)';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get lightMode => 'Chế độ sáng';

  @override
  String get darkModeSubtitle => 'Giảm chói mắt và dễ dùng hơn vào ban đêm';

  @override
  String get notifications => 'Thông báo';

  @override
  String get notificationsSubtitle => 'Nhận nhắc nhở và cập nhật tài chính';

  @override
  String get notificationPermissionDenied => 'Chưa cấp quyền thông báo.';

  @override
  String get exportData => 'Xuất dữ liệu';

  @override
  String get exportDataSubtitle =>
      'Xem trước và sao chép dữ liệu dưới dạng JSON hoặc CSV';

  @override
  String get exportBackup => 'Tạo bản sao lưu';

  @override
  String get exportBackupSubtitle =>
      'Lưu toàn bộ dữ liệu tài chính offline thành file JSON';

  @override
  String get exportJson => 'Xuất JSON';

  @override
  String get exportCsv => 'Xuất CSV';

  @override
  String get restoreBackup => 'Khôi phục bản sao lưu';

  @override
  String get restoreBackupSubtitle =>
      'Nhập file sao lưu và thay thế dữ liệu hiện tại trên thiết bị';

  @override
  String backupSavedMessage(String location) {
    return 'Đã lưu bản sao lưu: $location';
  }

  @override
  String backupRestoredMessage(int walletCount, int transactionCount) {
    return 'Đã khôi phục $walletCount ví và $transactionCount giao dịch';
  }

  @override
  String get invalidBackupFile =>
      'File sao lưu không hợp lệ hoặc không thể đọc.';

  @override
  String get copiedToClipboard => 'Đã sao chép vào bộ nhớ tạm';

  @override
  String get copy => 'Sao chép';

  @override
  String get resetData => 'Đặt lại dữ liệu';

  @override
  String get resetDataSubtitle => 'Xóa ví và giao dịch trên thiết bị này';

  @override
  String get resetDataPrompt =>
      'Toàn bộ ví và giao dịch trên thiết bị này sẽ bị xóa. Bạn có muốn tiếp tục không?';

  @override
  String get dataResetSuccess => 'Đã đặt lại dữ liệu';

  @override
  String get appLock => 'Khóa ứng dụng';

  @override
  String get appLockSubtitle => 'Yêu cầu bảo vệ bổ sung khi mở ứng dụng';

  @override
  String get pinSetup => 'Thiết lập PIN';

  @override
  String get pinSetupSubtitle =>
      'Chuẩn bị mã PIN truy cập nhanh cho các bản phát hành sau';

  @override
  String get appVersion => 'Phiên bản ứng dụng';

  @override
  String get developer => 'Nhà phát triển';

  @override
  String get settingsHeroTitle => 'Tùy chỉnh trải nghiệm';

  @override
  String get editTransactionSubtitle =>
      'Xem lại thông tin, chỉnh sửa nhanh và lưu ngay.';

  @override
  String get confirmTransaction => 'Xác nhận giao dịch';

  @override
  String get transactionConfirmed => 'Đã xác nhận giao dịch';

  @override
  String get pinConfigured => 'PIN đã được thiết lập và sẵn sàng sử dụng';

  @override
  String get setPin => 'Đặt PIN';

  @override
  String get createPinSubtitle =>
      'Tạo mã PIN 4 số để bảo vệ ứng dụng tài chính.';

  @override
  String get changePinSubtitle => 'Cập nhật mã PIN 4 số cho khóa ứng dụng.';

  @override
  String get enterPin => 'Nhập PIN';

  @override
  String get confirmPin => 'Xác nhận PIN';

  @override
  String get pinMustBe4Digits => 'PIN phải gồm đúng 4 chữ số.';

  @override
  String get pinDoesNotMatch => 'PIN xác nhận không khớp.';

  @override
  String get unlockApp => 'Mở khóa ứng dụng';

  @override
  String get enterPinContinue => 'Nhập PIN để tiếp tục vào Tiết Kiệm.';

  @override
  String get unlock => 'Mở khóa';

  @override
  String get invalidPin => 'PIN không đúng. Vui lòng thử lại.';

  @override
  String get smartSuggestions => 'Gợi ý thông minh';

  @override
  String get smartSuggestionsSubtitle => 'Dựa trên số tiền và ghi chú';

  @override
  String get enableRecurring => 'Bật lặp lại';

  @override
  String get repeatEvery => 'Lặp mỗi';

  @override
  String get weekly => 'Hàng tuần';

  @override
  String get monthly => 'Hàng tháng';

  @override
  String get recurringTitle => 'Định kỳ';

  @override
  String get noRecurringYet => 'Chưa có giao dịch định kỳ';

  @override
  String get createRecurringHint => 'Tạo từ giao dịch mới';

  @override
  String get budgetsTitle => 'Ngân sách';

  @override
  String get setBudget => 'Đặt ngân sách';

  @override
  String get budgetAmount => 'Số tiền ngân sách';

  @override
  String get monthlyBudgetHint => 'Giới hạn theo tháng cho danh mục';

  @override
  String get spentLabel => 'Đã chi';

  @override
  String get remainingLabel => 'Còn lại';

  @override
  String get budgetExceeded => 'Vượt ngân sách';

  @override
  String get createBudgetHint => 'Đặt ngân sách để theo dõi tiến độ';

  @override
  String get noBudgetsYet => 'Chưa có ngân sách nào';

  @override
  String get spendingInsightsTitle => 'Phân tích chi tiêu';

  @override
  String get monthlyInsightsSubtitle =>
      'Các điểm nhấn được phân tích tự động từ giao dịch cục bộ';

  @override
  String get topCategory => 'Danh mục cao nhất';

  @override
  String get comparedToLastPeriod => 'So với tháng trước';

  @override
  String get noPreviousPeriod => 'Chưa có dữ liệu kỳ trước';

  @override
  String get increase => 'Tăng';

  @override
  String get decrease => 'Giảm';

  @override
  String get same => 'Không đổi';

  @override
  String get averageDailySpend => 'Chi tiêu trung bình mỗi ngày';

  @override
  String get biggestExpense => 'Khoản chi lớn nhất';

  @override
  String spendingDays(int count) {
    return '$count ngày có chi tiêu';
  }

  @override
  String get categoryShiftTitle => 'Cần chú ý danh mục này';

  @override
  String categoryShiftMessage(String category, String amount) {
    return '$category đã tăng $amount so với tháng trước';
  }

  @override
  String get monthEndForecastTitle => 'Dự báo cuối tháng';

  @override
  String get monthEndForecastSubtitle =>
      'Ước tính kết thúc tháng dựa trên tốc độ chi tiêu hiện tại';

  @override
  String get projectedExpense => 'Chi tiêu dự báo';

  @override
  String get projectedNet => 'Chênh lệch dự báo';

  @override
  String remainingDaysLabel(int count) {
    return 'Còn $count ngày';
  }

  @override
  String get stayOnTrack => 'Vẫn đang đúng nhịp';

  @override
  String get watchBudgetPressure => 'Có áp lực ngân sách';

  @override
  String get spendingPaceHighTitle => 'Tốc độ chi đang cao';

  @override
  String spendingPaceHighMessage(String percent) {
    return 'Bạn đang chi nhanh hơn tháng trước khoảng $percent';
  }

  @override
  String get spendingPaceStableTitle => 'Tốc độ chi đang ổn định';

  @override
  String get spendingPaceStableMessage =>
      'Nhịp chi hiện tại đang khá cân bằng cho cả tháng';

  @override
  String get categoryNameRequired => 'Vui lòng nhập tên danh mục.';

  @override
  String get categoryIconRequired => 'Vui lòng nhập icon cho danh mục.';

  @override
  String get categoryAlreadyExists => 'Danh mục này đã tồn tại trong ví.';

  @override
  String get categoryInUseCannotDelete =>
      'Danh mục này đang được sử dụng nên không thể xóa.';

  @override
  String get categoryManagement => 'Quản lý danh mục';

  @override
  String get categoryManagementSubtitle =>
      'Thêm hoặc xóa danh mục cho từng ví.';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get addCategorySubtitle =>
      'Dùng tên và emoji icon từ bàn phím của bạn.';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get categoryEmojiIcon => 'Emoji icon';

  @override
  String get categoryEmojiHint => 'Ví dụ: 🍜';

  @override
  String deleteCategoryPrompt(String name) {
    return 'Xóa danh mục \"$name\"?';
  }

  @override
  String categoryScopeWallet(String walletName) {
    return 'Danh mục cho ví: $walletName';
  }

  @override
  String get noCategoriesYet => 'Chưa có danh mục nào';

  @override
  String get addCategoryHint => 'Hãy tạo danh mục đầu tiên cho ví này.';

  @override
  String get noCategoriesForWallet =>
      'Ví này chưa có danh mục cho loại giao dịch đang chọn.';

  @override
  String get selectCategoryToContinue => 'Hãy chọn danh mục để tiếp tục.';

  @override
  String get accountWallets => 'Ví tài khoản';

  @override
  String get cashWallets => 'Ví tiền mặt';

  @override
  String get walletPortfolio => 'Danh sách ví';

  @override
  String get walletPortfolioSubtitle =>
      'Mở một ví để xem chi tiết và thao tác nhanh hơn.';

  @override
  String get walletDetails => 'Chi tiết ví';

  @override
  String get editWalletSubtitle => 'Đổi tên, số dư, màu hoặc loại ví.';

  @override
  String get deleteWalletAction => 'Xóa ví';

  @override
  String get deleteWalletActionSubtitle =>
      'Chỉ xóa khi ví không còn giao dịch liên kết.';

  @override
  String get deleteWalletPrompt =>
      'Ví sẽ bị xóa nếu không còn giao dịch liên kết. Tiếp tục?';

  @override
  String addTransactionFromWallet(String walletName) {
    return 'Thêm giao dịch mới cho ví $walletName';
  }

  @override
  String get walletRecentTransactionsSubtitle =>
      'Hoạt động gần nhất liên quan tới ví này.';

  @override
  String get accountInfo => 'Thông tin tài khoản';

  @override
  String get accountInfoReady => 'Ví này đã sẵn sàng nhận chuyển khoản qua QR.';

  @override
  String get accountInfoIncomplete =>
      'Hãy thêm thông tin tài khoản để tạo QR giao dịch.';

  @override
  String get updateAccountInfo => 'Cập nhật thông tin tài khoản';

  @override
  String get bankName => 'Tên ngân hàng';

  @override
  String get accountNumber => 'Số tài khoản';

  @override
  String get accountHolder => 'Chủ tài khoản';

  @override
  String get paymentNote => 'Nội dung chuyển khoản';

  @override
  String get transactionQr => 'QR giao dịch';

  @override
  String get notConfiguredYet => 'Chưa cấu hình';

  @override
  String get bankNotificationAccess => 'Đọc thông báo ngân hàng';

  @override
  String get bankNotificationAccessSubtitle =>
      'Phát hiện giao dịch mới từ thông báo của app ngân hàng trên Android.';

  @override
  String get bankNotificationAccessGranted => 'Đã cấp quyền';

  @override
  String get bankNotificationAccessRequired => 'Chưa cấp quyền';

  @override
  String get bankNotificationUnsupported =>
      'Tính năng này hiện chỉ hỗ trợ trên Android.';

  @override
  String get detectedTransactionTitle => 'Phát hiện giao dịch mới';

  @override
  String get detectedTransactionSubtitle =>
      'Đã tìm thấy một thông báo ngân hàng khớp với ví của bạn. Hãy xác nhận trước khi lưu.';

  @override
  String get dismissDetectedTransaction => 'Bỏ qua';

  @override
  String get confirmDetectedTransaction => 'Thêm giao dịch';
}
