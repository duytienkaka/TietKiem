import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../data/services/account_qr_parser.dart';
import '../../domain/entities/scanned_account_qr.dart';

Future<ScannedAccountQr?> showAccountQrScanner(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<ScannedAccountQr>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const AccountQrScannerScreen(),
    ),
  );
}

class AccountQrScannerScreen extends StatefulWidget {
  const AccountQrScannerScreen({super.key});

  @override
  State<AccountQrScannerScreen> createState() => _AccountQrScannerScreenState();
}

class _AccountQrScannerScreenState extends State<AccountQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  final AccountQrParser _parser = const AccountQrParser();

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(isVi ? 'Quét QR tài khoản' : 'Scan account QR'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isVi
                        ? 'Hướng camera vào QR tài khoản ngân hàng. Ứng dụng sẽ tự điền thông tin nếu đọc được.'
                        : 'Point the camera at a bank account QR. The app will auto-fill details when possible.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) {
      return;
    }
    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .firstWhere(
          (value) => value != null && value.isNotEmpty,
          orElse: () => null,
        );
    if (rawValue == null) {
      return;
    }
    _handled = true;
    Navigator.of(context).pop(_parser.parse(rawValue));
  }
}
