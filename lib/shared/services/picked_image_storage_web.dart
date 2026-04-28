import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

Future<String> savePickedImage(XFile file) async {
  final bytes = await file.readAsBytes();
  final source = file.name.isNotEmpty ? file.name : file.path;
  final extension = path.extension(source).toLowerCase();
  final mimeType = switch (extension) {
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.webp' => 'image/webp',
    '.gif' => 'image/gif',
    _ => 'image/png',
  };
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}
