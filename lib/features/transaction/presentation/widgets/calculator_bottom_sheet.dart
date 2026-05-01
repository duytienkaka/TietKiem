import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

const String _backspaceKey = '\u232b';
const String _divideKey = '\u00f7';
const String _multiplyKey = '\u00d7';

Future<int?> showAmountCalculatorSheet(
  BuildContext context, {
  int initialValue = 0,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.46 : 0.34,
    ),
    builder: (sheetContext) => _CalculatorBottomSheet(initialValue: initialValue),
  );
}

class _CalculatorBottomSheet extends StatefulWidget {
  const _CalculatorBottomSheet({required this.initialValue});

  final int initialValue;

  @override
  State<_CalculatorBottomSheet> createState() => _CalculatorBottomSheetState();
}

class _CalculatorBottomSheetState extends State<_CalculatorBottomSheet> {
  static const List<String> _buttons = [
    'C', _backspaceKey, _divideKey, _multiplyKey,
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '=',
    '0', '.', '', '',
  ];

  late String _expression;
  String _resultText = '0';
  int? _resultValue;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _expression = widget.initialValue > 0 ? widget.initialValue.toString() : '';
    if (_expression.isNotEmpty) {
      _resultValue = widget.initialValue;
      _resultText = widget.initialValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.92;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 32 * (1 - value)),
              child: child,
            ),
          ),
          child: Material(
            color: scheme.surface,
            elevation: 18,
            shadowColor: Colors.black.withValues(alpha: 0.22),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + bottomPadding),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\u004d\u00e1y t\u00ednh',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _expression.isEmpty ? '0' : _displayExpression(_expression),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hasError ? 'L\u1ed7i' : _resultText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: _hasError ? scheme.error : scheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _buttons.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.98,
                            ),
                        itemBuilder: (context, index) {
                          final label = _buttons[index];
                          if (label.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return _CalculatorButton(
                            label: label,
                            variant: _buttonVariant(label),
                            operatorStyle: _isOperator(label),
                            onTap: () => _handleTap(label),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _resultValue == null || _hasError
                            ? null
                            : () => Navigator.of(context).pop(_resultValue),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('D\u00f9ng k\u1ebft qu\u1ea3'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(String label) {
    setState(() {
      switch (label) {
        case 'C':
          _expression = '';
          _resultText = '0';
          _resultValue = null;
          _hasError = false;
          return;
        case _backspaceKey:
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          _previewResult();
          return;
        case '=':
          _previewResult(commit: true);
          return;
        default:
          _appendToken(label);
          _previewResult();
          return;
      }
    });
  }

  void _appendToken(String token) {
    if (_hasError) {
      _expression = '';
      _hasError = false;
    }

    final normalized = _normalizeToken(token);
    if (_expression.isEmpty && _isBinaryOperator(normalized)) {
      return;
    }

    if (normalized == '.') {
      final segment = _currentSegment();
      if (segment.contains('.')) {
        return;
      }
      _expression += segment.isEmpty ? '0.' : '.';
      return;
    }

    if (_isBinaryOperator(normalized)) {
      if (_expression.isEmpty) {
        return;
      }

      final lastToken = _expression.substring(_expression.length - 1);
      if (_isBinaryOperator(lastToken)) {
        _expression = _expression.substring(0, _expression.length - 1) + normalized;
        return;
      }
    }

    _expression += normalized;
  }

  void _previewResult({bool commit = false}) {
    if (_expression.isEmpty) {
      _resultText = '0';
      _resultValue = null;
      _hasError = false;
      return;
    }

    final sanitized = _sanitizeExpression(_expression);
    final lastToken = sanitized.isEmpty ? '' : sanitized.substring(sanitized.length - 1);
    if (sanitized.isEmpty || _isBinaryOperator(lastToken)) {
      _resultText = '0';
      _resultValue = null;
      _hasError = false;
      return;
    }

    try {
      final parser = GrammarParser();
      final expression = parser.parse(sanitized);
      final evaluator = RealEvaluator(ContextModel());
      final result = evaluator.evaluate(expression).toDouble();

      if (!result.isFinite || result <= 0) {
        throw const FormatException('Invalid result');
      }

      final normalized = result.truncate();
      if (normalized <= 0) {
        throw const FormatException('Invalid result');
      }

      _resultValue = normalized;
      _resultText = normalized.toString();
      _hasError = false;

      if (commit) {
        _expression = normalized.toString();
      }
    } catch (_) {
      _resultValue = null;
      _resultText = 'L\u1ed7i';
      _hasError = true;
    }
  }

  String _displayExpression(String source) {
    return source.replaceAll('*', _multiplyKey).replaceAll('/', _divideKey);
  }

  String _sanitizeExpression(String source) =>
      source.replaceAll(_multiplyKey, '*').replaceAll(_divideKey, '/');

  String _normalizeToken(String source) {
    return switch (source) {
      _multiplyKey => '*',
      _divideKey => '/',
      _ => source,
    };
  }

  String _currentSegment() {
    final parts = _expression.split(RegExp(r'[+\-*/]'));
    return parts.isEmpty ? '' : parts.last;
  }

  _CalculatorButtonVariant _buttonVariant(String label) {
    if (label == '=') {
      return _CalculatorButtonVariant.equals;
    }
    if (label == 'C') {
      return _CalculatorButtonVariant.accent;
    }
    return _CalculatorButtonVariant.normal;
  }

  bool _isOperator(String label) =>
      label == _divideKey || label == _multiplyKey || label == '-' || label == '+' || label == '=';

  bool _isBinaryOperator(String label) =>
      label == '/' || label == '*' || label == '-' || label == '+';
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.onTap,
    this.variant = _CalculatorButtonVariant.normal,
    this.operatorStyle = false,
  });

  final String label;
  final VoidCallback onTap;
  final _CalculatorButtonVariant variant;
  final bool operatorStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final backgroundColor = switch (variant) {
      _CalculatorButtonVariant.equals => scheme.primary,
      _CalculatorButtonVariant.accent => scheme.secondaryContainer,
      _CalculatorButtonVariant.normal => operatorStyle
          ? scheme.primaryContainer
          : scheme.surfaceContainer,
    };
    final foregroundColor = switch (variant) {
      _CalculatorButtonVariant.equals => scheme.onPrimary,
      _CalculatorButtonVariant.accent => scheme.onSecondaryContainer,
      _CalculatorButtonVariant.normal => operatorStyle
          ? scheme.onPrimaryContainer
          : scheme.onSurface,
    };
    final borderColor = switch (variant) {
      _CalculatorButtonVariant.equals => scheme.primary.withValues(alpha: 0.22),
      _CalculatorButtonVariant.accent => scheme.secondary.withValues(alpha: 0.18),
      _CalculatorButtonVariant.normal => scheme.outlineVariant.withValues(alpha: 0.28),
    };

    return Material(
      color: backgroundColor,
      elevation: variant == _CalculatorButtonVariant.equals ? 4 : 0,
      shadowColor: scheme.primary.withValues(alpha: 0.24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: foregroundColor.withValues(alpha: 0.08),
        highlightColor: foregroundColor.withValues(alpha: 0.05),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              color: foregroundColor,
              fontWeight: variant == _CalculatorButtonVariant.equals
                  ? FontWeight.w900
                  : FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

enum _CalculatorButtonVariant { normal, accent, equals }
