import 'package:flutter/material.dart';

class SmoothBottomSheet extends StatelessWidget {
  const SmoothBottomSheet({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: child,
      ),
    );
  }
}
