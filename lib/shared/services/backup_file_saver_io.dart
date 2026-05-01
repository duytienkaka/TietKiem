import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> saveBackupFileImpl({
  required String fileName,
  required String contents,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final backupDirectory = Directory(p.join(directory.path, 'backups'));
  if (!backupDirectory.existsSync()) {
    backupDirectory.createSync(recursive: true);
  }

  final file = File(p.join(backupDirectory.path, fileName));
  await file.writeAsString(contents, flush: true);
  return file.path;
}
