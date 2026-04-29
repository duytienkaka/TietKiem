import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class VietnameseCurrencyInputFormatter extends TextInputFormatter {
  const VietnameseCurrencyInputFormatter({
    this.separator = '.',
  });

  final String separator;

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
        composing: TextRange.empty,
      );
    }

    final formatted = formatGroupedDigits(
      digits,
      separator: separator,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
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

  return formatGroupedDigits(value.toString(), separator: '.');
}

String formatGroupedDigits(
  String digits, {
  String separator = ',',
}) {
  final normalized = digits.replaceFirst(RegExp(r'^0+'), '');
  final source = normalized.isEmpty ? '0' : normalized;
  final buffer = StringBuffer();

  for (var index = 0; index < source.length; index++) {
    buffer.write(source[index]);
    final remaining = source.length - index - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(separator);
    }
  }

  return buffer.toString();
}

String formatVietnameseCurrency(String digits) =>
    formatGroupedDigits(digits, separator: '.');

TextEditingValue currencyEditingValueFromInt(int value) {
  final normalized = value < 0 ? 0 : value;
  final formatted = formatVietnameseCurrencyFromInt(normalized);
  return TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: formatted.length),
    composing: TextRange.empty,
  );
}

void applyCurrencyEditingValue(
  TextEditingController controller,
  int value,
) {
  controller.value = currencyEditingValueFromInt(value);
}
