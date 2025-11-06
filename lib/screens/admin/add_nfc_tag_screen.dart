import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nfc_provider.dart';
import '../../providers/checkpoint_provider.dart';
import '../../services/nfc_admin_service.dart';

class AddNfcTagScreen extends StatefulWidget {
  const AddNfcTagScreen({super.key});

  @override
  State<AddNfcTagScreen> createState() => _AddNfcTagScreenState();
}

class _AddNfcTagScreenState extends State<AddNfcTagScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _scannedUid;
  int? _selectedCheckpointId;
  String? _description;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCheckpoints();
  }

  Future<void> _loadCheckpoints() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checkpointProvider =
        Provider.of<CheckpointProvider>(context, listen: false);

    await checkpointProvider.loadCheckpoints(authProvider.token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่ม NFC Tag'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // คำอธิบาย
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'กรุณาสแกน NFC Tag ที่ต้องการเพิ่มเข้าระบบ',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // สแกน NFC
            _buildNfcScanSection(),

            const SizedBox(height: 24),

            // เลือกจุดตรวจ
            _buildCheckpointSelection(),

            const SizedBox(height: 24),

            // คำอธิบาย
            _buildDescriptionField(),

            const SizedBox(height: 32),

            // ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting || _scannedUid == null
                    ? null
                    : _submitNfcTag,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSubmitting ? 'กำลังบันทึก...' : 'บันทึก NFC Tag',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcScanSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.nfc, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'NFC Tag UID',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_scannedUid == null)
              Column(
                children: [
                  const Text(
                    'กรุณาแตะ NFC Tag',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scanNfc,
                      icon: const Icon(Icons.nfc),
                      label: const Text('สแกน NFC Tag'),
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
                            _scannedUid!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          _scannedUid = null;
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

  Widget _buildCheckpointSelection() {
    return Consumer<CheckpointProvider>(
      builder: (context, checkpointProvider, child) {
        final checkpoints = checkpointProvider.checkpoints;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'จุดตรวจ (ถ้ามี)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                DropdownButtonFormField<int>(
                  value: _selectedCheckpointId,
                  decoration: const InputDecoration(
                    hintText: 'เลือกจุดตรวจ (ไม่บังคับ)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('ไม่กำหนดจุดตรวจ'),
                    ),
                    ...checkpoints.map((checkpoint) {
                      return DropdownMenuItem<int>(
                        value: checkpoint.id,
                        child: Text(
                          '${checkpoint.checkpointCode} - ${checkpoint.checkpointName}',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCheckpointId = value;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'คำอธิบาย (ถ้ามี)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'เช่น: NFC Tag ประจำจุดตรวจ Gate A',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                _description = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanNfc() async {
  final nfcProvider = Provider.of<NfcProvider>(context, listen: false);

  print('🎯 Starting NFC scan from UI...');

  await nfcProvider.startNfcScan(
    onTagDetected: (uid) {
      print('🎉 Tag detected in UI: $uid');
      if (mounted) {
        setState(() {
          _scannedUid = uid;
        });
        nfcProvider.stopNfcScan();
        
        // ✅ แสดง SnackBar เมื่อสแกนสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ สแกน NFC สำเร็จ: $uid'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    },
    onError: (error) {
      print('❌ Error in UI: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    },
  );
}

  Future<void> _submitNfcTag() async {
    if (_scannedUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาสแกน NFC Tag'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await NfcAdminService.addNfcTag(
        authProvider.token!,
        _scannedUid!,
        checkpointId: _selectedCheckpointId,
        description: _description,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ เพิ่ม NFC Tag สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}