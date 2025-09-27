import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:my_collection_app/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();
  static const Uuid _uuid = Uuid();

  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int quality = 80,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: quality,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
      );
      
      if (image != null) {
        return await compressImage(image);
      }
      
      return null;
    } catch (e) {
      Logger.error('Erro ao selecionar imagem: $e', error: e);
      return null;
    }
  }

  static Future<XFile?> compressImage(XFile image) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${_uuid.v4()}.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 80,
        minWidth: 300,
        minHeight: 300,
        format: CompressFormat.jpeg,
      );
      
      return compressedFile;
    } catch (e) {
      Logger.error('Erro ao comprimir imagem: $e', error: e);
      return image; // Return original if compression fails
    }
  }

  static Future<void> deleteTemporaryFiles() async {
    try {
      final dir = await getTemporaryDirectory();
      final files = dir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.jpg')) {
          final stats = file.statSync();
          final age = DateTime.now().difference(stats.modified);
          
          // Delete files older than 1 hour
          if (age.inHours > 1) {
            file.deleteSync();
          }
        }
      }
    } catch (e) {
      Logger.error('Erro ao limpar arquivos temporários: $e', error: e);
    }
  }

  static String generateFileName(String extension) {
    return '${_uuid.v4()}.$extension';
  }

  static bool isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  }

  static double calculateAspectRatio(File imageFile) {
    // This would require additional image processing libraries
    // For now, return a default aspect ratio
    return 1.0;
  }
}
