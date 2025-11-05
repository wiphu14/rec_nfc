import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../providers/camera_provider.dart';

class CameraCaptureScreen extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraCaptureScreen({
    super.key,
    required this.onImageCaptured,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    // ✅ ใช้ checkCameraAvailability แทน isCameraAvailable
    final hasCamera = await cameraProvider.checkCameraAvailability();
    
    if (hasCamera && mounted) {
      await cameraProvider.initializeCamera();
    } else if (mounted) {
      _showErrorDialog('ไม่พบกล้อง', 'อุปกรณ์นี้ไม่มีกล้อง');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              Navigator.pop(context); // กลับไปหน้าก่อนหน้า
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);

    final File? imageFile = await cameraProvider.takePicture();

    if (imageFile != null && mounted) {
      // แสดงหน้า preview
      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => _ImagePreviewScreen(
            imageFile: imageFile,
          ),
        ),
      );

      if (confirmed == true && mounted) {
        // ส่งรูปกลับไป
        widget.onImageCaptured(imageFile);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          // ✅ ใช้ isCameraInitialized แทน isInitialized
          if (!cameraProvider.isCameraInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          // แสดง error
          if (cameraProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cameraProvider.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initCamera(),
                    child: const Text('ลองอีกครั้ง'),
                  ),
                ],
              ),
            );
          }

          // ✅ ใช้ cameraController แทน controller
          final controller = cameraProvider.cameraController;

          if (controller == null) {
            return const Center(
              child: Text(
                'กล้องไม่พร้อม',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera Preview
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              ),

              // Overlay UI
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    _buildTopBar(context, cameraProvider),

                    const Spacer(),

                    // Bottom Bar
                    _buildBottomBar(context, cameraProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CameraProvider cameraProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ปุ่มปิด
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          // ปุ่มสลับกล้อง
          if (cameraProvider.availableCameras != null &&
              cameraProvider.availableCameras!.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: cameraProvider.isProcessing
                  ? null
                  : () => cameraProvider.switchCamera(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CameraProvider cameraProvider) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 60),

          // ปุ่มถ่ายรูป
          GestureDetector(
            onTap: cameraProvider.isProcessing ? null : _takePicture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cameraProvider.isProcessing
                      ? Colors.grey
                      : Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 60),
        ],
      ),
    );
  }
}

// ==========================================
// Image Preview Screen
// ==========================================

class _ImagePreviewScreen extends StatelessWidget {
  final File imageFile;

  const _ImagePreviewScreen({
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ตรวจสอบรูปภาพ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),

            // Image Preview
            Expanded(
              child: Center(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ปุ่มถ่ายใหม่
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'ถ่ายใหม่',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ปุ่มใช้รูปนี้
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.check),
                      label: const Text('ใช้รูปนี้'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}