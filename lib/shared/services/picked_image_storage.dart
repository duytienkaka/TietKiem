import 'package:image_picker/image_picker.dart';

import 'picked_image_storage_stub.dart'
    if (dart.library.io) 'picked_image_storage_io.dart'
    if (dart.library.html) 'picked_image_storage_web.dart' as impl;

Future<String> savePickedImage(XFile file) => impl.savePickedImage(file);
