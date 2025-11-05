import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  /// ดึงรายการกล้องที่มีในเครื่อง
  static Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      final cameras = await availableCameras();
      if (kDebugMode) {
        print('📷 Available cameras: ${cameras.length}');
        for (var camera in cameras) {
          print('   - ${camera.name}: ${camera.lensDirection}');
        }
      }
      return cameras;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting cameras: $e');
      }
      return [];
    }
  }

  /// เริ่มต้นกล้อง
  static Future<CameraController> initializeCamera(
    CameraDescription camera, {
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    try {
      final controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (kDebugMode) {
        print('✅ Camera initialized: ${camera.name}');
      }

      return controller;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing camera: $e');
      }
      rethrow;
    }
  }

  /// ถ่ายรูป
  static Future<File?> takePicture(CameraController controller) async {
    if (!controller.value.isInitialized) {
      if (kDebugMode) {
        print('❌ Camera not initialized');
      }
      return null;
    }

    try {
      // ถ่ายรูป
      final XFile picture = await controller.takePicture();

      if (kDebugMode) {
        print('✅ Picture taken: ${picture.path}');
      }

      return File(picture.path);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error taking picture: $e');
      }
      return null;
    }
  }

  /// บีบอัดรูปภาพ
  static Future<File?> compressImage(
    File imageFile, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 Compressing image...');
      }

      // อ่านไฟล์รูปภาพ
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        if (kDebugMode) {
          print('❌ Failed to decode image');
        }
        return null;
      }

      // ปรับขนาดถ้ารูปใหญ่เกินไป
      img.Image resized = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        resized = img.copyResize(
          image,
          width: image.width > maxWidth ? maxWidth : null,
          height: image.height > maxHeight ? maxHeight : null,
        );
      }

      // บีบอัดรูป
      final compressedBytes = img.encodeJpg(resized, quality: quality);

      // บันทึกไฟล์
      final tempDir = await getTemporaryDirectory();
      final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(path.join(tempDir.path, fileName));
      await compressedFile.writeAsBytes(compressedBytes);

      // แสดงขนาดไฟล์
      final originalSize = await imageFile.length();
      final compressedSize = await compressedFile.length();
      final reduction = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);

      if (kDebugMode) {
        print('✅ Image compressed:');
        print('   Original: ${formatFileSize(originalSize)}');
        print('   Compressed: ${formatFileSize(compressedSize)}');
        print('   Reduction: $reduction%');
      }

      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error compressing image: $e');
      }
      return null;
    }
  }

  /// ดูขนาดไฟล์
  static Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting file size: $e');
      }
      return 0;
    }
  }

  /// แปลงขนาดไฟล์เป็นข้อความ (KB, MB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// ลบไฟล์ชั่วคราว
  static Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('🗑️ File deleted: ${file.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting file: $e');
      }
    }
  }

  /// ย้ายไฟล์ไปยัง directory ถาวร
  static Future<File?> saveToGallery(File imageFile) async {
    try {
      // ใช้ path_provider เพื่อหา documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(directory.path, fileName);
      
      // คัดลอกไฟล์
      final savedFile = await imageFile.copy(savedPath);
      
      if (kDebugMode) {
        print('💾 Image saved: ${savedFile.path}');
      }
      
      return savedFile;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving image: $e');
      }
      return null;
    }
  }
}