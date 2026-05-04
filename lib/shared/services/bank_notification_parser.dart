import '../finance_enums.dart';
import '../models/bank_notification_event.dart';

class ParsedBankNotification {
  const ParsedBankNotification({
    required this.bankSignature,
    required this.amount,
    required this.inferredType,
  });

  final BankSignature bankSignature;
  final int amount;
  final TransactionType inferredType;
}

class BankSignature {
  const BankSignature({
    required this.canonicalName,
    required this.aliasPresets,
    required this.keywords,
    required this.packageHints,
  });

  final String canonicalName;
  final List<String> aliasPresets;
  final List<String> keywords;
  final List<String> packageHints;
}

class BankNotificationParser {
  const BankNotificationParser();

  static const List<BankSignature> knownBanks = [
    BankSignature(
      canonicalName: 'Vietcombank',
      aliasPresets: ['VCB', 'Vietcombank', 'VCBDigibank'],
      keywords: ['vietcombank', 'vcb', 'vcbdigibank'],
      packageHints: ['vietcombank', 'vcb', 'vcbdigibank'],
    ),
    BankSignature(
      canonicalName: 'Techcombank',
      aliasPresets: ['TCB', 'Techcombank', 'F@st Mobile'],
      keywords: ['techcombank', 'tcb', 'f@st mobile', 'fast mobile'],
      packageHints: ['techcombank', 'tcb', 'fastmobile'],
    ),
    BankSignature(
      canonicalName: 'MB Bank',
      aliasPresets: ['MB', 'MBBank', 'MB Bank'],
      keywords: ['mb bank', 'mbbank', 'mb'],
      packageHints: ['mbbank', 'mb.mobile', 'mbbankapp'],
    ),
    BankSignature(
      canonicalName: 'BIDV',
      aliasPresets: ['BIDV', 'BIDV SmartBanking', 'SmartBanking'],
      keywords: ['bidv', 'smartbanking'],
      packageHints: ['bidv', 'smartbanking'],
    ),
  ];

