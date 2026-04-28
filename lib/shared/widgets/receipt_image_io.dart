import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
    if (source.startsWith('data:')) {
      return Image.memory(
        _decodeDataUri(source),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return Image.file(
      File(source),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }

  Uint8List _decodeDataUri(String value) {
    final commaIndex = value.indexOf(',');
    final encoded = commaIndex >= 0 ? value.substring(commaIndex + 1) : value;
    return base64Decode(encoded);
  }
}
