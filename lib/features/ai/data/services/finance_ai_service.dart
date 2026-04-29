import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../shared/finance_enums.dart';
import '../../../category/domain/entities/category.dart';
import '../../../transaction/domain/entities/finance_transaction.dart';
import '../../../wallet/domain/entities/wallet.dart';
import '../../domain/entities/ai_transaction_draft.dart';
import '../../domain/entities/monthly_spending_summary.dart';

class FinanceAiService {
  FinanceAiService({
    required this.enabled,
    required this.apiKey,
    http.Client? client,
    this.model = 'gemini-2.5-flash',
  }) : _client = client ?? http.Client();

  final bool enabled;
  final String? apiKey;
  final String model;
  final http.Client _client;

  bool get _canUseCloudAi => enabled && (apiKey?.trim().isNotEmpty ?? false);

  Future<AiTransactionDraft> classifyTransaction({
    required String note,
    required int amount,
    required TransactionType fallbackType,
    required List<Category> categories,
    required List<Wallet> wallets,
    required String languageCode,
  }) async {
    final local = _localParse(
      input: note,
      categories: categories,
      wallets: wallets,
      fallbackType: fallbackType,
      fallbackAmount: amount,
    );
    if (!_canUseCloudAi || note.trim().isEmpty) {
      return local;
    }

    try {
      final prompt = '''
You classify finance transactions for a mobile app.
Return only valid JSON.

Language: $languageCode
Fallback type: ${fallbackType.name}
Known wallets: ${jsonEncode(_walletDescriptors(wallets))}
Known categories: ${jsonEncode(_categoryDescriptors(categories))}

Transaction note: ${note.trim()}
Amount: $amount

Choose the most likely transaction type and category.
If unsure, keep the fallback type and leave unknown ids as null.
''';

      final payload = await _requestJson(
        schemaName: 'finance_transaction_classification',
        schema: {
          'type': 'object',
          'additionalProperties': false,
          'properties': {
            'type': {
              'type': ['string', 'null'],
              'enum': ['income', 'expense', 'transfer', null],
            },
            'categoryId': {
              'type': ['string', 'null'],
              'enum': [...categories.map((item) => item.id), null],
            },
            'walletId': {
              'type': ['string', 'null'],
              'enum': [...wallets.map((item) => item.id), null],
            },
            'targetWalletId': {
              'type': ['string', 'null'],
              'enum': [...wallets.map((item) => item.id), null],
            },
            'amount': {'type': ['integer', 'null']},
            'note': {'type': ['string', 'null']},
            'confidence': {'type': 'number'},
            'reason': {'type': 'string'},
          },
          'required': [
            'type',
            'categoryId',
            'walletId',
            'targetWalletId',
            'amount',
            'note',
            'confidence',
            'reason',
          ],
        },
        prompt: prompt,
      );

      return _draftFromMap(
        payload,
        fallback: local,
        usedCloudAi: true,
      );
    } catch (_) {
      return local;
    }
  }

  Future<AiTransactionDraft> parseNaturalLanguage({
    required String input,
    required List<Category> categories,
    required List<Wallet> wallets,
    required TransactionType fallbackType,
    required String languageCode,
  }) async {
    final local = _localParse(
      input: input,
      categories: categories,
      wallets: wallets,
      fallbackType: fallbackType,
    );
    if (!_canUseCloudAi || input.trim().isEmpty) {
      return local;
    }

    try {
      final prompt = '''
You convert natural-language finance input into a structured transaction draft.
Return only valid JSON.

Language: $languageCode
Known wallets: ${jsonEncode(_walletDescriptors(wallets))}
Known categories: ${jsonEncode(_categoryDescriptors(categories))}

User input: ${input.trim()}

Infer:
- type
- amount as integer in VND
- walletId
- targetWalletId only for transfers
- categoryId for income/expense
- a short cleaned note

If information is missing, return null for that field.
''';

      final payload = await _requestJson(
        schemaName: 'finance_natural_language_parse',
        schema: {
          'type': 'object',
          'additionalProperties': false,
          'properties': {
            'type': {
              'type': ['string', 'null'],
              'enum': ['income', 'expense', 'transfer', null],
            },
            'categoryId': {
              'type': ['string', 'null'],
              'enum': [...categories.map((item) => item.id), null],
            },
            'walletId': {
              'type': ['string', 'null'],
              'enum': [...wallets.map((item) => item.id), null],
            },
            'targetWalletId': {
              'type': ['string', 'null'],
              'enum': [...wallets.map((item) => item.id), null],
            },
            'amount': {'type': ['integer', 'null']},
            'note': {'type': ['string', 'null']},
            'confidence': {'type': 'number'},
            'reason': {'type': 'string'},
          },
          'required': [
            'type',
            'categoryId',
            'walletId',
            'targetWalletId',
            'amount',
            'note',
            'confidence',
            'reason',
          ],
        },
        prompt: prompt,
      );

      return _draftFromMap(
        payload,
        fallback: local,
        usedCloudAi: true,
      );
    } catch (_) {
      return local;
    }
  }

