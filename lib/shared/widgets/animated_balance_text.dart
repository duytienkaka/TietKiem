import 'package:flutter/material.dart';

import 'formatters.dart';

class AnimatedBalanceText extends StatefulWidget {
  const AnimatedBalanceText({
    super.key,
    required this.value,
    required this.style,
    this.color,
  });

  final double value;
  final TextStyle? style;
  final Color? color;

  @override
  State<AnimatedBalanceText> createState() => _AnimatedBalanceTextState();
}

class _AnimatedBalanceTextState extends State<AnimatedBalanceText> {
  late double _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedBalanceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _previousValue, end: widget.value),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      builder: (context, animatedValue, _) {
        return Text(
          formatCurrency(context, animatedValue),
          style: widget.style?.copyWith(color: widget.color),
        );
      },
    );
  }
}
