class VietQrPayloadBuilder {
  const VietQrPayloadBuilder();

  static const Map<String, String> _bankBinMap = {
    'vietcombank': '970436',
    'vcb': '970436',
    'vcbdigibank': '970436',
    'techcombank': '970407',
    'tcb': '970407',
    'f@st mobile': '970407',
    'fast mobile': '970407',
    'mb bank': '970422',
    'mbbank': '970422',
    'mb': '970422',
    'bidv': '970418',
    'bidv smartbanking': '970418',
    'smartbanking': '970418',
    'vietinbank': '970415',
    'ctg': '970415',
    'agribank': '970405',
    'sacombank': '970403',
    'tpbank': '970423',
    'vpbank': '970432',
    'ocb': '970448',
    'vib': '970441',
    'saigonbank': '970400',
  };

  String? build({
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    String? paymentNote,
    int? amount,
  }) {
    final bankBin = _resolveBankBin(bankName);
    final cleanAccount = accountNumber.replaceAll(RegExp(r'\s+'), '');
    if (bankBin == null || cleanAccount.isEmpty || accountHolder.trim().isEmpty) {
      return null;
    }

    // VietQR/NAPAS expects merchant account info to contain:
    // 00 = A000000727
    // 01 = nested beneficiary TLV (00 acqId, 01 accountNo)
    // 02 = service code
    final beneficiary = _field('00', bankBin) + _field('01', cleanAccount);
    final merchantAccount =
        _field('00', 'A000000727') +
        _field('01', beneficiary) +
        _field('02', 'QRIBFTTA');

    final additionalData = paymentNote?.trim().isNotEmpty == true
        ? _field('08', _sanitizeAdditionalInfo(paymentNote!))
        : '';
    final accountName = _sanitizeAccountName(accountHolder);

    final payloadWithoutCrc = [
      _field('00', '01'),
      _field('01', '12'),
      _field('38', merchantAccount),
      _field('53', '704'),
      if (amount != null && amount > 0) _field('54', amount.toString()),
      _field('58', 'VN'),
      _field('59', accountName),
      _field('60', 'HO CHI MINH'),
      if (additionalData.isNotEmpty) _field('62', additionalData),
      '6304',
    ].join();

    final crc = _crc16Ccitt(payloadWithoutCrc);
    return '$payloadWithoutCrc$crc';
  }

  String? _resolveBankBin(String bankName) {
    final normalized = _normalize(bankName);
    if (normalized.isEmpty) {
      return null;
    }
    for (final entry in _bankBinMap.entries) {
      final key = _normalize(entry.key);
      if (normalized == key || normalized.contains(key) || key.contains(normalized)) {
        return entry.value;
      }
    }
    return null;
  }

  String _field(String id, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$id$length$value';
  }

  String _sanitizeAccountName(String value) {
    final normalized = _stripVietnameseDiacritics(value).toUpperCase().trim();
    return normalized
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _sanitizeAdditionalInfo(String value) {
    final normalized = _stripVietnameseDiacritics(value).toUpperCase();
    final cleaned = normalized
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.length <= 25 ? cleaned : cleaned.substring(0, 25).trim();
  }

  String _crc16Ccitt(String value) {
    var crc = 0xFFFF;
    for (final codeUnit in value.codeUnits) {
      crc ^= codeUnit << 8;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc <<= 1;
        }
        crc &= 0xFFFF;
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  String _normalize(String value) {
    final lower = _stripVietnameseDiacritics(value).toLowerCase().trim();
    return lower.replaceAll(RegExp(r'[^a-z0-9@]+'), ' ').trim();
  }

  String _stripVietnameseDiacritics(String value) {
    const replacements = <String, String>{
      'à': 'a',
      'á': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'è': 'e',
      'é': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'ì': 'i',
      'í': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ò': 'o',
      'ó': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
      'À': 'A',
      'Á': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Ạ': 'A',
      'Ă': 'A',
      'Ằ': 'A',
      'Ắ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Â': 'A',
      'Ầ': 'A',
      'Ấ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'È': 'E',
      'É': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ẹ': 'E',
      'Ê': 'E',
      'Ề': 'E',
      'Ế': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ệ': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ị': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ọ': 'O',
      'Ô': 'O',
      'Ồ': 'O',
      'Ố': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ộ': 'O',
      'Ơ': 'O',
      'Ờ': 'O',
      'Ớ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ợ': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ụ': 'U',
      'Ư': 'U',
      'Ừ': 'U',
      'Ứ': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ự': 'U',
      'Ỳ': 'Y',
      'Ý': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
      'Đ': 'D',
    };
    var result = value;
    replacements.forEach((key, replacement) {
      result = result.replaceAll(key, replacement);
    });
    return result;
  }
}
