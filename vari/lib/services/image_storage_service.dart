import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();

  factory ImageStorageService() {
    return _instance;
  }

  ImageStorageService._internal();

  /// Save image file to local storage and return the file path
  Future<String?> saveImage(File imageFile, String reportId, String victimName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/patient_images');
      
      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename using report ID and victim name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${reportId}_${victimName}_$timestamp.jpg';
      final savedImage = File('${imagesDir.path}/$filename');

      // Copy image to local storage
      await imageFile.copy(savedImage.path);
      
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Retrieve image file from local storage
  Future<File?> getImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error retrieving image: $e');
      return null;
    }
  }

  /// Check if image exists locally
  Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete image from local storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
