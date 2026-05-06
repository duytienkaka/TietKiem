# Tiết Kiệm

Ứng dụng quản lý tài chính cá nhân viết bằng Flutter, tối ưu cho Android, offline-first và phù hợp để theo dõi thu chi hằng ngày.

## Tải xuống

- APK mới nhất: [Tải `TietKiem-latest.apk`](https://github.com/duytienkaka/TietKiem/raw/main/downloads/TietKiem-latest.apk)

Nếu GitHub chặn tải trực tiếp trên điện thoại, vào thư mục [`downloads/`](downloads/) trong repo rồi bấm vào file APK để tải thủ công.

## Phiên bản hiện tại

- `3.0.0`

## Tính năng chính

- Quản lý nhiều ví: tiền mặt, tài khoản ngân hàng, tiết kiệm
- Ghi nhận giao dịch: thu nhập, chi tiêu, chuyển tiền
- Quản lý danh mục riêng theo từng ví
- Giao dịch định kỳ
- Ngân sách theo danh mục
- Mục tiêu tiết kiệm
- Đính kèm ảnh hóa đơn từ camera hoặc thư viện
- Sao lưu và khôi phục dữ liệu cục bộ bằng JSON
- Khóa ứng dụng bằng PIN
- Hỗ trợ chia sẻ ví theo người dùng
- Đồng bộ dữ liệu với Supabase
- Phát hiện giao dịch ngân hàng từ thông báo Android

## Luồng phát hiện giao dịch ngân hàng

- App lắng nghe thông báo từ các app ngân hàng trên Android
- Nếu thông báo khớp với ví ngân hàng đã cấu hình, app có thể tự tạo giao dịch
- Nếu chưa đủ dữ liệu hoặc chưa khớp ví, app sẽ đưa vào mục `Giao dịch phát hiện`
- Nếu có hai thông báo cùng số tiền, một cộng và một trừ, app sẽ cố gộp thành `Chuyển tiền`

## Cài đặt nhanh

1. Tải file APK ở mục `Tải xuống`
2. Chép file sang điện thoại Android
3. Mở file APK để cài đặt
4. Nếu Android cảnh báo nguồn không xác định, cho phép cài đặt từ nguồn này rồi thử lại

## Lưu ý cho tính năng đọc thông báo ngân hàng

- Chỉ hỗ trợ Android
- Cần bật `Notification Access` trong phần cài đặt của thiết bị
- App chỉ dùng dữ liệu thông báo để tạo hoặc gợi ý tạo giao dịch
- Một số ngân hàng hiển thị nội dung thông báo khác nhau nên mức độ tự động hóa có thể khác nhau

## Chạy local cho developer

```bash
flutter pub get
flutter run
```

Chạy trên Chrome:

```bash
flutter run -d chrome
```

Build APK release:

```bash
flutter build apk --release
```

## Stack

- Flutter
- Material 3
- Riverpod
- go_router
- Drift (SQLite)
- SharedPreferences
- image_picker
- fl_chart
- Supabase

## Cấu trúc thư mục

```text
lib/
├── core/
├── features/
│   ├── budget/
│   ├── category/
│   ├── goal/
│   ├── recurring/
│   ├── transaction/
│   └── wallet/
├── l10n/
└── shared/
```

## Kiểm tra chất lượng

```bash
flutter analyze
flutter test
```

## Trạng thái hiện tại

- `flutter analyze`: pass
- `flutter test`: pass
- `flutter build apk --release`: pass
