import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/nfc_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/checkpoint_service.dart';

class CheckpointScanScreen extends StatefulWidget {
  final Map<String, dynamic> checkpoint;

  const CheckpointScanScreen({
    super.key,
    required this.checkpoint,
  });

  @override
  State<CheckpointScanScreen> createState() => _CheckpointScanScreenState();
}

class _CheckpointScanScreenState extends State<CheckpointScanScreen> {
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);
    nfcProvider.stopNfcScan();
    super.dispose();
  }

  Future<void> _startScanning() async {
    final nfcProvider = Provider.of<NfcProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await nfcProvider.startNfcScan(
      onTagDetected: (nfcUid) async {
        if (!mounted) return;

        setState(() {
          _isVerifying = true;
        });

        // ตรวจสอบ NFC กับ Backend
        final result = await CheckpointService.verifyNfc(
          authProvider.token!,
          nfcUid,
        );

        if (!mounted) return;

        setState(() {
          _isVerifying = false;
        });

        if (result['success']) {
          final checkpoint = result['checkpoint'];
          
          if (checkpoint['id'] == widget.checkpoint['id']) {
            // ✅ NFC ตรงกับจุดตรวจนี้ - ส่ง UID กลับไป
            Navigator.pop(context, nfcUid);
          } else {
            // NFC ไม่ตรงกับจุดตรวจนี้
            _showErrorDialog(
              'NFC Tag ไม่ถูกต้อง',
              'NFC Tag นี้สำหรับจุดตรวจ: ${checkpoint['name']}\n'
              'กรุณาสแกน NFC ที่จุดตรวจ: ${widget.checkpoint['checkpoint_name']}'
            );
          }
        } else {
          // NFC ไม่พบในระบบ
          _showErrorDialog('NFC Tag ไม่ถูกต้อง', result['message']);
        }
      },
      onError: (error) {
        if (!mounted) return;
        _showErrorDialog('เกิดข้อผิดพลาด', error);
      },
    );
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
            child: const Text('ลองอีกครั้ง'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              Navigator.pop(context); // กลับหน้าก่อนหน้า
            },
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกน NFC'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<NfcProvider>(
        builder: (context, nfcProvider, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ไอคอน NFC
                  if (nfcProvider.isScanning && !_isVerifying)
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.2),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: const Icon(
                            Icons.nfc,
                            size: 100,
                            color: Colors.blue,
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted) setState(() {});
                      },
                    ),

                  // ไอคอนกำลังตรวจสอบ
                  if (_isVerifying)
                    const CircularProgressIndicator(),

                  const SizedBox(height: 30),

                  // ชื่อจุดตรวจ
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            widget.checkpoint['checkpoint_code'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.checkpoint['checkpoint_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // สถานะการสแกน
                  if (nfcProvider.isScanning && !_isVerifying)
                    const Text(
                      'กรุณาแตะ NFC Tag ที่จุดตรวจ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  if (_isVerifying)
                    const Text(
                      'กำลังตรวจสอบ NFC Tag...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  // แสดง error message
                  if (nfcProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        nfcProvider.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}