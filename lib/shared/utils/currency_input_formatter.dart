import 'package:flutter/services.dart';

class VietnameseCurrencyInputFormatter extends TextInputFormatter {
  const VietnameseCurrencyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = extractDigits(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = formatVietnameseCurrency(digits);
    final digitsToRight = _countDigitsToRight(newValue);
    final selectionOffset = _resolveSelectionOffset(formatted, digitsToRight);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }

  int _countDigitsToRight(TextEditingValue value) {
    if (!value.selection.isValid) {
      return 0;
    }

    final rightSide = value.text.substring(value.selection.end);
    return _countDigits(rightSide);
  }

  int _resolveSelectionOffset(String formatted, int digitsToRight) {
    if (digitsToRight <= 0) {
      return formatted.length;
    }

    var offset = formatted.length;
    var seenDigits = 0;

    while (offset > 0 && seenDigits < digitsToRight) {
      offset--;
      if (_isDigit(formatted.codeUnitAt(offset))) {
        seenDigits++;
      }
    }

    return offset;
  }
}

String extractDigits(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

int parseVietnameseCurrency(String input) {
  final digits = extractDigits(input);
  return digits.isEmpty ? 0 : int.parse(digits);
}

String formatVietnameseCurrencyFromInt(int value) {
  if (value <= 0) {
    return '';
  }

  return formatVietnameseCurrency(value.toString());
}

String formatVietnameseCurrency(String digits) {
  final normalized = digits.replaceFirst(RegExp(r'^0+'), '');
  final source = normalized.isEmpty ? '0' : normalized;
  final buffer = StringBuffer();

  for (var index = 0; index < source.length; index++) {
    buffer.write(source[index]);
    final remaining = source.length - index - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;

int _countDigits(String input) {
  var count = 0;
  for (final codeUnit in input.codeUnits) {
    if (_isDigit(codeUnit)) {
      count++;
    }
  }
  return count;
}
