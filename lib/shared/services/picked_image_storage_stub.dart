import 'package:image_picker/image_picker.dart';

Future<String> savePickedImage(XFile file) async => file.path;
