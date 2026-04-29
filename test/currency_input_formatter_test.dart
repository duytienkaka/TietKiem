import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tietkiem/shared/utils/currency_input_formatter.dart';

void main() {
  group('VietnameseCurrencyInputFormatter', () {
    const formatter = VietnameseCurrencyInputFormatter();

    test('formats pasted large number with stable cursor', () {
      const result = TextEditingValue(
        text: '1000000000',
        selection: TextSelection.collapsed(offset: 10),
      );

      final formatted = formatter.formatEditUpdate(
        const TextEditingValue(),
        result,
      );

      expect(formatted.text, '1.000.000.000');
      expect(
        formatted.selection,
        const TextSelection.collapsed(offset: 13),
      );
      expect(formatted.composing, TextRange.empty);
    });

    test('strips non-digit characters from pasted value', () {
      const result = TextEditingValue(
        text: '1a2b3c4d5e6',
        selection: TextSelection.collapsed(offset: 11),
      );

      final formatted = formatter.formatEditUpdate(
        const TextEditingValue(),
        result,
      );

      expect(formatted.text, '123.456');
      expect(
        formatted.selection,
        const TextSelection.collapsed(offset: 7),
      );
      expect(formatted.composing, TextRange.empty);
    });

    test('keeps cursor stable during rapid typing sequence', () {
      var current = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );

      for (final input in ['1', '10', '100', '1000', '10000', '1000000']) {
        current = formatter.formatEditUpdate(
          current,
          TextEditingValue(
            text: input,
            selection: TextSelection.collapsed(offset: input.length),
          ),
        );
      }

      expect(current.text, '1.000.000');
      expect(
        current.selection,
        const TextSelection.collapsed(offset: 9),
      );
      expect(current.composing, TextRange.empty);
    });

    test('returns empty value cleanly when all digits are removed', () {
      final formatted = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '1.234',
          selection: TextSelection.collapsed(offset: 5),
        ),
        const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        ),
      );

      expect(formatted.text, '');
      expect(
        formatted.selection,
        const TextSelection.collapsed(offset: 0),
      );
      expect(formatted.composing, TextRange.empty);
    });
  });

  group('currency controller helpers', () {
    test('applyCurrencyEditingValue sets valid text, selection, and composing', () {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      applyCurrencyEditingValue(controller, 2500000);

      expect(controller.text, '2.500.000');
      expect(
        controller.selection,
        const TextSelection.collapsed(offset: 9),
      );
      expect(controller.value.composing, TextRange.empty);
    });

    test('format/parsing helpers stay symmetric for large values', () {
      const source = 987654321;
      final formatted = formatVietnameseCurrencyFromInt(source);

      expect(formatted, '987.654.321');
      expect(parseVietnameseCurrency(formatted), source);
    });
  });
}
