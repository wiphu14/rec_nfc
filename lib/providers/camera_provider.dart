import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class CameraProvider with ChangeNotifier {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  File? _capturedImage;
  String? _errorMessage;
  List<CameraDescription>? _availableCameras;
  int _selectedCameraIndex = 0;

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isProcessing => _isProcessing;
  File? get capturedImage => _capturedImage;
  String? get errorMessage => _errorMessage;
  List<CameraDescription>? get availableCameras => _availableCameras;
  int get selectedCameraIndex => _selectedCameraIndex;

  /// เช็คว่ามีกล้องหรือไม่
  Future<bool> checkCameraAvailability() async {
    try {
      // ✅ เรียก static method
      _availableCameras = await CameraService.getAvailableCameras();
      return _availableCameras != null && _availableCameras!.isNotEmpty;
    } catch (e) {
      _errorMessage = 'ไม่สามารถเข้าถึงกล้องได้: $e';
      notifyListeners();
      return false;
    }
  }

  /// เริ่มต้นกล้อง
  Future<void> initializeCamera({int cameraIndex = 0}) async {
    try {
      _isProcessing = true;
      _errorMessage = null;
      notifyListeners();

      // ตรวจสอบว่ามีกล้องหรือไม่
      if (_availableCameras == null || _availableCameras!.isEmpty) {
        await checkCameraAvailability();
      }

      if (_availableCameras == null || _availableCameras!.isEmpty) {
        throw Exception('ไม่พบกล้อง');
      }

      // ปิดกล้องเก่า (ถ้ามี)
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      // เลือกกล้อง
      _selectedCameraIndex = cameraIndex;
      final camera = _availableCameras![_selectedCameraIndex];

      // ✅ เรียก static method เพื่อสร้าง CameraController
      _cameraController = await CameraService.initializeCamera(camera);
      _isCameraInitialized = true;

      if (kDebugMode) {
        print('✅ Camera initialized: ${camera.name}');
      }

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'ไม่สามารถเริ่มกล้องได้: $e';
      _isCameraInitialized = false;
      _isProcessing = false;

      if (kDebugMode) {
        print('❌ Camera initialization error: $e');
      }

      notifyListeners();
    }
  }

  /// ถ่ายรูป
  Future<File?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _errorMessage = 'กล้องยังไม่พร้อม';
      notifyListeners();
      return null;
    }

    try {
      _isProcessing = true;
      _errorMessage = null;
      notifyListeners();

      // ✅ เรียก static method และส่ง controller เป็น parameter
      final File? imageFile = await CameraService.takePicture(_cameraController!);

      if (imageFile != null) {
        _capturedImage = imageFile;

        if (kDebugMode) {
          print('✅ Picture taken: ${imageFile.path}');
        }
      }

      _isProcessing = false;
      notifyListeners();

      return imageFile;
    } catch (e) {
      _errorMessage = 'ไม่สามารถถ่ายรูปได้: $e';
      _isProcessing = false;

      if (kDebugMode) {
        print('❌ Take picture error: $e');
      }

      notifyListeners();
      return null;
    }
  }

  /// บีบอัดรูปภาพ
  Future<File?> compressImage(File imageFile, {int quality = 85}) async {
    try {
      _isProcessing = true;
      notifyListeners();

      // ✅ เรียก static method
      final File? compressedFile = await CameraService.compressImage(
        imageFile,
        quality: quality,
      );

      _isProcessing = false;
      notifyListeners();

      return compressedFile;
    } catch (e) {
      _errorMessage = 'ไม่สามารถบีบอัดรูปได้: $e';
      _isProcessing = false;

      if (kDebugMode) {
        print('❌ Compress error: $e');
      }

      notifyListeners();
      return null;
    }
  }

  /// สลับกล้อง (หน้า/หลัง)
  Future<void> switchCamera() async {
    if (_availableCameras == null || _availableCameras!.length < 2) {
      _errorMessage = 'ไม่มีกล้องอื่นให้สลับ';
      notifyListeners();
      return;
    }

    try {
      // สลับ index
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras!.length;

      // เริ่มกล้องใหม่
      await initializeCamera(cameraIndex: _selectedCameraIndex);
    } catch (e) {
      _errorMessage = 'ไม่สามารถสลับกล้องได้: $e';
      notifyListeners();
    }
  }

  /// ล้างข้อมูลรูปที่ถ่าย
  void clearCapturedImage() {
    _capturedImage = null;
    notifyListeners();
  }

  /// ล้าง error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// รีเซ็ตทุกอย่าง
  void reset() {
    _capturedImage = null;
    _errorMessage = null;
    _isProcessing = false;
    notifyListeners();
  }

  /// ดูขนาดไฟล์
  Future<int?> getFileSize(File file) async {
    try {
      // ✅ เรียก static method
      return await CameraService.getFileSize(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file size: $e');
      }
      return null;
    }
  }

  /// แปลงขนาดไฟล์เป็นข้อความ
  String formatFileSize(int bytes) {
    // ✅ เรียก static method
    return CameraService.formatFileSize(bytes);
  }

  @override
  void dispose() {
    // ปิดกล้อง
    _cameraController?.dispose();
    super.dispose();
  }
}