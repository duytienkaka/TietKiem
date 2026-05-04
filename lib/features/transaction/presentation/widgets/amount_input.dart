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
    final scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth < 360 ? 170.0 : 210.0;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: fieldWidth,
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (value) =>
                          onChanged?.call(parseVietnameseCurrency(value)),
                      onFieldSubmitted: onFieldSubmitted,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        VietnameseCurrencyInputFormatter(),
                      ],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      validator: (value) {
                        final amount = parseVietnameseCurrency(value ?? '');
                        if (amount <= 0) {
                          return context.l10n.enterValidAmountGreaterThanZero;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'VND',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
