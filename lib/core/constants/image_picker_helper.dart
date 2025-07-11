import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage(BuildContext context) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );

    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();

      // Convert fileSize to kilobytes or megabytes as needed
      final fileSizeKB = fileSize / 1024; // convert to kilobytes
      final fileSizeMB = fileSizeKB / 1024; // convert to megabytes

      Logger().d('Image size: $fileSize bytes, $fileSizeKB KB, $fileSizeMB MB');
    }

    return image;
  }

  static Future<List<String>> pickImages(BuildContext context) async {
    final photo = <String>[];
    final image = await _picker.pickMultiImage();
    for (final e in image) {
      photo.add(e.path);
    }
    return photo;
  }
}
