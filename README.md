# Tiết Kiệm

Ứng dụng quản lý tài chính cá nhân viết bằng Flutter, tối ưu cho trải nghiệm mobile, offline-first, và phù hợp để theo dõi thu chi hằng ngày.

## Tải xuống

- APK mới nhất: [Tải `TietKiem-latest.apk`](https://github.com/duytienkaka/TietKiem/raw/main/downloads/TietKiem-latest.apk)

Nếu GitHub chặn tải trực tiếp trên mobile, bạn có thể vào thư mục [`downloads/`](downloads/) trong repo và bấm vào file APK.

## Tính năng chính

- Quản lý nhiều ví: tiền mặt, tài khoản ngân hàng.
- Ghi nhận giao dịch: thu nhập, chi tiêu, chuyển tiền.
- Đính kèm ảnh hóa đơn bằng camera hoặc thư viện.
- Xem thống kê theo tháng với biểu đồ thu chi.
- Quản lý ngân sách.
- Quản lý giao dịch định kỳ.
- Máy tính nhanh trong tab `Khác`.
- Mục tiêu tiết kiệm theo ví.
- Quản lý danh mục riêng theo từng ví.
- Sao lưu và khôi phục dữ liệu cục bộ bằng file JSON.
- Khóa ứng dụng bằng PIN.

## Cài đặt nhanh

1. Tải file APK ở mục `Tải xuống`.
2. Chép file sang điện thoại Android.
3. Cài đặt ứng dụng.
4. Nếu Android cảnh báo nguồn không xác định, cho phép cài đặt từ nguồn này rồi thử lại.

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
