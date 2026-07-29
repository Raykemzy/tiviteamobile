import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/services/third_party_services/media_upload_exception.dart';
import 'package:tivi_tea/core/utils/logger.dart';
import 'package:tivi_tea/core/utils/media_utils.dart';

class CloudinaryService {
  final CloudinaryPublic cloudinary;

  CloudinaryService({required this.cloudinary});

  /// Uploads [filePaths] to Cloudinary and returns the secure URLs.
  ///
  /// Throws [MediaUploadException] when any file exceeds the upload limit —
  /// nothing is uploaded in that case, so the user fixes the selection rather
  /// than ending up with a half-uploaded set.
  Future<List<String>> uploadImages(List<XFile> filePaths) async {
    final oversized = await MediaUtils.oversizedFiles(
      filePaths.map((e) => e.path),
    );
    if (oversized.isNotEmpty) {
      throw MediaUploadException.tooLarge(
        oversized.map((path) => path.split('/').last).toList(),
        MediaUtils.maxUploadLabel,
      );
    }

    List<String> uploadedImageUrls = [];

    List<Future<void>> uploadTasks = filePaths.map((XFile filePath) async {
      File file = File(filePath.path);
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(file.path),
        );
        if (response.secureUrl.isNotEmpty) {
          uploadedImageUrls.add(response.secureUrl);
        }
        debugLog('Uploaded image URL: ${response.secureUrl}');
      } catch (e) {
        debugLog('Error uploading image: $e');
      }
    }).toList();

    await Future.wait(uploadTasks);

    return uploadedImageUrls;
  }
}
