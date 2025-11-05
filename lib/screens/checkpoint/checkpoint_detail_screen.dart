import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import 'checkpoint_scan_screen.dart';

class CheckpointDetailScreen extends StatefulWidget {
  final Map<String, dynamic> checkpoint;

  const CheckpointDetailScreen({
    super.key,
    required this.checkpoint,
  });

  @override
  State<CheckpointDetailScreen> createState() => _CheckpointDetailScreenState();
}

class _CheckpointDetailScreenState extends State<CheckpointDetailScreen> {
  File? _capturedImage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final hasActiveSession = sessionProvider.activeSession != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดจุดตรวจ'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),

            const SizedBox(height: 16),

            // รายละเอียด
            _buildDetailsCard(),

            const SizedBox(height: 16),

            // NFC Tags
            if (widget.checkpoint['nfc_tag_count'] != null &&
                widget.checkpoint['nfc_tag_count'] > 0)
              _buildNfcTagsCard(),

            const SizedBox(height: 16),

            // รูปภาพที่ถ่าย
            if (_capturedImage != null) _buildCapturedImageCard(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(hasActiveSession),
    );
  }

  Widget _buildHeaderCard() {
    final isRequired = widget.checkpoint['is_required'] == 1 || 
                       widget.checkpoint['is_required'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRequired
              ? [Colors.orange, Colors.deepOrange]
              : [Colors.green, Colors.teal],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'จุดที่ ${widget.checkpoint['sequence_order'] ?? '?'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            widget.checkpoint['checkpoint_code'] ?? 'N/A',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            widget.checkpoint['checkpoint_name'] ?? 'ไม่มีชื่อ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isRequired)
                _buildBadge('บังคับ', Colors.white),
              if (widget.checkpoint['require_photo'] == 1 ||
                  widget.checkpoint['require_photo'] == true)
                _buildBadge('ถ่ายรูป', Colors.white),
              if (widget.checkpoint['nfc_tag_count'] != null &&
                  widget.checkpoint['nfc_tag_count'] > 0)
                _buildBadge('NFC', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายละเอียด',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),

            if (widget.checkpoint['location_detail'] != null)
              _buildDetailRow(
                Icons.location_on,
                'สถานที่',
                widget.checkpoint['location_detail'],
              ),

            if (widget.checkpoint['description'] != null)
              _buildDetailRow(
                Icons.description,
                'คำอธิบาย',
                widget.checkpoint['description'],
              ),

            _buildDetailRow(
              Icons.check_circle,
              'ประเภท',
              (widget.checkpoint['is_required'] == 1 ||
                      widget.checkpoint['is_required'] == true)
                  ? 'บังคับตรวจ'
                  : 'ไม่บังคับ',
            ),

            if (widget.checkpoint['require_photo'] == 1 ||
                widget.checkpoint['require_photo'] == true)
              _buildDetailRow(
                Icons.camera_alt,
                'ถ่ายรูป',
                'ต้องถ่ายรูป',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNfcTagsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  'NFC Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              'จุดตรวจนี้มี ${widget.checkpoint['nfc_tag_count']} NFC Tags',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedImageCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'รูปภาพที่ถ่าย',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _capturedImage = null;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool hasActiveSession) {
    if (!hasActiveSession) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.orange[50],
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'ยังไม่มี Session ที่ Active\nกรุณาเริ่ม Session ก่อนตรวจจุด',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

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
      child: Row(
        children: [
          // ปุ่มถ่ายรูป
          if (widget.checkpoint['require_photo'] == 1 ||
              widget.checkpoint['require_photo'] == true)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _openCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('ถ่ายรูป'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          if (widget.checkpoint['require_photo'] == 1 ||
              widget.checkpoint['require_photo'] == true)
            const SizedBox(width: 12),

          // ปุ่มสแกน NFC
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _scanNfc,
              icon: const Icon(Icons.nfc),
              label: const Text('สแกน NFC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ แก้ไขฟังก์ชันเปิดกล้อง - ไม่เรียก takePicture โดยตรง
  Future<void> _openCamera() async {
    // เปิดหน้ากล้องและรับรูปกลับมา
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

  Future<void> _scanNfc() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CheckpointScanScreen(
          checkpoint: widget.checkpoint,
        ),
      ),
    );

    if (result == true && mounted) {
      // NFC สแกนสำเร็จ - ไปหน้าบันทึก
      Navigator.pushNamed(
        context,
        '/log-checkpoint',
        arguments: {
          'checkpoint_id': widget.checkpoint['id'],
          'nfc_uid': 'scanned_uid',
        },
      );
    }
  }
}