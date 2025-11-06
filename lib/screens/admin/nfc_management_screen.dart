import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/nfc_admin_service.dart';

class NfcManagementScreen extends StatefulWidget {
  const NfcManagementScreen({super.key});

  @override
  State<NfcManagementScreen> createState() => _NfcManagementScreenState();
}

class _NfcManagementScreenState extends State<NfcManagementScreen> {
  List<Map<String, dynamic>> _nfcTags = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNfcTags();
  }

  Future<void> _loadNfcTags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await NfcAdminService.getNfcTags(authProvider.token!);

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _nfcTags = List<Map<String, dynamic>>.from(result['tags'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการ NFC Tags'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNfcTags,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewNfcTag(),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่ม NFC Tag'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNfcTags,
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      );
    }

    if (_nfcTags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'ยังไม่มี NFC Tags',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _addNewNfcTag(),
              icon: const Icon(Icons.add),
              label: const Text('เพิ่ม NFC Tag แรก'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNfcTags,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _nfcTags.length,
        itemBuilder: (context, index) {
          final tag = _nfcTags[index];
          return _buildNfcTagCard(tag);
        },
      ),
    );
  }

  Widget _buildNfcTagCard(Map<String, dynamic> tag) {
    final isActive = tag['is_active'] == 1 || tag['is_active'] == true;
    final checkpointName = tag['checkpoint_name'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? Colors.green[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.nfc,
            color: isActive ? Colors.green : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          tag['nfc_uid'] ?? 'N/A',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (checkpointName != null)
              Text('จุดตรวจ: $checkpointName')
            else
              const Text('ยังไม่ได้กำหนดจุดตรวจ'),
            Text(
              isActive ? 'ใช้งาน' : 'ปิดใช้งาน',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('แก้ไข'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('ลบ', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editNfcTag(tag);
                break;
              case 'toggle':
                _toggleNfcTag(tag);
                break;
              case 'delete':
                _deleteNfcTag(tag);
                break;
            }
          },
        ),
      ),
    );
  }

  Future<void> _addNewNfcTag() async {
    final result = await Navigator.pushNamed(context, '/admin-nfc-add');
    if (result == true && mounted) {
      _loadNfcTags();
    }
  }

  Future<void> _editNfcTag(Map<String, dynamic> tag) async {
    final result = await Navigator.pushNamed(
      context,
      '/admin-nfc-edit',
      arguments: tag,
    );
    if (result == true && mounted) {
      _loadNfcTags();
    }
  }

  Future<void> _toggleNfcTag(Map<String, dynamic> tag) async {
    final isActive = tag['is_active'] == 1 || tag['is_active'] == true;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive ? 'ปิดใช้งาน NFC Tag' : 'เปิดใช้งาน NFC Tag'),
        content: Text(
          isActive
              ? 'คุณต้องการปิดใช้งาน NFC Tag นี้หรือไม่?'
              : 'คุณต้องการเปิดใช้งาน NFC Tag นี้หรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await NfcAdminService.toggleNfcTag(
        authProvider.token!,
        tag['id'],
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'อัปเดตสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        _loadNfcTags();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNfcTag(Map<String, dynamic> tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ NFC Tag'),
        content: const Text('คุณต้องการลบ NFC Tag นี้หรือไม่? การดำเนินการนี้ไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await NfcAdminService.deleteNfcTag(
        authProvider.token!,
        tag['id'],
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบ NFC Tag สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        _loadNfcTags();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}