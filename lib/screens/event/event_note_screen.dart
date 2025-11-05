import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';

class EventNoteScreen extends StatefulWidget {
  const EventNoteScreen({super.key});

  @override
  State<EventNoteScreen> createState() => _EventNoteScreenState();
}

class _EventNoteScreenState extends State<EventNoteScreen> {
  final _noteController = TextEditingController();
  File? _capturedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    // เปิดกล้องและรับรูปกลับมา
    await Navigator.pushNamed(
      context,
      '/camera-capture',
      arguments: {
        'onImageCaptured': (File imageFile) {
          if (mounted) {
            setState(() {
              _capturedImage = imageFile;
            });
          }
        },
      },
    );
  }

  Future<void> _submitNote() async {
    if (_noteController.text.trim().isEmpty && _capturedImage == null) {
      _showErrorDialog('กรุณากรอกข้อมูล', 'กรุณาเขียนบันทึกหรือถ่ายรูป');
      return;
    }

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    // ตรวจสอบว่ามี active session
    if (sessionProvider.activeSession == null) {
      _showErrorDialog('ไม่มี Session', 'กรุณาเริ่ม Session ก่อน');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: เรียก API บันทึกหมายเหตุ
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // แสดงข้อความสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ บันทึกหมายเหตุสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );

      // กลับไปหน้าก่อนหน้า
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกหมายเหตุ'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ข้อมูล Session
            Consumer<SessionProvider>(
              builder: (context, sessionProvider, child) {
                final activeSession = sessionProvider.activeSession;

                if (activeSession == null) {
                  return Card(
                    color: Colors.orange[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ยังไม่มี Session ที่ Active',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session ปัจจุบัน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Session ID:'),
                            Text(
                              '#${activeSession['id']?.toString() ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // หมายเหตุ
            const Text(
              'หมายเหตุ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _noteController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'พิมพ์หมายเหตุที่นี่...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // รูปภาพ
            const Text(
              'รูปภาพ (ถ้ามี)',
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
                child: _capturedImage == null
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
                          _capturedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            if (_capturedImage != null)
              TextButton.icon(
                onPressed: () => setState(() => _capturedImage = null),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'ลบรูป',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 30),

            // ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitNote,
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