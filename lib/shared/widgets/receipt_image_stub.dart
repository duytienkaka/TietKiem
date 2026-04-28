import 'package:flutter/material.dart';

class ReceiptImage extends StatelessWidget {
  const ReceiptImage({
    super.key,
    required this.source,
    this.height = 180,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String source;
  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
