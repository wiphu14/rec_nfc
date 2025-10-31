import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class CameraProvider with ChangeNotifier {
  final CameraService _cameraService = CameraService();

  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  String? _capturedImagePath;
  String? _errorMessage;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isTakingPicture => _isTakingPicture;
  String? get capturedImagePath => _capturedImagePath;
  String? get errorMessage => _errorMessage;

  // Initialize camera
  Future<bool> initializeCamera({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    _isInitialized = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _controller = await _cameraService.initializeCamera(direction: direction);

      if (_controller == null) {
        _errorMessage = 'ไม่สามารถเปิดกล้องได้';
        notifyListeners();
        return false;
      }

      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Take picture
  Future<String?> takePicture() async {
    if (!_isInitialized || _isTakingPicture) {
      return null;
    }

    _isTakingPicture = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imagePath = await _cameraService.takePicture();

      if (imagePath != null) {
        _capturedImagePath = imagePath;
      } else {
        _errorMessage = 'ไม่สามารถถ่ายรูปได้';
      }

      _isTakingPicture = false;
      notifyListeners();
      return imagePath;
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      _isTakingPicture = false;
      notifyListeners();
      return null;
    }
  }

  // Retake picture
  void retakePicture() {
    _capturedImagePath = null;
    notifyListeners();
  }

  // Compress image
  Future<File> compressImage(String imagePath, {int quality = 85}) async {
    return await _cameraService.compressImage(imagePath, quality: quality);
  }

  // Upload image
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    return await _cameraService.uploadImage(imageFile);
  }

  // Switch camera
  Future<bool> switchCamera() async {
    try {
      _isInitialized = false;
      notifyListeners();

      _controller = await _cameraService.switchCamera();

      if (_controller == null) {
        _errorMessage = 'ไม่สามารถสลับกล้องได้';
        notifyListeners();
        return false;
      }

      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Check camera availability
  Future<bool> isCameraAvailable() async {
    return await _cameraService.isCameraAvailable();
  }

  // Get file size
  Future<int> getFileSize(String filePath) async {
    return await _cameraService.getFileSize(filePath);
  }

  // Format file size
  String formatFileSize(int bytes) {
    return _cameraService.formatFileSize(bytes);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}