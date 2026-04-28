import 'package:flutter/material.dart';

class AnimatedTransactionItem extends StatefulWidget {
  const AnimatedTransactionItem({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<AnimatedTransactionItem> createState() => _AnimatedTransactionItemState();
}

class _AnimatedTransactionItemState extends State<AnimatedTransactionItem> {
  static const _maxStaggerItems = 6;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.index.clamp(0, _maxStaggerItems);
    Future<void>.delayed(Duration(milliseconds: 28 * safeIndex), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _visible ? 1 : 0,
          child: widget.child,
        ),
      ),
    );
  }
}
