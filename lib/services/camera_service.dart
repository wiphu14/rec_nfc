// lib/services/camera_service.dart

import 'dart:io'; // ✅ เพิ่ม
import 'dart:convert'; // ✅ เพิ่ม
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../config/api_config.dart'; // ✅ เพิ่ม
import 'storage_service.dart';

class CameraService {
  final StorageService _storageService = StorageService();
  
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  // Get available cameras
  Future<List<CameraDescription>> getAvailableCameras() async {
    if (_cameras == null) {
      _cameras = await availableCameras();
    }
    return _cameras!;
  }

  // Initialize camera
  Future<CameraController?> initializeCamera({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    try {
      final cameras = await getAvailableCameras();
      
      if (cameras.isEmpty) {
        return null;
      }

      // Find camera with specified direction
      CameraDescription? selectedCamera;
      try {
        selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == direction,
        );
      } catch (e) {
        // If not found, use first camera
        selectedCamera = cameras.first;
      }

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      
      return _controller;
    } catch (e) {
      print('Error initializing camera: $e');
      return null;
    }
  }

  // Take picture
  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  // Compress image
  Future<File> compressImage(String imagePath, {int quality = 85}) async {
    try {
      // Read image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return imageFile;
      }

      // Resize if too large (max 1920px)
      img.Image resized = image;
      if (image.width > 1920 || image.height > 1920) {
        if (image.width > image.height) {
          resized = img.copyResize(image, width: 1920);
        } else {
          resized = img.copyResize(image, height: 1920);
        }
      }

      // Compress
      final compressedBytes = img.encodeJpg(resized, quality: quality);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return File(imagePath);
    }
  }

  // Create thumbnail
  Future<File?> createThumbnail(String imagePath, {int size = 300}) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return null;
      }

      // Create square thumbnail
      final thumbnail = img.copyResizeCropSquare(image, size: size);
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 85);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(
        tempDir.path,
        'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final thumbnailFile = File(tempPath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailFile;
    } catch (e) {
      print('Error creating thumbnail: $e');
      return null;
    }
  }

  // Upload image to server
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      final token = await _storageService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'ไม่พบ Token',
        };
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadImageEndpoint), // ✅ แก้ใช้ ApiConfig
      );

      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'image_path': data['data']['image_path'],
          'image_thumbnail': data['data']['image_thumbnail'],
          'image_url': data['data']['image_url'],
          'thumbnail_url': data['data']['thumbnail_url'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'อัพโหลดรูปภาพไม่สำเร็จ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาด: ${e.toString()}',
      };
    }
  }

  // Save image locally
  Future<String?> saveImageLocally(String imagePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final savedDir = Directory('${appDir.path}/images');
      
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }

      final fileName = path.basename(imagePath);
      final savedPath = path.join(savedDir.path, fileName);

      final imageFile = File(imagePath);
      await imageFile.copy(savedPath);

      return savedPath;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
    }
  }

  // Dispose camera
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  // Get controller
  CameraController? get controller => _controller;

  // Check if camera is available
  Future<bool> isCameraAvailable() async {
    try {
      final cameras = await getAvailableCameras();
      return cameras.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Switch camera
  Future<CameraController?> switchCamera() async {
    if (_controller == null) return null;

    final currentDirection = _controller!.description.lensDirection;
    final newDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await _controller!.dispose();
    return await initializeCamera(direction: newDirection);
  }

  // Get image file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  // Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}