  List<String> aliasPresetsForBank(String bankName) {
    final normalized = normalize(bankName);
    if (normalized.isEmpty) {
      return const [];
    }

    final scored = knownBanks
        .map((bank) => (bank: bank, score: _scoreSignature(bank, normalized)))
        .where((item) => item.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (scored.isEmpty) {
      return const [];
    }

    final topScore = scored.first.score;
    final selected = scored
        .where((item) => item.score >= topScore - 2)
        .take(3)
        .map((item) => item.bank)
        .toList();

    final presets = <String>[];
    for (final bank in selected) {
      for (final alias in bank.aliasPresets) {
        if (!presets.contains(alias)) {
          presets.add(alias);
        }
      }
    }
    return presets;
  }

  ParsedBankNotification? parse(BankNotificationEvent event) {
    final signature = _identifyBank(event);
    if (signature == null) {
      return null;
    }

    final normalized = _normalize(event.combinedText);
    final amount = switch (signature.canonicalName) {
      'Vietcombank' => _extractForVietcombank(event.combinedText),
      'Techcombank' => _extractForTechcombank(event.combinedText),
      'MB Bank' => _extractForMb(event.combinedText),
      'BIDV' => _extractForBidv(event.combinedText),
      _ => _extractGenericAmount(event.combinedText),
    };

    if (amount == null || amount <= 0) {
      return null;
    }

    final type = _inferType(normalized);
    return ParsedBankNotification(
      bankSignature: signature,
      amount: amount,
      inferredType: type,
    );
  }

  BankSignature? _identifyBank(BankNotificationEvent event) {
    final normalizedText = _normalize(event.combinedText);
    final normalizedPackage = _normalize(event.packageName);
    for (final bank in knownBanks) {
      if (bank.packageHints.any(normalizedPackage.contains)) {
        return bank;
      }
      if (bank.keywords.map(_normalize).any(normalizedText.contains)) {
        return bank;
      }
    }
    return null;
  }

  int? _extractForVietcombank(String text) {
    return _extractByPatterns(text, const [
      r'ghi co[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'nhan[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'\+(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'so tien[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
    ]);
  }

  int? _extractForTechcombank(String text) {
    return _extractByPatterns(text, const [
      r'ghi co[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'nhan[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'\+(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'gd\s*(?:\+|-)\s*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
    ]);
  }

  int? _extractForMb(String text) {
    return _extractByPatterns(text, const [
      r'ghi co[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'gd:\s*(?:\+|-)\s*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'\+(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'nhan[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
    ]);
  }

  int? _extractForBidv(String text) {
    return _extractByPatterns(text, const [
      r'ghi co[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'nhan[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'\+(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'so tien gd[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
    ]);
  }

  int? _extractGenericAmount(String text) {
    return _extractByPatterns(text, const [
      r'ghi co[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'nhan[^0-9]*(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'\+(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'(\d[\d\., ]+)\s*(?:vnd|vnđ|đ)',
      r'(?<!\d)(\d{4,18})(?!\d)',
    ]);
  }

  int? _extractByPatterns(String text, List<String> patterns) {
    for (final pattern in patterns) {
      final regExp = RegExp(pattern, caseSensitive: false, dotAll: true);
      final match = regExp.firstMatch(text);
      final raw = match?.group(1);
      if (raw == null) {
        continue;
      }
      final value = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
      if (value != null && value > 0) {
        return value;
      }
    }
    return null;
  }

  TransactionType _inferType(String normalizedText) {
    const incomeKeywords = [
      'ghi co',
      'nhan tien',
      'nhan ck',
      'chuyen den',
      'tien vao',
      'vao tk',
      'credited',
      'received',
      '+',
    ];
    const expenseKeywords = [
      'ghi no',
      'rut tien',
      'tru tien',
      'thanh toan',
      'payment',
      'debited',
      'chuyen tien',
      '-',
    ];
    if (incomeKeywords.any(normalizedText.contains)) {
      return TransactionType.income;
    }
    if (expenseKeywords.any(normalizedText.contains)) {
      return TransactionType.expense;
    }
    return TransactionType.expense;
  }

  String normalize(String value) => _normalize(value);

  int _scoreSignature(BankSignature bank, String normalizedQuery) {
    var best = 0;
    final candidates = <String>[
      bank.canonicalName,
      ...bank.aliasPresets,
      ...bank.keywords,
    ].map(normalize).where((item) => item.isNotEmpty);

    for (final candidate in candidates) {
      final score = _scoreCandidate(candidate, normalizedQuery);
      if (score > best) {
        best = score;
      }
    }
    return best;
  }

  int _scoreCandidate(String candidate, String query) {
    if (candidate == query) {
      return 100;
    }
    if (candidate.contains(query) || query.contains(candidate)) {
      return 80;
    }

    final candidateCompact = candidate.replaceAll(' ', '');
    final queryCompact = query.replaceAll(' ', '');
    if (candidateCompact.contains(queryCompact) ||
        queryCompact.contains(candidateCompact)) {
      return 72;
    }

    final candidateTokens = _tokenize(candidate);
    final queryTokens = _tokenize(query);
    if (candidateTokens.isEmpty || queryTokens.isEmpty) {
      return 0;
    }

    final overlap = candidateTokens.intersection(queryTokens).length;
    if (overlap == 0) {
      final partialOverlap = candidateTokens
          .where(
            (token) => queryTokens.any(
              (queryToken) =>
                  token.startsWith(queryToken) || queryToken.startsWith(token),
            ),
          )
          .length;
      return partialOverlap > 0 ? 40 + (partialOverlap * 8) : 0;
    }

    return 50 + (overlap * 10);
  }

  Set<String> _tokenize(String value) {
    return value
        .split(RegExp(r'\s+'))
        .map((item) => item.trim())
        .where((item) => item.length >= 2)
        .toSet();
  }

  String _normalize(String value) {
    final lower = _stripVietnameseDiacritics(value).toLowerCase();
    return lower.replaceAll(RegExp(r'[^a-z0-9+\-]+'), ' ').trim();
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