  Future<MonthlySpendingSummary> summarizeMonth({
    required List<FinanceTransaction> transactions,
    required List<Category> categories,
    required DateTime month,
    required String languageCode,
  }) async {
    final local = _localMonthlySummary(
      transactions: transactions,
      categories: categories,
      month: month,
      languageCode: languageCode,
    );
    if (!_canUseCloudAi || transactions.isEmpty) {
      return local;
    }

    try {
      final income = transactions
          .where((item) => item.type == TransactionType.income)
          .fold<double>(0, (sum, item) => sum + item.amount);
      final expense = transactions
          .where((item) => item.type == TransactionType.expense)
          .fold<double>(0, (sum, item) => sum + item.amount);
      final groupedExpense = <String, double>{};
      for (final transaction in transactions.where(
        (item) => item.type == TransactionType.expense,
      )) {
        groupedExpense.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }

      final prompt = '''
You are a fintech spending coach. Summarize one month of spending in a concise, friendly, practical style.
Return only valid JSON.

Language: $languageCode
Month: ${month.year}-${month.month.toString().padLeft(2, '0')}
Income total: $income
Expense total: $expense
Transaction count: ${transactions.length}
Expense by category: ${jsonEncode(groupedExpense)}
Categories: ${jsonEncode(_categoryDescriptors(categories))}

Write a short headline, one summary paragraph, and up to 3 action bullets.
''';

      final payload = await _requestJson(
        schemaName: 'finance_monthly_summary',
        schema: {
          'type': 'object',
          'additionalProperties': false,
          'properties': {
            'headline': {'type': 'string'},
            'summary': {'type': 'string'},
            'bullets': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': ['headline', 'summary', 'bullets'],
        },
        prompt: prompt,
      );

      return MonthlySpendingSummary(
        headline: _stringOrFallback(payload['headline'], local.headline),
        summary: _stringOrFallback(payload['summary'], local.summary),
        bullets: (payload['bullets'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .where((item) => item.trim().isNotEmpty)
            .take(3)
            .toList(),
        usedCloudAi: true,
      );
    } catch (_) {
      return local;
    }
  }

  Future<Map<String, dynamic>> _requestJson({
    required String schemaName,
    required Map<String, Object?> schema,
    required String prompt,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      ),
      headers: {
        'x-goog-api-key': apiKey!.trim(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseJsonSchema': {
            'title': schemaName,
            ...schema,
          },
          'maxOutputTokens': 400,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gemini request failed: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = _extractOutputText(payload);
    final decoded = jsonDecode(outputText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON output.');
    }
    return decoded;
  }

  String _extractOutputText(Map<String, dynamic> payload) {
    final candidates = payload['candidates'];
    if (candidates is List<dynamic>) {
      for (final candidate in candidates.whereType<Map<String, dynamic>>()) {
        final content = candidate['content'];
        if (content is! Map<String, dynamic>) {
          continue;
        }
        final parts = content['parts'];
        if (parts is! List<dynamic>) {
          continue;
        }
        for (final part in parts.whereType<Map<String, dynamic>>()) {
          final text = part['text'];
          if (text is String && text.trim().isNotEmpty) {
            return text;
          }
        }
      }
    }

    throw const FormatException('No output text returned.');
  }

  AiTransactionDraft _draftFromMap(
    Map<String, dynamic> payload, {
    required AiTransactionDraft fallback,
    required bool usedCloudAi,
  }) {
    return AiTransactionDraft(
      type: _typeFromName(payload['type'] as String?) ?? fallback.type,
      amount: (payload['amount'] as num?)?.toInt() ?? fallback.amount,
      walletId: payload['walletId'] as String? ?? fallback.walletId,
      targetWalletId:
          payload['targetWalletId'] as String? ?? fallback.targetWalletId,
      categoryId: payload['categoryId'] as String? ?? fallback.categoryId,
      note: _stringOrNull(payload['note']) ?? fallback.note,
      confidence: (payload['confidence'] as num?)?.toDouble() ?? fallback.confidence,
      reason: _stringOrFallback(payload['reason'], fallback.reason),
      usedCloudAi: usedCloudAi,
    );
  }

  AiTransactionDraft _localParse({
    required String input,
    required List<Category> categories,
    required List<Wallet> wallets,
    required TransactionType fallbackType,
    int? fallbackAmount,
  }) {
    final normalized = input.trim().toLowerCase();
    final detectedType = _detectType(normalized) ?? fallbackType;
    final amount = _parseAmount(normalized) ?? fallbackAmount;
    final walletMatches = _matchWalletIds(normalized, wallets);
    final categoryId = detectedType == TransactionType.transfer
        ? null
        : _matchCategoryId(normalized, categories, detectedType);

    return AiTransactionDraft(
      type: detectedType,
      amount: amount,
      walletId: walletMatches.isNotEmpty ? walletMatches.first : null,
      targetWalletId: detectedType == TransactionType.transfer &&
              walletMatches.length > 1
          ? walletMatches[1]
          : null,
      categoryId: categoryId,
      note: input.trim().isEmpty ? null : input.trim(),
      confidence: normalized.isEmpty ? 0 : 0.62,
      reason: detectedType == TransactionType.transfer
          ? 'Matched transfer keywords and wallet names locally.'
          : 'Matched amount and category keywords locally.',
      usedCloudAi: false,
    );
  }

  MonthlySpendingSummary _localMonthlySummary({
    required List<FinanceTransaction> transactions,
    required List<Category> categories,
    required DateTime month,
    required String languageCode,
  }) {
    final income = transactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expense = transactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final net = income - expense;

    final expenseByCategory = <String, double>{};
    for (final transaction in transactions.where(
      (item) => item.type == TransactionType.expense,
    )) {
      expenseByCategory.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final topCategory = expenseByCategory.entries.fold<MapEntry<String, double>?>(
      null,
      (current, entry) =>
          current == null || entry.value > current.value ? entry : current,
    );

    final topCategoryName = topCategory == null
        ? null
        : categories
            .where((item) => item.id == topCategory.key)
            .firstOrNull
            ?.name;

    if (languageCode == 'vi') {
      return MonthlySpendingSummary(
        headline: net >= 0 ? 'Tháng này vẫn cân đối' : 'Tháng này chi vượt thu',
        summary:
            'Bạn có ${transactions.length} giao dịch trong tháng ${month.month}/${month.year}. Tổng thu là ${income.toStringAsFixed(0)} VND, tổng chi là ${expense.toStringAsFixed(0)} VND.',
        bullets: [
          if (topCategoryName != null)
            'Danh mục chi nhiều nhất là $topCategoryName với ${topCategory!.value.toStringAsFixed(0)} VND.',
          if (net >= 0)
            'Bạn còn dương ${net.toStringAsFixed(0)} VND sau khi trừ chi tiêu.'
          else
            'Bạn đang âm ${net.abs().toStringAsFixed(0)} VND, nên xem lại các khoản chi lớn.',
          'Ưu tiên rà soát các khoản chi lặp lại và thiết lập ngân sách cho danh mục lớn nhất.',
        ],
      );
    }

    return MonthlySpendingSummary(
      headline: net >= 0 ? 'This month stays healthy' : 'This month is overspent',
      summary:
          'You logged ${transactions.length} transactions in ${month.month}/${month.year}. Total income is ${income.toStringAsFixed(0)} VND and total expense is ${expense.toStringAsFixed(0)} VND.',
      bullets: [
        if (topCategoryName != null)
          'Your highest spend category is $topCategoryName at ${topCategory!.value.toStringAsFixed(0)} VND.',
        if (net >= 0)
          'You are still ahead by ${net.toStringAsFixed(0)} VND after expenses.'
        else
          'You are behind by ${net.abs().toStringAsFixed(0)} VND and should review large expenses.',
        'Review recurring costs and set a tighter budget for the largest category.',
      ],
    );
  }

  List<Map<String, String>> _walletDescriptors(List<Wallet> wallets) {
    return wallets
        .map((wallet) => {'id': wallet.id, 'name': wallet.name})
        .toList();
  }

  List<Map<String, String>> _categoryDescriptors(List<Category> categories) {
    return categories
        .map((category) => {'id': category.id, 'name': category.name})
        .toList();
  }

  List<String> _matchWalletIds(String input, List<Wallet> wallets) {
    final matches = <String>[];
    for (final wallet in wallets) {
      final tokens = wallet.name.toLowerCase().split(RegExp(r'\s+'));
      if (tokens.any((token) => token.length > 1 && input.contains(token))) {
        matches.add(wallet.id);
      }
    }
    return matches.toSet().toList();
  }

  String? _matchCategoryId(
    String input,
    List<Category> categories,
    TransactionType type,
  ) {
    final keywordMap = <String, List<String>>{
      'food': ['ăn', 'com', 'cơm', 'cafe', 'cà phê', 'trà sữa', 'bún', 'phở'],
      'transport': ['grab', 'taxi', 'xăng', 'gửi xe', 'bus', 'xe'],
      'shopping': ['mua', 'shop', 'shopee', 'lazada', 'quần áo', 'đồ'],
      'bills': ['điện', 'nước', 'wifi', 'internet', 'tiền nhà', 'hóa đơn'],
      'health': ['thuốc', 'bệnh viện', 'khám', 'nha khoa', 'sức khỏe'],
      'salary': ['lương', 'salary', 'payroll'],
      'bonus': ['thưởng', 'bonus', 'hoa hồng'],
      'gift': ['quà', 'gift', 'lì xì', 'mừng'],
    };

    for (final category in categories) {
      if (category.type != type) {
        continue;
      }

      final keywords = keywordMap[category.id] ?? const <String>[];
      if (keywords.any(input.contains)) {
        return category.id;
      }

      final nameLower = category.name.toLowerCase();
      if (input.contains(nameLower)) {
        return category.id;
      }
    }
    return null;
  }

  TransactionType? _detectType(String input) {
    if (input.isEmpty) {
      return null;
    }
    if (_containsAny(input, ['chuyển', 'transfer', 'sang ví', 'qua ví'])) {
      return TransactionType.transfer;
    }
    if (_containsAny(
      input,
      ['lương', 'thưởng', 'được cho', 'nhận', 'income', 'salary', 'bonus'],
    )) {
      return TransactionType.income;
    }
    return TransactionType.expense;
  }

  int? _parseAmount(String input) {
    final amountMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(k|nghìn|ngàn|tr|triệu|m|củ)?',
      caseSensitive: false,
    ).firstMatch(input);
    if (amountMatch == null) {
      return null;
    }

    final base = double.tryParse(
      amountMatch.group(1)!.replaceAll('.', '').replaceAll(',', '.'),
    );
    if (base == null) {
      return null;
    }

    final unit = amountMatch.group(2)?.toLowerCase();
    final multiplier = switch (unit) {
      'k' || 'nghìn' || 'ngàn' => 1000,
      'tr' || 'triệu' || 'm' || 'củ' => 1000000,
      _ => 1,
    };

    return (base * multiplier).round();
  }

  bool _containsAny(String input, List<String> needles) {
    return needles.any(input.contains);
  }

  TransactionType? _typeFromName(String? value) {
    return switch (value) {
      'income' => TransactionType.income,
      'expense' => TransactionType.expense,
      'transfer' => TransactionType.transfer,
      _ => null,
    };
  }

  String _stringOrFallback(Object? value, String fallback) {
    final stringValue = _stringOrNull(value);
    return stringValue ?? fallback;
  }

  String? _stringOrNull(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
