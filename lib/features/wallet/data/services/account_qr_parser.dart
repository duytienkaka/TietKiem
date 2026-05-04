import '../../domain/entities/scanned_account_qr.dart';

class AccountQrParser {
  const AccountQrParser();

  static const Map<String, String> _bankBinMap = {
    '970436': 'Vietcombank',
    '970407': 'Techcombank',
    '970422': 'MB Bank',
    '970418': 'BIDV',
    '970415': 'VietinBank',
    '970432': 'VPBank',
    '970403': 'Sacombank',
    '970423': 'TPBank',
    '970405': 'Agribank',
    '970448': 'OCB',
    '970441': 'VIB',
    '970400': 'Saigonbank',
  };

  ScannedAccountQr parse(String rawValue) {
    final raw = rawValue.trim();
    final normalized = raw.toLowerCase();

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final fromUri = _fromMap({
        ...uri.queryParameters.map((key, value) => MapEntry(key.toLowerCase(), value)),
      }, rawValue: raw);
      if (fromUri.accountNumber != null || fromUri.bankName != null) {
        return fromUri;
      }
    }

    final keyValue = <String, String>{};
    for (final line in raw.split(RegExp(r'[\n\r;|]+'))) {
      final match = RegExp(r'^([^:=]{2,40})[:=]\s*(.+)$').firstMatch(line.trim());
      if (match != null) {
        keyValue[match.group(1)!.trim().toLowerCase()] = match.group(2)!.trim();
      }
    }
    if (keyValue.isNotEmpty) {
      final fromMap = _fromMap(keyValue, rawValue: raw);
      if (fromMap.accountNumber != null || fromMap.bankName != null) {
        return fromMap;
      }
    }

    if (normalized.startsWith('000201') || normalized.contains('0010a000000727')) {
      final fromVietQr = _fromEmv(raw);
      if (fromVietQr.accountNumber != null || fromVietQr.bankName != null) {
        return fromVietQr;
      }
    }

    return ScannedAccountQr(rawValue: raw);
  }

  ScannedAccountQr _fromMap(
    Map<String, String> data, {
    required String rawValue,
  }) {
    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return null;
    }

    return ScannedAccountQr(
      rawValue: rawValue,
      bankName: pick(const [
        'bankname',
        'bank_name',
        'bank',
        'bankcode',
      ]),
      accountNumber: pick(const [
        'accountnumber',
        'account_number',
        'accountno',
        'account_no',
        'acc',
        'accno',
      ]),
      accountHolder: pick(const [
        'accountholder',
        'account_holder',
        'name',
        'fullname',
      ]),
      paymentNote: pick(const [
        'addinfo',
        'content',
        'note',
        'message',
        'memo',
        'description',
      ]),
    );
  }

  ScannedAccountQr _fromEmv(String rawValue) {
    final root = _parseTlv(rawValue);
    final merchantInfo =
        root['38'] ?? root['26'] ?? root['27'] ?? root['28'] ?? root['29'];
    final merchantData = merchantInfo == null ? const <String, String>{} : _parseTlv(merchantInfo);
    final beneficiaryData = merchantData['01'] == null
        ? const <String, String>{}
        : _parseTlv(merchantData['01']!);
    final bankBin = beneficiaryData['00'] ?? merchantData['01'];
    final accountNumber =
        beneficiaryData['01'] ?? merchantData['02'] ?? merchantData['03'];
    final addInfo = root['62'] == null ? const <String, String>{} : _parseTlv(root['62']!);
    final bankName = bankBin == null ? null : _bankBinMap[bankBin];
    final merchantName = root['59'];

    return ScannedAccountQr(
      rawValue: rawValue,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: merchantName,
      paymentNote: addInfo['08'] ?? addInfo['07'],
    );
  }

  Map<String, String> _parseTlv(String rawValue) {
    final values = <String, String>{};
    var index = 0;
    while (index + 4 <= rawValue.length) {
      final id = rawValue.substring(index, index + 2);
      final lengthRaw = rawValue.substring(index + 2, index + 4);
      final length = int.tryParse(lengthRaw);
      if (length == null) {
        break;
      }
      final start = index + 4;
      final end = start + length;
      if (end > rawValue.length) {
        break;
      }
      values[id] = rawValue.substring(start, end);
      index = end;
    }
    return values;
  }
}
