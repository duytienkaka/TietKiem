import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/utils/currency_input_formatter.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.controller,
    required this.rawValue,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
    this.onCalculated,
  });

  final TextEditingController controller;
  final int rawValue;
  final FocusNode? focusNode;
  final ValueChanged<int>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<int>? onCalculated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: (value) => onChanged?.call(parseVietnameseCurrency(value)),
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        VietnameseCurrencyInputFormatter(),
      ],
      textAlign: TextAlign.center,
      style: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: '0',
        suffixText: ' VND',
        suffixStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        fillColor: Colors.transparent,
        filled: false,
      ),
      validator: (value) {
        final amount = parseVietnameseCurrency(value ?? '');
        if (amount <= 0) {
          return context.l10n.enterValidAmountGreaterThanZero;
        }
        return null;
      },
    );
  }
}
