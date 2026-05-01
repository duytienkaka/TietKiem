import 'dart:convert';

import '../../domain/entities/scanned_bill_qr.dart';

class BillQrParser {
  static const _amountKeys = [
    'amount',
    'total',
    'total_amount',
    'grand_total',
    'payable',
    'subtotal',
    'price',
    'value',
    'tong',
    'tongtien',
    'thanhtien',
  ];

  static const _merchantKeys = [
    'merchant',
    'store',
    'shop',
    'seller',
    'merchant_name',
    'store_name',
    'brand',
    'name',
  ];

  static const _noteKeys = [
    'note',
    'description',
    'content',
    'message',
    'memo',
    'order',
    'bill',
    'invoice',
  ];

  static ScannedBillQr parse(String rawValue) {
    final normalized = rawValue.trim();
    final map = _extractStructuredData(normalized);

    final amount = _parseAmountFromMap(map) ?? _parseAmountFromText(normalized);
    final merchant = _firstString(map, _merchantKeys);
    final note = _firstString(map, _noteKeys);

    return ScannedBillQr(
      rawValue: normalized,
      amount: amount,
      merchant: merchant,
      note: note,
    );
  }

  static Map<String, String> _extractStructuredData(String rawValue) {
    final collected = <String, String>{};

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final key = entry.key.toString().trim().toLowerCase();
          final value = entry.value?.toString().trim();
          if (key.isNotEmpty && value != null && value.isNotEmpty) {
            collected[key] = value;
          }
        }
      }
    } catch (_) {
      // Fall through to other formats.
    }

    final uri = Uri.tryParse(rawValue);
    if (uri != null && uri.queryParameters.isNotEmpty) {
      for (final entry in uri.queryParameters.entries) {
        if (entry.value.trim().isNotEmpty) {
          collected.putIfAbsent(entry.key.trim().toLowerCase(), () => entry.value.trim());
        }
      }
    }

    final separators = RegExp(r'[\n\r;|]+');
    for (final chunk in rawValue.split(separators)) {
      final trimmed = chunk.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final match = RegExp(r'^([A-Za-z0-9_ ]{2,40})\s*[:=]\s*(.+)$').firstMatch(trimmed);
      if (match == null) {
        continue;
      }
      final key = match.group(1)!.trim().toLowerCase().replaceAll(' ', '_');
      final value = match.group(2)!.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        collected.putIfAbsent(key, () => value);
      }
    }

    return collected;
  }

  static String? _firstString(Map<String, String> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static int? _parseAmountFromMap(Map<String, String> map) {
    for (final key in _amountKeys) {
      final value = map[key];
      final amount = _parseAmount(value);
      if (amount != null && amount > 0) {
        return amount;
      }
    }
    return null;
  }

  static int? _parseAmountFromText(String rawValue) {
    final labeled = RegExp(
      r'(total|amount|payable|tong|tongtien|thanhtien)[^0-9]{0,12}([0-9][0-9\., ]{2,})',
      caseSensitive: false,
    );
    for (final match in labeled.allMatches(rawValue)) {
      final amount = _parseAmount(match.group(2));
      if (amount != null && amount > 0) {
        return amount;
      }
    }

    final generic = RegExp(r'([0-9][0-9\., ]{3,})');
    int? best;
    for (final match in generic.allMatches(rawValue)) {
      final amount = _parseAmount(match.group(1));
      if (amount != null && amount > 999) {
        if (best == null || amount > best) {
          best = amount;
        }
      }
    }
    return best;
  }

  static int? _parseAmount(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final onlyDigits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) {
      return null;
    }
    return int.tryParse(onlyDigits);
  }
}
