import 'dart:ui';

import 'package:flutter/material.dart';

import 'formatters.dart';

class AnimatedBalanceText extends StatefulWidget {
  const AnimatedBalanceText({
    super.key,
    required this.previousBalance,
    required this.currentBalance,
    this.style,
    this.duration = const Duration(milliseconds: 1100),
    this.curve = Curves.easeOutCubic,
    this.increaseColor = const Color(0xFF17B26A),
    this.decreaseColor = const Color(0xFFF04438),
    this.neutralColor,
    this.enableScaleEffect = true,
  });

  final double previousBalance;
  final double currentBalance;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final Color increaseColor;
  final Color decreaseColor;
  final Color? neutralColor;
  final bool enableScaleEffect;

  @override
  State<AnimatedBalanceText> createState() => _AnimatedBalanceTextState();
}

class _AnimatedBalanceTextState extends State<AnimatedBalanceText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _curve;
  late Animation<double> _scale;
  late double _fromBalance;
  late double _toBalance;

  @override
  void initState() {
    super.initState();
    _fromBalance = widget.previousBalance;
    _toBalance = widget.currentBalance;
    _controller = AnimationController(
      vsync: this,
      duration: _resolveDuration(),
    );
    _configureAnimations();
    if (_fromBalance != _toBalance) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedBalanceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = _resolveDuration();
    }
    if (oldWidget.curve != widget.curve || oldWidget.enableScaleEffect != widget.enableScaleEffect) {
      _configureAnimations();
    }
    if (oldWidget.currentBalance != widget.currentBalance ||
        oldWidget.previousBalance != widget.previousBalance) {
      _fromBalance = widget.previousBalance;
      _toBalance = widget.currentBalance;
      _controller.duration = _resolveDuration();
      if (_fromBalance == _toBalance) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _configureAnimations() {
    _curve = CurvedAnimation(parent: _controller, curve: widget.curve);
    _scale = widget.enableScaleEffect
        ? TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 1, end: 1.035)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
              weight: 45,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 1.035, end: 1)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 55,
            ),
          ]).animate(_controller)
        : kAlwaysCompleteAnimation;
  }

  Duration _resolveDuration() {
    final delta = (_toBalance - _fromBalance).abs();
    if (delta <= 100000) {
      return const Duration(milliseconds: 1600);
    }
    if (delta <= 500000) {
      return const Duration(milliseconds: 1350);
    }
    return widget.duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animatedValue = lerpDouble(_fromBalance, _toBalance, _curve.value) ?? _toBalance;
        final trendColor = _resolveTrendColor(context);
        return Transform.scale(
          scale: widget.enableScaleEffect ? _scale.value : 1,
          child: Text(
            formatCurrency(context, animatedValue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: widget.style?.copyWith(color: trendColor),
          ),
        );
      },
    );
  }

  Color _resolveTrendColor(BuildContext context) {
    if (_toBalance > _fromBalance) {
      return widget.increaseColor;
    }
    if (_toBalance < _fromBalance) {
      return widget.decreaseColor;
    }
    return widget.neutralColor ??
        widget.style?.color ??
        Theme.of(context).colorScheme.onSurface;
  }
}
