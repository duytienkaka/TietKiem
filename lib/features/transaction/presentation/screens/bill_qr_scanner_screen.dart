import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../data/services/bill_qr_parser.dart';
import '../../domain/entities/scanned_bill_qr.dart';

Future<ScannedBillQr?> showBillQrScanner(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<ScannedBillQr>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const BillQrScannerScreen(),
    ),
  );
}

class BillQrScannerScreen extends StatefulWidget {
  const BillQrScannerScreen({super.key});

  @override
  State<BillQrScannerScreen> createState() => _BillQrScannerScreenState();
}

class _BillQrScannerScreenState extends State<BillQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _handled = false;
  bool _torchEnabled = false;

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
        title: Text(isVi ? 'Quét mã bill' : 'Scan bill QR'),
        actions: [
          IconButton(
            onPressed: () async {
              await _controller.toggleTorch();
              if (mounted) {
                setState(() => _torchEnabled = !_torchEnabled);
              }
            },
            icon: Icon(_torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded),
          ),
        ],
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVi ? 'Hướng camera vào mã QR trên bill' : 'Point the camera at the QR on the receipt',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isVi
                            ? 'Ứng dụng sẽ thử đọc số tiền và nội dung để tạo giao dịch nháp.'
                            : 'The app will try to read amount and bill details into a draft transaction.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
    final parsed = BillQrParser.parse(rawValue);
    Navigator.of(context).pop(parsed);
  }
}
