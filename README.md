# Tiet Kiem

Ứng dụng quản lý tài chính cá nhân viết bằng Flutter, tối ưu cho trải nghiệm mobile kiểu fintech và chạy offline-first.

## Tính năng chính

- Quản lý nhiều ví: tiền mặt, ngân hàng, tiết kiệm.
- Ghi nhận giao dịch: thu nhập, chi tiêu, chuyển tiền.
- Đính kèm ảnh hóa đơn bằng camera hoặc thư viện.
- Xem thống kê theo tháng với biểu đồ chi tiêu và thu/chi.
- Quản lý ngân sách theo danh mục.
- Quản lý giao dịch định kỳ.
- Máy tính nhanh trong màn `Khác`.
- Hồ sơ, cài đặt, đổi ngôn ngữ, dark mode, export/reset dữ liệu.
- Khóa ứng dụng bằng PIN.

## Kiến trúc và lưu trữ

- Flutter + Material 3
- Riverpod cho state management
- go_router cho điều hướng
- Drift (SQLite) cho wallets, categories, transactions
- SharedPreferences cho app settings, PIN, budgets, recurring rules
- image_picker cho ảnh hóa đơn
- fl_chart cho biểu đồ

App hiện không dùng backend và không có tính năng AI.

## Cấu trúc thư mục

```text
lib/
├── core/
│   ├── database/
│   ├── error/
│   ├── router/
│   └── theme/
├── features/
│   ├── budget/
│   ├── category/
│   ├── recurring/
│   ├── transaction/
│   └── wallet/
├── l10n/
└── shared/
```

## Các màn hình

- `Trang chủ`: tổng số dư, ví, giao dịch gần đây, thêm nhanh.
- `Giao dịch`: tìm kiếm, lọc, xem lịch sử giao dịch.
- `Thống kê`: biểu đồ theo tháng và drill-down giao dịch.
- `Ví`: tạo/sửa/xóa ví.
- `Khác`: máy tính, định kỳ, ngân sách.
- `Hồ sơ`: avatar, tên, email, thống kê cơ bản.
- `Cài đặt`: ngôn ngữ, dark mode, thông báo, export/reset, app lock.

## Chạy dự án

```bash
flutter pub get
flutter run
```

Chạy web:

```bash
flutter run -d chrome
```

Build web:

```bash
flutter build web
```

## Kiểm tra chất lượng

```bash
flutter analyze
flutter test
```

## Ghi chú phát triển

- Toàn bộ text UI đi qua `l10n`.
- Hạn chế hardcode màu và spacing ngoài theme/widget dùng chung.
- Không thay đổi business logic khi chỉ chỉnh UI/UX.
- Các tính năng `Budget` và `Recurring` hiện được gom về tab `Khác`.

## Trạng thái hiện tại

- `flutter analyze`: pass
- `flutter test`: pass
- `flutter build web`: pass
