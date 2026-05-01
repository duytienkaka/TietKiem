import 'backup_file_saver_stub.dart'
    if (dart.library.io) 'backup_file_saver_io.dart'
    if (dart.library.html) 'backup_file_saver_web.dart';

Future<String> saveBackupFile({
  required String fileName,
  required String contents,
}) {
  return saveBackupFileImpl(
    fileName: fileName,
    contents: contents,
  );
}
