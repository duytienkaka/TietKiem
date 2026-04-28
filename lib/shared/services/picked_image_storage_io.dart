import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> savePickedImage(XFile file) async {
  final directory = await getApplicationDocumentsDirectory();
  final receiptDir = Directory(path.join(directory.path, 'receipts'));
  if (!await receiptDir.exists()) {
    await receiptDir.create(recursive: true);
  }

  final savedPath = path.join(
    receiptDir.path,
    '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}',
  );
  await File(file.path).copy(savedPath);
  return savedPath;
}
