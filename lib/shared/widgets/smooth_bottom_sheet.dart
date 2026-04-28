import 'package:flutter/material.dart';

class SmoothBottomSheet extends StatelessWidget {
  const SmoothBottomSheet({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubicEmphasized,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 36 * (1 - value)),
          child: Transform.scale(
            scale: 0.985 + (0.015 * value),
            child: Opacity(opacity: value, child: child),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF1F2F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: child,
      ),
    );
  }
}
