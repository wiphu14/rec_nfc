import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../config/app_config.dart';
import '../../models/checkpoint_model.dart';
import '../../models/session_model.dart';
import '../../models/nfc_scan_result.dart';
import '../../providers/camera_provider.dart';
import '../../widgets/loading_widget.dart';

class CameraCaptureScreen extends StatefulWidget {
  final CheckpointModel checkpoint;
  final SessionModel session;
  final NfcScanResult scanResult;

  const CameraCaptureScreen({
    Key? key,
    required this.checkpoint,
    required this.session,
    required this.scanResult,
  }) : super(key: key);

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    final isAvailable = await cameraProvider.isCameraAvailable();
    
    if (!isAvailable) {
      _showCameraNotAvailableDialog();
      return;
    }

    await cameraProvider.initializeCamera();
  }

  void _showCameraNotAvailableDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppConfig.errorColor),
            SizedBox(width: 8),
            Text('กล้องไม่พร้อมใช้งาน'),
          ],
        ),
        content: const Text(
          'ไม่พบกล้องในอุปกรณ์หรือไม่ได้รับอนุญาตให้เข้าถึงกล้อง\n\nกรุณาตรวจสอบการอนุญาต',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    final imagePath = await cameraProvider.takePicture();
    
    if (imagePath == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cameraProvider.errorMessage ?? 'ไม่สามารถถ่ายรูปได้',
          ),
          backgroundColor: AppConfig.errorColor,
        ),
      );
    }
  }

  Future<void> _toggleFlash() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    if (cameraProvider.controller == null) return;

    try {
      if (_isFlashOn) {
        await cameraProvider.controller!.setFlashMode(FlashMode.off);
      } else {
        await cameraProvider.controller!.setFlashMode(FlashMode.torch);
      }
      
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    await cameraProvider.switchCamera();
  }

  void _confirmImage() {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    if (cameraProvider.capturedImagePath == null) return;

    Navigator.pushReplacementNamed(
      context,
      '/event_note',
      arguments: {
        'checkpoint': widget.checkpoint,
        'session': widget.session,
        'scan_result': widget.scanResult,
        'image_path': cameraProvider.capturedImagePath,
      },
    );
  }

  void _retakePicture() {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    cameraProvider.retakePicture();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    if (cameraProvider.controller == null || 
        !cameraProvider.controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraProvider.controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          if (!cameraProvider.isInitialized) {
            return const Center(
              child: LoadingWidget(color: Colors.white),
            );
          }

          if (cameraProvider.capturedImagePath != null) {
            return _buildPreviewView(cameraProvider.capturedImagePath!);
          }

          return _buildCameraView(cameraProvider);
        },
      ),
    );
  }

  Widget _buildCameraView(CameraProvider cameraProvider) {
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(cameraProvider.controller!),
        ),

        // Top Bar
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

                // Checkpoint Info
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.checkpoint.checkpointName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'จุดที่ ${widget.checkpoint.sequenceOrder}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Flash Toggle
                IconButton(
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFlash,
                ),
              ],
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch Camera
                IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _switchCamera,
                ),

                // Capture Button
                GestureDetector(
                  onTap: cameraProvider.isTakingPicture ? null : _takePicture,
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Placeholder
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView(String imagePath) {
    return Stack(
      children: [
        // Image Preview
        Positioned.fill(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),

        // Top Bar
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppConfig.successColor),
                SizedBox(width: 8),
                Text(
                  'ตรวจสอบรูปภาพ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                // Retake Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retakePicture,
                    icon: const Icon(Icons.refresh),
                    label: const Text('ถ่ายใหม่'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Confirm Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmImage,
                    icon: const Icon(Icons.check),
                    label: const Text('ใช้รูปนี้'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}