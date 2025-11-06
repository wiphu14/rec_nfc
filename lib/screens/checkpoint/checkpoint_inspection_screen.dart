import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/checkpoint_provider.dart';
import '../../providers/nfc_provider.dart';
import '../../services/checkpoint_service.dart';

class CheckpointInspectionScreen extends StatefulWidget {
  final Map<String, dynamic> checkpoint;

  const CheckpointInspectionScreen({
    super.key,
    required this.checkpoint,
  });

  @override
  State<CheckpointInspectionScreen> createState() =>
      _CheckpointInspectionScreenState();
}

class _CheckpointInspectionScreenState
    extends State<CheckpointInspectionScreen> {
  final _eventController = TextEditingController();
  final _noteController = TextEditingController();
  
  String? _scannedNfcUid;
  File? _capturedPhoto;
  bool _isSubmitting = false;
  
  // Step tracker
  int _currentStep = 0;
  final List<String> _steps = [
    'สแกน NFC',
    'ถ่ายรูป',
    'บันทึกเหตุการณ์',
    'หมายเหตุ',
    'ยืนยัน',
  ];

  @override
  void dispose() {
    _eventController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตรวจจุด'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkpoint Info Card
                  _buildCheckpointInfoCard(),

                  const SizedBox(height: 20),

                  // Step 1: NFC Scan
                  _buildNfcSection(),

                  const SizedBox(height: 20),

                  // Step 2: Photo
                  _buildPhotoSection(),

                  const SizedBox(height: 20),

                  // Step 3: Event Note
                  _buildEventSection(),

                  const SizedBox(height: 20),

                  // Step 4: Additional Note
                  _buildNoteSection(),

                  const SizedBox(height: 20),

                  // Step 5: Summary
                  _buildSummarySection(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        children: [
          Row(
            children: List.generate(_steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                                ? Colors.blue
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _steps[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrent ? Colors.blue : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.checkpoint['sequence_order'] ?? '?'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.checkpoint['checkpoint_code'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.checkpoint['checkpoint_name'] ?? 'ไม่มีชื่อ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.nfc,
                  color: _scannedNfcUid != null ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '1. สแกน NFC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_scannedNfcUid != null)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const Divider(),
            if (_scannedNfcUid == null)
              Column(
                children: [
                  const Text(
                    'กรุณาแตะ NFC Tag ที่จุดตรวจ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scanNfc,
                      icon: const Icon(Icons.nfc),
                      label: const Text('สแกน NFC'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'สแกน NFC สำเร็จ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'UID: $_scannedNfcUid',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          _scannedNfcUid = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final requirePhoto = widget.checkpoint['require_photo'] == 1 ||
        widget.checkpoint['require_photo'] == true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: _capturedPhoto != null ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  '2. ถ่ายรูป ${requirePhoto ? "(บังคับ)" : "(ไม่บังคับ)"}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_capturedPhoto != null)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const Divider(),
            if (_capturedPhoto == null)
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('แตะเพื่อถ่ายรูป'),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _capturedPhoto!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.refresh),
                          label: const Text('ถ่ายใหม่'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _capturedPhoto = null;
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'ลบ',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: _eventController.text.isNotEmpty
                      ? Colors.green
                      : Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '3. บันทึกเหตุการณ์',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_eventController.text.isNotEmpty)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const Divider(),
            TextField(
              controller: _eventController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'บันทึกสิ่งที่พบ/เหตุการณ์ที่เกิดขึ้น...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  color: _noteController.text.isNotEmpty
                      ? Colors.green
                      : Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '4. หมายเหตุ (ถ้ามี)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_noteController.text.isNotEmpty)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const Divider(),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'หมายเหตุเพิ่มเติม...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.summarize, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '5. สรุป',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildSummaryRow('✅ NFC UID:', _scannedNfcUid ?? 'ยังไม่สแกน'),
            _buildSummaryRow(
                '✅ รูปภาพ:', _capturedPhoto != null ? 'ถ่ายแล้ว' : 'ยังไม่ถ่าย'),
            _buildSummaryRow(
              '✅ บันทึกเหตุการณ์:',
              _eventController.text.isNotEmpty ? 'กรอกแล้ว' : 'ยังไม่กรอก',
            ),
            _buildSummaryRow(
              '✅ หมายเหตุ:',
              _noteController.text.isNotEmpty ? 'กรอกแล้ว' : 'ไม่มี',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSubmit = _scannedNfcUid != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canSubmit && !_isSubmitting ? _submitInspection : null,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
              _isSubmitting ? 'กำลังบันทึก...' : 'บันทึกการตรวจ',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? Colors.green : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanNfc() async {
    final result = await Navigator.pushNamed(
      context,
      '/checkpoint-scan',
      arguments: widget.checkpoint,
    );

    if (result != null && result is String && mounted) {
      setState(() {
        _scannedNfcUid = result;
        if (_currentStep == 0) _currentStep = 1;
      });
    }
  }

  Future<void> _takePhoto() async {
    await Navigator.pushNamed(
      context,
      '/camera-capture',
      arguments: {
        'onImageCaptured': (File imageFile) {
          if (mounted) {
            setState(() {
              _capturedPhoto = imageFile;
              if (_currentStep == 1) _currentStep = 2;
            });
          }
        },
      },
    );
  }

  Future<void> _submitInspection() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    // ตรวจสอบ session
    if (sessionProvider.activeSession == null) {
      _showErrorDialog('ไม่มี Session', 'กรุณาเริ่ม Session ก่อน');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // รวมบันทึกเหตุการณ์และหมายเหตุ
      final notes = [
        if (_eventController.text.trim().isNotEmpty)
          'เหตุการณ์: ${_eventController.text.trim()}',
        if (_noteController.text.trim().isNotEmpty)
          'หมายเหตุ: ${_noteController.text.trim()}',
      ].join('\n');

      final result = await CheckpointService.logCheckpoint(
        token: authProvider.token!,
        sessionId: sessionProvider.activeSession!['id'],
        checkpointId: widget.checkpoint['id'],
        nfcUid: _scannedNfcUid,
        notes: notes.isNotEmpty ? notes : null,
        photo: _capturedPhoto,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ บันทึกการตรวจสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        // กลับไปหน้าก่อนหน้า
        Navigator.pop(context, true);
      } else {
        _showErrorDialog('ไม่สามารถบันทึกได้', result['message']);
      }
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
}