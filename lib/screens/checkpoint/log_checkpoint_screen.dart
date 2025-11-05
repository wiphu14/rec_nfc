import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/checkpoint_provider.dart';
import '../../services/checkpoint_service.dart';

class LogCheckpointScreen extends StatefulWidget {
  final int checkpointId;
  final String? nfcUid;

  const LogCheckpointScreen({
    super.key,
    required this.checkpointId,
    this.nfcUid,
  });

  @override
  State<LogCheckpointScreen> createState() => _LogCheckpointScreenState();
}

class _LogCheckpointScreenState extends State<LogCheckpointScreen> {
  final _notesController = TextEditingController();
  File? _photo;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final result = await Navigator.pushNamed(
      context,
      '/camera-capture',
      arguments: {
        'onImageCaptured': (File imageFile) {
          setState(() {
            _photo = imageFile;
          });
        },
      },
    );
  }

  Future<void> _submitLog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    // ตรวจสอบว่ามี session
    if (sessionProvider.activeSession == null) {
      _showErrorDialog('ไม่มี Session', 'กรุณาเริ่ม session ก่อน');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await CheckpointService.logCheckpoint(
        token: authProvider.token!,
        sessionId: sessionProvider.activeSession!['id'],
        checkpointId: widget.checkpointId,
        nfcUid: widget.nfcUid,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        photo: _photo,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        // แสดงความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'บันทึกสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        // กลับไปหน้าก่อนหน้า
        Navigator.pop(context, true);
      } else {
        _showErrorDialog('เกิดข้อผิดพลาด', result['message']);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog('เกิดข้อผิดพลาด', e.toString());
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
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkpointProvider = Provider.of<CheckpointProvider>(context);
    final checkpoint = checkpointProvider.findCheckpointById(widget.checkpointId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกการตรวจจุด'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ข้อมูลจุดตรวจ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkpoint?.checkpointCode ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      checkpoint?.checkpointName ?? 'ไม่พบจุดตรวจ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.nfcUid != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.nfc, size: 16, color: Colors.blue),
                          const SizedBox(width: 5),
                          Text(
                            'NFC: ${widget.nfcUid}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // รูปภาพ
            const Text(
              'รูปภาพ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: _photo == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('แตะเพื่อถ่ายรูป'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _photo!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            if (_photo != null)
              TextButton.icon(
                onPressed: () => setState(() => _photo = null),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'ลบรูป',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            // หมายเหตุ
            const Text(
              'หมายเหตุ (ถ้ามี)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'พิมพ์หมายเหตุที่นี่...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'บันทึก',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}