import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/app_config.dart';
import '../../models/checkpoint_model.dart';
import '../../models/session_model.dart';
import '../../models/nfc_scan_result.dart';
import '../../providers/event_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/camera_provider.dart';
import '../../widgets/loading_widget.dart';

class EventNoteScreen extends StatefulWidget {
  final CheckpointModel checkpoint;
  final SessionModel session;
  final NfcScanResult scanResult;
  final String? imagePath;

  const EventNoteScreen({
    super.key,
    required this.checkpoint,
    required this.session,
    required this.scanResult,
    this.imagePath,
  });

  @override
  State<EventNoteScreen> createState() => _EventNoteScreenState();
}

class _EventNoteScreenState extends State<EventNoteScreen> {
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCompressing = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);

    File? imageFile;

    // Compress image if exists
    if (widget.imagePath != null) {
      setState(() {
        _isCompressing = true;
      });

      try {
        imageFile = await cameraProvider.compressImage(
          widget.imagePath!,
          quality: 85,
        );
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "ไม่สามารถประมวลผลรูปภาพได้",
            backgroundColor: AppConfig.errorColor,
          );
        }
      }

      if (mounted) {
        setState(() {
          _isCompressing = false;
        });
      }
    }

    if (!mounted) return;

    // Create event - Use nfcTagId from scanResult.uid
    // Note: You may need to verify the tag UID with backend first
    // For now, we'll use a placeholder ID
    final success = await eventProvider.createEventWithImage(
      sessionId: widget.session.id,
      checkpointId: widget.checkpoint.id,
      nfcTagId: 1, // This should be retrieved from backend after verifying scanResult.uid
      eventNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      imageFile: imageFile,
    );

    if (!mounted) return;

    if (success) {
      // Reload session
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );
      await sessionProvider.loadActiveSession();

      if (!mounted) return;

      final eventData = eventProvider.lastCreatedEvent!;
      final isAllCompleted = eventData['is_all_completed'] ?? false;

      if (isAllCompleted) {
        _showCompletionDialog();
      } else {
        _showSuccessDialog();
      }
    } else {
      Fluttertoast.showToast(
        msg: eventProvider.errorMessage ?? 'บันทึกเหตุการณ์ไม่สำเร็จ',
        backgroundColor: AppConfig.errorColor,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _showSuccessDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppConfig.successColor, size: 32),
            SizedBox(width: 12),
            Text('บันทึกสำเร็จ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('บันทึกเหตุการณ์เรียบร้อยแล้ว'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConfig.primaryColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ตรวจแล้ว:'),
                      Text(
                        '${Provider.of<EventProvider>(context, listen: false).lastCreatedEvent!['completed_checkpoints']} จุด',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ความคืบหน้า:'),
                      Text(
                        '${Provider.of<EventProvider>(context, listen: false).lastCreatedEvent!['progress_percentage'].toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
            ),
            child: const Text('ตรวจจุดต่อไป'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Column(
          children: [
            Icon(
              Icons.celebration,
              color: AppConfig.successColor,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'ตรวจครบทุกจุดแล้ว!',
              style: TextStyle(
                color: AppConfig.successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'คุณได้ตรวจครบทุกจุดตรวจในรอบนี้แล้ว',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'ต้องการสิ้นสุดรอบการตรวจหรือไม่?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: const Text('ตรวจต่อ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (mounted) {
                final sessionProvider = Provider.of<SessionProvider>(
                  context,
                  listen: false,
                );

                final success = await sessionProvider.completeSession();

                if (mounted) {
                  if (success) {
                    Fluttertoast.showToast(
                      msg: "สิ้นสุดรอบการตรวจสำเร็จ",
                      backgroundColor: AppConfig.successColor,
                    );
                  }

                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.successColor,
            ),
            child: const Text('สิ้นสุดรอบการตรวจ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกเหตุการณ์'),
        backgroundColor: AppConfig.primaryColor,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isCreating || _isCompressing) {
            return LoadingOverlay(
              message: _isCompressing
                  ? 'กำลังประมวลผลรูปภาพ...'
                  : 'กำลังบันทึกเหตุการณ์...',
            );
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCheckpointInfo(),
                  _buildScanInfo(),
                  if (widget.imagePath != null) _buildImagePreview(),
                  _buildNoteInput(),
                  _buildSaveButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckpointInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConfig.primaryColor,
            AppConfig.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'จุดที่ ${widget.checkpoint.sequenceOrder}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.checkpoint.checkpointName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.checkpoint.checkpointCode,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.successColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.nfc,
                color: AppConfig.successColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'สแกน NFC สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.successColor,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildInfoRow('Tag UID', widget.scanResult.uid),
          _buildInfoRow('เวลาสแกน', _formatDateTime(widget.scanResult.scanTime)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo_camera, color: AppConfig.primaryColor),
              SizedBox(width: 8),
              Text(
                'รูปภาพประกอบ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.imagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes, color: AppConfig.primaryColor),
              SizedBox(width: 8),
              Text(
                'หมายเหตุ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '(ไม่บังคับ)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'กรอกหมายเหตุเพิ่มเติม...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 4,
            maxLength: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _saveEvent,
        icon: const Icon(Icons.save),
        label: const Text('บันทึกเหตุการณ์'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} น.';
    } catch (e) {
      return dateTime;
    }
  }
}